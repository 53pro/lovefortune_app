import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lovefortune_app/core/theme/app_theme.dart';
import 'package:lovefortune_app/features/today_us/today_us_viewmodel.dart';
import '../models/compatibility_info.dart';
import '../viewmodels/love_counseling_viewmodel.dart';

class PostWriteScreen extends ConsumerStatefulWidget {
  const PostWriteScreen({super.key});

  @override
  ConsumerState<PostWriteScreen> createState() => _PostWriteScreenState();
}

class _PostWriteScreenState extends ConsumerState<PostWriteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();

  final List<String> _tags = [];
  bool _attachCompatibility = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final cleaned = tag.trim().replaceAll('#', '');
    if (cleaned.isNotEmpty && !_tags.contains(cleaned)) {
      setState(() {
        _tags.add(cleaned);
      });
    }
    _tagController.clear();
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      CompatibilityInfo? compatInfo;

      if (_attachCompatibility) {
        final todayUsState = ref.read(todayUsViewModelProvider);
        final horoscope = todayUsState.horoscope;
        final partner = todayUsState.partnerProfile;

        if (horoscope != null && partner != null) {
          final score = horoscope.compatibilityScore;
          
          // Style displayText based on score range
          String displayText = '$score% 궁합';
          if (score >= 90) {
            displayText = '$score% 찰떡궁합';
          } else if (score >= 70) {
            displayText = '$score% 좋은궁합';
          } else if (score >= 50) {
            displayText = '$score% 보통궁합';
          }

          compatInfo = CompatibilityInfo(
            partnerId: partner.id,
            partnerNickname: '',
            score: score,
            type: 'chemistry',
            displayText: displayText,
            tag: '#$displayText',
            createdAt: DateTime.now(),
          );
        }
      }

      await ref.read(loveCounselingViewModelProvider.notifier).createPost(
            content: _contentController.text.trim(),
            customTags: _tags.map((t) => '#$t').toList(),
            compatibilityInfo: compatInfo,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('연애 고민글이 성공적으로 등록되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록에 실패했습니다: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayUsState = ref.watch(todayUsViewModelProvider);
    final hasCompatibility = todayUsState.horoscope != null && todayUsState.partnerProfile != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('고민 올리기'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                  )
                : const Text(
                    '등록',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.brandPink,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSoft,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.hairline),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_person_outlined, size: 20, color: AppTheme.brandPink),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '이 대나무숲은 100% 익명으로 작성됩니다. 본인의 실명이나 아이디는 다른 사람에게 절대 노출되지 않으니 안심하세요.',
                        style: TextStyle(fontSize: 12, color: AppTheme.body, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Content input
              TextFormField(
                controller: _contentController,
                maxLength: 1000,
                maxLines: 8,
                minLines: 4,
                decoration: const InputDecoration(
                  labelText: '내용',
                  hintText: '자세한 연애 고민을 작성해주세요. 상대방과의 대화, 고민되는 이유 등을 자세히 쓰면 좋은 조언을 얻기 쉬워요.',
                  alignLabelWithHint: true,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return '내용을 입력해주세요.';
                  if (val.trim().length < 10) return '최소 10자 이상 작성해주세요.';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Compatibility attachment switch
              _buildCompatibilityAttachmentCard(hasCompatibility, todayUsState),
              const SizedBox(height: 20),

              // Tags input
              const Text(
                '태그 추가',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.ink),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        hintText: '태그 입력 후 추가 (예: 권태기, 사내연애)',
                      ),
                      onSubmitted: _addTag,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _addTag(_tagController.text),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('추가'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tags display list
              if (_tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tags.map((tag) {
                    return Chip(
                      label: Text('#$tag'),
                      onDeleted: () => _removeTag(tag),
                      backgroundColor: AppTheme.surfaceCard,
                      labelStyle: const TextStyle(color: AppTheme.body, fontSize: 13),
                      deleteIconColor: AppTheme.muted,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                        side: const BorderSide(color: AppTheme.hairline),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompatibilityAttachmentCard(bool hasCompatibility, TodayUsState todayUsState) {
    if (!hasCompatibility) {
      return Card(
        color: AppTheme.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          side: const BorderSide(color: AppTheme.hairline),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '궁합 점수 태그 첨부하기',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.muted),
              ),
              SizedBox(height: 8),
              Text(
                '오늘 두 분의 궁합 조회를 완료하셨다면 점수와 파트너 닉네임 태그를 글에 포함시킬 수 있습니다. 오늘우리 탭에서 먼저 궁합을 보고 와주세요!',
                style: TextStyle(fontSize: 12, color: AppTheme.mutedSoft, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    final score = todayUsState.horoscope!.compatibilityScore;
    final isHighScore = score >= 90;
    final badgeColor = isHighScore ? AppTheme.brandPink : AppTheme.brandPeach;
    final textColor = isHighScore ? AppTheme.onPrimary : AppTheme.ink;

    return Card(
      color: AppTheme.surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        side: BorderSide(color: _attachCompatibility ? badgeColor : AppTheme.hairline, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.favorite_rounded, color: AppTheme.brandPink),
                    SizedBox(width: 8),
                    Text(
                      '궁합 결과 첨부하기',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.ink),
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: _attachCompatibility,
                  onChanged: (val) {
                    setState(() {
                      _attachCompatibility = val;
                    });
                  },
                  activeColor: AppTheme.brandPink,
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedOpacity(
              opacity: _attachCompatibility ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.canvas,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.hairline),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '태그 미리보기',
                            style: TextStyle(fontSize: 11, color: AppTheme.mutedSoft),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: badgeColor,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isHighScore ? Icons.auto_awesome : Icons.favorite,
                                      size: 12,
                                      color: textColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      score >= 90 ? '95% 찰떡궁합' : '$score% 궁합',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
