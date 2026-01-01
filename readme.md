## ☕ Horus Cafe: Enterprise IoT Beverage Management System

**Horus Cafe** is a full-stack smart-ordering ecosystem designed for high-traffic office and university environments. It bridges the gap between digital mobile ordering and physical hardware notification systems, featuring a Flutter-based client, a Flask-powered synchronization engine, and ESP32 IoT display nodes.

---

## 🏗️ System Architecture

The system utilizes a central **RESTful API** to orchestrate real-time data flow between heterogeneous clients.

### 1. Mobile Client (Flutter)

A Material 3 compliant application utilizing a **Finite State Machine (FSM)** for its chat-based ordering engine.

* **Persistent Auth:** Local caching of user credentials and profile data.
* **Media Handling:** Client-side image compression and Base64 encoding for profile synchronization.

### 2. Synchronization Gateway (Flask)

The core middleware responsible for business logic and data normalization.

* **Data Translation:** Intercepts localized Arabic strings and converts them to numeric primitives for IoT compatibility.
* **Resource Management:** Decodes Base64 payloads into physical `.jpg` files stored in a mapped directory.

### 3. IoT Display Node (ESP32)

A hardware peripheral that polls the server for active orders. It utilizes the normalized numeric data to display order specifics (e.g., sugar levels) on hardware that lacks complex font-rendering capabilities.

---

## 🔌 API Endpoints Reference

The backend exposes a RESTful API to handle authentication, profile management, and IoT synchronization.

### **1. Authentication & Profile**

| Method | Endpoint | Description | Payload |
| --- | --- | --- | --- |
| `POST` | `/auth/login` | Validates Staff ID and returns full profile. | `{"staff_id": "1181318"}` |
| `POST` | `/auth/register_web` | Web-based registration (handles HTML Form data). | `Form: {staff_name, staff_id, room}` |
| `POST` | `/auth/update_profile` | Updates user metadata and profile image. | `{"staff_id": "...", "department": "...", "profile_image": "base64"}` |

### **2. Order Management**

| Method | Endpoint | Description | Payload |
| --- | --- | --- | --- |
| `POST` | `/orders/create` | Submits a new beverage request from the app. | `{"staff_id": "...", "items": [...], "notes": "..."}` |
| `GET` | `/orders/active/<boy_id>` | **IoT Endpoint:** Fetches pending orders for ESP32. | `None` |
| `POST` | `/orders/update_status` | Changes order status (e.g., PENDING → ACCEPTED). | `{"order_id": 1, "status": "ACCEPTED"}` |

---

## 🔄 IoT Data Normalization (Sugar Level Translation)

One of the project's critical features is the **Numeric Translation Layer**. Since standard ESP32 OLED/LCD screens struggle with RTL (Arabic) rendering, the Flask server converts localized sugar descriptions into numeric "spoonful" counts before delivery to the hardware.

| Arabic Label (Mobile App) | Numeric Output (IoT Device) | Translation |
| --- | --- | --- |
| **سادة** | `0` | Plain / No Sugar |
| **ع الريحة** | `0.5` | Trace Sugar |
| **مظبوط** | `1` | Balanced / 1 Spoon |
| **زيادة** | `2` | Extra / 2 Spoons |

---

## 📂 Project Structure

```text
├── horus_mobile/           # Flutter source code
│   ├── core/               # Networking (Dio) & API Constants
│   ├── features/auth/      # Identity Management & Local Storage
│   ├── features/chat/      # State-machine logic & Order creation
│   └── features/profile/   # Profile UI & Image Picker integration
├── horus_backend/          # Flask Microservices
│   ├── static/             # Assets & Decoded Profile Images
│   ├── templates/          # Web-based registration portal
│   └── main.py             # Route Handlers & Database Migration
└── horus_iot/              # Firmware for ESP32/Arduino

```

---

## 🚀 Deployment Guide

### **1. Server Initialization**

Ensure Python 3.9+ is installed.

```bash
pip install flask flask-cors
python main.py

```

The server will initialize an SQLite database and prepare the `static/profile_images` directory.

### **2. Mobile Client Configuration**

Update the API endpoint in `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = "http://YOUR_SERVER_IP:5000";

```

Execute `flutter run` to deploy to an Android or iOS device.

### **3. IoT Hardware Setup**

Update the WiFi credentials and the server's local IP address in the ESP32 firmware. The device will poll `/orders/active/<boy_id>` to retrieve pending requests.

---

## 🎨 Design Philosophy

The system follows a **"Dark Cafe"** aesthetic, utilizing a palette of **Deep Charcoal (#121212)** and **Electric Purple (#BB86FC)**. This design language is maintained across the Mobile UI and the Web Registration portal to ensure brand consistency and reduce visual strain in indoor environments.

---

## 📄 License

This project is licensed under the MIT License.

---

## Developed By Ahmad Elshafee
