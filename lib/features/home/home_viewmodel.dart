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
  final bool isProfileIncomplete; // 프로필 미완성 상태 추가

  HomeState({
    this.isLoading = false,
    this.horoscope,
    this.errorMessage,
    this.myProfile,
    this.partnerProfile,
    this.isProfileIncomplete = false, // 기본값은 false
  });

  HomeState copyWith({
    bool? isLoading,
    HoroscopeModel? horoscope,
    String? errorMessage,
    ProfileModel? myProfile,
    ProfileModel? partnerProfile,
    bool? isProfileIncomplete,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      horoscope: horoscope ?? this.horoscope,
      errorMessage: errorMessage ?? this.errorMessage,
      myProfile: myProfile ?? this.myProfile,
      partnerProfile: partnerProfile ?? this.partnerProfile,
      isProfileIncomplete: isProfileIncomplete ?? this.isProfileIncomplete,
    );
  }
}

class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() {
    return HomeState();
  }

  Future<void> fetchHoroscope() async {
    // 상태를 초기화할 때 isProfileIncomplete도 초기화합니다.
    state = state.copyWith(isLoading: true, errorMessage: null, isProfileIncomplete: false);
    logger.i('프로필 및 운세 데이터 가져오기 시작...');

    try {
      final profileRepository = ref.read(profileRepositoryProvider);
      final horoscopeRepository = ref.read(horoscopeRepositoryProvider);

      final myProfile = await profileRepository.getMyProfile();
      final partnerProfile = await profileRepository.getSelectedPartner();

      if (myProfile == null || partnerProfile == null) {
        // Exception을 던지는 대신, isProfileIncomplete 상태를 true로 설정합니다.
        logger.w('프로필 정보가 부족하여 설정 화면으로 유도합니다.');
        state = state.copyWith(isLoading: false, isProfileIncomplete: true);
        return; // 운세 로직을 더 이상 진행하지 않고 종료합니다.
      }

      state = state.copyWith(myProfile: myProfile, partnerProfile: partnerProfile);

      final result = await horoscopeRepository.getHoroscope(myProfile, partnerProfile);

      state = state.copyWith(isLoading: false, horoscope: result);
      logger.i('운세 데이터 가져오기 성공!');
    } catch (e) {
      logger.e('데이터 가져오기 실패:', error: e);
      final message = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: message);
    }
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(
      () => HomeViewModel(),
);
