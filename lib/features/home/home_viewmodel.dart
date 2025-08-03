import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/models/horoscope_model.dart';
import 'package:lovefortune_app/core/repositories/horoscope_repository.dart';
import 'package:logger/logger.dart'; // logger 라이브러리 import

// 로거 인스턴스 생성
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

  Future<void> fetchHoroscope(String userBirth, String partnerBirth) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    logger.i('운세 데이터 가져오기 시작...'); // 로그 추가

    try {
      final result = await _repository.getHoroscope(userBirth, partnerBirth);
      state = state.copyWith(isLoading: false, horoscope: result);
      logger.i('운세 데이터 가져오기 성공!'); // 로그 추가
    } catch (e) {
      // 에러 발생 시, 상세 내용을 로그로 출력합니다.
      logger.e('운세 데이터 가져오기 실패:', error: e);
      state = state.copyWith(isLoading: false, errorMessage: '운세를 불러오는 데 실패했어요. 다시 시도해주세요.');
    }
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(
      () => HomeViewModel(),
);
