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
    apiKey: 'AIzaSyByliKAI_SsB7bpDHkiTnXK4-GXKit_Trg',
    authDomain: 'vclass-f6edc.firebaseapp.com',
    projectId: 'vclass-f6edc',
    storageBucket: 'vclass-f6edc.firebasestorage.app',
    messagingSenderId: '703170143570',
    appId: '1:703170143570:web:d57687f84ac10f6148068b',
    measurementId: 'G-JYMF5P61LR'
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCf_834FseWa9oDatC5trKN8R9bnkFRSBI',
    appId: '1:703170143570:web:032b67fa33a1be74636615',
    messagingSenderId: '703170143570',
    projectId: 'vclass-f6edc',
    storageBucket: 'vclass-f6edc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCf_834FseWa9oDatC5trKN8R9bnkFRSBI',
    appId: '1:703170143570:web:032b67fa33a1be74636615',
    messagingSenderId: '703170143570',
    projectId: 'vclass-f6edc',
    storageBucket: 'vclass-f6edc.firebasestorage.app',
    iosBundleId: 'com.example.classManagementSystem',
  );
}