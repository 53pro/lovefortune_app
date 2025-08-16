// --- lib/features/tips/personality_report_screen.dart (수정) ---
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/models/personality_report_model.dart';
import 'package:lovefortune_app/features/tips/personality_report_viewmodel.dart';

class PersonalityReportScreen extends ConsumerStatefulWidget {
  const PersonalityReportScreen({super.key});

  @override
  ConsumerState<PersonalityReportScreen> createState() => _PersonalityReportScreenState();
}

class _PersonalityReportScreenState extends ConsumerState<PersonalityReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(personalityReportViewModelProvider.notifier).fetchReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(personalityReportViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('우리의 관계 설명서')),
      // body를 SafeArea로 감싸서 시스템 UI와의 겹침을 방지합니다.
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.errorMessage != null
            ? Center(child: Text(state.errorMessage!))
            : state.report != null
            ? _buildContentView(state.report!)
            : const Center(child: Text('리포트를 생성 중입니다...')),
      ),
    );
  }

  Widget _buildContentView(PersonalityReportModel report) {
    // 각 섹션이 명확히 구분되도록 ListView의 구성을 변경합니다.
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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

  // 각 섹션을 Card 위젯으로 감싸 시각적으로 분리합니다.
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
