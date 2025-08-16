import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/models/conflict_guide_model.dart';
import 'package:lovefortune_app/core/repositories/horoscope_repository.dart';
import 'package:lovefortune_app/core/repositories/profile_repository.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ConflictGuideState {
  final bool isLoading;
  final ConflictGuideModel? guide; // 반환 타입을 ConflictGuideModel로 수정
  final String? errorMessage;

  ConflictGuideState({this.isLoading = false, this.guide, this.errorMessage});

  ConflictGuideState copyWith({bool? isLoading, ConflictGuideModel? guide, String? errorMessage}) {
    return ConflictGuideState(
      isLoading: isLoading ?? this.isLoading,
      guide: guide ?? this.guide,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ConflictGuideViewModel extends Notifier<ConflictGuideState> {
  @override
  ConflictGuideState build() {
    return ConflictGuideState();
  }

  Future<void> fetchGuide(String topic) async {
    state = state.copyWith(isLoading: true);
    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      final horoscopeRepo = ref.read(horoscopeRepositoryProvider);

      final myProfile = await profileRepo.getMyProfile();
      final partnerProfile = await profileRepo.getSelectedPartner();

      if (myProfile == null || partnerProfile == null) {
        throw Exception('프로필 정보가 필요합니다.');
      }

      // 이제 Repository는 ConflictGuideModel을 반환합니다.
      final result = await horoscopeRepo.getConflictGuide(myProfile, partnerProfile, topic);
      state = state.copyWith(isLoading: false, guide: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '가이드를 불러오는 데 실패했습니다.');
    }
  }
}

final conflictGuideViewModelProvider = NotifierProvider<ConflictGuideViewModel, ConflictGuideState>(
      () => ConflictGuideViewModel(),
);
