import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/models/profile_model.dart';
import 'package:lovefortune_app/core/models/special_advice_model.dart';
import 'package:lovefortune_app/core/repositories/horoscope_repository.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class SpecialAdviceState {
  final bool isLoading;
  final SpecialAdviceModel? advice;
  final String? errorMessage;

  SpecialAdviceState({this.isLoading = false, this.advice, this.errorMessage});

  SpecialAdviceState copyWith({bool? isLoading, SpecialAdviceModel? advice, String? errorMessage}) {
    return SpecialAdviceState(
      isLoading: isLoading ?? this.isLoading,
      advice: advice ?? this.advice,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SpecialAdviceViewModel extends Notifier<SpecialAdviceState> {
  @override
  SpecialAdviceState build() {
    return SpecialAdviceState();
  }

  Future<void> fetchSpecialAdvice(ProfileModel myProfile, ProfileModel partnerProfile) async {
    final stopwatch = Stopwatch()..start();
    state = state.copyWith(isLoading: true, errorMessage: null);
    logger.i('스페셜 조언 ViewModel: 데이터 요청 시작...');

    try {
      final repo = ref.read(horoscopeRepositoryProvider);
      final result = await repo.getSpecialAdvice(myProfile, partnerProfile);

      stopwatch.stop();
      logger.i('✅ 스페셜 조언 데이터 가져오기 성공! (소요 시간: ${stopwatch.elapsedMilliseconds}ms)');

      state = state.copyWith(isLoading: false, advice: result);

    } catch (e, stackTrace) {
      stopwatch.stop();
      logger.e('스페셜 조언 ViewModel: 데이터 요청 실패 (소요 시간: ${stopwatch.elapsedMilliseconds}ms)', error: e, stackTrace: stackTrace);
      state = state.copyWith(isLoading: false, errorMessage: '스페셜 조언을 불러오는 데 실패했습니다.');
    }
  }
}

final specialAdviceViewModelProvider = NotifierProvider<SpecialAdviceViewModel, SpecialAdviceState>(
      () => SpecialAdviceViewModel(),
);
