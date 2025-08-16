import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/models/conflict_guide_model.dart';
import 'package:lovefortune_app/features/tips/conflict_guide_viewmodel.dart';

class ConflictGuideScreen extends ConsumerStatefulWidget {
  final String topic;
  const ConflictGuideScreen({super.key, required this.topic});

  @override
  ConsumerState<ConflictGuideScreen> createState() => _ConflictGuideScreenState();
}

class _ConflictGuideScreenState extends ConsumerState<ConflictGuideScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conflictGuideViewModelProvider.notifier).fetchGuide(widget.topic);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conflictGuideViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: Text(widget.topic)),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.errorMessage != null
            ? Center(child: Text(state.errorMessage!))
            : state.guide != null
            ? _buildContentView(state.guide!)
            : const Center(child: Text('가이드를 생성 중입니다...')),
      ),
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
