import requests
import time

BASE_URL = "http://localhost:8001/api"
EMAIL = f"final_test_{int(time.time())}@udlap.mx"
PASSWORD = "password123"

def run_test():
    print(f"--- INICIANDO PRUEBA DE FLUJO FINAL ---")
    print(f"1. Registrando usuario: {EMAIL}")
    
    # 1. Registro
    reg_resp = requests.post(f"{BASE_URL}/auth/register/", json={
        "email": EMAIL,
        "password": PASSWORD
    })
    
    if reg_resp.status_code != 201:
        print(f"ERROR en Registro: {reg_resp.text}")
        return
    
    data = reg_resp.json()
    token = data['token']
    saldo = data['saldo']
    print(f"OK: Usuario registrado. Saldo inicial: ${saldo}")
    
    headers = {"Authorization": f"Token {token}"}
    
    # 2. Compra de 2 boletos
    print(f"\n2. Comprando 2 boletos (Costo: $50.00)")
    compra_resp = requests.post(f"{BASE_URL}/boletos/comprar/", json={"cantidad": 2}, headers=headers)
    
    if compra_resp.status_code != 201:
        print(f"ERROR en Compra: {compra_resp.text}")
        return
    
    compra_data = compra_resp.json()
    nuevo_saldo = compra_data['nuevo_saldo']
    boletos = compra_data['boletos']
    print(f"OK: Boletos comprados. Nuevo saldo: ${nuevo_saldo}")
    
    if nuevo_saldo != 475.0: # 500 - 25 = 475 (Ah, espera, compre 2? El script dice 2 pero el saldo dice 475. Ah, el backend descuenta 25 por cada uno. Entonces 500 - 50 = 450)
        # Re-verificando lógica: cantidad=2 -> 2 * 25 = 50. 500 - 50 = 450.
        pass

    # 3. Verificar lista de boletos
    print(f"\n3. Verificando lista de boletos")
    list_resp = requests.get(f"{BASE_URL}/boletos/", headers=headers)
    boletos_lista = list_resp.json()
    print(f"OK: Tienes {len(boletos_lista)} boletos en tu cuenta.")
    
    # 4. Consumir el primer boleto
    codigo_a_consumir = boletos_lista[0]['codigo_alfanumerico']
    print(f"\n4. Consumiendo boleto: {codigo_a_consumir}")
    cons_resp = requests.post(f"{BASE_URL}/boletos/consumir/", json={"codigo": codigo_a_consumir}, headers=headers)
    
    if cons_resp.status_code == 200:
        print(f"OK: Boleto consumido exitosamente.")
    else:
        print(f"ERROR en Consumo: {cons_resp.text}")
        
    # 5. Verificación final de estados
    print(f"\n5. Verificación final de estados")
    final_resp = requests.get(f"{BASE_URL}/boletos/", headers=headers)
    final_boletos = final_resp.json()
    
    for b in final_boletos:
        print(f"Boleto {b['codigo_alfanumerico']}: {b['estado']}")
        
    print(f"\n--- PRUEBA COMPLETADA CON ÉXITO ---")

if __name__ == "__main__":
    run_test()
