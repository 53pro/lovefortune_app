import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lovefortune_app/core/constants/ad_constants.dart';
import 'package:lovefortune_app/core/models/personality_report_model.dart';
import 'package:lovefortune_app/core/models/profile_model.dart'; // ProfileModel을 사용하기 위해 import

class PersonalityReportScreen extends StatefulWidget {
  final Future<PersonalityReportModel> reportFuture;
  // 애칭을 표시하기 위해 프로필 정보를 전달받습니다.
  final ProfileModel myProfile;
  final ProfileModel partnerProfile;

  const PersonalityReportScreen({
    super.key,
    required this.reportFuture,
    required this.myProfile,
    required this.partnerProfile,
  });

  @override
  State<PersonalityReportScreen> createState() => _PersonalityReportScreenState();
}

class _PersonalityReportScreenState extends State<PersonalityReportScreen> {
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _adWatched = false;

  final adUnitId = AdConstants.specialAdviceRewardedAdUnitId;

  @override
  void initState() {
    super.initState();
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
          });
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadRewardedAd();
        },
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

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('우리의 관계 설명서')),
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
              '관계 설명서가 잠겨있어요',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '짧은 광고를 시청하고\n두 분의 관계 설명서를 확인해보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isAdLoaded ? _showRewardedAd : null,
              icon: _isAdLoaded
                  ? const Icon(Icons.slow_motion_video)
                  : const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              label: Text(_isAdLoaded ? '광고 보고 설명서 확인' : '광고 불러오는 중...'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B86E5),
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

  Widget _buildFutureContent() {
    return FutureBuilder<PersonalityReportModel>(
      future: widget.reportFuture,
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
        return const Center(child: Text('리포트를 불러올 수 없습니다.'));
      },
    );
  }

  Widget _buildContentView(PersonalityReportModel report) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 상단에 프로필 헤더를 추가합니다.
        _buildCoupleHeader(),
        const SizedBox(height: 16),
        _buildSection(
          title: report.myPersonalityTitle,
          description: report.myPersonalityDescription,
          icon: Icons.person_outline,
          iconColor: const Color(0xFF5B86E5),
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: report.partnerPersonalityTitle,
          description: report.partnerPersonalityDescription,
          icon: Icons.favorite_border,
          iconColor: const Color(0xFFFF8A8A),
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: '두 분의 시너지',
          description: report.relationshipSynergy,
          icon: Icons.auto_awesome_outlined,
          iconColor: const Color(0xFF34C759),
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: '기억해주세요',
          description: report.relationshipCaution,
          icon: Icons.shield_outlined,
          iconColor: const Color(0xFFFF9F43),
        ),
      ],
    );
  }

  // 프로필 헤더를 생성하는 위젯 (추가)
  Widget _buildCoupleHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProfile(widget.myProfile, const Color(0xFF5B86E5)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(Icons.favorite, color: Color(0xFFFF8A8A), size: 28),
          ),
          _buildProfile(widget.partnerProfile, const Color(0xFFFF8A8A)),
        ],
      ),
    );
  }

  // 헤더에 사용될 프로필 위젯 (추가)
  Widget _buildProfile(ProfileModel profile, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: color,
          child: Text(
            profile.nickname.isNotEmpty ? profile.nickname[0] : '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          profile.nickname,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
