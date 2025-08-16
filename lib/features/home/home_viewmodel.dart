import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/models/horoscope_model.dart';
import 'package:lovefortune_app/core/models/profile_model.dart';
import 'package:lovefortune_app/core/models/special_advice_model.dart'; // 스페셜 조언 모델 import
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
  final bool isProfileIncomplete;

  HomeState({
    this.isLoading = false,
    this.horoscope,
    this.errorMessage,
    this.myProfile,
    this.partnerProfile,
    this.isProfileIncomplete = false,
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
    // API 호출 시간을 측정하기 위해 Stopwatch를 시작합니다.
    final stopwatch = Stopwatch()..start();

    state = state.copyWith(isLoading: true, errorMessage: null, isProfileIncomplete: false);
    logger.i('프로필 및 운세 데이터 가져오기 시작...');

    try {
      final profileRepository = ref.read(profileRepositoryProvider);
      final horoscopeRepository = ref.read(horoscopeRepositoryProvider);

      final myProfile = await profileRepository.getMyProfile();
      final partnerProfile = await profileRepository.getSelectedPartner();

      if (myProfile == null || partnerProfile == null) {
        logger.w('프로필 정보가 부족하여 설정 화면으로 유도합니다.');
        state = state.copyWith(isLoading: false, isProfileIncomplete: true);
        return;
      }

      state = state.copyWith(myProfile: myProfile, partnerProfile: partnerProfile);

      final result = await horoscopeRepository.getHoroscope(myProfile, partnerProfile);

      // Stopwatch를 멈추고, 성공 시 소요 시간을 로그로 출력합니다.
      stopwatch.stop();
      logger.i('✅ 운세 데이터 가져오기 성공! (소요 시간: ${stopwatch.elapsedMilliseconds}ms)');

      state = state.copyWith(isLoading: false, horoscope: result);
    } catch (e) {
      // Stopwatch를 멈추고, 실패 시에도 소요 시간을 로그로 출력합니다.
      stopwatch.stop();
      logger.e('데이터 가져오기 실패: (소요 시간: ${stopwatch.elapsedMilliseconds}ms)', error: e);

      final message = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: message);
    }
  }
  // 스페셜 조언을 미리 요청하고, Future를 반환하는 함수 (추가)
  Future<SpecialAdviceModel> fetchSpecialAdvice() async {
    logger.i('HomeViewModel: 스페셜 조언 미리 가져오기 시작...');
    final profileRepository = ref.read(profileRepositoryProvider);
    final horoscopeRepository = ref.read(horoscopeRepositoryProvider);

    final myProfile = await profileRepository.getMyProfile();
    final partnerProfile = await profileRepository.getSelectedPartner();

    if (myProfile == null || partnerProfile == null) {
      throw Exception('프로필 정보가 없어 스페셜 조언을 볼 수 없습니다.');
    }

    return horoscopeRepository.getSpecialAdvice(myProfile, partnerProfile);
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(
      () => HomeViewModel(),
);
