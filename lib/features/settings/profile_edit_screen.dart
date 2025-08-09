import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/theme/app_theme.dart';

// 이 화면이 '내 정보'를 수정하는지 '상대방 정보'를 수정하는지 구분하기 위한 enum
enum ProfileType { me, partner }

class ProfileEditScreen extends ConsumerStatefulWidget {
  final ProfileType profileType;

  const ProfileEditScreen({
    super.key,
    required this.profileType,
  });

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  // 이름 컨트롤러를 제거합니다.
  final _nicknameController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // TODO: ViewModel에서 기존 프로필 정보를 불러와서 컨트롤러와 상태를 초기화하는 로직 추가
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  // 날짜 선택 다이얼로그를 보여주는 함수
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor, // 헤더 배경색
              onPrimary: Colors.white, // 헤더 글자색
              onSurface: AppTheme.primaryColor, // 선택된 날짜 글자색
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor, // 버튼 글자색
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.profileType == ProfileType.me;
    final title = isMe ? '내 정보 수정' : '상대방 정보 수정';

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
              // 이름 입력 필드를 제거하고 애칭 필드만 남깁니다.
              _buildTextField(
                controller: _nicknameController,
                labelText: '애칭',
                icon: Icons.favorite_border,
              ),
              const SizedBox(height: 16),
              _buildDateField(context),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  // TODO: ViewModel의 저장 함수 호출
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('저장하기', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 텍스트 필드를 위한 공용 위젯
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
    );
  }

  // 날짜 선택 필드를 위한 위젯
  Widget _buildDateField(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: '생년월일',
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Text(
          _selectedDate == null
              ? '날짜를 선택해주세요'
              : '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일',
          style: TextStyle(
            fontSize: 16,
            color: _selectedDate == null ? Theme.of(context).hintColor : null,
          ),
        ),
      ),
    );
  }
}
