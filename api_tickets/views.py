import secrets
import uuid

from django.conf import settings
from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from django.core.cache import cache
from django.db import transaction

from rest_framework import status
from rest_framework.authentication import TokenAuthentication
from rest_framework.authtoken.models import Token
from rest_framework.decorators import (
    api_view,
    authentication_classes,
    permission_classes,
)
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response

from .models import Boleto, PerfilUsuario
from .serializers import BoletoSerializer


PRECIO_BOLETO = 25
RESET_CACHE_PREFIX = 'pwreset:'


def _reset_cache_key(email):
    return f'{RESET_CACHE_PREFIX}{email.lower().strip()}'


def _generar_codigo_reset():
    return f'{secrets.randbelow(1_000_000):06d}'


@api_view(['GET'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def get_boletos(request):
    boletos = Boleto.objects.filter(usuario=request.user).order_by('-fecha_compra')
    serializer = BoletoSerializer(boletos, many=True)
    return Response(serializer.data)


@api_view(['POST'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def comprar_boletos(request):
    try:
        cantidad = int(request.data.get('cantidad', 1))
    except (ValueError, TypeError):
        return Response(
            {'error': 'Cantidad invalida'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    if cantidad < 1 or cantidad > 50:
        return Response(
            {'error': 'La cantidad debe estar entre 1 y 50'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    costo_total = cantidad * PRECIO_BOLETO

    with transaction.atomic():
        perfil = PerfilUsuario.objects.select_for_update().get(usuario=request.user)
        if perfil.saldo < costo_total:
            return Response(
                {'error': f'Saldo insuficiente. Costo: ${costo_total}, Saldo: ${perfil.saldo}'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        perfil.saldo -= costo_total
        perfil.save()

        nuevos = [
            Boleto(
                codigo_alfanumerico=f'BOL-{str(uuid.uuid4())[:8].upper()}',
                usuario=request.user,
            )
            for _ in range(cantidad)
        ]
        Boleto.objects.bulk_create(nuevos)

    boletos = Boleto.objects.filter(usuario=request.user).order_by('-fecha_compra')[:cantidad]
    serializer = BoletoSerializer(boletos, many=True)
    return Response(
        {
            'boletos': serializer.data,
            'nuevo_saldo': float(perfil.saldo),
        },
        status=status.HTTP_201_CREATED,
    )


@api_view(['POST'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def consumir_boleto(request):
    codigo = request.data.get('codigo')
    if not codigo:
        return Response(
            {'error': 'Codigo no proporcionado'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    try:
        boleto = Boleto.objects.get(codigo_alfanumerico=codigo)
    except Boleto.DoesNotExist:
        return Response(
            {'error': 'Boleto no encontrado'},
            status=status.HTTP_404_NOT_FOUND,
        )

    if boleto.usuario_id != request.user.id:
        return Response(
            {'error': 'No tienes permiso para usar este boleto'},
            status=status.HTTP_403_FORBIDDEN,
        )

    if boleto.estado == 'Usado':
        return Response(
            {'error': 'El boleto ya ha sido usado'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    boleto.estado = 'Usado'
    boleto.save(update_fields=['estado'])
    return Response({'message': 'Boleto consumido exitosamente'}, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    email = request.data.get('email')
    password = request.data.get('password')

    if not email or not password:
        return Response(
            {'error': 'Email y password son requeridos'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    try:
        user_obj = User.objects.get(email__iexact=email)
        username = user_obj.username
    except User.DoesNotExist:
        username = email

    user = authenticate(username=username, password=password)
    if user is None:
        return Response(
            {'error': 'Credenciales invalidas'},
            status=status.HTTP_401_UNAUTHORIZED,
        )

    perfil, _ = PerfilUsuario.objects.get_or_create(usuario=user)
    token, _ = Token.objects.get_or_create(user=user)
    return Response(
        {
            'message': 'Login exitoso',
            'username': user.username,
            'email': user.email,
            'saldo': float(perfil.saldo),
            'token': token.key,
        },
        status=status.HTTP_200_OK,
    )


@api_view(['POST'])
@permission_classes([AllowAny])
def registrar_usuario(request):
    email = request.data.get('email')
    password = request.data.get('password')

    if not email or not password:
        return Response(
            {'error': 'Email y password son requeridos'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    username = request.data.get('username') or email.split('@')[0]

    if User.objects.filter(email__iexact=email).exists():
        return Response(
            {'error': 'El email ya esta registrado'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    user = User.objects.create_user(username=username, email=email, password=password)
    perfil, _ = PerfilUsuario.objects.get_or_create(usuario=user)
    token, _ = Token.objects.get_or_create(user=user)

    return Response(
        {
            'message': 'Usuario creado exitosamente',
            'username': user.username,
            'email': user.email,
            'saldo': float(perfil.saldo),
            'token': token.key,
        },
        status=status.HTTP_201_CREATED,
    )


@api_view(['POST'])
@permission_classes([AllowAny])
def request_password_reset(request):
    # Devuelve 200 siempre para no filtrar si el email existe.
    email = (request.data.get('email') or '').strip()
    if not email:
        return Response(
            {'error': 'Email requerido'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    payload = {'message': 'Si el correo existe, se envio un codigo de recuperacion'}

    try:
        User.objects.get(email__iexact=email)
    except User.DoesNotExist:
        return Response(payload, status=status.HTTP_200_OK)

    codigo = _generar_codigo_reset()
    cache.set(_reset_cache_key(email), codigo, timeout=settings.PASSWORD_RESET_CODE_TTL)

    # TODO: enviar el codigo por correo cuando este configurado SMTP.
    if settings.DEBUG:
        payload['debug_codigo'] = codigo

    return Response(payload, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([AllowAny])
def reset_password_view(request):
    email = (request.data.get('email') or '').strip()
    codigo = (request.data.get('codigo') or '').strip()
    new_password = request.data.get('new_password')

    if not email or not codigo or not new_password:
        return Response(
            {'error': 'Email, codigo y new_password son requeridos'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    cached = cache.get(_reset_cache_key(email))
    if not cached or not secrets.compare_digest(str(cached), codigo):
        return Response(
            {'error': 'Codigo invalido o expirado'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    try:
        user = User.objects.get(email__iexact=email)
    except User.DoesNotExist:
        return Response(
            {'error': 'Codigo invalido o expirado'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    user.set_password(new_password)
    user.save()
    cache.delete(_reset_cache_key(email))
    Token.objects.filter(user=user).delete()

    return Response(
        {'message': 'Contrasena actualizada exitosamente'},
        status=status.HTTP_200_OK,
    )
