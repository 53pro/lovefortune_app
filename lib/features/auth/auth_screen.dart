import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/features/auth/auth_viewmodel.dart';
import 'package:lovefortune_app/features/auth/sign_up_screen.dart'; // 새로 만든 화면 import

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final authViewModel = ref.read(authViewModelProvider.notifier);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
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
              const SizedBox(height: 60),
              const Text(
                '오늘 우리는',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5B86E5),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '로그인하여 당신의 연애 운세를 확인하세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '이메일',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              if (authState.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                _buildAuthButtons(authViewModel),
              const SizedBox(height: 24),
              _buildSocialLoginDivider(),
              const SizedBox(height: 24),
              _buildSocialLoginButtons(authViewModel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButtons(AuthViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            viewModel.signInWithEmail(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5B86E5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text('이메일로 로그인', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            // 회원가입 로직 대신, SignUpScreen으로 이동하도록 수정
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SignUpScreen()),
            );
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text('이메일로 회원가입'),
        ),
      ],
    );
  }

  Widget _buildSocialLoginDivider() {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('또는', style: TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSocialLoginButtons(AuthViewModel viewModel) {
    return Center( // 버튼을 중앙에 배치하기 위해 Center 위젯 사용
      child: IconButton(
        onPressed: () {
          viewModel.signInWithGoogle();
        },
        // Image.network 대신 Image.asset을 사용하여 프로젝트 내부 이미지를 불러옵니다.
        icon: Image.asset('assets/images/google_logo.png', height: 40),
        iconSize: 50,
      ),
    );
  }
}
