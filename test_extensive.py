import requests
import time

BASE_URL = "http://127.0.0.1:8001/api"

def login(email, password):
    r = requests.post(f"{BASE_URL}/auth/login/", json={"email": email, "password": password})
    if r.status_code == 200:
        return r.json().get("token")
    else:
        print(f"Error login {email}: {r.text}")
        return None

def comprar_boletos(token, cantidad):
    headers = {}
    if token:
        headers["Authorization"] = f"Token {token}"
    r = requests.post(f"{BASE_URL}/boletos/comprar/", json={"cantidad": cantidad}, headers=headers)
    return r.json()

def get_boletos(token=None):
    headers = {}
    if token:
        headers["Authorization"] = f"Token {token}"
    r = requests.get(f"{BASE_URL}/boletos/", headers=headers)
    return r.json()

# --- INICIO DE PRUEBAS ---

print("=== INICIANDO PRUEBAS EXTENSIVAS DE AISLAMIENTO ===\n")

# 1. Ricardo compra 3 boletos
token_ricardo = login("ricardo@udlap.mx", "udlap2026")
print(f"Ricardo comprando 3 boletos...")
comprar_boletos(token_ricardo, 3)

# 2. Hector compra 2 boletos
token_hector = login("hector@udlap.mx", "udlap2026")
print(f"Hector comprando 2 boletos...")
comprar_boletos(token_hector, 2)

# 3. Jose compra 1 boleto
token_jose = login("jose@udlap.mx", "udlap2026")
print(f"Jose comprando 1 boleto...")
comprar_boletos(token_jose, 1)

# 4. Invitado compra 4 boletos
# Como el script corre desde la misma IP, trataremos de simularlo sin token
print(f"Invitado comprando 4 boletos...")
comprar_boletos(None, 4)

print("\n--- VERIFICANDO RESULTADOS ---\n")

# Verificar Ricardo
boletos_r = get_boletos(token_ricardo)
print(f"Ricardo: {len(boletos_r)} boletos (Esperado: 3)")
for b in boletos_r:
    print(f"  - {b['codigo_alfanumerico']}")

# Verificar Hector
boletos_h = get_boletos(token_hector)
print(f"Hector: {len(boletos_h)} boletos (Esperado: 2)")
for b in boletos_h:
    print(f"  - {b['codigo_alfanumerico']}")

# Verificar Jose
boletos_j = get_boletos(token_jose)
print(f"Jose: {len(boletos_j)} boletos (Esperado: 1)")
for b in boletos_j:
    print(f"  - {b['codigo_alfanumerico']}")

# Verificar Invitado
boletos_i = get_boletos(None)
print(f"Invitado (IP 127.0.0.1): {len(boletos_i)} boletos (Esperado: 4)")
for b in boletos_i:
    print(f"  - {b['codigo_alfanumerico']}")

# VALIDACIÓN FINAL
print("\n--- RESUMEN DE AISLAMIENTO ---")
total_boletos = len(boletos_r) + len(boletos_h) + len(boletos_j) + len(boletos_i)
print(f"Total boletos encontrados: {total_boletos}")

if len(boletos_r) == 3 and len(boletos_h) == 2 and len(boletos_j) == 1 and len(boletos_i) == 4:
    print("\n[OK] PRUEBA EXITOSA: Cada usuario tiene exactamente la cantidad que compró.")
else:
    print("\n[ERROR] PRUEBA FALLIDA: Hay cruce de boletos o pérdida de datos.")
