import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/features/auth/auth_providers.dart'; // 새로 만든 provider 파일 import
import 'package:lovefortune_app/features/auth/auth_screen.dart';
import 'package:lovefortune_app/features/main/main_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          // 사용자가 로그인했다면, 프로필 완성 여부를 확인하는 화면으로 이동합니다.
          return const ProfileGate();
        } else {
          // 로그아웃 상태이면 로그인 화면을 보여줍니다.
          return const AuthScreen();
        }
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(body: Center(child: Text('오류가 발생했습니다: $error'))),
    );
  }
}

// 프로필 완성 여부에 따라 화면을 분기하는 새로운 위젯
class ProfileGate extends ConsumerWidget {
  const ProfileGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileCompleteness = ref.watch(profileCompletenessProvider);

    return profileCompleteness.when(
      data: (isComplete) {
        if (isComplete) {
          // 프로필이 완전하면 홈(0) 탭으로 시작하는 메인 화면을 보여줍니다.
          return const MainScreen(initialIndex: 0);
        } else {
          // 프로필이 불완전하면 내 정보(2) 탭으로 시작하는 메인 화면을 보여줍니다.
          return const MainScreen(initialIndex: 2);
        }
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(body: Center(child: Text('프로필 확인 중 오류: $error'))),
    );
  }
}
