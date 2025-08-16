// --- lib/features/self_discovery/self_discovery_screen.dart (신규 생성) ---
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/models/profile_model.dart';
import 'package:lovefortune_app/core/models/self_discovery_model.dart';
import 'package:lovefortune_app/features/self_discovery/self_discovery_viewmodel.dart';

class SelfDiscoveryScreen extends ConsumerStatefulWidget {
  final ProfileModel myProfile;

  const SelfDiscoveryScreen({super.key, required this.myProfile});

  @override
  ConsumerState<SelfDiscoveryScreen> createState() => _SelfDiscoveryScreenState();
}

class _SelfDiscoveryScreenState extends ConsumerState<SelfDiscoveryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selfDiscoveryViewModelProvider.notifier).fetchSelfDiscoveryTip(widget.myProfile);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(selfDiscoveryViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('새로운 나를 발견하는 시간'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? Center(child: Text(state.errorMessage!))
          : state.tip != null
          ? _buildContentView(state.tip!)
          : const Center(child: Text('팁을 불러오는 중입니다...')),
    );
  }

  Widget _buildContentView(SelfDiscoveryModel tip) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTipCard(
            icon: Icons.explore_outlined,
            title: '오늘의 테마',
            content: tip.dailyTheme,
            iconColor: const Color(0xFF5B86E5),
            isLarge: true,
          ),
          const SizedBox(height: 16),
          _buildTipCard(
            icon: Icons.lightbulb_outline,
            title: '성장 팁',
            content: tip.growthTip,
            iconColor: const Color(0xFF34C759),
          ),
          const SizedBox(height: 16),
          _buildTipCard(
            icon: Icons.question_answer_outlined,
            title: '성찰 질문',
            content: tip.reflectiveQuestion,
            iconColor: const Color(0xFFFF9F43),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required String content,
    required Color iconColor,
    bool isLarge = false,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              textAlign: isLarge ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                fontSize: isLarge ? 22 : 16,
                height: 1.6,
                color: isLarge ? Colors.black : Colors.grey[700],
                fontWeight: isLarge ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}