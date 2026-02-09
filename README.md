# 🏎️ Legendary Motors - Premium Dealership App

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Platform](https://img.shields.io/badge/platform-ios%20%7C%20android%20%7C%20web-lightgrey)

**Legendary Motors** is a high-fidelity mobile application designed for luxury car enthusiasts and high-net-worth collectors. It provides a seamless digital showroom experience with real-time tracking, secure payments, and smart sensor integration.

---

## ✨ Key Features

### 💎 Premium Digital Showroom
- **4K Visuals**: High-resolution image galleries for supercars and hypercars.
- **Hero Animations**: Fluid transitions between inventory and car details.
- **Deep Specs**: Detailed performance data (HP, Torque, 0-60) parsed from a structured backend.

### 🛡️ Smart Logic & Performance
- **Offline Mode**: Full SQLite caching allows users to browse their "Garage" and inventory without internet.
- **RBAC**: Role-Based Access Control for dealership Admins vs. Members.
- **State Management**: Robust architecture using `Provider` for reactive UI updates.

### 🔌 Hardware Integration
- **Geolocation**: Context-aware greetings based on local weather (GPS + OpenWeather).
- **Battery Monitoring**: Device-aware UI that reflects system health.
- **Biometric Ready**: Foundation for FaceID/Fingerprint secure entry.

### 💳 Secure Transactions
- **Stripe Integration**: Secure $5,000 reservation deposit flow.
- **Apple/Google Pay**: Native payment sheet support.

---

## 🧪 Testing Suite

We maintain a rigorous testing standard with **65+ automated test cases**:

### 1. Unified Functional Suite
Ensures UI components and business logic work in harmony.
```bash
flutter test test/complete_test_suite.dart
```

### 2. Comprehensive Model & Data Tests
Verifies JSON parsing, fallbacks, and data integrity.
```bash
flutter test test/comprehensive_unit_test.dart
```

### 3. Widget & Aesthetic Validation
Tests individual premium components like `PremiumButton` and `OfflineBanner`.
```bash
flutter test test/widgets_test.dart
```

---

## 🚀 Getting Started

1. **Clone & Install**:
   ```bash
   git clone https://github.com/NethanK7/LegendaryMotors-App.git
   flutter pub get
   ```
2. **Environment Setup**:
   Ensure `.env` is present in the root with your API keys.
3. **Run Application**:
   ```bash
   flutter run
   ```

---

## 📂 Project Structure

- `lib/api`: API Client & Constants.
- `lib/providers`: Reactive State Management.
- `lib/screens`: Feature-based UI Modules (Auth, Inventory, Admin, etc.).
- `lib/services`: Hardware Sensors, SQLite, and Auth logic.
- `test/`: Comprehensive unit and widget testing suite.

---

**Developed for COM2461-SENG2461 Assignment**
