// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC5sxVH8lGMW5HDjuSuLiXlz-6lY0wpgHc',
    appId: '1:376054658245:android:cc58fedeff9c944e2cecac',
    messagingSenderId: '376054658245',
    projectId: 'blelist',
    storageBucket: 'blelist.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDG3T396OXMlhHVDQ9A6htK8Rt-AwNnob4',
    appId: '1:376054658245:ios:d757e414ea2379572cecac',
    messagingSenderId: '376054658245',
    projectId: 'blelist',
    storageBucket: 'blelist.appspot.com',
    iosClientId: '376054658245-no14mfbqfaod88o3sajtni5s0i7g1kuo.apps.googleusercontent.com',
    iosBundleId: 'com.gadgeon.bleList',
  );
}
