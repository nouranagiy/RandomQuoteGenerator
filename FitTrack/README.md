# FitTrack - Fitness Tracker

A modern, professional fitness tracking app built with Flutter and Firebase.

## Features

- **Authentication**: Splash → Onboarding → Sign Up / Login → Home flow
- **Firebase Auth + Firestore**: User profiles stored at `users/{uid}`
- **Localization**: English and Arabic with RTL support
- **Themes**: Light, Dark, and System default modes (persisted)
- **Fitness Tracking**: Steps, calories, workout duration, activity detection
- **Weekly Progress**: 7-day bar chart and daily summaries
- **Activity Log**: Add, edit, delete, and view activities

## Architecture

```
lib/
├── core/                 # Cross-cutting infrastructure
│   ├── constants/        # Design tokens (spacing, radius, colors)
│   ├── localization/     # Locale management
│   ├── router/           # Centralized navigation
│   └── theme/            # Material 3 theme system
├── features/             # Feature-based modules
│   ├── auth/
│   │   ├── data/         # AuthService (Firebase)
│   │   └── presentation/ # Login, SignUp, Splash, Onboarding
│   ├── activity/
│   │   └── presentation/ # Add, Edit, History, Weekly screens
│   ├── home/
│   │   └── presentation/ # Home, Settings
│   └── profile/
│       └── data/         # UserModel, ProfileProvider
├── models/               # Data models
├── services/             # Legacy services (step counter, storage, sensors)
├── widgets/              # Reusable components
└── generated/           # Generated localization files
```

## Firebase Configuration (REQUIRED)

The app requires Firebase setup to run. Follow these steps:

1. **Create a Firebase project** at https://console.firebase.google.com/

2. **Add your Flutter apps:**
   - Android: package name `com.example.task3`
   - iOS: bundle ID `com.example.task3`

3. **Enable Authentication:**
   - Go to Authentication → Sign-in method → Enable Email/Password

4. **Configure Firestore:**
   - Create Firestore database
   - Deploy the `firestore.rules` file (see **Deploying Security Rules** below).

## Deploying Security Rules (fixes `PERMISSION_DENIED`)

If Sign Up succeeds but profile/welcome fails with
`PERMISSION_DENIED: Missing or insufficient permissions` on `users/{uid}`,
the Firestore security rules have **not been published** to the project yet.

> **Note about the log:** the message
> `Listen for Query(target=Query(users/<uid>...)) failed: PERMISSION_DENIED`
> is normal cloud_firestore internal logging — even a direct single-document
> read (`collection('users').doc(uid).get()`) is implemented as an internal
> listen. The app does **not** use a collection query and does **not** add
> `orderBy(__name__)`. The error means the published rules reject the read,
> i.e. the rules below are not live yet. Run `deploy_rules.ps1` for a summary.

The rules live in `firestore.rules` (wired in `firebase.json` and pinned to
project `fittrack-728fa` in `.firebaserc`) but must be published to Firebase:

**Option A — Firebase CLI:**
```bash
# Install the CLI (requires Node.js): npm install -g firebase-tools
firebase login
firebase use fittrack-728fa
firebase deploy --only firestore:rules
```

**Option B — Firebase Console (no installs needed):**
1. Open https://console.firebase.google.com and select project `fittrack-728fa`
2. Go to **Firestore Database → Rules** tab
3. Replace the editor contents with the exact contents of `firestore.rules`
4. Click **Publish**

The rules allow each signed-in user to read/write **only their own** document:

```text
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

The database is **not** left public, and no `allow ... : if true` is used.

5. **Generate config files with FlutterFire CLI:**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli

   # Generate firebase_options.dart
   flutterfire configure
   ```

6. **Android configuration:**
   - Download `google-services.json` from Project Settings
   - Place it in `android/app/google-services.json`

7. **iOS configuration:**
   - Download `GoogleService-Info.plist` from Project Settings
   - Place it in `ios/Runner/GoogleService-Info.plist`

8. **Run the app:**
   ```bash
   flutter run
   ```

## Security Rules

Firestore security rules are in `firestore.rules`. Users can only read/write their own profile document at `users/{uid}`.

## Theme

- Light/Dark/System modes with a professional green-based Material 3 palette
- Persisted across sessions via SharedPreferences
- RTL support for Arabic

## Localization

- English and Arabic via ARB files in `l10n/`
- Language switcher in Settings screen
- Locale persisted across sessions

## State Management

Uses `provider` package for:
- `LocaleProvider` - locale management
- `ProfileProvider` - Firebase user profile
- `ThemeModeManager` - theme mode

## Development

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter run
```