from django.contrib.auth import authenticate
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
    
    print(f"DEBUG: Compra solicitada por usuario: {request.user} (Auth: {request.user.is_authenticated})")
    print(f"DEBUG: Cantidad: {cantidad}")

    client_id = get_client_id(request)
    new_boletos = []
    
    for _ in range(cantidad):
        codigo = f"BOL-{str(uuid.uuid4())[:8].upper()}"
        
        if request.user.is_authenticated:
            # Si está logueado, el boleto es SUYO
            boleto = Boleto.objects.create(
                codigo_alfanumerico=codigo,
                usuario=request.user
            )
        else:
            # Si es invitado, el boleto es del identificador (IP o DeviceID)
            boleto = Boleto.objects.create(
                codigo_alfanumerico=codigo,
                identificador_invitado=client_id
            )
        new_boletos.append(boleto)
    
    serializer = BoletoSerializer(new_boletos, many=True)
    return Response(serializer.data, status=status.HTTP_201_CREATED)

@api_view(['POST'])
def login_view(request):
    username = request.data.get('email')
    password = request.data.get('password')
    
    user = authenticate(username=username, password=password)
    
    if user is not None:
        token, created = Token.objects.get_or_create(user=user)
        return Response({
            'message': 'Login successful',
            'username': user.username,
            'token': token.key
        }, status=status.HTTP_200_OK)
    
    return Response({'error': 'Credenciales inválidas'}, status=status.HTTP_401_UNAUTHORIZED)
