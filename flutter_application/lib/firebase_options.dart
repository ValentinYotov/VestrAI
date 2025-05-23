// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyBBJdINJhFxYS52k2bbz9vR0eh9bJq4MwM',
    appId: '1:321728950660:web:09f499e5d26377a373add1',
    messagingSenderId: '321728950660',
    projectId: 'vestrai-aa3a2',
    authDomain: 'vestrai-aa3a2.firebaseapp.com',
    storageBucket: 'vestrai-aa3a2.firebasestorage.app',
    measurementId: 'G-VW31PB9X4Y',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBFU_3G_y32PAoWrftEkOTz8iFyLe4-qxU',
    appId: '1:321728950660:android:871b6030b7014fce73add1',
    messagingSenderId: '321728950660',
    projectId: 'vestrai-aa3a2',
    storageBucket: 'vestrai-aa3a2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBBMPCAgpT3yoj5CtVTj_aINJgWYVVGESw',
    appId: '1:321728950660:ios:b0302a1920b2074273add1',
    messagingSenderId: '321728950660',
    projectId: 'vestrai-aa3a2',
    storageBucket: 'vestrai-aa3a2.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBBMPCAgpT3yoj5CtVTj_aINJgWYVVGESw',
    appId: '1:321728950660:ios:b0302a1920b2074273add1',
    messagingSenderId: '321728950660',
    projectId: 'vestrai-aa3a2',
    storageBucket: 'vestrai-aa3a2.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBBJdINJhFxYS52k2bbz9vR0eh9bJq4MwM',
    appId: '1:321728950660:web:9c3b3cb4dafd742d73add1',
    messagingSenderId: '321728950660',
    projectId: 'vestrai-aa3a2',
    authDomain: 'vestrai-aa3a2.firebaseapp.com',
    storageBucket: 'vestrai-aa3a2.firebasestorage.app',
    measurementId: 'G-Y7G2N0B1H1',
  );
}
