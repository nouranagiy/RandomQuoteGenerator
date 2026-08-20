# CodeAlpha Language Learning App
A simple and user-friendly Language Learning App built with Flutter as part of the CodeAlpha App Development Internship.
📱 Project Overview
The Language Learning App is a language learning application that helps users learn new words and phrases in a foreign language. Users can browse vocabulary by category, add their own words, save favorites, mark words as learned, and test their knowledge through interactive quizzes.
✨ Features

* Vocabulary library with translations
* Pronunciation guide for each word
* Example sentences for each word
* Words organized by category
* Add new words manually
* Select word category
* Edit existing words
* Delete words
* View favorite words list
* Mark words as favorites
* Mark words as learned
* Interactive multiple-choice quizzes
* Select quiz category
* Select quiz length
* Track best and last quiz scores
* Daily learning progress dashboard
* Learning progress indicators
* Word count by category
* Onboarding screen for first-time users
* Local data storage
* Light Mode and Dark Mode
* Clean and responsive user interface

🗂️ Word Categories
The app supports different word categories:

* Greetings
* Common Words
* Education
* Food & Drinks
* Time
* Other (custom categories added by the user)

🛠️ Technologies Used

* Flutter
* Dart
* Material Design
* SharedPreferences
* UUID
* StatefulWidget
* Navigation
* Custom Widgets

📂 Project Structure

```text
lib/
├── models/
│   └── language_word.dart
│
├── screens/
│   ├── home_screen.dart
│   ├── add_word_screen.dart
│   ├── edit_word_screen.dart
│   ├── vocabulary_screen.dart
│   ├── favorites_screen.dart
│   └── quiz_screen.dart
│
├── services/
│   └── language_storage.dart
│
└── main.dart

```

🚀 How to Run
Prerequisites
Make sure you have:

* Flutter SDK installed
* Dart SDK
* Android Studio or Visual Studio Code
* An Android emulator or physical Android device

Installation
Clone the repository:

```bash
git clone https://github.com/nouranagiy/CodeAlpha_LingoLearn.git

```

Open the project:

```bash
cd CodeAlpha_LingoLearn

```

Install dependencies:

```bash
flutter pub get

```

Run the application:

```bash
flutter run

```

📱 Learning Data
The application stores vocabulary, favorites, learned status, and quiz results locally on the device using SharedPreferences.
Data remains saved between sessions and can be edited or reset at any time from the Settings screen.
🎯 Internship Task
This project was developed as Task 4: Language Learning App for the CodeAlpha App Development Internship.
📌 Task Requirements Covered

* Help users learn new words and phrases in a selected language
* Daily lessons and flashcards with translations and pronunciations
* Quizzes to check learning progress
* Clean and intuitive UI
* Categories for vocabulary
* Local data storage

Additional features were implemented to improve the learning experience, including favorites, learned-word tracking, adjustable quiz length, quiz score history, an onboarding flow, and dark mode.

👩‍💻 Developer

Nora Nagy

Information Systems Graduate | Flutter Developer

📄 License

This project was developed for educational and internship purposes.
