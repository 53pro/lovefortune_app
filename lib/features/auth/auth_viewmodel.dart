import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

final logger = Logger();

// 이메일 유효성 검사 상태를 나타내는 enum
enum EmailValidationState { initial, checking, available, unavailable }

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final EmailValidationState emailState;

  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.emailState = EmailValidationState.initial,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    EmailValidationState? emailState,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      emailState: emailState ?? this.emailState,
    );
  }
}

class AuthViewModel extends Notifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  AuthState build() {
    return AuthState();
  }

  // 이메일 중복 여부를 확인하는 함수
  Future<void> checkEmailAvailability(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      state = state.copyWith(emailState: EmailValidationState.initial);
      return;
    }
    state = state.copyWith(emailState: EmailValidationState.checking);
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isEmpty) {
        state = state.copyWith(emailState: EmailValidationState.available);
      } else {
        state = state.copyWith(emailState: EmailValidationState.unavailable);
      }
    } catch (e) {
      // 이메일 형식이 잘못된 경우 등
      state = state.copyWith(emailState: EmailValidationState.initial);
    }
  }

  // 이메일/비밀번호로 회원가입
  Future<void> signUpWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    logger.i('회원가입 시도: email: $email');

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(isLoading: false);
      logger.i('회원가입 성공: email: $email');
    } on FirebaseAuthException catch (e) {
      logger.e('Firebase 회원가입 에러: code: ${e.code}, message: ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = '비밀번호가 너무 약합니다. 6자 이상으로 설정해주세요.';
          break;
        case 'email-already-in-use':
          errorMessage = '이미 사용 중인 이메일입니다.';
          break;
        case 'invalid-email':
          errorMessage = '유효하지 않은 이메일 형식입니다.';
          break;
        default:
          errorMessage = '회원가입 중 오류가 발생했습니다. 다시 시도해주세요.';
      }
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
    } catch (e) {
      logger.e('알 수 없는 회원가입 에러: $e');
      state = state.copyWith(isLoading: false, errorMessage: '알 수 없는 오류가 발생했습니다.');
    }
  }

  // 이메일/비밀번호로 로그인
  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    logger.i('로그인 시도: email: $email');

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(isLoading: false);
      logger.i('로그인 성공: email: $email');
    } on FirebaseAuthException catch (e) {
      logger.e('Firebase 로그인 에러: code: ${e.code}, message: ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'invalid-credential':
          errorMessage = '이메일 또는 비밀번호가 올바르지 않습니다.';
          break;
        case 'user-disabled':
          errorMessage = '사용이 중지된 계정입니다.';
          break;
        default:
          errorMessage = '로그인 중 오류가 발생했습니다. 다시 시도해주세요.';
      }
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
    } catch (e) {
      logger.e('알 수 없는 로그인 에러: $e');
      state = state.copyWith(isLoading: false, errorMessage: '알 수 없는 오류가 발생했습니다.');
    }
  }

  // 구글 로그인
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    logger.i('구글 로그인 시도');
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        logger.w('구글 로그인이 사용자에 의해 취소되었습니다.');
        return;
      }
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      state = state.copyWith(isLoading: false);
      logger.i('구글 로그인 성공: email: ${googleUser.email}');
    } catch (e) {
      logger.e('구글 로그인 에러: $e');
      state = state.copyWith(
          isLoading: false, errorMessage: '구글 로그인에 실패했습니다. 다시 시도해주세요.');
    }
  }
}

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
      () => AuthViewModel(),
);
