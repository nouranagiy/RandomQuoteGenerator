# CodeAlpha Fitness Tracker App

A simple and user-friendly Fitness Tracker App built with Flutter as part of the CodeAlpha App Development Internship.

## 📱 Project Overview

The Fitness Tracker App is a fitness tracking application that helps users monitor their daily physical activities and track their fitness progress. Users can record activities manually, track steps automatically, monitor calories and workout duration, and review their daily and weekly progress.

## ✨ Features

* Track daily steps
* Automatic step counting using device sensors
* Automatic activity detection
* Add fitness activities manually
* Select activity type
* Edit existing activities
* Delete activities
* View activity history
* Track workout duration
* Track calories burned
* Daily fitness dashboard
* Daily progress indicators
* Weekly progress tracking
* Weekly activity summary
* Daily steps chart
* Local data storage
* Light Mode and Dark Mode
* Clean and responsive user interface

## 🏃 Activity Types

The app supports different fitness activities:

* Walking
* Running
* Cycling
* Gym
* Swimming
* Yoga
* Other

## 🛠️ Technologies Used

* Flutter
* Dart
* Material Design
* SharedPreferences
* Pedometer
* UUID
* StatefulWidget
* Navigation
* Custom Widgets

## 📂 Project Structure

```text
lib/
├── models/
│   └── fitness_entry.dart
│
├── screens/
│   ├── home_screen.dart
│   ├── add_activity_screen.dart
│   ├── edit_activity_screen.dart
│   ├── activity_history_screen.dart
│   └── weekly_progress_screen.dart
│
├── services/
│   ├── fitness_storage.dart
│   ├── step_counter_service.dart
│   └── activity_recognition_service.dart
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
git clone https://github.com/nouranagiy/CodeAlpha_FitnessTracker.git
```

Open the project:

```bash
cd CodeAlpha_FitnessTracker
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

## 📱 Automatic Step Counting

The application uses the device's pedometer sensor to track steps automatically.

For the best experience, it is recommended to run the application on a physical Android device that supports step counting.

## 🎯 Internship Task

This project was developed as **Task 3: Fitness Tracker App** for the CodeAlpha App Development Internship.

## 📌 Task Requirements Covered

* Track daily fitness activities
* Track steps
* Track workouts
* Track calories burned
* Add and log fitness data manually
* Daily progress dashboard
* Weekly progress summary
* Visual progress chart
* Local data storage
* Simple and user-friendly interface

Additional features were implemented to improve the fitness tracking experience, including automatic step counting, activity detection, activity history, editing and deleting activities, activity types, and dark mode.

## 👩‍💻 Developer

**Nora Nagy**

Information Systems Graduate | Flutter Developer

## 📄 License

This project was developed for educational and internship purposes.
