import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lovefortune_app/core/theme/app_theme.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../viewmodels/love_counseling_viewmodel.dart';
import '../repositories/love_counseling_repository.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();
  bool _isPostOwner = false;
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _checkPostOwnership();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _checkPostOwnership() async {
    try {
      final isOwner = await ref.read(loveCounselingRepositoryProvider).isPostOwner(widget.post.id);
      if (mounted) {
        setState(() {
          _isPostOwner = isOwner;
        });
      }
    } catch (_) {}
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSubmittingComment = true;
    });

    try {
      await ref.read(postCommentsViewModelProvider(widget.post.id).notifier).addComment(text);
      _commentController.clear();
      if (mounted) {
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글이 성공적으로 등록되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글 등록 실패: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingComment = false;
        });
      }
    }
  }

  Future<void> _deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시글 삭제'),
        content: const Text('이 게시글을 정말로 삭제할까요? 삭제된 게시글은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소', style: TextStyle(color: AppTheme.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(loveCounselingViewModelProvider.notifier).deletePost(widget.post.id);
        if (mounted) {
          Navigator.of(context).pop(); // Go back to board screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('게시글이 삭제되었습니다.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('게시글 삭제 실패: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(postCommentsViewModelProvider(widget.post.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('대나무숲 상세보기'),
        actions: [
          if (_isPostOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.error),
              onPressed: _deletePost,
              tooltip: '고민 삭제',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(postCommentsViewModelProvider(widget.post.id).notifier).fetchComments(),
              child: CustomScrollView(
                slivers: [
                  // 1. Post Content Card Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildPostDetailCard(),
                    ),
                  ),

                  // Comments section title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.forum_outlined, size: 18, color: AppTheme.muted),
                              const SizedBox(width: 6),
                              Text(
                                '댓글 ${commentsState.comments.length}개',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.muted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(color: AppTheme.hairline, height: 1),
                        ],
                      ),
                    ),
                  ),

                  // 2. Comments List Section
                  if (commentsState.isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else if (commentsState.comments.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 36, color: AppTheme.mutedSoft),
                              const SizedBox(height: 12),
                              Text(
                                '따뜻한 조언의 첫 댓글을 남겨주세요!',
                                style: TextStyle(fontSize: 13, color: AppTheme.mutedSoft),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final comment = commentsState.comments[index];
                          return _CommentRow(
                            comment: comment,
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('댓글 삭제'),
                                  content: const Text('이 댓글을 정말로 삭제할까요?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('취소', style: TextStyle(color: AppTheme.muted)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('삭제', style: TextStyle(color: AppTheme.error)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await ref
                                    .read(postCommentsViewModelProvider(widget.post.id).notifier)
                                    .deleteComment(comment.id);
                              }
                            },
                          );
                        },
                        childCount: commentsState.comments.length,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 3. Comment Input Box at the Bottom
          _buildCommentInputArea(),
        ],
      ),
    );
  }

  Widget _buildPostDetailCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.canvas,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Nickname & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                ),
                child: Text(
                  widget.post.nickname,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.bodyStrong,
                  ),
                ),
              ),
              Text(
                DateFormat('yyyy.MM.dd HH:mm').format(widget.post.createdAt),
                style: const TextStyle(fontSize: 12, color: AppTheme.mutedSoft),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content
          Text(
            widget.post.content,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.body,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Compatibility badge & Tags
          if (widget.post.compatibilityInfo != null || widget.post.tags.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (widget.post.compatibilityInfo != null)
                  _buildCompatibilityBadge(widget.post.compatibilityInfo!),
                ...widget.post.tags
                    .where((tag) => widget.post.compatibilityInfo == null || tag != widget.post.compatibilityInfo!.tag)
                    .map((tag) => _buildNormalTag(tag)),
              ],
            ),
            const SizedBox(height: 16),
          ],

          const Divider(color: AppTheme.hairline, height: 1),
          const SizedBox(height: 12),

          // Likes row
          Row(
            children: [
              InkWell(
                onTap: () async {
                  try {
                    await ref.read(loveCounselingViewModelProvider.notifier).likePost(widget.post.id);
                  } catch (e) {
                    if (e.toString().contains("already_liked")) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('이미 좋아요를 누른 게시글입니다.')),
                        );
                      }
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.hairline),
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_rounded, size: 16, color: AppTheme.brandPink),
                      const SizedBox(width: 6),
                      Text(
                        '좋아요 ${widget.post.likesCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityBadge(dynamic compat) {
    final isHighScore = compat.score >= 90;
    final badgeColor = isHighScore ? AppTheme.brandPink : AppTheme.brandPeach;
    final textColor = isHighScore ? AppTheme.onPrimary : AppTheme.ink;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isHighScore ? Icons.auto_awesome : Icons.favorite,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            '${compat.displayText}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: AppTheme.hairline, width: 0.5),
      ),
      child: Text(
        tag.startsWith('#') ? tag : '#$tag',
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.muted,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCommentInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: AppTheme.canvas,
        border: const Border(top: BorderSide(color: AppTheme.hairline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: '따뜻한 위로와 조언을 남겨주세요...',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              minLines: 1,
              maxLines: 4,
            ),
          ),
          const SizedBox(width: 12),
          _isSubmittingComment
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppTheme.brandPink),
                  onPressed: _submitComment,
                ),
        ],
      ),
    );
  }
}

class _CommentRow extends ConsumerStatefulWidget {
  final CommentModel comment;
  final VoidCallback onDelete;

  const _CommentRow({required this.comment, required this.onDelete});

  @override
  ConsumerState<_CommentRow> createState() => _CommentRowState();
}

class _CommentRowState extends ConsumerState<_CommentRow> {
  bool _isCommentOwner = false;

  @override
  void initState() {
    super.initState();
    _checkCommentOwnership();
  }

  Future<void> _checkCommentOwnership() async {
    try {
      final isOwner = await ref.read(loveCounselingRepositoryProvider).isCommentOwner(widget.comment.id);
      if (mounted) {
        setState(() {
          _isCommentOwner = isOwner;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.hairline, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nickname & Timestamp & Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    widget.comment.nickname,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.bodyStrong,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(widget.comment.createdAt),
                    style: const TextStyle(fontSize: 11, color: AppTheme.mutedSoft),
                  ),
                ],
              ),
              if (_isCommentOwner)
                IconButton(
                  icon: const Icon(Icons.close, size: 16, color: AppTheme.muted),
                  onPressed: widget.onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 16,
                  tooltip: '댓글 삭제',
                ),
            ],
          ),
          const SizedBox(height: 6),
          
          // Content
          Text(
            widget.comment.content,
            style: const TextStyle(fontSize: 14, color: AppTheme.body, height: 1.4),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return DateFormat('MM.dd HH:mm').format(dateTime);
    }
  }
}
