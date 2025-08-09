import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:lovefortune_app/features/tips/tips_viewmodel.dart'; // ViewModel (다음 단계에서 생성)

class TipsScreen extends ConsumerStatefulWidget {
  const TipsScreen({super.key});

  @override
  ConsumerState<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends ConsumerState<TipsScreen> {
  @override
  void initState() {
    super.initState();
    // TODO: 화면이 처음 로드될 때 ViewModel의 fetchTips 함수 호출
  }

  @override
  Widget build(BuildContext context) {
    // TODO: ViewModel의 상태를 watch하여 UI 업데이트

    return Scaffold(
      appBar: AppBar(
        title: const Text('관계 팁'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- 여기에 ViewModel과 연결된 카드들이 들어갑니다 ---

            // 예시 UI (데이터 연결 전)
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

  // 아래는 UI 구조를 보여주기 위한 예시 위젯들입니다.
  // 실제로는 ViewModel의 데이터로 채워져야 합니다.

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
