import requests

BASE_URL = "http://127.0.0.1:8001/api"

def comprar_boletos(device_id, cantidad):
    headers = {"X-Device-ID": device_id}
    r = requests.post(f"{BASE_URL}/boletos/comprar/", json={"cantidad": cantidad}, headers=headers)
    return r.json()

def get_boletos(device_id):
    headers = {"X-Device-ID": device_id}
    r = requests.get(f"{BASE_URL}/boletos/", headers=headers)
    return r.json()

print("=== PRUEBA DE IDENTIFICADORES ÚNICOS (DEVICE ID) ===\n")

# Dispositivo A compra 2 boletos
print("Dispositivo A comprando 2 boletos...")
comprar_boletos("IPHONE-V7-XYZ", 2)

# Dispositivo B compra 1 boleto
print("Dispositivo B comprando 1 boleto...")
comprar_boletos("SAMSUNG-S21-ABC", 1)

# Verificar A
boletos_a = get_boletos("IPHONE-V7-XYZ")
print(f"Dispositivo A: {len(boletos_a)} boletos (Esperado: 2)")

# Verificar B
boletos_b = get_boletos("SAMSUNG-S21-ABC")
print(f"Dispositivo B: {len(boletos_b)} boletos (Esperado: 1)")

if len(boletos_a) == 2 and len(boletos_b) == 1:
    print("\n[OK] IDENTIFICACIÓN POR DISPOSITIVO FUNCIONA CORRECTAMENTE.")
else:
    print("\n[ERROR] FALLA EN IDENTIFICACIÓN POR DISPOSITIVO.")
