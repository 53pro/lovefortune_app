import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lovefortune_app/core/models/profile_model.dart';
import 'package:lovefortune_app/core/repositories/horoscope_repository.dart';
import 'package:lovefortune_app/core/repositories/profile_repository.dart';
import 'package:lovefortune_app/features/settings/profile_edit_screen.dart'; // ProfileType을 사용하기 위해 import 추가
import 'package:logger/logger.dart'; // logger 라이브러리 import

final logger = Logger(); // 로거 인스턴스 생성
class SettingsState {
  final bool isLoading; // 데이터를 불러오는 중인지 확인하는 상태
  final ProfileModel? myProfile;
  final List<ProfileModel> partners;
  final String? selectedPartnerId;

  SettingsState({
    this.isLoading = false,
    this.myProfile,
    this.partners = const [],
    this.selectedPartnerId,
  });

  SettingsState copyWith({
    bool? isLoading,
    ProfileModel? myProfile,
    List<ProfileModel>? partners,
    String? selectedPartnerId,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      myProfile: myProfile ?? this.myProfile,
      partners: partners ?? this.partners,
      selectedPartnerId: selectedPartnerId ?? this.selectedPartnerId,
    );
  }
}

class SettingsViewModel extends Notifier<SettingsState> {
  late ProfileRepository _profileRepo;
  late HoroscopeRepository _horoscopeRepo;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  SettingsState build() {
    _profileRepo = ref.read(profileRepositoryProvider);
    _horoscopeRepo = ref.read(horoscopeRepositoryProvider);
    // ViewModel이 처음 생성될 때 바로 데이터를 불러오도록 합니다.
    Future.microtask(() => loadProfileData());
    return SettingsState(isLoading: true); // 초기 상태를 '로딩 중'으로 설정
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> loadProfileData() async {
    state = state.copyWith(isLoading: true);
    logger.i('프로필 데이터 로딩 시작...');
    try {
      final myProfile = await _profileRepo.getMyProfile();
      final partners = await _profileRepo.getPartners();
      final selectedPartner = await _profileRepo.getSelectedPartner();

      logger.i('내 프로필 로드 결과: ${myProfile?.nickname ?? "데이터 없음"}');
      logger.i('파트너 목록 로드 결과: ${partners.length}명');
      logger.i('선택된 파트너 로드 결과: ${selectedPartner?.nickname ?? "데이터 없음"}');

      state = state.copyWith(
        isLoading: false,
        myProfile: myProfile,
        partners: partners,
        selectedPartnerId: selectedPartner?.id,
      );
      logger.i('✅ SettingsState 업데이트 완료.');
    } catch (e) {
      logger.e('프로필 데이터 로딩 실패:', error: e);
      state = state.copyWith(isLoading: false);
    }
  }

  // 이 함수의 정의에 {String? imageUrl} 부분을 추가해주세요.
  Future<void> updateMyProfile(String nickname, DateTime birthdate, {String? imageUrl}) async {
    // Repository의 함수를 호출할 때 imageUrl을 그대로 전달합니다.
    await _profileRepo.updateMyProfile(nickname, birthdate, imageUrl: imageUrl);
    await _horoscopeRepo.clearHoroscopeCache();
    await loadProfileData();
  }

  Future<void> addPartner(String nickname, DateTime birthdate) async {
    await _profileRepo.addPartner(nickname, birthdate);
    await loadProfileData();
  }

  Future<void> updatePartner(ProfileModel updatedPartner) async {
    await _profileRepo.updatePartner(updatedPartner);
    await _horoscopeRepo.clearHoroscopeCache();
    await loadProfileData();
  }

  Future<void> deletePartner(String partnerId) async {
    if (state.selectedPartnerId == partnerId) {
      await _profileRepo.setSelectedPartner('');
    }
    await _profileRepo.deletePartner(partnerId);
    await _horoscopeRepo.clearHoroscopeCache();
    await loadProfileData();
  }

  Future<void> setSelectedPartner(String partnerId) async {
    await _profileRepo.setSelectedPartner(partnerId);
    await _horoscopeRepo.clearHoroscopeCache();
    await loadProfileData();
  }

  // 이미지 선택 및 업로드 함수
  Future<void> pickAndUploadImage(ProfileType type, {String? partnerId}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      final imageUrl = await _profileRepo.uploadProfileImage(imageFile);

      if (type == ProfileType.me && state.myProfile != null) {
        await updateMyProfile(state.myProfile!.nickname, state.myProfile!.birthdate, imageUrl: imageUrl);
      } else if (type == ProfileType.partner && partnerId != null) {
        final partner = state.partners.firstWhere((p) => p.id == partnerId);
        final updatedPartner = ProfileModel(
          id: partner.id,
          nickname: partner.nickname,
          birthdate: partner.birthdate,
          imageUrl: imageUrl,
        );
        await updatePartner(updatedPartner);
      }
      // 데이터가 변경되었으므로 다시 로드하여 UI에 즉시 반영
      await loadProfileData();
    }
  }
}

final settingsViewModelProvider = NotifierProvider<SettingsViewModel, SettingsState>(
      () => SettingsViewModel(),
);
