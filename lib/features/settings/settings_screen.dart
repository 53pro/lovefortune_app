import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/features/settings/settings_viewmodel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          // 프로필 정보 수정 섹션
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('내 정보 수정'),
            subtitle: const Text('이름, 생년월일을 수정합니다.'),
            onTap: () {
              // 내 정보 수정 화면으로 이동
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('상대방 정보 수정'),
            subtitle: const Text('상대방의 이름, 생년월일을 수정합니다.'),
            onTap: () {
              // 상대방 정보 수정 화면으로 이동
            },
          ),
          const Divider(),

          // 계정 관리 섹션
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('로그아웃'),
            onTap: () {
              // ref.read를 사용하여 ViewModel의 함수를 호출합니다.
              ref.read(settingsViewModelProvider.notifier).signOut();
              // 2. 현재 화면을 닫아 AuthWrapper가 보여주는 화면으로 돌아갑니다.
              // mounted 체크를 통해 위젯이 여전히 화면에 있는지 확인하는 것이 안전합니다.
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
