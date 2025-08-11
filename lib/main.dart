import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lovefortune_app/features/auth/auth_wrapper.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lovefortune_app/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lovefortune_app/core/repositories/horoscope_repository.dart';
import 'package:intl/date_symbol_data_local.dart'; // 날짜 초기화를 위해 import 합니다.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // 한국어 날짜 형식을 사용하기 위해 초기화 코드를 추가합니다.
  await initializeDateFormatting('ko_KR', null);

  final prefs = await SharedPreferences.getInstance();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ProviderScope(
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
