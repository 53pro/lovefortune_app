// --- lib/features/tips/personality_report_viewmodel.dart (신규 생성) ---
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/models/personality_report_model.dart';
import 'package:lovefortune_app/core/repositories/horoscope_repository.dart';
import 'package:lovefortune_app/core/repositories/profile_repository.dart';

class PersonalityReportState {
  final bool isLoading;
  final PersonalityReportModel? report;
  final String? errorMessage;

  PersonalityReportState({this.isLoading = false, this.report, this.errorMessage});

  PersonalityReportState copyWith({bool? isLoading, PersonalityReportModel? report, String? errorMessage}) {
    return PersonalityReportState(
      isLoading: isLoading ?? this.isLoading,
      report: report ?? this.report,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PersonalityReportViewModel extends Notifier<PersonalityReportState> {
  @override
  PersonalityReportState build() {
    return PersonalityReportState();
  }

  Future<void> fetchReport() async {
    state = state.copyWith(isLoading: true);
    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      final horoscopeRepo = ref.read(horoscopeRepositoryProvider);

      final myProfile = await profileRepo.getMyProfile();
      final partnerProfile = await profileRepo.getSelectedPartner();

      if (myProfile == null || partnerProfile == null) {
        throw Exception('프로필 정보가 필요합니다.');
      }

      final result = await horoscopeRepo.getPersonalityReport(myProfile, partnerProfile);
      state = state.copyWith(isLoading: false, report: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '리포트를 불러오는 데 실패했습니다.');
    }
  }
}

final personalityReportViewModelProvider = NotifierProvider<PersonalityReportViewModel, PersonalityReportState>(
      () => PersonalityReportViewModel(),
);
