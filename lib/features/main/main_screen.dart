import 'package:flutter/material.dart';
import 'package:lovefortune_app/features/home/home_screen.dart';
import 'package:lovefortune_app/features/settings/settings_screen.dart';
// import 'package:lovefortune_app/features/tips/tips_screen.dart'; // 관계 팁 화면 (추후 생성)

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 현재 선택된 탭의 인덱스를 저장하는 변수
  int _selectedIndex = 0;

  // 각 탭에 해당하는 화면 위젯 목록
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    // TipsScreen(), // TODO: 관계 팁 화면을 만들어 추가해야 합니다.
    Scaffold(body: Center(child: Text('관계 팁 (개발 예정)'))), // 임시 화면
    SettingsScreen(),
  ];

  // 탭이 선택되었을 때 호출되는 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack을 사용하여 탭이 전환되어도 각 화면의 상태를 유지합니다.
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            activeIcon: Icon(Icons.lightbulb),
            label: '관계 팁',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '내 정보',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF5B86E5),
        onTap: _onItemTapped,
      ),
    );
  }
}
