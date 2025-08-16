import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/features/auth/auth_providers.dart';
import 'package:lovefortune_app/features/home/home_screen.dart';
import 'package:lovefortune_app/features/settings/settings_screen.dart';
import 'package:lovefortune_app/features/tips/tips_screen.dart';

// ConsumerStatefulWidget으로 변경하여 ref에 접근하고 상태를 관리합니다.
class MainScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    TipsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    // ref.read를 통해 현재 프로필 완성 여부를 확인합니다.
    // .when을 사용하여 로딩, 데이터, 에러 상태를 모두 안전하게 처리합니다.
    final isProfileComplete = ref.read(profileCompletenessProvider).when(
      data: (isComplete) => isComplete,
      loading: () => false, // 로딩 중일 때는 프로필이 미완성된 것으로 간주합니다.
      error: (err, stack) => false, // 에러 발생 시에도 미완성으로 간주합니다.
    );

    // 프로필이 미완성이며, '내 정보' 탭(인덱스 2)이 아닌 다른 탭을 누른 경우
    if (!isProfileComplete && index != 2) {
      // 안내 메시지를 보여줍니다.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('내 정보와 상대방 정보를 먼저 입력하세요'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // 프로필이 완전하거나 '내 정보' 탭을 누른 경우, 탭을 이동합니다.
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 프로필 상태가 변경될 때 UI가 반응하도록 watch합니다.
    ref.watch(profileCompletenessProvider);

    return Scaffold(
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
        onTap: _onItemTapped,
      ),
    );
  }
}
