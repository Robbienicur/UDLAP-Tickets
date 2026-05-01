# 🎫 UDLAP Tickets - Sistema de Gestión de Boletos

Bienvenido al proyecto **UDLAP Tickets**. Esta es una plataforma integral (Backend Django + App Flutter) diseñada para la compra, gestión y validación de boletos para estudiantes de la UDLAP.

## 🚀 Características Principales
- **Autenticación Segura**: Sistema de Login/Registro con Tokens.
- **Gestión de Saldo**: Cada usuario cuenta con un saldo virtual para comprar boletos ($25.00 c/u).
- **Mis Boletos**: Visualización dinámica de boletos disponibles y usados.
- **Validación QR**: Códigos QR expandibles con opción de consumo instantáneo.
- **Persistencia**: Sesión automática (Auto-Login) y almacenamiento local.
- **Modo Invitado**: Permite a usuarios no registrados comprar boletos asociados a su dispositivo (IP/DeviceID).

---

## 🛠️ Requisitos Previos
- **Python 3.10+**
- **Flutter SDK** (Canal estable)
- **Git**

---

## 📂 Configuración del Backend (Django)

1. **Crear Entorno Virtual**:
   ```bash
   python -m venv venv
   source venv/Scripts/activate  # En Windows: venv\Scripts\activate
   ```

2. **Instalar Dependencias**:
   ```bash
   pip install django djangorestframework django-cors-headers
   ```

3. **Migrar Base de Datos**:
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```

4. **Cargar Datos de Prueba (Usuarios Ricardo, Hector, etc.)**:
   Ejecuta el script de inicialización que hemos preparado:
   ```bash
   python setup_dev_data.py
   ```

5. **Iniciar Servidor**:
   ```bash
   python manage.py runserver 8001
   ```
   > **Nota**: El backend debe correr en el puerto **8001** para que la App se conecte correctamente.

---

## 📱 Configuración de la App (Flutter)

1. **Obtener Paquetes**:
   ```bash
   flutter pub get
   ```

2. **Ejecutar la App**:
   - **Windows**: `flutter run -d windows`
   - **Web**: `flutter run -d chrome`

---

## 🧪 Datos de Prueba (Login)
Puedes usar las siguientes credenciales para probar el flujo completo:
- **Usuario 1**: `ricardo@udlap.mx` / `password123`
- **Usuario 2**: `hector@udlap.mx` / `password123`
- **Registro**: ¡También puedes crear tu propia cuenta desde la App!

---

## 🛠️ Tecnologías Usadas
- **Backend**: Django, Django REST Framework (API JSON).
- **Frontend**: Flutter, Material Design 3.
- **Base de Datos**: SQLite (para desarrollo).
- **Seguridad**: Token Authentication, CORS policy.

---

Desarrollado con ❤️ para la comunidad UDLAP.
