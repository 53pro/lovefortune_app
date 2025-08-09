import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/theme/app_theme.dart';
import 'package:lovefortune_app/features/settings/profile_edit_screen.dart';

class PartnerListScreen extends ConsumerWidget {
  const PartnerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: ViewModel에서 파트너 목록 데이터를 불러와야 합니다.
    final partners = [
      {'nickname': '자기', 'birthdate': '1995년 5월 15일', 'isSelected': true},
      {'nickname': '애기', 'birthdate': '1996년 8월 20일', 'isSelected': false},
      {'nickname': '코딩이', 'birthdate': '1992년 1월 1일', 'isSelected': false},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('상대방 정보 관리'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: partners.length,
        itemBuilder: (context, index) {
          final partner = partners[index];
          final isSelected = partner['isSelected'] as bool;

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Theme.of(context).dividerColor,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: CircleAvatar(
                backgroundColor: isSelected ? AppTheme.primaryColor : Colors.grey[300],
                child: Text(
                  // Object 타입을 String으로 명시적으로 캐스팅합니다.
                  (partner['nickname'] as String)[0],
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                // Object 타입을 String으로 명시적으로 캐스팅합니다.
                partner['nickname'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(partner['birthdate'] as String), // Object 타입을 String으로 명시적으로 캐스팅합니다.
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
                  : const Icon(Icons.radio_button_unchecked),
              onTap: () {
                // TODO: ViewModel을 통해 현재 선택된 파트너를 변경하는 로직
              },
              onLongPress: () {
                // 길게 눌러서 수정 화면으로 이동
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileEditScreen(profileType: ProfileType.partner),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 새로운 파트너를 추가하기 위해 ProfileEditScreen으로 이동
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ProfileEditScreen(profileType: ProfileType.partner),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
