import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/features/home/home_viewmodel.dart';
import 'package:lovefortune_app/features/settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 스트리밍 함수 대신 일반 함수를 호출하도록 수정합니다.
      ref
          .read(homeViewModelProvider.notifier)
          .fetchHoroscope('1995-05-15', '1996-08-20');
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘 우리는'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          // 새로고침 시에도 일반 함수를 호출하도록 수정합니다.
          onRefresh: () => viewModel.fetchHoroscope('1995-05-15', '1996-08-20'),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCoupleInfoSection(),
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
                          _buildNativeAdCard(),
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
    );
  }

  Widget _buildCoupleInfoSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildProfile('나', '코딩이', const Color(0xFF5B86E5)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Icon(Icons.favorite, color: Color(0xFFFF8A8A), size: 28),
        ),
        _buildProfile('너', '파트너', const Color(0xFFFF8A8A)),
      ],
    );
  }

  Widget _buildProfile(String title, String name, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: color,
          child: Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
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
              onPressed: () {
                // 리워드 광고 로직 호출
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

  Widget _buildNativeAdCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEAEBEE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sponsored', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                'https://placehold.co/600x300/5B86E5/FFFFFF?text=Awesome+Product',
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  height: 150,
                  child: Center(child: Text('Image not available')),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('새로운 나를 발견하는 시간', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('당신만을 위한 특별한 아이템을 만나보세요.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B86E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: const Text('자세히 보기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
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
