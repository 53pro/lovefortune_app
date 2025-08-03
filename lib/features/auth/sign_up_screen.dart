import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/features/auth/auth_viewmodel.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // 비밀번호 보이기/숨기기 상태
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // 이메일 중복 체크를 위한 디바운서
  Timer? _debounce;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onEmailChanged(String email) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(authViewModelProvider.notifier).checkEmailAvailability(email);
    });
  }

  void _signUp() {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('비밀번호가 일치하지 않습니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    ref.read(authViewModelProvider.notifier).signUpWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // ViewModel의 상태 변화를 감지하여 UI 피드백(스낵바 등)을 줍니다.
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      // 에러가 발생했을 경우
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
      // 회원가입에 성공했을 경우 (로딩이 끝났고, 이전 상태는 로딩 중이었을 때)
      else if (!next.isLoading && (previous?.isLoading ?? false)) {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원가입이 완료되었습니다. 로그인해주세요.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('이메일로 회원가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          // mainAxisAlignment를 .start로 변경하여 위젯을 상단으로 정렬합니다.
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20), // 상단 여백 추가
            TextField(
              controller: _emailController,
              onChanged: _onEmailChanged,
              decoration: InputDecoration(
                labelText: '이메일',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email_outlined),
                suffixIcon: _buildEmailSuffixIcon(authState.emailState),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: '비밀번호',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isPasswordVisible,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_person_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isConfirmPasswordVisible,
            ),
            const SizedBox(height: 24),
            if (authState.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: authState.emailState == EmailValidationState.available ? _signUp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B86E5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('회원가입 완료', style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }

  // 안정성을 위해 state 파라미터를 nullable(?)로 변경합니다.
  Widget? _buildEmailSuffixIcon(EmailValidationState? state) {
    // null일 경우 아무것도 표시하지 않습니다.
    if (state == null) return null;

    switch (state) {
      case EmailValidationState.checking:
        return const Padding(
          padding: EdgeInsets.all(12.0),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      case EmailValidationState.available:
        return const Icon(Icons.check_circle, color: Colors.green);
      case EmailValidationState.unavailable:
        return const Icon(Icons.cancel, color: Colors.red);
      case EmailValidationState.initial:
      default:
        return null;
    }
  }
}
