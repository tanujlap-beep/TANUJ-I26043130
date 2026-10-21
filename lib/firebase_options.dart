// File generated or configured for Firebase integration
// SIST University Student Hub
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your SIST Student Hub app.
///
/// Replace these credentials with your actual project keys from:
/// https://console.firebase.google.com -> Project Settings -> General -> Your apps
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        return web;
    }
  }

  // Web & Default Platform Configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoStudentHubKey2026SISTPlatform',
    appId: '1:108429381029:web:78fa98cd123456789',
    messagingSenderId: '108429381029',
    projectId: 'sist-student-hub-2026',
    authDomain: 'sist-student-hub-2026.firebaseapp.com',
    storageBucket: 'sist-student-hub-2026.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoStudentHubKey2026SISTAndroid',
    appId: '1:108429381029:android:4321ba9876543210',
    messagingSenderId: '108429381029',
    projectId: 'sist-student-hub-2026',
    storageBucket: 'sist-student-hub-2026.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoStudentHubKey2026SISTApple',
    appId: '1:108429381029:ios:9876ba5432101234',
    messagingSenderId: '108429381029',
    projectId: 'sist-student-hub-2026',
    storageBucket: 'sist-student-hub-2026.appspot.com',
    iosBundleId: 'com.sist.studenthub',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDemoStudentHubKey2026SISTWindows',
    appId: '1:108429381029:web:windowsClient1234567',
    messagingSenderId: '108429381029',
    projectId: 'sist-student-hub-2026',
    authDomain: 'sist-student-hub-2026.firebaseapp.com',
    storageBucket: 'sist-student-hub-2026.appspot.com',
  );
}
