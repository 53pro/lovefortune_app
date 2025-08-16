import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // AdMob 라이브러리 import
import 'package:intl/intl.dart';
import 'package:lovefortune_app/core/constants/ad_constants.dart'; // 광고 상수 파일 import
import 'package:lovefortune_app/core/models/profile_model.dart';
import 'package:lovefortune_app/features/home/home_viewmodel.dart';
import 'package:lovefortune_app/features/self_discovery/self_discovery_screen.dart';
import 'package:lovefortune_app/features/special_advice/special_advice_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DateTime? lastPressed;
  NativeAd? _nativeAd;
  bool _isNativeAdLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeViewModelProvider.notifier).fetchHoroscope();
    });
    _loadNativeAd(); // 화면이 시작될 때 네이티브 광고를 불러옵니다.
  }

  @override
  void dispose() {
    _nativeAd?.dispose(); // 화면이 사라질 때 광고를 해제합니다.
    super.dispose();
  }

  // 네이티브 광고를 불러오는 함수
  void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: AdConstants.homeNativeAdUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isNativeAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
      request: const AdRequest(),
      // 광고의 디자인을 우리 앱 스타일에 맞게 설정합니다.
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white,
        cornerRadius: 16.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: const Color(0xFF5B86E5),
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.grey,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
      ),
    );
    _nativeAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        final now = DateTime.now();
        final isWarning = lastPressed == null || now.difference(lastPressed!) > const Duration(seconds: 2);
        if (isWarning) {
          lastPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('한 번 더 누르면 종료됩니다.'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('오늘 우리는'),
          actions: [
            IconButton(
              icon: const Icon(Icons.casino_outlined),
              tooltip: '운명 새로고침',
              onPressed: () {
                viewModel.fetchHoroscope();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => viewModel.fetchHoroscope(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDateHeader(),
                    _buildCoupleInfoSection(state),
                    const SizedBox(height: 24),
                    if (state.isLoading)
                      const Center(heightFactor: 5, child: CircularProgressIndicator())
                    else if (state.errorMessage != null)
                      Center(heightFactor: 5, child: Text(state.errorMessage!))
                    else if (state.horoscope != null)
                        Column(
                          children: [
                            _buildHoroscopeCard(state),
                            const SizedBox(height: 16),
                            _buildAdviceCard(state),
                            const SizedBox(height: 16),
                            // --- 네이티브 광고 섹션 ---
                            if (_isNativeAdLoaded && _nativeAd != null)
                              Container(
                                height: 320, // 광고 템플릿에 맞는 높이
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFEAEBEE)),
                                ),
                                child: AdWidget(ad: _nativeAd!),
                              ),
                            if (_isNativeAdLoaded) const SizedBox(height: 16),
                            // --- 자기 발견 카드 ---
                            _buildSelfDiscoveryCard(context, state),
                            const SizedBox(height: 16),
                            _buildDateCard(state),
                          ],
                        )
                      else
                        const Center(heightFactor: 5, child: Text('오늘의 운세를 확인해보세요!')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    final today = DateTime.now();
    final formattedDate = DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR').format(today);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.only(bottom: 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEBEE)),
      ),
      child: Center(
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              fontFamily: 'Pretendard',
            ),
            children: <TextSpan>[
              TextSpan(text: '${DateFormat('yyyy년 MM월 dd일').format(today)} '),
              TextSpan(
                text: DateFormat('EEEE', 'ko_KR').format(today),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5B86E5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoupleInfoSection(HomeState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildProfile('나', state.myProfile, const Color(0xFF5B86E5)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Icon(Icons.favorite, color: Color(0xFFFF8A8A), size: 28),
        ),
        _buildProfile('너', state.partnerProfile, const Color(0xFFFF8A8A)),
      ],
    );
  }

  Widget _buildProfile(String title, ProfileModel? profile, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: color,
          backgroundImage: profile?.imageUrl != null
              ? NetworkImage(profile!.imageUrl!)
              : null,
          child: profile?.imageUrl == null
              ? Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          profile?.nickname ?? (title == '나' ? '나' : '상대방'),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildHoroscopeCard(HomeState state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEAEBEE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              '오늘의 궁합 지수는?',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Text(
              '${state.horoscope!.compatibilityScore}점',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: Color(0xFFFF8A8A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.horoscope!.summary,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceCard(HomeState state) {
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
            const _CardTitle(icon: Icons.lightbulb_outline, title: '상세 조언 보기'),
            const SizedBox(height: 16),
            _AdviceItem(
              icon: Icons.sentiment_very_satisfied,
              iconColor: Colors.green,
              title: '긍정적인 점',
              content: state.horoscope!.positiveAdvice,
            ),
            const SizedBox(height: 12),
            _AdviceItem(
              icon: Icons.sentiment_neutral,
              iconColor: Colors.orange,
              title: '주의할 점',
              content: state.horoscope!.cautionAdvice,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (state.myProfile != null && state.partnerProfile != null) {
                  final viewModel = ref.read(homeViewModelProvider.notifier);
                  final adviceFuture = viewModel.fetchSpecialAdvice();
                  await Future.delayed(const Duration(seconds: 3));
                  if (mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SpecialAdviceScreen(
                          adviceFuture: adviceFuture,
                        ),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('프로필 정보가 없어 스페셜 조언을 볼 수 없습니다.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A8A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_collection, color: Colors.white),
                  SizedBox(width: 8),
                  Text('광고 보고 스페셜 조언 보기',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSelfDiscoveryCard(BuildContext context, HomeState state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEAEBEE)),
      ),
      child: InkWell(
        onTap: () {
          if (state.myProfile != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SelfDiscoveryScreen(myProfile: state.myProfile!),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('내 정보가 없어 팁을 볼 수 없습니다.')),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(Icons.psychology_outlined, color: const Color(0xFF5B86E5), size: 32),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('새로운 나를 발견하는 시간', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('오늘의 나를 위한 성장 팁 확인하기', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateCard(HomeState state) {
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
            const _CardTitle(icon: Icons.calendar_today, title: '오늘의 추천 데이트'),
            const SizedBox(height: 16),
            Text(state.horoscope!.recommendedDate, style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _CardTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _AdviceItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;

  const _AdviceItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(content, style: TextStyle(color: Colors.grey[700], height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }
}
