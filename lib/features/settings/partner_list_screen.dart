import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/theme/app_theme.dart';
import 'package:lovefortune_app/features/settings/profile_edit_screen.dart';
import 'package:lovefortune_app/features/settings/settings_viewmodel.dart';
import 'package:intl/intl.dart';

// 편집 모드를 관리하기 위해 StatefulWidget으로 변경합니다.
class PartnerListScreen extends ConsumerStatefulWidget {
  const PartnerListScreen({super.key});

  @override
  ConsumerState<PartnerListScreen> createState() => _PartnerListScreenState();
}

class _PartnerListScreenState extends ConsumerState<PartnerListScreen> {
  // 편집 모드 상태를 관리하는 변수
  bool _isEditMode = false;

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsViewModelProvider);
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    final partners = settingsState.partners;
    final selectedPartnerId = settingsState.selectedPartnerId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('상대방 정보 관리'),
        actions: [
          // 파트너가 있을 경우에만 '편집' 버튼을 보여줍니다.
          if (partners.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditMode = !_isEditMode;
                });
              },
              child: Text(_isEditMode ? '완료' : '편집'),
            ),
        ],
      ),
      body: partners.isEmpty
          ? const Center(
        child: Text(
          '등록된 상대방 정보가 없습니다.\n아래 + 버튼을 눌러 추가해주세요.',
          textAlign: TextAlign.center,
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: partners.length,
        itemBuilder: (context, index) {
          final partner = partners[index];
          final isSelected = partner.id == selectedPartnerId;

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
              leading: _isEditMode
              // 편집 모드일 때 보여줄 삭제 버튼
                  ? IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('삭제 확인'),
                      content: Text("'${partner.nickname}' 님을 목록에서 삭제하시겠습니까?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    viewModel.deletePartner(partner.id);
                  }
                },
              )
              // 일반 모드일 때 보여줄 프로필 아바타
                  : CircleAvatar(
                backgroundColor: isSelected ? AppTheme.primaryColor : Colors.grey[300],
                child: Text(
                  partner.nickname.isNotEmpty ? partner.nickname[0] : '?',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                partner.nickname,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(DateFormat('yyyy년 MM월 dd일').format(partner.birthdate)),
              trailing: isSelected && !_isEditMode
                  ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
                  : const Icon(Icons.radio_button_unchecked, color: Colors.transparent), // 편집 모드일 때는 선택 표시 숨김
              onTap: () {
                if (!_isEditMode) {
                  // 일반 모드에서만 파트너 선택 가능
                  viewModel.setSelectedPartner(partner.id);
                }
              },
              onLongPress: () {
                // 길게 눌러서 수정 화면으로 이동
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfileEditScreen(
                      profileType: ProfileType.partner,
                      profile: partner,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
