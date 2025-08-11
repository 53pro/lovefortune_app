import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String id;
  final String nickname;
  final DateTime birthdate;
  final String? imageUrl; // 프로필 이미지 URL 필드 추가

  ProfileModel({
    required this.id,
    required this.nickname,
    required this.birthdate,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'birthdate': Timestamp.fromDate(birthdate),
      'imageUrl': imageUrl, // 저장할 데이터에 추가
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String,
      nickname: map['nickname'] as String,
      birthdate: (map['birthdate'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'] as String?, // 불러올 데이터에 추가
    );
  }
}