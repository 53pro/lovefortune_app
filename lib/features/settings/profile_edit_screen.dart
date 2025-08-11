import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/theme/app_theme.dart';
import 'package:lovefortune_app/features/settings/settings_viewmodel.dart';
import 'package:lovefortune_app/core/models/profile_model.dart';

enum ProfileType { me, partner }

class ProfileEditScreen extends ConsumerStatefulWidget {
  final ProfileType profileType;
  final ProfileModel? profile;

  const ProfileEditScreen({
    super.key,
    required this.profileType,
    this.profile,
  });

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _nicknameController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.profile != null) {
      _nicknameController.text = widget.profile!.nickname;
      _selectedDate = widget.profile!.birthdate;
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      // 초기 날짜를 '선택된 날짜' 또는 '오늘로부터 20년 전'으로 설정합니다.
      initialDate: _selectedDate ?? DateTime(DateTime.now().year - 20, DateTime.now().month, DateTime.now().day),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveProfile() {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 정보를 입력해주세요.')),
      );
      return;
    }

    final viewModel = ref.read(settingsViewModelProvider.notifier);
    if (widget.profileType == ProfileType.me) {
      viewModel.updateMyProfile(nickname, _selectedDate!);
    } else {
      if (widget.profile != null) {
        final updatedPartner = ProfileModel(
          id: widget.profile!.id,
          nickname: nickname,
          birthdate: _selectedDate!,
        );
        viewModel.updatePartner(updatedPartner);
      } else {
        viewModel.addPartner(nickname, _selectedDate!);
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.profileType == ProfileType.me;
    final title = isMe ? '내 정보 수정' : (widget.profile != null ? '상대방 정보 수정' : '상대방 정보 추가');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // --- 이미지 선택 UI 주석 처리 ---
              /*
              Center(
                child: GestureDetector(
                  onTap: () {
                    final viewModel = ref.read(settingsViewModelProvider.notifier);
                    viewModel.pickAndUploadImage(widget.profileType, partnerId: widget.profile?.id);
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: widget.profile?.imageUrl != null
                        ? NetworkImage(widget.profile!.imageUrl!)
                        : null,
                    child: widget.profile?.imageUrl == null
                        ? Icon(Icons.camera_alt, size: 40, color: Colors.grey[400])
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              */
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: '애칭',
                  prefixIcon: Icon(Icons.favorite_border),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '생년월일',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? '날짜를 선택해주세요'
                        : '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일',
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('저장하기', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
