import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/models/horoscope_model.dart';
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

  // 함수 이름을 getHoroscope로 다시 변경합니다.
  Future<void> fetchHoroscope(String userBirth, String partnerBirth) async {
    state = state.copyWith(isLoading: true, errorMessage: null, horoscope: null);
    logger.i('운세 데이터 가져오기 시작...');

    try {
      // Repository의 getHoroscope 함수를 호출합니다.
      final result = await _repository.getHoroscope(userBirth, partnerBirth);

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
