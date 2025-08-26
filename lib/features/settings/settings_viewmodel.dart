import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lovefortune_app/core/models/profile_model.dart';
import 'package:lovefortune_app/core/repositories/horoscope_repository.dart';
import 'package:lovefortune_app/core/repositories/profile_repository.dart';
import 'package:lovefortune_app/features/auth/auth_providers.dart';
import 'package:lovefortune_app/features/settings/profile_edit_screen.dart';
import 'package:lovefortune_app/features/today_us/today_us_viewmodel.dart'; // today_us_viewmodel을 import 합니다.
import 'package:logger/logger.dart';

final logger = Logger();

class SettingsState {
  final bool isLoading;
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
    Future.microtask(() => loadProfileData());
    return SettingsState(isLoading: true);
  }

  // 데이터 변경 후, 프로필 완성 여부와 '오늘우리' 탭을 모두 갱신하는 helper 함수
  Future<void> _reloadDataAndRefresh() async {
    await loadProfileData();
    // profileCompletenessProvider를 무효화하여 다시 실행하도록 합니다.
    ref.invalidate(profileCompletenessProvider);
    // TodayUsViewModel의 fetchHoroscope 함수를 호출하여 '오늘우리' 화면 데이터를 갱신합니다.
    ref.read(todayUsViewModelProvider.notifier).fetchHoroscope();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> loadProfileData() async {
    state = state.copyWith(isLoading: true);
    try {
      final myProfile = await _profileRepo.getMyProfile();
      final partners = await _profileRepo.getPartners();
      final selectedPartner = await _profileRepo.getSelectedPartner();
      state = state.copyWith(
        isLoading: false,
        myProfile: myProfile,
        partners: partners,
        selectedPartnerId: selectedPartner?.id,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateMyProfile(String nickname, DateTime birthdate, {String? imageUrl}) async {
    await _profileRepo.updateMyProfile(nickname, birthdate, imageUrl: imageUrl);
    await _horoscopeRepo.clearHoroscopeCache();
    await _reloadDataAndRefresh();
  }

  Future<void> addPartner(String nickname, DateTime birthdate) async {
    final newPartner = await _profileRepo.addPartner(nickname, birthdate);
    final partners = await _profileRepo.getPartners();
    if (partners.length == 1) {
      await _profileRepo.setSelectedPartner(newPartner.id);
    }
    await _reloadDataAndRefresh();
  }

  Future<void> updatePartner(ProfileModel updatedPartner) async {
    await _profileRepo.updatePartner(updatedPartner);
    await _horoscopeRepo.clearHoroscopeCache();
    await _reloadDataAndRefresh();
  }

  Future<void> deletePartner(String partnerId) async {
    if (state.selectedPartnerId == partnerId) {
      await _profileRepo.setSelectedPartner('');
    }
    await _profileRepo.deletePartner(partnerId);
    await _horoscopeRepo.clearHoroscopeCache();
    await _reloadDataAndRefresh();
  }

  Future<void> setSelectedPartner(String partnerId) async {
    await _profileRepo.setSelectedPartner(partnerId);
    await _horoscopeRepo.clearHoroscopeCache();
    await _reloadDataAndRefresh();
  }

  // 이미지 선택 및 업로드 함수 (현재 UI에서는 사용되지 않음)
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
      await loadProfileData();
    }
  }
}

final settingsViewModelProvider = NotifierProvider<SettingsViewModel, SettingsState>(
      () => SettingsViewModel(),
);
