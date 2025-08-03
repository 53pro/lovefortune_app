import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lovefortune_app/features/auth/auth_wrapper.dart';
// FlutterFire CLI로 생성된 파일을 import 합니다.
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // .env 라이브러리 import

void main() async {
  // runApp을 실행하기 전에 Flutter 엔진과 위젯 바인딩이 준비되었는지 확인합니다.
  // Firebase.initializeApp()과 같은 비동기 작업을 수행하기 위해 필수적입니다.
  WidgetsFlutterBinding.ensureInitialized();
  // .env 파일을 로드합니다.
  await dotenv.load(fileName: ".env");
  // Firebase 서비스를 사용하기 위해 앱을 초기화합니다.
  // 이 코드가 활성화되어야 Firebase 관련 기능이 정상적으로 동작합니다.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(
    // Riverpod 상태 관리를 앱 전체에서 사용하기 위해
    // 최상위 위젯을 ProviderScope로 감싸줍니다.
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '오늘 우리는',
      // 디버그 모드에서 화면 우측 상단에 표시되는 "DEBUG" 배너를 제거합니다.
      debugShowCheckedModeBanner: false,
      // 앱의 전체적인 디자인 테마를 설정합니다.
      theme: ThemeData(
        // 우리가 디자인한 화이트 테마를 적용합니다.
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF212121), // 아이콘 및 텍스트 색상
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF212121),
          ),
        ),
        // Pretendard 폰트를 기본으로 설정합니다. (추후 폰트 파일 추가 필요)
        // fontFamily: 'Pretendard',
        useMaterial3: true,
      ),
      // 앱이 처음 실행될 때 보여줄 화면을 지정합니다.
      home: const AuthWrapper(),
    );
  }
}
