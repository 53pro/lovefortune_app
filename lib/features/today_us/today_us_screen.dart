import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:lovefortune_app/core/constants/ad_constants.dart';
import 'package:lovefortune_app/core/models/profile_model.dart';
import 'package:lovefortune_app/features/self_discovery/self_discovery_screen.dart';
import 'package:lovefortune_app/features/special_advice/special_advice_screen.dart';
import 'package:lovefortune_app/features/settings/settings_screen.dart';
import 'package:lovefortune_app/features/today_us/today_us_viewmodel.dart';

class TodayUsScreen extends ConsumerStatefulWidget {
  const TodayUsScreen({super.key});

  @override
  ConsumerState<TodayUsScreen> createState() => _TodayUsScreenState();
}

class _TodayUsScreenState extends ConsumerState<TodayUsScreen> {
  DateTime? lastPressed;
  NativeAd? _nativeAd;
  bool _isNativeAdLoaded = false;
  // 중복 실행을 방지하기 위한 상태 변수를 추가합니다.
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(todayUsViewModelProvider.notifier).fetchHoroscope();
    });
    _loadNativeAd();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: AdConstants.homeNativeAdUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isNativeAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
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
    final state = ref.watch(todayUsViewModelProvider);
    final viewModel = ref.read(todayUsViewModelProvider.notifier);

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
          title: const Text('오늘우리'),
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
                    else if (state.isProfileIncomplete)
                      _buildIncompleteProfileWidget(context)
                    else if (state.errorMessage != null)
                        _buildErrorWidget(context, viewModel)
                      else if (state.horoscope != null)
                          Column(
                            children: [
                              _buildHoroscopeCard(state),
                              const SizedBox(height: 16),
                              _buildAdviceCard(state),
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

  Widget _buildErrorWidget(BuildContext context, TodayUsViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined, color: Colors.grey, size: 48),
            const SizedBox(height: 16),
            const Text(
              '운세를 불러오는 데 실패했어요.\n네트워크 연결을 확인해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                viewModel.fetchHoroscope();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('다시 불러오기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B86E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIncompleteProfileWidget(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, color: Colors.grey, size: 48),
            const SizedBox(height: 16),
            const Text(
              '우선 나랑 상대방의 생일 정보를 입력해주세요',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
              icon: const Icon(Icons.edit_note),
              label: const Text('정보 입력하러 가기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B86E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          ],
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

  Widget _buildCoupleInfoSection(TodayUsState state) {
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

  Widget _buildHoroscopeCard(TodayUsState state) {
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

  Widget _buildAdviceCard(TodayUsState state) {
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
              // 버튼이 이미 눌렸는지(_isProcessing) 확인하여 중복 실행을 방지합니다.
              onPressed: _isProcessing ? null : () async {
                // 이미 처리 중이면 아무것도 하지 않습니다.
                if (_isProcessing) return;

                // 처리 시작을 알립니다.
                setState(() {
                  _isProcessing = true;
                });

                try {
                  if (state.myProfile != null && state.partnerProfile != null) {
                    final viewModel = ref.read(todayUsViewModelProvider.notifier);
                    final adviceFuture = viewModel.fetchSpecialAdvice();

                    // TODO: 여기에 실제 리워드 광고 로직을 추가합니다.
                    await Future.delayed(const Duration(seconds: 1)); // 광고 시청 시간 흉내

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
                } finally {
                  // 작업이 끝나면(성공하든 실패하든) 플래그를 다시 false로 설정합니다.
                  if (mounted) {
                    setState(() {
                      _isProcessing = false;
                    });
                  }
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
              child: _isProcessing
                  ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Row(
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

  Widget _buildSelfDiscoveryCard(BuildContext context, TodayUsState state) {
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

  Widget _buildDateCard(TodayUsState state) {
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
