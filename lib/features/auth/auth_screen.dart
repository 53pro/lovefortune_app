import 'package:lovefortune_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/features/auth/auth_viewmodel.dart';
import 'package:lovefortune_app/features/settings/legal_detail_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final authViewModel = ref.read(authViewModelProvider.notifier);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Center(child: Image.asset('assets/images/auth_couple.png', height: 240)),
              const SizedBox(height: 32),
              const Text(
                '오늘 우리는',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '로그인하여 당신의 연애 운세를 확인하세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.muted,
                ),
              ),
              const SizedBox(height: 100),
              if (authState.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                _buildSocialLoginButtons(authViewModel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButtons(AuthViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            viewModel.signInWithGoogle();
          },
          icon: const FaIcon(
            FontAwesomeIcons.google,
            color: AppTheme.brandCoral,
          ),
          label: const Text(
            'Google로 로그인',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.ink,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.canvas,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: AppTheme.muted, width: 0.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            viewModel.signInWithApple();
          },
          icon: const FaIcon(
            FontAwesomeIcons.apple,
            color: AppTheme.onPrimary,
          ),
          label: const Text(
            'Apple로 로그인',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.onPrimary,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.ink,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildLegalNotice(),
      ],
    );
  }

  Widget _buildLegalNotice() {
    const linkStyle = TextStyle(
      fontSize: 12,
      color: AppTheme.ink,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
    );
    const normalStyle = TextStyle(
      fontSize: 12,
      color: AppTheme.muted,
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text('로그인 진행 시 ', style: normalStyle),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const LegalDetailScreen(type: LegalType.terms),
              ),
            );
          },
          child: const Text('이용약관', style: linkStyle),
        ),
        const Text(' 및 ', style: normalStyle),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const LegalDetailScreen(type: LegalType.privacy),
              ),
            );
          },
          child: const Text('개인정보 처리방침', style: linkStyle),
        ),
        const Text('에 동의하는 것으로 간주됩니다.', style: normalStyle),
      ],
    );
  }
}
