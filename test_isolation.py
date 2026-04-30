import requests

BASE_URL = "http://127.0.0.1:8001/api"

def login(email, password):
    r = requests.post(f"{BASE_URL}/auth/login/", json={"email": email, "password": password})
    return r.json().get("token")

def get_boletos(token=None):
    headers = {}
    if token:
        headers["Authorization"] = f"Token {token}"
    r = requests.get(f"{BASE_URL}/boletos/", headers=headers)
    return r.json()

def comprar_boleto(token=None):
    headers = {}
    if token:
        headers["Authorization"] = f"Token {token}"
    r = requests.post(f"{BASE_URL}/boletos/comprar/", json={"cantidad": 1}, headers=headers)
    return r.json()

# 1. Limpiar base de datos antes de la prueba
print("Limpiando boletos...")
# (Esto lo haré con un comando aparte para no complicar el script)

# 2. Prueba con Ricardo
token_ricardo = login("ricardo@udlap.mx", "udlap2026")
print(f"Token Ricardo: {token_ricardo}")
comprar_boleto(token_ricardo)
boletos_ricardo = get_boletos(token_ricardo)
print(f"Boletos Ricardo: {[b['codigo_alfanumerico'] for b in boletos_ricardo]}")

# 3. Prueba con Hector
token_hector = login("hector@udlap.mx", "udlap2026")
print(f"Token Hector: {token_hector}")
boletos_hector = get_boletos(token_hector)
print(f"Boletos Hector (debería ser []): {[b['codigo_alfanumerico'] for b in boletos_hector]}")

# 4. Prueba con Invitado
boletos_invitado = get_boletos()
print(f"Boletos Invitado (debería ser [] si no se ha comprado nada): {[b['codigo_alfanumerico'] for b in boletos_invitado]}")

if len(boletos_ricardo) > 0 and len(boletos_hector) == 0:
    print("\n[OK] AISLAMIENTO VERIFICADO: Los usuarios solo ven sus propios boletos.")
else:
    print("\n[ERROR] ERROR DE AISLAMIENTO detectado.")

