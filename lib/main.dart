import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lovefortune_app/features/auth/auth_wrapper.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lovefortune_app/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lovefortune_app/core/repositories/horoscope_repository.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // 로컬라이제이션 import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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
      title: '오늘우리는',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // --- 한글 설정을 추가합니다 ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어
        // TODO: 향후 지원할 다른 언어들을 여기에 추가할 수 있습니다. (예: Locale('en', 'US'))
      ],
      locale: const Locale('ko'), // 앱의 기본 언어를 한국어로 설정
      // --------------------------

      home: const AuthWrapper(),
    );
  }
}
