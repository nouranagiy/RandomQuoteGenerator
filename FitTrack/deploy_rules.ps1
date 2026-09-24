# Deploy Firestore Security Rules for LingoLearn/FitTrack
#
# Target project: fittrack-728fa  (confirmed via google-services.json + firebase_options.dart + .firebaserc)
#
# The Flutter code already reads/writes the profile as a DIRECT document:
#     FirebaseFirestore.instance.collection('users').doc(uid).get()  /  .set(...)
# It does NOT use a collection query, and does NOT add orderBy(__name__).
#
# The remaining PERMISSION_DENIED is because these rules are NOT yet published
# to the Firebase project. Choose ONE of the two methods below.

Write-Host ""
Write-Host "=============================="
Write-Host "Firestore Security Rules"
Write-Host "=============================="
Write-Host @'
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
'@
Write-Host ""
Write-Host "===== METHOD A (recommended, no installs) ====="
Write-Host "1. Open https://console.firebase.google.com and select project:"
Write-Host "     fittrack-728fa"
Write-Host "     (The Android app com.example.task3 uses THIS project - verified)."
Write-Host "2. Left menu -> Firestore Database -> Rules tab."
Write-Host "3. Replace ALL existing rules with the rules shown above."
Write-Host "4. Click PUBLISH."
Write-Host ""
Write-Host "===== METHOD B (Firebase CLI) ====="
Write-Host "1. Install Node.js, then:"
Write-Host "     npm install -g firebase-tools"
Write-Host "     firebase login"
Write-Host "2. Pin the project (already done via .firebaserc) and deploy:"
Write-Host "     firebase use fittrack-728fa"
Write-Host "     firebase deploy --only firestore:rules"
Write-Host ""
Write-Host "After publishing, the log will no longer show PERMISSION_DENIED,"
Write-Host "the profile at users/{uid} becomes readable/writable, and the"
Write-Host "Welcome Header loads the user's name."
