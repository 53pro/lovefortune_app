import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/features/auth/auth_providers.dart';
import 'package:lovefortune_app/features/personality/personality_screen.dart';
import 'package:lovefortune_app/features/today_us/today_us_screen.dart';
import 'package:lovefortune_app/features/love_counseling/views/love_counseling_screen.dart';
import 'package:lovefortune_app/features/settings/settings_screen.dart';
import 'package:lovefortune_app/features/tips/tips_screen.dart';
import 'package:lovefortune_app/features/today_us/today_us_viewmodel.dart';
import 'package:lovefortune_app/utils/dialogs.dart';

// 앱 전체에서 현재 선택된 탭 인덱스를 관리하는 Provider
final mainScreenIndexProvider = StateProvider<int>((ref) => 0);

const List<Widget> _widgetOptions = <Widget>[
  PersonalityScreen(),
  TodayUsScreen(),
  LoveCounselingScreen(),
  TipsScreen(),
  SettingsScreen(),
];

class MainScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 1. Provider의 초기값을 '단 한 번만' 설정합니다.
      if (ref.read(mainScreenIndexProvider) != widget.initialIndex) {
        ref.read(mainScreenIndexProvider.notifier).state = widget.initialIndex;
      }

      // 2. 프로필 정보가 완전한 경우, '오늘우리' 탭의 데이터를 미리 불러옵니다.
      final isProfileComplete = ref.read(profileCompletenessProvider).value ?? false;
      if (isProfileComplete) {
        ref.read(todayUsViewModelProvider.notifier).fetchHoroscope();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(mainScreenIndexProvider);
    final isProfileComplete = ref.watch(profileCompletenessProvider).value ?? false;

    void onItemTapped(int index) {
      if (!isProfileComplete && index != 4) {
        // SnackBar 대신 공용 팝업 함수를 호출합니다.
        showProfileNeededPopup(context, ref);
      } else {
        ref.read(mainScreenIndexProvider.notifier).state = index;
      }
    }

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite_rounded),
            label: '오늘우리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum_outlined),
            activeIcon: Icon(Icons.forum_rounded),
            label: '대나무숲',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories_outlined),
            activeIcon: Icon(Icons.auto_stories_rounded),
            label: '관계 팁',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face_outlined),
            activeIcon: Icon(Icons.face_rounded),
            label: '내 정보',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }
}
