import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/models/horoscope_model.dart';
import 'package:lovefortune_app/core/models/profile_model.dart';
import 'package:lovefortune_app/core/repositories/horoscope_repository.dart';
import 'package:lovefortune_app/core/repositories/profile_repository.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class HomeState {
  final bool isLoading;
  final HoroscopeModel? horoscope;
  final String? errorMessage;
  final ProfileModel? myProfile;
  final ProfileModel? partnerProfile;

  HomeState({
    this.isLoading = false,
    this.horoscope,
    this.errorMessage,
    this.myProfile,
    this.partnerProfile,
  });

  HomeState copyWith({
    bool? isLoading,
    HoroscopeModel? horoscope,
    String? errorMessage,
    ProfileModel? myProfile,
    ProfileModel? partnerProfile,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      horoscope: horoscope ?? this.horoscope,
      errorMessage: errorMessage ?? this.errorMessage,
      myProfile: myProfile ?? this.myProfile,
      partnerProfile: partnerProfile ?? this.partnerProfile,
    );
  }
}

class HomeViewModel extends Notifier<HomeState> {
  // late final 변수들을 제거하여 LateInitializationError를 원천적으로 방지합니다.

  @override
  HomeState build() {
    // build 메서드는 상태를 초기화하는 역할만 합니다.
    return HomeState();
  }

  Future<void> fetchHoroscope() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    logger.i('프로필 및 운세 데이터 가져오기 시작...');

    try {
      // Repository들을 메서드 내에서 직접 ref.read를 통해 읽어옵니다.
      // 이렇게 하면 provider가 초기화된 후에만 사용되므로 안전합니다.
      final profileRepository = ref.read(profileRepositoryProvider);
      final horoscopeRepository = ref.read(horoscopeRepositoryProvider);

      final myProfile = await profileRepository.getMyProfile();
      final partnerProfile = await profileRepository.getSelectedPartner();

      if (myProfile == null || partnerProfile == null) {
        throw Exception('프로필 정보가 없습니다. 설정에서 정보를 입력해주세요.');
      }

      state = state.copyWith(myProfile: myProfile, partnerProfile: partnerProfile);

      final result = await horoscopeRepository.getHoroscope(myProfile, partnerProfile);

      state = state.copyWith(isLoading: false, horoscope: result);
      logger.i('운세 데이터 가져오기 성공!');
    } catch (e) {
      logger.e('데이터 가져오기 실패:', error: e);
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(
      () => HomeViewModel(),
);
