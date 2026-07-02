# 💊 MediScan AI — Smart Drug Finder & OCR Prescription Scanner

<p align="center">
  <img src="https://img.shields.io/badge/FLUTTER-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/DART-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white"/>
  <img src="https://img.shields.io/badge/State%20Management-BLoC-0052CC?style=for-the-badge&logo=bloc&logoColor=white"/>
  <img src="https://img.shields.io/badge/AI%20OCR-Supported-4285F4?style=for-the-badge&logo=google&logoColor=white"/>
</p>

---

## 🌟 Overview
**MediScan AI** is an intelligent digital healthcare companion built with Flutter, designed to make medicine details, guidelines, and prescription parsing accessible to everyone in Bangladesh. It leverages advanced OCR text recognition and offline databases to deliver instant, easy-to-understand medicine directions, dosage schedules, indications, side effects, and alternative choices in Bengali and English.

---

## 🎬 Application Demo
Watch the app in action:

[![MediScan AI Demo](https://img.shields.io/badge/Demo-Watch_Screen_Recording-E4405F?style=for-the-badge&logo=google-drive&logoColor=white)](https://drive.google.com/file/d/1HN9RtgsofczFHIC2lyTwVPr0ZXwuS0fo/view?usp=sharing)

---

## ✨ Features

### 🔍 1. Smart Drug Finder
*   **Offline Search:** Quickly find local medicines and generic INN groups using the fast preseeded SQLite database.
*   **Alternative Suggestions:** Instantly view equivalent alternative brands in Bangladesh, complete with manufacturer details and estimated pricing.

### 📸 2. OCR Medicine Scanner
*   **Box & Blister Pack Scanner:** Scan the text on medicine packaging using high-precision camera/gallery OCR text recognition.
*   **Interactive Analysis:** Displays scanned details, local information, dosages, side effects, and precautions instantly.

### 📋 3. Intelligent Prescription Reader
*   **Handwritten Prescription Parser:** Upload or take a picture of a handwritten doctor’s prescription to decode the list of medicines.
*   **Automatic Dose Parsing:** Extract and break down dosage instructions (e.g. `1-0-1` for morning & night) automatically.

### 🔊 4. Audio Guidance & Accessibility
*   **Text-to-Speech (TTS):** Have medicine descriptions, directions, and precautions read out loud in Bengali or English.
*   **Language Translation:** Seamless toggle to translate any medical instruction or detail page between English and Bengali with a single click.

### ⏰ 5. Smart Pill Reminders
*   **Custom Alarm Scheduling:** Set up customized medicine alarms based on specific days of the week, times, and dosages.
*   **Local Notifications:** Receive interactive push notifications right when it's time to take your pills, even offline.

### 📝 6. Medical History Diary
*   **Automatically Logged Activity:** Keeps a chronological record of your scanned prescriptions and searched medicines for easy future checkups.

---

## 🛠️ Tech Stack & Architecture

### Tech Stack
*   **Framework:** Flutter & Dart
*   **State Management:** BLoC (Business Logic Component) Pattern using `flutter_bloc`
*   **Local Storage:** SQLite (`sqflite` & `path_provider`) for fast local queries and reminders
*   **OCR Engine:** `google_mlkit_text_recognition`
*   **Speech Synthesis:** `flutter_tts` for voice assistance
*   **Local Alerts:** `flutter_local_notifications` for scheduled alarms
*   **Translation Engine:** `translator` package

### Folder Structure & Clean Architecture
The codebase strictly follows a modular, feature-oriented clean architecture design:
```text
lib/
├── core/                  # Shared configurations, constants, UI themes, and services
│   ├── config/            # Secret key templates and endpoints
│   ├── constants/         # App constants, strings, and localizations
│   ├── services/          # SQLite Database, Notifications, TTS, and OCR services
│   └── theme/             # Premium dark-mode UI colors and styles
└── features/              # Feature-driven modules (Splash, Onboarding, Dashboard, etc.)
    ├── dashboard/         # Bottom Navigation & App Dashboard Hub
    ├── history/           # Saved scan logs and medical history
    ├── prescription/      # Prescription scanning UI and state
    ├── reminder/          # Pill schedule creator and background notification managers
    ├── scanner/           # Medicine package scanner, details view, and alternative queries
    └── settings/          # System configurations and diagnostic checks
```

---

## 🚀 Getting Started

### Prerequisites
Make sure you have the following installed on your machine:
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (version matching `^3.11.0` or higher)
*   [Dart SDK](https://dart.dev/get-started)
*   Android Studio / VS Code

### Steps to Run

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/Shakil-ahd/medicine_guide_ai.git
    cd medicine_guide_ai
    ```

2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the Project:**
    Connect your device/emulator and execute:
    ```bash
    flutter run
    ```

---

## ⚠️ Disclaimer
All medical information, recommendations, prescription readouts, and drug instructions provided by **MediScan AI** are for educational and informational purposes only. This app is **not** a substitute for professional medical advice, diagnosis, or treatment. Always consult a certified healthcare professional before taking, changing, or discontinuing any medication.
