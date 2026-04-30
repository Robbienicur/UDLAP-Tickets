from django.contrib.auth import authenticate
from django.contrib.auth.models import User

from rest_framework import status
from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.authentication import TokenAuthentication, SessionAuthentication
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from .models import Boleto
from .serializers import BoletoSerializer
import uuid

def get_client_id(request):
    # Primero intentamos obtener un ID único enviado por la App (X-Device-ID)
    device_id = request.META.get('HTTP_X_DEVICE_ID')
    if device_id:
        return device_id
        
    # Si no hay Device ID, usamos la IP como respaldo
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        return x_forwarded_for.split(',')[0]
    return request.META.get('REMOTE_ADDR')

@api_view(['GET'])
@authentication_classes([TokenAuthentication])
@permission_classes([AllowAny])

def get_boletos(request):
    if request.user.is_authenticated:
        # Si está logueado, vemos sus boletos
        print(f"DEBUG: Recuperando boletos para usuario {request.user}")
        boletos = Boleto.objects.filter(usuario=request.user).order_by('fecha_compra')
    else:
        # Si no, tratamos como invitado
        client_id = get_client_id(request)
        print(f"DEBUG: Recuperando boletos para invitado {client_id}")
        boletos = Boleto.objects.filter(identificador_invitado=client_id, usuario__isnull=True).order_by('fecha_compra')
    
    serializer = BoletoSerializer(boletos, many=True)
    return Response(serializer.data)

@api_view(['POST'])
@authentication_classes([TokenAuthentication])
@permission_classes([AllowAny])
def comprar_boletos(request):
    try:
        cantidad = int(request.data.get('cantidad', 1))
    except (ValueError, TypeError):
        cantidad = 1
    
    costo_total = cantidad * 25 # 25 pesos por boleto
    
    if request.user.is_authenticated:
        # Verificar saldo
        perfil = request.user.perfil
        if perfil.saldo < costo_total:
            return Response({'error': f'Saldo insuficiente. Costo: ${costo_total}, Saldo: ${perfil.saldo}'}, 
                            status=status.HTTP_400_BAD_REQUEST)
        
        # Descontar saldo
        perfil.saldo -= costo_total
        perfil.save()

    client_id = get_client_id(request)
    new_boletos = []
    
    for _ in range(cantidad):
        codigo = f"BOL-{str(uuid.uuid4())[:8].upper()}"
        if request.user.is_authenticated:
            boleto = Boleto.objects.create(codigo_alfanumerico=codigo, usuario=request.user)
        else:
            boleto = Boleto.objects.create(codigo_alfanumerico=codigo, identificador_invitado=client_id)
        new_boletos.append(boleto)
    
    serializer = BoletoSerializer(new_boletos, many=True)
    return Response({
        'boletos': serializer.data,
        'nuevo_saldo': float(request.user.perfil.saldo) if request.user.is_authenticated else None
    }, status=status.HTTP_201_CREATED)

@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    email = request.data.get('email')
    password = request.data.get('password')
    
    # En Django el email suele ser el username en este flujo, o buscamos por email
    try:
        user_obj = User.objects.get(email=email)
        username = user_obj.username
    except User.DoesNotExist:
        username = email # Intentar como username directo
        
    user = authenticate(username=username, password=password)
    
    if user is not None:
        # Aseguramos que tenga perfil (cartera de saldo)
        from .models import PerfilUsuario
        perfil, _ = PerfilUsuario.objects.get_or_create(usuario=user)
        
        token, created = Token.objects.get_or_create(user=user)
        return Response({
            'message': 'Login successful',
            'username': user.username,
            'email': user.email,
            'saldo': float(perfil.saldo),
            'token': token.key
        }, status=status.HTTP_200_OK)
    
    return Response({'error': 'Credenciales inválidas'}, status=status.HTTP_401_UNAUTHORIZED)

@api_view(['POST'])
@permission_classes([AllowAny])
def reset_password_view(request):
    email = request.data.get('email')
    new_password = request.data.get('new_password')
    check_only = request.data.get('check_only', False)
    
    try:
        user = User.objects.get(email=email)
        if check_only:
            return Response({'message': 'Email válido'}, status=status.HTTP_200_OK)
            
        if not new_password:
            return Response({'error': 'Nueva contraseña requerida'}, status=status.HTTP_400_BAD_REQUEST)
            
        user.set_password(new_password)
        user.save()
        return Response({'message': 'Contraseña actualizada exitosamente'}, status=status.HTTP_200_OK)
    except User.DoesNotExist:
        return Response({'error': 'Dirección de correo no registrada'}, status=status.HTTP_404_NOT_FOUND)

@api_view(['POST'])
@permission_classes([AllowAny])
def registrar_usuario(request):
    email = request.data.get('email')
    password = request.data.get('password')
    username = request.data.get('username', email.split('@')[0])
    
    if not email or not password:
        return Response({'error': 'Email y password son requeridos'}, status=status.HTTP_400_BAD_REQUEST)
    
    if User.objects.filter(email=email).exists():
        return Response({'error': 'El email ya está registrado'}, status=status.HTTP_400_BAD_REQUEST)
        
    user = User.objects.create_user(username=username, email=email, password=password)
    
    from .models import PerfilUsuario
    perfil, _ = PerfilUsuario.objects.get_or_create(usuario=user)
    
    token, _ = Token.objects.get_or_create(user=user)
    
    return Response({
        'message': 'Usuario creado exitosamente',
        'username': user.username,
        'email': user.email,
        'saldo': float(perfil.saldo),
        'token': token.key
    }, status=status.HTTP_201_CREATED)

@api_view(['POST'])
@permission_classes([AllowAny])
def consumir_boleto(request):
    codigo = request.data.get('codigo')
    if not codigo:
        return Response({'error': 'Código no proporcionado'}, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        boleto = Boleto.objects.get(codigo_alfanumerico=codigo)
        if boleto.estado == 'Usado':
            return Response({'error': 'El boleto ya ha sido usado'}, status=status.HTTP_400_BAD_REQUEST)
        
        boleto.estado = 'Usado'
        boleto.save()
        return Response({'message': 'Boleto consumido exitosamente'}, status=status.HTTP_200_OK)
    except Boleto.DoesNotExist:
        return Response({'error': 'Boleto no encontrado'}, status=status.HTTP_404_NOT_FOUND)

