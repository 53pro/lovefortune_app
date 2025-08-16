import 'package:flutter/material.dart';
import 'package:lovefortune_app/core/models/special_advice_model.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lovefortune_app/core/constants/ad_constants.dart';

// StatefulWidget으로 변경하여 광고 로딩 및 표시 상태를 관리합니다.
class SpecialAdviceScreen extends StatefulWidget {
  final Future<SpecialAdviceModel> adviceFuture;

  const SpecialAdviceScreen({
    super.key,
    required this.adviceFuture,
  });

  @override
  State<SpecialAdviceScreen> createState() => _SpecialAdviceScreenState();
}

class _SpecialAdviceScreenState extends State<SpecialAdviceScreen> {
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _adWatched = false;

  // AdConstants에서 광고 유닛 ID를 가져옵니다.
  final adUnitId = AdConstants.specialAdviceRewardedAdUnitId;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  // 리워드 광고를 불러오는 함수
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
          });
        },
      ),
    );
  }

  // 광고를 보여주는 함수
  void _showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadRewardedAd(); // 다음을 위해 새 광고 로드
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadRewardedAd();
        },
      );
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          // 사용자가 광고 시청을 완료했을 때
          setState(() {
            _adWatched = true;
          });
        },
      );
      _rewardedAd = null;
    }
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 스페셜 조언'),
      ),
      // 광고 시청 여부에 따라 다른 UI를 보여줍니다.
      body: _adWatched
          ? _buildFutureContent() // 광고 시청 완료 후: 조언 내용 표시
          : _buildAdPrompt(), // 광고 시청 전: 광고 보기 버튼 표시
    );
  }

  // 광고 시청을 유도하는 UI
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
              '비밀 조언이 잠겨있어요',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '짧은 광고를 시청하고\n오늘의 스페셜 조언을 확인해보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              // 광고가 로드되었을 때만 버튼 활성화
              onPressed: _isAdLoaded ? _showRewardedAd : null,
              icon: _isAdLoaded
                  ? const Icon(Icons.slow_motion_video)
                  : const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              label: Text(_isAdLoaded ? '광고 보고 조언 확인하기' : '광고 불러오는 중...'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FutureBuilder를 사용하여 조언 내용을 표시하는 UI
  Widget _buildFutureContent() {
    return FutureBuilder<SpecialAdviceModel>(
      future: widget.adviceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('오류: ${snapshot.error}'));
        }
        if (snapshot.hasData) {
          return _buildContentView(snapshot.data!);
        }
        return const Center(child: Text('조언을 불러올 수 없습니다.'));
      },
    );
  }

  Widget _buildContentView(SpecialAdviceModel advice) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildAdviceCard(
            icon: Icons.vpn_key_outlined,
            title: '우리 둘만의 비밀 코드',
            content: advice.synergyPoint,
            highlight: advice.conflictWarning,
            iconColor: const Color(0xFF5B86E5),
          ),
          const SizedBox(height: 16),
          _buildAdviceCard(
            icon: Icons.timelapse_outlined,
            title: '미래 엿보기',
            content: advice.weekendForecast,
            highlight: advice.monthlyLuckyDay,
            iconColor: const Color(0xFFFF8A8A),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard({
    required IconData icon,
    required String title,
    required String content,
    required String highlight,
    required Color iconColor,
  }) {
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
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(content, style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[700])),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                highlight,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: iconColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
