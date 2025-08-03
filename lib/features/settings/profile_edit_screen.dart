import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final _nameController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // TODO: ViewModel에서 기존 프로필 정보를 불러와서 컨트롤러와 상태를 초기화하는 로직 추가
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // 날짜 선택 다이얼로그를 보여주는 함수
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _selectDate(context),
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDate == null
                    ? '생년월일 선택'
                    : '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.centerLeft,
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const Spacer(), // 남은 공간을 모두 차지
            ElevatedButton(
              onPressed: () {
                // TODO: ViewModel의 저장 함수 호출
                // final name = _nameController.text;
                // final birthDate = _selectedDate;
                // Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B86E5),
                padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }
}
