import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lovefortune_app/core/constants/ad_constants.dart';
import 'package:lovefortune_app/core/models/conflict_topic_model.dart';
import 'package:lovefortune_app/core/models/personality_report_model.dart';
import 'package:lovefortune_app/core/models/profile_model.dart';
import 'package:lovefortune_app/features/main/main_screen.dart';
import 'package:lovefortune_app/features/settings/settings_viewmodel.dart';
import 'package:lovefortune_app/features/tips/conflict_guide_screen.dart';
import 'package:lovefortune_app/features/tips/personality_report_screen.dart';
import 'package:lovefortune_app/features/tips/tips_viewmodel.dart';
import 'package:lovefortune_app/utils/dialogs.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class TipsScreen extends ConsumerStatefulWidget {
  const TipsScreen({super.key});

  @override
  ConsumerState<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends ConsumerState<TipsScreen> {
  NativeAd? _nativeAd;
  bool _isNativeAdLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tipsViewModelProvider.notifier).fetchTips();
    });
    _loadNativeAd();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  void _loadNativeAd() {
    logger.i('네이티브 광고 로드를 시작합니다...');
    _nativeAd = NativeAd(
      adUnitId: AdConstants.tipsNativeAdUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          logger.i('✅ 네이티브 광고 로드 성공!');
          if (mounted) {
            setState(() {
              _isNativeAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          logger.e('⛔ 네이티브 광고 로드 실패:', error: error);
          ad.dispose();
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white,
        cornerRadius: 16.0,
      ),
    );
    _nativeAd!.load();
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
            if (_isNativeAdLoaded && _nativeAd != null)
              Container(
                height: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEAEBEE)),
                ),
                child: AdWidget(ad: _nativeAd!),
              ),
            if (_isNativeAdLoaded) const SizedBox(height: 16),
            _buildConflictGuideCard(context, ref, settingsState, state.conflictTopics),
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
                            partnerProfile: partnerProfile!,
                          ),
                        ),
                      );
                    }
                  } else {
                    showProfileNeededPopup(context, ref);
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
      BuildContext context, WidgetRef ref, SettingsState settingsState, List<ConflictTopicModel> topics) {
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
                        final guideFuture = ref.read(tipsViewModelProvider.notifier).fetchConflictGuide(topic.topic);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ConflictGuideScreen(
                              topic: topic.topic,
                              category: topic.category,
                              guideFuture: guideFuture,
                            ),
                          ),
                        );
                      } else {
                        showProfileNeededPopup(context, ref);
                      }
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
