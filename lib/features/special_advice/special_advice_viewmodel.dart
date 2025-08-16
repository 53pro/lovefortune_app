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
    state = state.copyWith(isLoading: true, errorMessage: null);
    logger.i('스페셜 조언 ViewModel: 데이터 요청 시작...');

    try {
      final repo = ref.read(horoscopeRepositoryProvider);
      final result = await repo.getSpecialAdvice(myProfile, partnerProfile);

      // Repository로부터 받은 결과가 정상인지 로그로 확인합니다.
      logger.d('스페셜 조언 ViewModel: Repository로부터 데이터 수신 완료. 내용: ${result.synergyPoint}');

      // 상태를 업데이트합니다.
      state = state.copyWith(isLoading: false, advice: result);
      logger.i('✅ 스페셜 조언 ViewModel: 상태 업데이트 성공!');

    } catch (e, stackTrace) {
      // 에러 발생 시, 스택 트레이스까지 상세하게 기록합니다.
      logger.e('스페셜 조언 ViewModel: 데이터 요청 실패', error: e, stackTrace: stackTrace);
      state = state.copyWith(isLoading: false, errorMessage: '스페셜 조언을 불러오는 데 실패했습니다.');
    }
  }
}

final specialAdviceViewModelProvider = NotifierProvider<SpecialAdviceViewModel, SpecialAdviceState>(
      () => SpecialAdviceViewModel(),
);
