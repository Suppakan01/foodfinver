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
    apiKey: 'AIzaSyCrH7nUrJOs1YWOSqGUkXS2xoSgY2KjU9c',
    appId: '1:189589604839:android:4799f14d46349ec4bb5542',
    messagingSenderId: '189589604839',
    projectId: 'projectfood-bb05e',
    authDomain: 'projectfood-bb05e.firebaseapp.com',
    storageBucket: 'projectfood-bb05e.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey:
        'AIzaSyCrH7nUrJOs1YWOSqGUkXS2xoSgY2KjU9c', // ค้นหาได้จาก google-services.json
    appId: '1:189589604839:android:4799f14d46349ec4bb5542', // จากรูปที่ 2
    messagingSenderId: '189589604839',
    projectId: 'projectfood-bb05e',
    storageBucket: 'projectfood-bb05e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCrH7nUrJOs1YWOSqGUkXS2xoSgY2KjU9c',
    appId: '1:189589604839:android:4799f14d46349ec4bb5542',
    messagingSenderId: '189589604839',
    projectId: 'projectfood-bb05e',
    storageBucket: 'projectfood-bb05e.firebasestorage.app',
    iosBundleId: 'com.example.foodfinver',
  );
}
