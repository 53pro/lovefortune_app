// --- lib/core/models/profile_model.dart (신규 생성) ---
// 나와 파트너의 정보를 담는 데이터 모델을 새로 만듭니다.
class ProfileModel {
  final String id; // Firestore Document ID
  final String nickname;
  final DateTime birthdate;

  ProfileModel({
    required this.id,
    required this.nickname,
    required this.birthdate,
  });
}