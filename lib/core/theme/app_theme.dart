import 'package:flutter/material.dart';

// 앱의 전체적인 디자인 시스템을 관리하는 클래스입니다.
class AppTheme {
  // 라이트 테마 정의
  static final ThemeData lightTheme = ThemeData(
    // 기본 배경색
    scaffoldBackgroundColor: const Color(0xFFF7F8FA),
    // 앱 바 테마
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
    // 하단 네비게이션 바 테마
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFF5B86E5), // 선택된 아이템 색상 (소프트 블루)
      unselectedItemColor: Color(0xFF757575), // 비선택 아이템 색상 (미디엄 그레이)
      backgroundColor: Colors.white,
      elevation: 0,
    ),
    // Pretendard 폰트를 기본으로 설정합니다. (추후 폰트 파일 추가 필요)
    // fontFamily: 'Pretendard',
    useMaterial3: true,
  );

  // 자주 사용하는 색상을 쉽게 가져다 쓸 수 있도록 상수로 정의합니다.
  static const Color primaryColor = Color(0xFF5B86E5);
  static const Color accentColor = Color(0xFFFF8A8A);
}
