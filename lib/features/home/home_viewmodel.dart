import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/models/horoscope_model.dart';
import 'package:lovefortune_app/core/models/profile_model.dart'; // ProfileModel import
import 'package:lovefortune_app/core/repositories/horoscope_repository.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class HomeState {
  final bool isLoading;
  final HoroscopeModel? horoscope;
  final String? errorMessage;

  HomeState({
    this.isLoading = false,
    this.horoscope,
    this.errorMessage,
  });

  HomeState copyWith({
    bool? isLoading,
    HoroscopeModel? horoscope,
    String? errorMessage,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      horoscope: horoscope ?? this.horoscope,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class HomeViewModel extends Notifier<HomeState> {
  late final HoroscopeRepository _repository;

  @override
  HomeState build() {
    _repository = ref.read(horoscopeRepositoryProvider);
    return HomeState();
  }

  // 이제 함수는 파라미터를 받지 않고, 내부에서 프로필 정보를 가져와야 합니다.
  Future<void> fetchHoroscope() async {
    state = state.copyWith(isLoading: true, errorMessage: null, horoscope: null);
    logger.i('운세 데이터 가져오기 시작...');

    try {
      // TODO: Firestore에서 실제 내 정보와 현재 선택된 파트너 정보를 가져오는 로직이 필요합니다.
      // 지금은 테스트를 위해 더미 데이터를 사용합니다.
      final myProfile = ProfileModel(
          id: 'myUserId',
          nickname: '나',
          birthdate: DateTime(1995, 5, 15)
      );
      final partnerProfile = ProfileModel(
          id: 'partnerId123',
          nickname: '파트너',
          birthdate: DateTime(1996, 8, 20)
      );

      // Repository에 ProfileModel 객체를 전달합니다.
      final result = await _repository.getHoroscope(myProfile, partnerProfile);

      state = state.copyWith(isLoading: false, horoscope: result);
      logger.i('운세 데이터 가져오기 성공!');
    } catch (e) {
      logger.e('운세 데이터 가져오기 실패:', error: e);
      state = state.copyWith(isLoading: false, errorMessage: '운세를 불러오는 데 실패했어요. 다시 시도해주세요.');
    }
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(
      () => HomeViewModel(),
);
