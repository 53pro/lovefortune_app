import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lovefortune_app/features/auth/auth_wrapper.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lovefortune_app/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences import
import 'package:lovefortune_app/core/repositories/horoscope_repository.dart'; // Provider를 override하기 위해 import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // SharedPreferences 인스턴스를 앱 시작 전에 미리 로드합니다.
  final prefs = await SharedPreferences.getInstance();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ProviderScope(
      // overrides를 사용하여 sharedPreferencesProvider의 값을
      // 미리 로드한 인스턴스로 지정합니다.
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '오늘 우리는',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}
