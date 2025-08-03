import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ViewModel은 특별한 상태를 가질 필요가 없으므로, Notifier<void>를 사용합니다.
class SettingsViewModel extends Notifier<void> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void build() {
    // 이 ViewModel은 상태를 관리하지 않으므로, 초기화 시 아무것도 하지 않습니다.
    return;
  }

  // 로그아웃을 처리하는 함수
  Future<void> signOut() async {
    try {
      // Firebase Auth 인스턴스를 통해 로그아웃을 요청합니다.
      await _auth.signOut();
    } catch (e) {
      // 에러가 발생할 경우 콘솔에 출력합니다.
      // 실제 앱에서는 사용자에게 에러 메시지를 보여주는 로직을 추가할 수 있습니다.
      print('로그아웃 중 에러 발생: $e');
    }
  }
}

// SettingsViewModel을 UI에서 사용할 수 있도록 Provider를 정의합니다.
final settingsViewModelProvider = NotifierProvider<SettingsViewModel, void>(
      () => SettingsViewModel(),
);
