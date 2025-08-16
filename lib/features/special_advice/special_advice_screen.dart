import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/models/profile_model.dart';
import 'package:lovefortune_app/core/models/special_advice_model.dart';
import 'package:lovefortune_app/features/special_advice/special_advice_viewmodel.dart';

class SpecialAdviceScreen extends ConsumerStatefulWidget {
  // 홈 화면에서 전달받을 프로필 정보
  final ProfileModel myProfile;
  final ProfileModel partnerProfile;

  const SpecialAdviceScreen({
    super.key,
    required this.myProfile,
    required this.partnerProfile,
  });

  @override
  ConsumerState<SpecialAdviceScreen> createState() => _SpecialAdviceScreenState();
}

class _SpecialAdviceScreenState extends ConsumerState<SpecialAdviceScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 처음 로드될 때, 전달받은 프로필 정보로 스페셜 조언을 요청합니다.
    // 이 코드가 빠져있어서 데이터 로딩이 시작되지 않았습니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(specialAdviceViewModelProvider.notifier)
          .fetchSpecialAdvice(widget.myProfile, widget.partnerProfile);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(specialAdviceViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 스페셜 조언'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? Center(child: Text(state.errorMessage!))
          : state.advice != null
          ? _buildContentView(state.advice!)
          : const Center(child: Text('조언을 불러오는 중입니다...')),
    );
  }

  Widget _buildContentView(SpecialAdviceModel advice) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildAdviceCard(
            icon: Icons.vpn_key_outlined,
            title: '우리 둘만의 비밀 코드',
            content: advice.synergyPoint,
            highlight: advice.conflictWarning,
            iconColor: const Color(0xFF5B86E5),
          ),
          const SizedBox(height: 16),
          _buildAdviceCard(
            icon: Icons.timelapse_outlined,
            title: '미래 엿보기',
            content: advice.weekendForecast,
            highlight: advice.monthlyLuckyDay,
            iconColor: const Color(0xFFFF8A8A),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard({
    required IconData icon,
    required String title,
    required String content,
    required String highlight,
    required Color iconColor,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(content, style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[700])),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                highlight,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: iconColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
