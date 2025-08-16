import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/repositories/profile_repository.dart';

// Firebase의 인증 상태 변화를 실시간으로 감지하는 StreamProvider
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// 프로필 정보가 모두 입력되었는지 확인하는 FutureProvider
final profileCompletenessProvider = FutureProvider<bool>((ref) async {
  // 로그인 상태가 변경될 때마다 이 provider가 재실행되도록 authStateChangesProvider를 watch합니다.
  ref.watch(authStateChangesProvider);

  final profileRepo = ref.watch(profileRepositoryProvider);

  // 사용자가 로그인했는지 먼저 확인합니다.
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return false; // 로그인하지 않았으면 프로필은 불완전합니다.
  }

  final myProfile = await profileRepo.getMyProfile();
  final partnerProfile = await profileRepo.getSelectedPartner();

  // 내 정보와 선택된 파트너 정보가 모두 있어야 완전한 것으로 간주합니다.
  return myProfile != null && partnerProfile != null;
});
