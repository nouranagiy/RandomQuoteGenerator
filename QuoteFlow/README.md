# QuoteFlow

A modern Flutter quote application with authentication, favorites, localization, and a resilient startup flow.

## 📱 Project Overview

QuoteFlow displays inspirational quotes, lets users sign in, save favorites, copy quotes, and switch between Light and Dark modes. The app is localized for English and Arabic, uses a responsive navigation shell, and recovers gracefully from startup failures.

## ✨ Features

- Splash startup with a minimum display duration and automatic retry on failure
- Onboarding flow for first launch
- Authentication with email/password sign-in and sign-up
- Localized quote display in English and Arabic
- New quote generation
- Favorite management with failure handling and rollback
- Copy quotes to the clipboard
- Settings with theme and locale preferences
- Responsive shell with navigation rail on larger screens and a bottom navigation bar on compact screens
- Accessibility-aware layout and RTL support

## 🛠️ Technologies Used

- Flutter and Dart
- Material Design 3
- Firebase Authentication and Cloud Firestore
- Provider for state management
- SharedPreferences for local preferences
- Flutter Localizations for English and Arabic support

## 📂 Project Structure

```text
lib/
├── core/
│   ├── bootstrap.dart
│   ├── constants/
│   ├── localization/
│   ├── routing/
│   ├── theme/
│   └── utils/
├── features/
│   ├── auth/
│   ├── favorites/
│   ├── home/
│   ├── onboarding/
│   ├── settings/
│   ├── shell/
│   └── splash/
├── models/
├── shared/
│   ├── providers/
│   └── widgets/
├── main.dart
|── app.dart
└── firebase_options.dart
assets/
└── fonts/
test/
```

## 🚀 How to Run

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- An Android emulator or physical device

### Installation

```bash
flutter pub get
flutter run
```

## 📌 Requirements Covered

- Random quote displayed when opening the application
- New Quote button
- Different quote on each request
- Quote text and author displayed clearly
- Clean and user-friendly interface

Additional implemented features include authentication, favorites, clipboard copying, local preference storage, Light/Dark mode, localization, and startup error recovery.

## 👩‍💻 Developer

**Nora Nagiy**

Information Systems Graduate | Flutter Developer

## 📄 License

This project was developed for educational purposes.
