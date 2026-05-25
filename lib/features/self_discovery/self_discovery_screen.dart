import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/theme/app_theme.dart';
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Image.asset('assets/images/discovery_couple.png', height: 160)),
            const SizedBox(height: 16),
            // 오늘의 테마
            _buildThemeCard(tip.dailyTheme),
            const SizedBox(height: 20),
            
            // 심층 분석
            _buildAnalysisCard(tip.detailedAnalysis),
            const SizedBox(height: 20),
            
            // 성장 팁 & 실천 가이드
            _buildActionCard(tip.growthTip, tip.actionableSteps),
            const SizedBox(height: 20),
  
            // 추천 습관
            _buildHabitCard(tip.recommendedHabit),
            const SizedBox(height: 20),
            
            // 성찰 질문
            _buildQuestionCard(tip.reflectiveQuestion),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(String theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.brandLavender,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, color: AppTheme.ink, size: 40),
          const SizedBox(height: 16),
          const Text(
            '오늘의 테마',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.ink),
          ),
          const SizedBox(height: 8),
          Text(
            theme,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.ink),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(String analysis) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: AppTheme.primary),
              const SizedBox(width: 8),
              const Text('심층 분석', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.ink)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            analysis,
            style: const TextStyle(fontSize: 16, height: 1.6, color: AppTheme.body),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String tip, List<String> steps) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.brandTeal,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates, color: AppTheme.onDark),
              const SizedBox(width: 8),
              const Text('성장 팁 & 실천 가이드', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.onDark)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            tip,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.5, color: AppTheme.onDark),
          ),
          const SizedBox(height: 24),
          if (steps.isNotEmpty) ...[
            const Text('이렇게 실천해보세요:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.brandMint)),
            const SizedBox(height: 12),
            ...steps.map((step) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16, color: AppTheme.onDark, fontWeight: FontWeight.bold)),
                  Expanded(child: Text(step, style: const TextStyle(fontSize: 16, height: 1.5, color: AppTheme.onDark))),
                ],
              ),
            )),
          ]
        ],
      ),
    );
  }

  Widget _buildHabitCard(String habit) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.brandPeach,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: AppTheme.ink, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('추천 습관', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.ink)),
                const SizedBox(height: 8),
                Text(habit, style: const TextStyle(fontSize: 16, height: 1.5, color: AppTheme.ink)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuestionCard(String question) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.brandPink,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline, color: AppTheme.onDark),
              const SizedBox(width: 8),
              const Text('오늘의 성찰 질문', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.onDark)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.5, color: AppTheme.onDark),
          ),
        ],
      ),
    );
  }
}