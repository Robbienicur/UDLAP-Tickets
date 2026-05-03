<div align="center">

<img src="assets/images/udlap-logo.png" alt="UDLAP" height="45">

<br><br>

<a href="#"><img src="https://hatscripts.github.io/circle-flags/flags/mx.svg" width="28" alt="Español"></a>
&nbsp;
<a href="README.en.md"><img src="https://hatscripts.github.io/circle-flags/flags/us.svg" width="28" alt="English"></a>

</div>

---

<div align="center">

<img src="assets/images/udlap-tickets-logo.png" alt="UDLAP Tickets" height="150">

<br>

# UDLAP Tickets

**Sistema de boletos digitales para el estacionamiento universitario**

<br>

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Django](https://img.shields.io/badge/Django-092E20?style=for-the-badge&logo=django&logoColor=white)](https://www.djangoproject.com)
[![Material Design](https://img.shields.io/badge/Material%20Design%203-757575?style=for-the-badge&logo=materialdesign&logoColor=white)](https://m3.material.io)

[![Android](https://img.shields.io/badge/Android-3DDC84?style=flat-square&logo=android&logoColor=white)](#)
[![iOS](https://img.shields.io/badge/iOS-000000?style=flat-square&logo=apple&logoColor=white)](#)
[![Web](https://img.shields.io/badge/Web-4285F4?style=flat-square&logo=googlechrome&logoColor=white)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-brightgreen?style=flat-square)](#)

</div>

---

## 📋 Tabla de Contenidos

- [Acerca del Proyecto](#-acerca-del-proyecto)
- [Funcionalidades](#-funcionalidades)
- [Arquitectura](#-arquitectura)
- [Comenzar](#-comenzar)
  - [Requisitos Previos](#requisitos-previos)
  - [Configuración del Backend](#configuración-del-backend)
  - [Configuración de la App](#configuración-de-la-app)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [API REST](#-api-rest)
- [Flujo de la Aplicación](#-flujo-de-la-aplicación)
- [Equipo](#-equipo)
- [Licencia](#-licencia)

---

## 🎯 Acerca del Proyecto

**UDLAP Tickets** es una plataforma full-stack que moderniza el sistema de acceso al estacionamiento de la Universidad de las Américas Puebla. La solución combina una aplicación móvil en Flutter con un backend en Django REST Framework para permitir a estudiantes y personal universitario comprar y gestionar boletos digitales de forma rápida, segura y sin necesidad de boletos físicos.

### ¿Por qué UDLAP Tickets?

| Problema | Solución |
|----------|----------|
| Filas largas en casetas de cobro | Compra anticipada desde el celular |
| Boletos físicos que se pierden | Boletos digitales siempre disponibles |
| Sin opciones de pago flexible | Pago con tarjeta o saldo recargable |
| No hay control de historial | Historial completo de compras |
| Validación lenta en el acceso | Códigos QR escaneables al instante |

---

## ✨ Funcionalidades

<table>
<tr>
<td width="50%">

### 🔐 Autenticación
- Inicio de sesión con correo institucional
- Registro de nuevos usuarios
- Recuperación de contraseña con código verificable
- Sesión persistente con auto-login

</td>
<td width="50%">

### 🎫 Gestión de Boletos
- Compra de boletos con descuento de saldo
- Listado de boletos activos y usados
- Códigos QR generados por boleto
- Historial de compras y consumos

</td>
</tr>
<tr>
<td width="50%">

### 💳 Métodos de Pago
- Pago con tarjeta de crédito/débito
- Pago con saldo recargable
- Recarga de saldo mediante código de barras

</td>
<td width="50%">

### 👤 Perfil de Usuario
- Información personal
- Saldo disponible en tiempo real
- Notificaciones de actividad
- Cierre de sesión seguro

</td>
</tr>
</table>

---

## 📱 Capturas de Pantalla

<div align="center">

<table>
<tr>
<td align="center" width="25%">
  <img src="assets/screenshots/01-login.jpg" width="220" alt="Pantalla de inicio de sesión"><br>
  <sub><b>Iniciar sesión</b></sub><br>
  <sub>Acceso institucional o modo invitado</sub>
</td>
<td align="center" width="25%">
  <img src="assets/screenshots/02-inicio.jpg" width="220" alt="Pantalla de inicio"><br>
  <sub><b>Inicio</b></sub><br>
  <sub>Compra rápida desde el home</sub>
</td>
<td align="center" width="25%">
  <img src="assets/screenshots/03-mis-boletos.jpg" width="220" alt="Mis boletos"><br>
  <sub><b>Mis boletos</b></sub><br>
  <sub>Códigos QR escaneables</sub>
</td>
<td align="center" width="25%">
  <img src="assets/screenshots/04-mi-perfil.jpg" width="220" alt="Mi perfil"><br>
  <sub><b>Mi perfil</b></sub><br>
  <sub>Cuenta, ayuda y términos</sub>
</td>
</tr>
</table>

</div>

---

## 🏗 Arquitectura

La plataforma se divide en dos componentes que conviven en este monorepo:

```
┌──────────────────────────┐         HTTPS / JSON         ┌──────────────────────────┐
│                          │ ◀─────────────────────────▶  │                          │
│   App Flutter            │   Token Authentication       │   Backend Django REST    │
│   (Android / iOS / Web)  │                              │   (api_tickets)          │
│                          │                              │                          │
└──────────────────────────┘                              └────────────┬─────────────┘
                                                                       │
                                                                       ▼
                                                          ┌──────────────────────────┐
                                                          │   SQLite (desarrollo)    │
                                                          │   PostgreSQL (producción)│
                                                          └──────────────────────────┘
```

- **Frontend (Flutter):** arquitectura basada en pantallas con `Navigator` y `ApiService` singleton para comunicarse con el backend. Persistencia local con `shared_preferences`.
- **Backend (Django):** API REST con Token Authentication, modelos `Boleto` y `PerfilUsuario`, y endpoints para registro, login, recuperación de contraseña, compra y consumo de boletos.
- **Configuración:** valores sensibles (`SECRET_KEY`, `DEBUG`, `ALLOWED_HOSTS`, CORS) se leen desde variables de entorno; ver `.env.example`.

---

## 🚀 Comenzar

### Requisitos Previos

| Herramienta | Versión Mínima | Instalación |
|-------------|----------------|-------------|
| Flutter SDK | 3.10+ | [flutter.dev/get-started](https://docs.flutter.dev/get-started/install) |
| Dart SDK | 3.10.4+ | Incluido con Flutter |
| Python | 3.10+ | [python.org/downloads](https://www.python.org/downloads/) |
| Android Studio / Xcode | Última estable | [developer.android.com](https://developer.android.com/studio) |

> **Tip:** Verifica tu instalación de Flutter ejecutando `flutter doctor`.

### Configuración del Backend

```bash
# 1. Clonar el repositorio
git clone https://github.com/Robbienicur/UDLAP-Tickets.git
cd UDLAP-Tickets

# 2. Crear y activar entorno virtual
python -m venv venv
source venv/bin/activate          # macOS / Linux
# venv\Scripts\activate           # Windows

# 3. Instalar dependencias
pip install django djangorestframework django-cors-headers

# 4. Configurar variables de entorno
cp .env.example .env              # editar valores segun el entorno

# 5. Aplicar migraciones
python manage.py makemigrations
python manage.py migrate

# 6. Iniciar el servidor en el puerto 8001
python manage.py runserver 8001
```

> **Importante:** el cliente Flutter espera el backend en el puerto **8001** por defecto. Para cambiarlo, configura `--dart-define=API_BASE_URL=...` al ejecutar la app.

### Configuración de la App

```bash
# Desde la raíz del repo
flutter pub get

# Ejecutar en modo debug
flutter run

# Apuntar a un backend específico
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8001/api
```

<details>
<summary><strong>🔧 Comandos útiles adicionales</strong></summary>

```bash
# Analizar el código Flutter
flutter analyze

# Ejecutar tests
flutter test

# Construir APK de release
flutter build apk --release

# Construir para iOS
flutter build ios --release

# Verificar configuración de Django
python manage.py check
```

</details>

---

## 📁 Estructura del Proyecto

```
UDLAP-Tickets/
├── 📂 api_tickets/              # App Django con la lógica de negocio
│   ├── models.py                # Boleto, PerfilUsuario
│   ├── views.py                 # Endpoints REST
│   ├── urls.py                  # Rutas del API
│   └── serializers.py
├── 📂 backend_tickets/          # Configuración del proyecto Django
│   ├── settings.py              # Lee variables de entorno
│   ├── urls.py
│   └── wsgi.py
├── 📂 lib/                      # Código fuente Flutter
│   ├── 📄 main.dart             # Punto de entrada
│   ├── 📂 models/               # Modelos de datos (Boleto)
│   ├── 📂 screens/              # Pantallas de la aplicación
│   │   ├── auth/                # Login, registro, recuperación
│   │   ├── home/                # Pantalla principal y notificaciones
│   │   └── tickets/             # Saldo, historial, recarga
│   ├── 📂 services/             # ApiService (cliente HTTP)
│   └── 📂 theme/                # Paleta UDLAP y tipografía
├── 📂 android/ ios/ web/        # Configuración nativa por plataforma
├── 📂 test/                     # Tests de widgets
├── 📄 manage.py                 # Entry point de Django
├── 📄 .env.example              # Plantilla de variables de entorno
├── 📄 pubspec.yaml              # Dependencias Flutter
└── 📄 README.md
```

---

## 🌐 API REST

Base URL en desarrollo: `http://localhost:8001/api`

| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| `POST` | `/auth/register/` | Crear nueva cuenta | No |
| `POST` | `/auth/login/` | Iniciar sesión y obtener token | No |
| `POST` | `/auth/request-reset/` | Solicitar código de recuperación | No |
| `POST` | `/auth/reset-password/` | Confirmar nueva contraseña con código | No |
| `GET` | `/boletos/` | Listar boletos del usuario | Sí |
| `POST` | `/boletos/comprar/` | Comprar boletos (descuenta saldo) | Sí |
| `POST` | `/boletos/consumir/` | Marcar boleto como usado | Sí |

La autenticación usa el header `Authorization: Token <key>`. El código de recuperación expira a los 10 minutos.

---

## 🔄 Flujo de la Aplicación

```
┌─────────────┐     ┌──────────────┐     ┌──────────────────┐
│   Login /   │────▶│    Home      │────▶│  Confirmación    │
│  Registro   │     │  (Boletos)   │     │   de Compra      │
└─────────────┘     └──────────────┘     └──────────────────┘
                            │                     │
                            ▼                     │
                    ┌──────────────┐              │
                    │  Mis Boletos │              │
                    │  (QR + uso)  │              │
                    └──────────────┘              │
                                                  │
                          ┌───────────────────────┼───────────────────┐
                          ▼                       ▼                   ▼
                   ┌─────────────┐      ┌──────────────┐    ┌──────────────┐
                   │   Pago con  │      │  Pago con    │    │    Otros     │
                   │   Tarjeta   │      │    Saldo     │    │   Métodos    │
                   └─────────────┘      └──────────────┘    └──────────────┘
                                               │
                                               ▼
                                        ┌─────────────┐
                                        │  Recargar   │
                                        │    Saldo    │
                                        └─────────────┘
```

---

## 👥 Equipo

<div align="center">

Proyecto desarrollado para la materia de **Ingeniería de Software** — UDLAP

El equipo trabaja bajo el framework **Scrum**, organizando el desarrollo en Sprints con entregas incrementales.

| Integrante | Rol Scrum |
|:----------:|:---------:|
| **Robbie Nicolas Curioso de Salazar** | Product Owner |
| **Héctor Jesús Núñez Tecpanecatl** | Scrum Master |
| **José Luis Godínez Carillo** | Developer |
| **Sebastián Torres Morales** | Developer |
| **Ricardo Carballido Rosas** | Developer |

</div>

---

## 📄 Licencia

Este proyecto es **open source**. Cualquier persona es libre de clonar, modificar y contribuir al desarrollo de la aplicación.

Distribuido bajo la Licencia MIT. Consulta el archivo [`LICENSE`](LICENSE) para más información.

---

<div align="center">

[![GitHub](https://img.shields.io/badge/Ver%20en-GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Robbienicur/UDLAP-Tickets)

UDLAP · Puebla, México

</div>
