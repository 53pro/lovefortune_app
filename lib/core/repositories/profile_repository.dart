import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/models/profile_model.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart'; // logger 라이브러리 import

final logger = Logger(); // 로거 인스턴스 생성

final profileRepositoryProvider = Provider((ref) {
  return ProfileRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
    FirebaseStorage.instance,
  );
});

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  ProfileRepository(this._firestore, this._auth, this._storage);

  String? get _userId => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> get _userDocRef {
    if (_userId == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(_userId);
  }

  Future<ProfileModel?> getMyProfile() async {
    logger.i('Firestore에서 내 프로필 정보 가져오기 시도...');
    if (_userId == null) {
      logger.w('사용자가 로그인하지 않았습니다.');
      return null;
    }
    try {
      final doc = await _userDocRef.get();
      if (!doc.exists || doc.data()?['myProfile'] == null) {
        logger.w('Firestore에 내 프로필 문서가 없거나 myProfile 필드가 없습니다.');
        return null;
      }

      final data = doc.data()!['myProfile'] as Map<String, dynamic>;
      logger.i('✅ Firestore에서 내 프로필 데이터 로드 성공:', error: data);
      return ProfileModel.fromMap(data);
    } catch (e) {
      logger.e('내 프로필 정보 가져오기 실패:', error: e);
      return null;
    }
  }

  // imageUrl 파라미터를 받도록 함수 시그니처를 수정합니다.
  Future<void> updateMyProfile(String nickname, DateTime birthdate, {String? imageUrl}) async {
    final doc = await _userDocRef.get();
    // 기존 이미지 URL을 유지하기 위한 로직
    final existingData = doc.data()?['myProfile'] as Map<String, dynamic>?;
    final existingImageUrl = existingData?['imageUrl'];

    final myProfile = ProfileModel(
      id: _userId!,
      nickname: nickname,
      birthdate: birthdate,
      //imageUrl: imageUrl ?? existingImageUrl,
    );
    await _userDocRef.set({'myProfile': myProfile.toMap()}, SetOptions(merge: true));
    logger.i('내 프로필 정보 Firestore에 저장 완료.');
  }

  Future<List<ProfileModel>> getPartners() async {
    final doc = await _userDocRef.get();
    if (!doc.exists || doc.data()?['partners'] == null) return [];
    final partnersData = doc.data()!['partners'] as List<dynamic>;
    return partnersData.map((data) => ProfileModel.fromMap(data as Map<String, dynamic>)).toList();
  }

  Future<void> addPartner(String nickname, DateTime birthdate) async {
    const uuid = Uuid();
    final newPartner = ProfileModel(id: uuid.v4(), nickname: nickname, birthdate: birthdate);
    await _userDocRef.set({
      'partners': FieldValue.arrayUnion([newPartner.toMap()])
    }, SetOptions(merge: true));
  }

  Future<void> updatePartner(ProfileModel updatedPartner) async {
    final partners = await getPartners();
    final index = partners.indexWhere((p) => p.id == updatedPartner.id);
    if (index != -1) {
      partners[index] = updatedPartner;
      await _userDocRef.update({'partners': partners.map((p) => p.toMap()).toList()});
    }
  }

  Future<void> deletePartner(String partnerId) async {
    final partners = await getPartners();
    partners.removeWhere((p) => p.id == partnerId);
    await _userDocRef.update({'partners': partners.map((p) => p.toMap()).toList()});
  }

  Future<void> setSelectedPartner(String partnerId) async {
    await _userDocRef.set({'selectedPartnerId': partnerId}, SetOptions(merge: true));
  }

  Future<ProfileModel?> getSelectedPartner() async {
    final doc = await _userDocRef.get();
    if (!doc.exists || doc.data()?['selectedPartnerId'] == null) return null;
    final selectedPartnerId = doc.data()!['selectedPartnerId'] as String;
    final partners = await getPartners();
    try {
      return partners.firstWhere((p) => p.id == selectedPartnerId);
    } catch (e) {
      return null;
    }
  }

  Future<String> uploadProfileImage(File imageFile) async {
    final ref = _storage.ref().child('profile_images').child('$_userId/${DateTime.now().millisecondsSinceEpoch}');
    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }
}
