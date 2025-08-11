import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/features/settings/partner_list_screen.dart';
import 'package:lovefortune_app/features/settings/profile_edit_screen.dart';
import 'package:lovefortune_app/features/settings/settings_viewmodel.dart';
import 'package:lovefortune_app/core/theme/app_theme.dart';

// StatefulWidget에서 간단한 ConsumerWidget으로 변경합니다.
// 이제 ViewModel이 스스로 데이터를 불러오므로, UI에서 initState를 사용할 필요가 없습니다.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsViewModelProvider);
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    final myProfile = settingsState.myProfile;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보'),
      ),
      body: RefreshIndicator(
        // 화면을 아래로 당겨서 데이터를 새로고침하는 기능은 그대로 유지합니다.
        onRefresh: () => viewModel.loadProfileData(),
        child: settingsState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 20),
            _buildSectionTitle('계정 정보'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: ListTile(
                leading: const Icon(Icons.email_outlined, color: AppTheme.primaryColor),
                title: const Text('이메일'),
                subtitle: Text(user?.email ?? '로그인 정보 없음'),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('프로필 관리'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('내 정보 수정'),
                    subtitle: Text(myProfile?.nickname ?? '애칭을 등록해주세요.'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileEditScreen(
                            profileType: ProfileType.me,
                            profile: myProfile,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.favorite_border),
                    title: const Text('상대방 정보 관리'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PartnerListScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('앱 정보'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('앱 버전'),
                    trailing: Text('1.0.0'),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppTheme.accentColor),
                    title: const Text('로그아웃', style: TextStyle(color: AppTheme.accentColor)),
                    onTap: () async {
                      await ref.read(settingsViewModelProvider.notifier).signOut();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
