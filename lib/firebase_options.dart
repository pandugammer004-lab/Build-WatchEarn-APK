import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA9xQfWbNc1Ht99KXx5GMLIuk_wfItw9BA',
    appId: '1:461764093304:web:8651c6cbe624a08024d48d', // generic web appId, but we can use the android one if we don't have it, or just use the android one. Let's use android one if no web app exists in firebase.
    messagingSenderId: '461764093304',
    projectId: 'mobile-app-f270c',
    authDomain: 'mobile-app-f270c.firebaseapp.com',
    storageBucket: 'mobile-app-f270c.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA9xQfWbNc1Ht99KXx5GMLIuk_wfItw9BA',
    appId: '1:461764093304:android:61891c996e598d1624d48d',
    messagingSenderId: '461764093304',
    projectId: 'mobile-app-f270c',
    storageBucket: 'mobile-app-f270c.firebasestorage.app',
  );
}
