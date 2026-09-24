# Flashcard Quiz App

A simple and user-friendly Flashcard Quiz App built with Flutter.

## 📱 Project Overview

The Flashcard Quiz App is a learning application that helps users create, organize, and review flashcards. Users can study questions and answers, organize cards into categories, and test their knowledge using an interactive quiz mode. The app supports authentication, cloud sync, and both English and Arabic languages.

## ✨ Features

* Create new flashcards
* Edit existing flashcards
* Delete flashcards
* View questions and answers
* Show answer functionality
* Navigate between flashcards using Previous and Next
* Organize flashcards by categories
* Favorite flashcards
* Interactive Quiz Mode
* Multiple-choice quiz questions
* Automatic answer validation
* Quiz progress indicator
* Score and percentage calculation
* Try Again option
* Secure user authentication (sign up, login, logout)
* Cloud sync with Firebase Cloud Firestore
* Light Mode and Dark Mode
* English and Arabic localization
* Clean and responsive user interface

## 🛠️ Technologies Used

* Flutter & Dart
* Material Design
* Firebase Authentication
* Firebase Cloud Firestore
* SharedPreferences for local preferences
* Flutter Localizations (English / Arabic)
* State Management (StatefulWidget)
* Navigation

## 📂 Project Structure

```text
lib/
├── core/
│   ├── constants/
│   ├── localization/
│   ├── models/
│   ├── services/
│   ├── theme/
│   └── utils/
│
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       ├── screens/
│   │       └── widgets/
│   ├── flashcard/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── screens/
│   │       └── widgets/
│   ├── home/
│   │   └── presentation/
│   │       ├── home_screen.dart
│   │       └── widgets/
│   └── splash/
│       └── presentation/
│           ├── onboarding_screen.dart
│           └── splash_screen.dart
│
├── widgets/
│   ├── app_header.dart
│   ├── confirm_dialog.dart
│   ├── empty_state_widget.dart
│   ├── flashcard_widget.dart
│   ├── loading_button.dart
│   └── welcome_header.dart
│
└── main.dart
```

## 🚀 How to Run

### Prerequisites

Make sure you have:

* Flutter SDK installed
* Dart SDK
* Android Studio or Visual Studio Code
* An Android emulator or physical Android device

### Installation

Clone the repository:

```bash
git clone https://github.com/nouranagiy/FlashcardQuizApp.git
```

Open the project:

```bash
cd FlashcardQuizApp
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

> **Note:** authentication and data sync require a valid Firebase project. Add your own `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) and run `flutterfire configure` to regenerate `lib/firebase_options.dart`.

## 📌 Task Requirements Covered

* Flashcards with questions and answers
* Show Answer functionality
* Previous and Next navigation
* Add flashcards
* Edit flashcards
* Delete flashcards
* Clean and simple user interface

Additional features were implemented to improve the learning experience, including categories, favorites, cloud storage, dark mode, and an interactive quiz system.

## 👩‍💻 Developer

**Nora Nagiy**

Information Systems Graduate | Flutter Developer

## 📄 License

This project was developed for educational.