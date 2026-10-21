# 🎓 SIST University — Student Hub

An intelligent, cross-platform campus super-app built with **Flutter** & **Firebase**. Designed to streamline university student life, academic tracking, services, and online enrollment.

### 🌐 [Click Here to Open the Live App](https://tanujlap-beep.github.io/TANUJ-I26043130/)
> **Live Web Deployment**: [https://tanujlap-beep.github.io/TANUJ-I26043130/](https://tanujlap-beep.github.io/TANUJ-I26043130/)  
> Tap or click the link above to instantly launch the live interactive app directly in your browser without any installation!

![Live Demo](https://img.shields.io/badge/Demo-Live%20Web%20App-brightgreen?style=for-the-badge&logo=googlechrome&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Ready-FFCA28?logo=firebase&logoColor=black)
![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Android%20%7C%20iOS%20%7C%20Desktop-4CAF50)

---

## 🌟 Key Features

- **🏛️ Interactive Campus Dashboard**: Explore academic services, university departments, research centers, and real-time events.
- **📝 Student Registration & Enrollment Portal (`student_form.dart`)**:
  - Multi-step student profile onboarding.
  - Degree program selection, semester tracker, and scholarship eligibility.
  - Comprehensive form validation and dynamic GPA calculator.
- **🔥 Firebase Integration (`firebase_service.dart`)**:
  - Live Firestore data synchronization for student records.
  - Offline-first resilience with graceful fallback mock mode for local testing.
  - Ready-to-configure Firebase Authentication and Cloud Storage.
- **🎨 Modern Material 3 & Glassmorphism Design**:
  - Adaptive layout for Web, Mobile, and Desktop form factors.
  - Rich dynamic themes (Emerald Forest, Royal Indigo, Cyber Dark).
- **🧪 Test Coverage**: Automated unit and widget tests for student form validation and interface stability.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.0+)
- [Dart SDK](https://dart.dev/get-dart)
- An IDE (VS Code, Android Studio, or IntelliJ)

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/tanujlap-beep/TANUJ-I26043130.git
   cd TANUJ-I26043130
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   - On Chrome / Web:
     ```bash
     flutter run -d chrome
     ```
   - On Windows:
     ```bash
     flutter run -d windows
     ```
   - On Mobile / Emulator:
     ```bash
     flutter run
     ```

4. **Run Automated Tests:**
   ```bash
   flutter test
   ```

---

## 📁 Project Architecture

```
lib/
├── firebase_options.dart   # Multi-platform Firebase configuration
├── firebase_service.dart   # Firestore sync & fallback offline manager
├── student_form.dart       # Student onboarding & enrollment portal
└── main.dart               # Main app router, dashboard, campus services, & themes
test/
├── student_form_test.dart  # Form validation & widget tests
└── widget_test.dart        # General smoke tests
assets/
└── images/                 # Campus heroes, lab visuals, & facility photos
```

---

## 🔐 Firebase Setup (Optional)

To connect your own Firebase project:
1. Create a Firebase project in the [Firebase Console](https://console.firebase.google.com).
2. Enable **Firestore Database** and **Firebase Authentication**.
3. Replace the placeholder keys in [lib/firebase_options.dart](file:///lib/firebase_options.dart) with your credentials or run:
   ```bash
   flutterfire configure
   ```

---

## 📄 License
Licensed under the [MIT License](LICENSE).

