import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lovefortune_app/core/constants/ad_constants.dart';
import 'package:lovefortune_app/core/models/conflict_guide_model.dart';
import 'package:lovefortune_app/features/tips/tips_viewmodel.dart';

class ConflictGuideScreen extends ConsumerStatefulWidget {
  final String topic;
  final String category;
  final Future<ConflictGuideModel> guideFuture;

  const ConflictGuideScreen({
    super.key,
    required this.topic,
    required this.category,
    required this.guideFuture,
  });

  @override
  ConsumerState<ConflictGuideScreen> createState() => _ConflictGuideScreenState();
}

class _ConflictGuideScreenState extends ConsumerState<ConflictGuideScreen> {
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _adWatched = false;
  bool _adFailedToLoad = false; // 광고 로딩 실패 상태 추가
  late Future<ConflictGuideModel> _guideFuture;

  final adUnitId = AdConstants.specialAdviceRewardedAdUnitId;

  @override
  void initState() {
    super.initState();
    _guideFuture = widget.guideFuture;
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _rewardedAd = ad;
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          setState(() {
            _isAdLoaded = false;
            _adFailedToLoad = true;
          });
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) => ad.dispose(),
        onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
      );
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          setState(() {
            _adWatched = true;
          });
        },
      );
      _rewardedAd = null;
    }
  }

  // 재시도 버튼을 눌렀을 때 실행되는 함수
  void _retryFetch() {
    setState(() {
      // ViewModel의 함수를 다시 호출하여 새로운 Future를 생성하고 상태를 업데이트합니다.
      _guideFuture = ref.read(tipsViewModelProvider.notifier).fetchConflictGuide(widget.topic);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.topic)),
      body: SafeArea(
        child: _adWatched
            ? _buildFutureContent()
            : _buildAdPrompt(),
      ),
    );
  }

  Widget _buildAdPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 60, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              '갈등 해결 가이드가 잠겨있어요',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _adFailedToLoad
                  ? '광고를 불러오지 못했어요.\n아래 버튼을 눌러 바로 가이드를 확인하세요.'
                  : '짧은 광고를 시청하고\n맞춤 해결책을 확인해보세요!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            if (_adFailedToLoad)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _adWatched = true;
                  });
                },
                child: const Text('바로 가이드 보기'),
              )
            else
              ElevatedButton.icon(
                onPressed: _isAdLoaded ? _showRewardedAd : null,
                icon: _isAdLoaded
                    ? const Icon(Icons.slow_motion_video)
                    : const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                label: Text(_isAdLoaded ? '광고 보고 가이드 확인' : '광고 불러오는 중...'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B86E5),
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFutureContent() {
    return FutureBuilder<ConflictGuideModel>(
      future: _guideFuture, // 상태로 관리되는 Future를 사용합니다.
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // 에러 발생 시, 재시도 버튼을 포함한 UI를 보여줍니다.
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text('가이드를 불러오는 데 실패했습니다.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _retryFetch,
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          );
        }
        if (snapshot.hasData) {
          return _buildContentView(snapshot.data!);
        }
        return const Center(child: Text('가이드를 불러올 수 없습니다.'));
      },
    );
  }

  Widget _buildContentView(ConflictGuideModel guide) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          title: '나의 성향 분석',
          description: guide.analysisForMe,
          icon: Icons.person_outline,
          iconColor: const Color(0xFF5B86E5),
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: '상대방의 성향 분석',
          description: guide.analysisForPartner,
          icon: Icons.favorite_border,
          iconColor: const Color(0xFFFF8A8A),
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: '관계 솔루션',
          description: guide.solutionProposal,
          icon: Icons.lightbulb_outline,
          iconColor: const Color(0xFF34C759),
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: '대화 예시',
          description: '"${guide.dialogueExample}"',
          icon: Icons.chat_bubble_outline,
          iconColor: const Color(0xFFFF9F43),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(fontSize: 16, height: 1.7, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
