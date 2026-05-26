import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:lovefortune_app/core/theme/app_theme.dart';
import '../models/post_model.dart';
import '../viewmodels/love_counseling_viewmodel.dart';
import 'post_write_screen.dart';
import 'post_detail_screen.dart';

class LoveCounselingScreen extends ConsumerStatefulWidget {
  const LoveCounselingScreen({super.key});

  @override
  ConsumerState<LoveCounselingScreen> createState() => _LoveCounselingScreenState();
}

class _LoveCounselingScreenState extends ConsumerState<LoveCounselingScreen> {
  final ScrollController _scrollController = ScrollController();
  
  // AdMob native ad mappings
  static const String _adUnitId = 'ca-app-pub-1036680323060821/4749675087';
  final Map<int, NativeAd> _adMap = {};
  final Set<int> _loadingAdIndices = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Dispose all loaded ads to prevent memory leaks
    for (final ad in _adMap.values) {
      ad.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(loveCounselingViewModelProvider.notifier).fetchMorePosts();
    }
  }

  Future<void> _refreshPosts() async {
    // Clear and dispose current ads on refresh
    for (final ad in _adMap.values) {
      ad.dispose();
    }
    setState(() {
      _adMap.clear();
      _loadingAdIndices.clear();
    });
    await ref.read(loveCounselingViewModelProvider.notifier).refreshPosts();
  }

  bool _isAdIndex(int index) {
    // 0-based indices: 0, 1, 2 are posts. 3 is ad.
    // 4, 5, 6 are posts. 7 is ad.
    // So every 4th index (index + 1 is divisible by 4) is an ad slot.
    return (index + 1) % 4 == 0;
  }

  int _getPostIndex(int index) {
    // Post index is current index minus the number of ads before it
    return index - (index ~/ 4);
  }

  void _loadAdForIndex(int index) {
    if (_adMap.containsKey(index) || _loadingAdIndices.contains(index)) return;

    _loadingAdIndices.add(index);
    
    final nativeAd = NativeAd(
      adUnitId: _adUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _adMap[index] = ad as NativeAd;
              _loadingAdIndices.remove(index);
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _loadingAdIndices.remove(index);
            });
          }
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: AppTheme.canvas,
        cornerRadius: 16.0,
      ),
    );

    nativeAd.load();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loveCounselingViewModelProvider);

    // Calculate total count including injected ads
    final totalPosts = state.posts.length;
    final totalAds = totalPosts ~/ 3;
    final hasMoreIndicator = state.hasMore ? 1 : 0;
    final totalListItems = totalPosts + totalAds + hasMoreIndicator;

    return Scaffold(
      appBar: AppBar(
        title: const Text('대나무숲'),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshPosts,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: state.isLoading && state.posts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshPosts,
              child: state.posts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: totalListItems,
                      itemBuilder: (context, index) {
                        // 1. Check if it's the loading indicator item at the end
                        final isLastItem = index == totalListItems - 1;
                        if (isLastItem && state.hasMore) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        // 2. Check if it's an ad index
                        if (_isAdIndex(index)) {
                          _loadAdForIndex(index); // Trigger lazy loading
                          return _buildAdContainer(index);
                        }

                        // 3. Render Post Card
                        final postIndex = _getPostIndex(index);
                        if (postIndex >= state.posts.length) {
                          return const SizedBox.shrink();
                        }
                        
                        final post = state.posts[postIndex];
                        return _buildPostCard(post);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const PostWriteScreen()),
          );
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        ),
        icon: const Icon(Icons.edit_document),
        label: const Text('고민 나누기', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAdContainer(int index) {
    return Container(
      height: 320,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.hairline, width: 1),
        color: AppTheme.canvas,
      ),
      child: _adMap.containsKey(index)
          ? AdWidget(ad: _adMap[index]!)
          : const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.forum_outlined, size: 64, color: AppTheme.mutedSoft),
              SizedBox(height: 16),
              Text(
                '아직 작성된 고민글이 없습니다.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.muted),
              ),
              SizedBox(height: 8),
              Text(
                '첫 번째 연애 고민을 나누어보세요!',
                style: TextStyle(fontSize: 14, color: AppTheme.mutedSoft),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostCard(PostModel post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        side: const BorderSide(color: AppTheme.hairline, width: 1),
      ),
      color: AppTheme.canvas,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(post: post),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Nickname and Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                        ),
                        child: Text(
                          post.nickname,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.bodyStrong,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatDate(post.createdAt),
                    style: const TextStyle(fontSize: 12, color: AppTheme.mutedSoft),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Content Summary (Titles are removed)
              Text(
                post.content,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.body,
                  height: 1.45,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Compatibility badge & Tags
              if (post.compatibilityInfo != null || post.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (post.compatibilityInfo != null)
                      _buildCompatibilityBadge(post.compatibilityInfo!),
                    ...post.tags
                        .where((tag) => post.compatibilityInfo == null || tag != post.compatibilityInfo!.tag)
                        .map((tag) => _buildNormalTag(tag)),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              const Divider(color: AppTheme.hairline, height: 1),
              const SizedBox(height: 8),

              // Footer: Likes and Comments counts
              Row(
                children: [
                  // Likes Icon & Count
                  InkWell(
                    onTap: () async {
                      try {
                        await ref.read(loveCounselingViewModelProvider.notifier).likePost(post.id);
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite_rounded, size: 18, color: AppTheme.brandPink),
                          const SizedBox(width: 4),
                          Text(
                            '${post.likesCount}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Comments Icon & Count
                  Row(
                    children: [
                      const Icon(Icons.mode_comment_outlined, size: 18, color: AppTheme.muted),
                      const SizedBox(width: 4),
                      Text(
                        '${post.commentsCount}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
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
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return DateFormat('MM.dd').format(dateTime);
    }
  }
}
