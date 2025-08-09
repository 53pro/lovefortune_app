import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/features/tips/tips_viewmodel.dart';

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
      ref.read(tipsViewModelProvider.notifier).fetchTips('1995-05-15', '1996-08-20');
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(tipsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('관계 팁'),
        actions: [
          // '팁 새로고침' 버튼으로 변경합니다.
          IconButton(
            icon: const Icon(Icons.casino_outlined),
            tooltip: '팁 새로고침',
            onPressed: () {
              // TODO: 여기에 리워드 광고 보기 로직을 추가합니다.
              viewModel.fetchTips('1995-05-15', '1996-08-20');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildRelationshipGuideCard(),
            const SizedBox(height: 16),
            _buildWeeklyQuestionCard(),
            const SizedBox(height: 16),
            _buildConflictGuideCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationshipGuideCard() {
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
            const Text('우리의 관계 설명서', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('두 분의 타고난 성향을 분석하여 서로를 더 깊이 이해할 수 있도록 도와드려요.', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: const Text('자세히 보기')),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyQuestionCard() {
    return Card(
      elevation: 0,
      color: const Color(0xFF5B86E5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('이번 주 질문', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            Text(
              '"요즘 나에게 가장 힘이 되었던 순간은 언제였어?"',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.white.withOpacity(0.9)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictGuideCard() {
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
            const Text('상황별 갈등 해결 가이드', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('연락 문제로 다퉜을 때'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              title: const Text('데이트 약속을 정할 때'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
