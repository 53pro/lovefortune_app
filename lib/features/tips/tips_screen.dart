import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/models/profile_model.dart';
import 'package:lovefortune_app/features/tips/tips_viewmodel.dart';
import 'package:lovefortune_app/features/tips/personality_report_screen.dart';
import 'package:lovefortune_app/core/models/conflict_topic_model.dart';
import 'package:lovefortune_app/features/settings/settings_viewmodel.dart';
import 'package:lovefortune_app/core/models/personality_report_model.dart'; // 이 import 구문을 추가합니다.

class TipsScreen extends ConsumerStatefulWidget {
  const TipsScreen({super.key});

  @override
  ConsumerState<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends ConsumerState<TipsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tipsViewModelProvider.notifier).fetchTips();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tipsViewModelProvider);
    final viewModel = ref.read(tipsViewModelProvider.notifier);
    final settingsState = ref.watch(settingsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('관계 팁'),
        actions: [
          IconButton(
            icon: const Icon(Icons.casino_outlined),
            tooltip: '팁 새로고침',
            onPressed: () {
              viewModel.fetchTips();
            },
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildRelationshipGuideCard(context, ref, settingsState),
            const SizedBox(height: 16),
            _buildWeeklyQuestionCard(state.weeklyQuestion),
            const SizedBox(height: 16),
            _buildConflictGuideCard(context, state.conflictTopics),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationshipGuideCard(
      BuildContext context, WidgetRef ref, SettingsState settingsState) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEAEBEE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('우리의 관계 설명서',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('두 분의 타고난 성향을 분석하여 서로를 더 깊이 이해할 수 있도록 도와드려요.',
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () async {
                  final viewModel = ref.read(tipsViewModelProvider.notifier);
                  final myProfile = settingsState.myProfile;
                  ProfileModel? partnerProfile;

                  if (settingsState.selectedPartnerId != null &&
                      settingsState.partners.isNotEmpty) {
                    try {
                      partnerProfile = settingsState.partners.firstWhere(
                              (p) => p.id == settingsState.selectedPartnerId);
                    } catch (e) {
                      partnerProfile = null;
                    }
                  } else if (settingsState.partners.isNotEmpty) {
                    partnerProfile = settingsState.partners.first;
                  }

                  if (myProfile != null && partnerProfile != null) {
                    final checkResult = await viewModel.checkNeedsApiCall();

                    Future<PersonalityReportModel>? reportFuture;
                    if (checkResult.needsApiCall) {
                      reportFuture = viewModel.fetchPersonalityReport();
                    }

                    if (mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PersonalityReportScreen(
                            needsApiCall: checkResult.needsApiCall,
                            cachedReport: checkResult.cachedReport,
                            reportFuture: reportFuture,
                            myProfile: myProfile,
                            // null 체크가 완료되었으므로 ! 연산자를 사용하여 null이 아님을 명시합니다.
                            partnerProfile: partnerProfile!,
                          ),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              '프로필 정보가 없어 설명서를 볼 수 없습니다. 내 정보와 상대방 정보를 모두 등록해주세요.')),
                    );
                  }
                },
                child: const Text('자세히 보기')),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyQuestionCard(String? question) {
    return Card(
      elevation: 0,
      color: const Color(0xFF5B86E5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('이번 주 질문',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 12),
            Text(
              question ?? '질문을 불러오는 중입니다...',
              textAlign: TextAlign.center,
              style:
              TextStyle(fontSize: 20, color: Colors.white.withOpacity(0.9)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictGuideCard(
      BuildContext context, List<ConflictTopicModel> topics) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEAEBEE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('오늘의 갈등 해결 가이드',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (topics.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: Text('오늘은 갈등 없이 평온한 하루가 예상됩니다.')),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  return ListTile(
                    title: Text(topic.topic),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) =>
                      //         ConflictGuideScreen(topic: topic.topic),
                      //   ),
                      // );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
