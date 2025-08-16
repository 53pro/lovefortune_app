import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/models/profile_model.dart';
import 'package:lovefortune_app/core/models/self_discovery_model.dart';
import 'package:lovefortune_app/core/repositories/tips_repository.dart'; // HoroscopeRepository 대신 TipsRepository를 import

class SelfDiscoveryState {
  final bool isLoading;
  final SelfDiscoveryModel? tip;
  final String? errorMessage;

  SelfDiscoveryState({this.isLoading = false, this.tip, this.errorMessage});

  SelfDiscoveryState copyWith({bool? isLoading, SelfDiscoveryModel? tip, String? errorMessage}) {
    return SelfDiscoveryState(
      isLoading: isLoading ?? this.isLoading,
      tip: tip ?? this.tip,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SelfDiscoveryViewModel extends Notifier<SelfDiscoveryState> {
  @override
  SelfDiscoveryState build() {
    return SelfDiscoveryState();
  }

  Future<void> fetchSelfDiscoveryTip(ProfileModel myProfile) async {
    state = state.copyWith(isLoading: true);
    try {
      // tipsRepositoryProvider를 통해 Repository를 읽어옵니다.
      final repo = ref.read(tipsRepositoryProvider);
      final result = await repo.getSelfDiscoveryTip(myProfile);
      state = state.copyWith(isLoading: false, tip: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '자기 발견 팁을 불러오는 데 실패했습니다.');
    }
  }
}

final selfDiscoveryViewModelProvider = NotifierProvider<SelfDiscoveryViewModel, SelfDiscoveryState>(
      () => SelfDiscoveryViewModel(),
);
