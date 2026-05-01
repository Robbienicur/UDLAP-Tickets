import os
import django
import uuid

# Configuración de Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend_tickets.settings')
django.setup()

from django.contrib.auth.models import User
from api_tickets.models import Boleto, PerfilUsuario

def setup_data():
    print("--- INICIANDO CARGA DE DATOS DE PRUEBA ---")
    
    users_to_create = [
        {"username": "ricardo", "email": "ricardo@udlap.mx", "pass": "password123"},
        {"username": "hector", "email": "hector@udlap.mx", "pass": "password123"},
        {"username": "jose", "email": "jose@udlap.mx", "pass": "password123"},
    ]
    
    for u in users_to_create:
        # Borrar si existe para empezar limpio
        User.objects.filter(email=u['email']).delete()
        User.objects.filter(username=u['username']).delete()
        
        user = User.objects.create_user(
            username=u['username'], 
            email=u['email'], 
            password=u['pass']
        )
        
        # El PerfilUsuario se crea automáticamente vía Signal (models.py)
        # Vamos a darle un poco más de saldo a Ricardo para que presuma
        perfil = user.perfil
        if u['username'] == 'ricardo':
            perfil.saldo = 1000.00
        perfil.save()
        
        # Crear 2 boletos para cada uno
        for _ in range(2):
            Boleto.objects.create(
                codigo_alfanumerico=f"BOL-{str(uuid.uuid4())[:8].upper()}",
                usuario=user,
                estado='Disponible'
            )
            
        print(f"OK: Creado {u['email']} con saldo ${perfil.saldo} y 2 boletos.")

    print("\n--- DATOS CARGADOS EXITOSAMENTE ---")
    print("Ya puedes iniciar el servidor con: python manage.py runserver 8001")

if __name__ == "__main__":
    setup_data()
