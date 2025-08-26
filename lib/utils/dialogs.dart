import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/features/main/main_screen.dart';

// 프로필 정보가 필요할 때 보여줄 공용 팝업 함수입니다.
void showProfileNeededPopup(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('알림'),
      content: const Text('내 정보와 상대방 정보를 먼저 입력해야 이용할 수 있어요.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 팝업 닫기
            // '내 정보' 탭(인덱스 3)으로 이동
            ref.read(mainScreenIndexProvider.notifier).state = 3;
          },
          child: const Text('정보 입력하러 가기'),
        ),
      ],
    ),
  );
}
