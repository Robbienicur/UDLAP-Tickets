<div align="center">

<img src="assets/images/udlap-logo.png" alt="UDLAP" height="45">

<br><br>

<a href="README.md"><img src="https://hatscripts.github.io/circle-flags/flags/mx.svg" width="28" alt="Español"></a>
&nbsp;
<a href="#"><img src="https://hatscripts.github.io/circle-flags/flags/us.svg" width="28" alt="English"></a>

</div>

---

<div align="center">

<img src="assets/images/udlap-tickets-logo.png" alt="UDLAP Tickets" height="150">

<br>

# UDLAP Tickets

**Digital ticketing system for university parking**

<br>

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Material Design](https://img.shields.io/badge/Material%20Design%203-757575?style=for-the-badge&logo=materialdesign&logoColor=white)](https://m3.material.io)

[![Android](https://img.shields.io/badge/Android-3DDC84?style=flat-square&logo=android&logoColor=white)](#)
[![iOS](https://img.shields.io/badge/iOS-000000?style=flat-square&logo=apple&logoColor=white)](#)
[![Web](https://img.shields.io/badge/Web-4285F4?style=flat-square&logo=googlechrome&logoColor=white)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-brightgreen?style=flat-square)](#)

</div>

---

## 📋 Table of Contents

- [About the Project](#-about-the-project)
- [Features](#-features)
- [Architecture](#-architecture)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Running the App](#running-the-app)
- [Project Structure](#-project-structure)
- [App Flow](#-app-flow)
- [Team](#-team)
- [License](#-license)

---

## 🎯 About the Project

**UDLAP Tickets** is a mobile application built with Flutter that modernizes the parking access system at Universidad de las Américas Puebla. The app allows students and university staff to purchase and manage digital parking tickets quickly, securely, and without the need for physical tickets.

### Why UDLAP Tickets?

| Problem | Solution |
|---------|----------|
| Long lines at toll booths | Buy ahead from your phone |
| Physical tickets that get lost | Digital tickets always available |
| No flexible payment options | Pay with card or rechargeable balance |
| No purchase history | Full transaction history |

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 🔐 Authentication
- Login with institutional email
- New user registration
- Guest access

</td>
<td width="50%">

### 🎫 Ticket Management
- Select ticket quantity
- View active tickets
- Purchase history

</td>
</tr>
<tr>
<td width="50%">

### 💳 Payment Methods
- Credit/debit card payment
- Rechargeable balance payment
- Balance top-up via barcode

</td>
<td width="50%">

### 👤 User Profile
- Personal information
- Real-time available balance
- Account management

</td>
</tr>
</table>

---

## 🏗 Architecture

The application follows a **screen-based** architecture with imperative navigation using `Navigator`:

```
lib/
├── main.dart                          # Entry point
└── screens/
    ├── login_screen.dart              # Login
    ├── registro_screen.dart           # User registration
    ├── home_screen.dart               # Main screen with navigation
    ├── confirmacion_screen.dart       # Purchase confirmation
    ├── pago_tarjeta_screen.dart       # Card payment form
    ├── saldo_screen.dart              # Balance screen
    └── recargar_saldo_screen.dart     # Balance top-up (barcode)
```

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed:

| Tool | Minimum Version | Installation |
|------|----------------|-------------|
| Flutter SDK | 3.10+ | [flutter.dev/get-started](https://docs.flutter.dev/get-started/install) |
| Dart SDK | 3.10.4+ | Included with Flutter |
| Android Studio / Xcode | Latest stable | [developer.android.com](https://developer.android.com/studio) / App Store |

> **Tip:** Verify your setup by running `flutter doctor` in the terminal.

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/Robbienicur/UDLAP-Tickets.git

# 2. Navigate to the project directory
cd UDLAP-Tickets

# 3. Install dependencies
flutter pub get
```

### Running the App

```bash
# Run in debug mode
flutter run

# Run on a specific device
flutter run -d chrome      # Web
flutter run -d android     # Android
flutter run -d ios         # iOS
```

<details>
<summary><strong>🔧 Additional useful commands</strong></summary>

```bash
# Analyze the code
flutter analyze

# Run tests
flutter test

# Build release APK
flutter build apk --release

# Build for iOS
flutter build ios --release
```

</details>

---

## 📁 Project Structure

```
UDLAP-Tickets/
├── 📂 android/               # Android native configuration
├── 📂 ios/                    # iOS native configuration
├── 📂 lib/                    # Main source code
│   ├── 📄 main.dart           # Application entry point
│   └── 📂 screens/            # Application screens
├── 📂 linux/                  # Linux support
├── 📂 macos/                  # macOS support
├── 📂 web/                    # Web support
├── 📂 windows/                # Windows support
├── 📂 test/                   # Unit and widget tests
├── 📄 pubspec.yaml            # Dependencies and configuration
├── 📄 analysis_options.yaml   # Code analysis rules
└── 📄 README.md               # Documentation
```

---

## 🔄 App Flow

```
┌─────────────┐     ┌──────────────┐     ┌──────────────────┐
│   Login /   │────▶│    Home      │────▶│    Purchase      │
│  Register   │     │  (Tickets)   │     │   Confirmation   │
└─────────────┘     └──────────────┘     └──────────────────┘
                                                  │
                          ┌───────────────────────┼───────────────────┐
                          ▼                       ▼                   ▼
                   ┌─────────────┐      ┌──────────────┐    ┌──────────────┐
                   │  Card       │      │  Balance     │    │    Other     │
                   │  Payment    │      │  Payment     │    │   Methods    │
                   └─────────────┘      └──────────────┘    └──────────────┘
                                               │
                                               ▼
                                        ┌─────────────┐
                                        │   Top-up    │
                                        │   Balance   │
                                        └─────────────┘
```

---

## 👥 Team

<div align="center">

Project developed for the **Software Engineering** course — UDLAP

| Member | Role |
|:------:|:----:|
| **Robbie Nicolas Curioso de Salazar** | Developer |
| **José Luis Godínez Carillo** | Developer |
| **Héctor Jesús Núñez Tecpanecatl** | Developer |
| **Sebastián Torres Morales** | Developer |
| **Ricardo Carballido Rosas** | Developer |

</div>

---

## 📄 License

This project is **open source**. Anyone is free to clone, modify, and contribute to the development of the application.

Distributed under the MIT License. See the [`LICENSE`](LICENSE) file for more information.

---

<div align="center">

[![GitHub](https://img.shields.io/badge/View%20on-GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Robbienicur/UDLAP-Tickets)

UDLAP · Puebla, Mexico

</div>
