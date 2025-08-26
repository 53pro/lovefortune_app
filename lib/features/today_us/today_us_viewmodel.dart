import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/models/horoscope_model.dart';
import 'package:lovefortune_app/core/models/profile_model.dart';
import 'package:lovefortune_app/core/models/special_advice_model.dart'; // 이 import 구문을 추가합니다.
import 'package:lovefortune_app/core/repositories/horoscope_repository.dart';
import 'package:lovefortune_app/core/repositories/profile_repository.dart';
import 'package:logger/logger.dart';

final logger = Logger();

// 클래스 이름을 TodayUsState로 변경합니다.
class TodayUsState {
  final bool isLoading;
  final HoroscopeModel? horoscope;
  final String? errorMessage;
  final ProfileModel? myProfile;
  final ProfileModel? partnerProfile;
  final bool isProfileIncomplete;

  TodayUsState({
    this.isLoading = false,
    this.horoscope,
    this.errorMessage,
    this.myProfile,
    this.partnerProfile,
    this.isProfileIncomplete = false,
  });

  TodayUsState copyWith({
    bool? isLoading,
    HoroscopeModel? horoscope,
    String? errorMessage,
    ProfileModel? myProfile,
    ProfileModel? partnerProfile,
    bool? isProfileIncomplete,
  }) {
    return TodayUsState(
      isLoading: isLoading ?? this.isLoading,
      horoscope: horoscope ?? this.horoscope,
      errorMessage: errorMessage ?? this.errorMessage,
      myProfile: myProfile ?? this.myProfile,
      partnerProfile: partnerProfile ?? this.partnerProfile,
      isProfileIncomplete: isProfileIncomplete ?? this.isProfileIncomplete,
    );
  }
}

// ViewModel 클래스 이름을 TodayUsViewModel으로 변경합니다.
class TodayUsViewModel extends Notifier<TodayUsState> {
  @override
  TodayUsState build() {
    return TodayUsState();
  }

  Future<void> fetchHoroscope() async {
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

      state = state.copyWith(isLoading: false, horoscope: result);
      logger.i('운세 데이터 가져오기 성공!');
    } catch (e) {
      logger.e('데이터 가져오기 실패:', error: e);
      final message = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: message);
    }
  }

  // 스페셜 조언 미리 요청 기능도 여기에 포함됩니다.
  Future<SpecialAdviceModel> fetchSpecialAdvice() async {
    logger.i('TodayUsViewModel: 스페셜 조언 미리 가져오기 시작...');
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

// Provider 이름도 변경합니다.
final todayUsViewModelProvider = NotifierProvider<TodayUsViewModel, TodayUsState>(
      () => TodayUsViewModel(),
);
