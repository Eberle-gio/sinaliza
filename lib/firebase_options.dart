import 'package:firebase_core/firebase_core.dart';

/// Configure these values with `flutterfire configure` in a real Firebase
/// project, or pass them as --dart-define values while building the web app.
class FirebaseConfig {
  // Aceita tanto o JSON copiado do Firebase quanto os nomes do exemplo antigo.
  static const apiKey = String.fromEnvironment('FIREBASE_API_KEY',
      defaultValue: String.fromEnvironment('apiKey'));
  static const appId = String.fromEnvironment('FIREBASE_APP_ID',
      defaultValue: String.fromEnvironment('appId'));
  static const messagingSenderId = String.fromEnvironment('FIREBASE_SENDER_ID',
      defaultValue: String.fromEnvironment('messagingSenderId'));
  static const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID',
      defaultValue: String.fromEnvironment('projectId'));
  static const authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN',
      defaultValue: String.fromEnvironment('authDomain'));
  static const storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: String.fromEnvironment('storageBucket'),
  );

  static bool get isConfigured =>
      apiKey.isNotEmpty && appId.isNotEmpty && projectId.isNotEmpty &&
      messagingSenderId.isNotEmpty;

  static FirebaseOptions get webOptions => FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    authDomain: authDomain.isEmpty ? null : authDomain,
    storageBucket: storageBucket.isEmpty ? null : storageBucket,
  );
}
