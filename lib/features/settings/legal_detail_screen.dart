import 'package:flutter/material.dart';
import 'package:lovefortune_app/core/theme/app_theme.dart';
import 'package:lovefortune_app/core/constants/legal_texts.dart';

enum LegalType { terms, privacy }

class LegalDetailScreen extends StatelessWidget {
  final LegalType type;

  const LegalDetailScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final title = type == LegalType.terms ? '이용약관' : '개인정보 처리방침';
    final content = type == LegalType.terms
        ? LegalTexts.termsOfService
        : LegalTexts.privacyPolicy;

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.canvas,
        foregroundColor: AppTheme.ink,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 14.0,
              color: AppTheme.body,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}
