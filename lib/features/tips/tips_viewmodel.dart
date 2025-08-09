// --- lib/features/tips/tips_viewmodel.dart ---
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/features/tips/relationship_tips_model.dart';
// import 'package:lovefortune_app/core/repositories/horoscope_repository.dart'; // Repository 연결 필요

class TipsState {
  final bool isLoading;
  final RelationshipTipsModel? tips;
  final String? errorMessage;

  TipsState({this.isLoading = false, this.tips, this.errorMessage});

  TipsState copyWith({bool? isLoading, RelationshipTipsModel? tips, String? errorMessage}) {
    return TipsState(
      isLoading: isLoading ?? this.isLoading,
      tips: tips ?? this.tips,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TipsViewModel extends Notifier<TipsState> {
  @override
  TipsState build() {
    return TipsState();
  }

  Future<void> fetchTips(String userBirth, String partnerBirth) async {
    state = state.copyWith(isLoading: true);
    // TODO: Repository를 통해 AI에게 관계 팁 데이터를 요청하는 로직 구현
  }
}

final tipsViewModelProvider = NotifierProvider<TipsViewModel, TipsState>(
      () => TipsViewModel(),
);
