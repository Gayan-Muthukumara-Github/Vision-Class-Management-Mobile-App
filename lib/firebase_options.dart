import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAXw_ri6wzacwM0dPahk8eV0QSNwPm5dzY',
    authDomain: 'vclass-98af2.firebaseapp.com',
    projectId: 'vclass-98af2',
    storageBucket: 'vclass-98af2.firebasestorage.app',
    messagingSenderId: '326560189072',
    appId: '1:326560189072:web:032b67fa33a1be74636615',
    measurementId: 'G-1PTPLVMC5E',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAXw_ri6wzacwM0dPahk8eV0QSNwPm5dzY',
    appId: '1:326560189072:android:YOUR_ANDROID_APP_ID',
    messagingSenderId: '326560189072',
    projectId: 'vclass-98af2',
    storageBucket: 'vclass-98af2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAXw_ri6wzacwM0dPahk8eV0QSNwPm5dzY',
    appId: '1:326560189072:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '326560189072',
    projectId: 'vclass-98af2',
    storageBucket: 'vclass-98af2.firebasestorage.app',
    iosBundleId: 'com.example.classManagementSystem',
  );
}