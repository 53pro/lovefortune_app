import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../repositories/love_counseling_repository.dart';

// ==========================================
// 1. Board Post List State & ViewModel
// ==========================================

class LoveCounselingState {
  final bool isLoading;
  final bool isMoreLoading;
  final List<PostModel> posts;
  final bool hasMore;
  final String? errorMessage;

  LoveCounselingState({
    this.isLoading = false,
    this.isMoreLoading = false,
    this.posts = const [],
    this.hasMore = true,
    this.errorMessage,
  });

  LoveCounselingState copyWith({
    bool? isLoading,
    bool? isMoreLoading,
    List<PostModel>? posts,
    bool? hasMore,
    String? errorMessage,
  }) {
    return LoveCounselingState(
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      posts: posts ?? this.posts,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LoveCounselingViewModel extends Notifier<LoveCounselingState> {
  late final LoveCounselingRepository _repository;
  static const int _pageSize = 15;

  @override
  LoveCounselingState build() {
    _repository = ref.read(loveCounselingRepositoryProvider);
    // Fetch initial page on construction
    Future.microtask(() => fetchInitialPosts());
    return LoveCounselingState();
  }

  /// Initial load of counseling posts
  Future<void> fetchInitialPosts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final posts = await _repository.getPosts(limit: _pageSize);
      state = state.copyWith(
        isLoading: false,
        posts: posts,
        hasMore: posts.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '게시글을 가져오는 데 실패했습니다: ${e.toString()}',
      );
    }
  }

  /// Pull-to-refresh posts list
  Future<void> refreshPosts() async {
    try {
      final posts = await _repository.getPosts(limit: _pageSize);
      state = state.copyWith(
        posts: posts,
        hasMore: posts.length >= _pageSize,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: '새로고침 실패: ${e.toString()}',
      );
    }
  }

  /// Load more posts (Pagination)
  Future<void> fetchMorePosts() async {
    if (state.isMoreLoading || !state.hasMore || state.posts.isEmpty) return;

    state = state.copyWith(isMoreLoading: true);
    try {
      final lastPost = state.posts.last;
      final morePosts = await _repository.getPosts(
        limit: _pageSize,
        startAfter: lastPost.createdAt,
      );

      state = state.copyWith(
        isMoreLoading: false,
        posts: [...state.posts, ...morePosts],
        hasMore: morePosts.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isMoreLoading: false,
        errorMessage: '추가 게시글을 로드하지 못했습니다.',
      );
    }
  }

  /// Creates a new post and prepends it to the list
  Future<void> createPost({
    required String content,
    List<String> customTags = const [],
    dynamic compatibilityInfo, // CompatibilityInfo?
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.createPost(
        content: content,
        customTags: customTags,
        compatibilityInfo: compatibilityInfo,
      );
      // Refresh list to show the new post
      await refreshPosts();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '게시글 업로드 실패: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Likes a post in Firestore and increments likesCount locally
  Future<void> likePost(String postId) async {
    try {
      await _repository.likePost(postId);
      
      // Optimistic update of local post state
      final updatedPosts = state.posts.map((post) {
        if (post.id == postId) {
          return PostModel(
            id: post.id,
            content: post.content,
            nickname: post.nickname,
            createdAt: post.createdAt,
            likesCount: post.likesCount + 1,
            commentsCount: post.commentsCount,
            tags: post.tags,
            compatibilityInfo: post.compatibilityInfo,
          );
        }
        return post;
      }).toList();

      state = state.copyWith(posts: updatedPosts);
    } catch (e) {
      // Fail silently or log error
    }
  }

  /// Deletes a post and removes it from the list
  Future<void> deletePost(String postId) async {
    try {
      await _repository.deletePost(postId);
      state = state.copyWith(
        posts: state.posts.where((p) => p.id != postId).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: '게시글 삭제 실패: ${e.toString()}');
      rethrow;
    }
  }
}

final loveCounselingViewModelProvider =
    NotifierProvider<LoveCounselingViewModel, LoveCounselingState>(
  () => LoveCounselingViewModel(),
);

// ==========================================
// 2. Post Comments List State & ViewModel
// ==========================================

class PostCommentsState {
  final bool isLoading;
  final List<CommentModel> comments;
  final String? errorMessage;

  PostCommentsState({
    this.isLoading = false,
    this.comments = const [],
    this.errorMessage,
  });

  PostCommentsState copyWith({
    bool? isLoading,
    List<CommentModel>? comments,
    String? errorMessage,
  }) {
    return PostCommentsState(
      isLoading: isLoading ?? this.isLoading,
      comments: comments ?? this.comments,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PostCommentsViewModel extends AutoDisposeFamilyNotifier<PostCommentsState, String> {
  late final LoveCounselingRepository _repository;
  late final String _postId;

  @override
  PostCommentsState build(String arg) {
    _repository = ref.read(loveCounselingRepositoryProvider);
    _postId = arg;
    Future.microtask(() => fetchComments());
    return PostCommentsState(isLoading: true);
  }

  /// Fetches comments for the post
  Future<void> fetchComments() async {
    try {
      final comments = await _repository.getComments(_postId);
      state = PostCommentsState(comments: comments);
    } catch (e) {
      state = PostCommentsState(
        errorMessage: '댓글을 불러오지 못했습니다: ${e.toString()}',
      );
    }
  }

  /// Adds a comment, updates comment counts
  Future<void> addComment(String content) async {
    try {
      await _repository.addComment(postId: _postId, content: content);
      
      // Refresh the comments list
      await fetchComments();

      // Trigger posts list refresh to sync the commentsCount on the home screen
      ref.read(loveCounselingViewModelProvider.notifier).refreshPosts();
    } catch (e) {
      state = state.copyWith(errorMessage: '댓글 작성을 실패했습니다: ${e.toString()}');
      rethrow;
    }
  }

  /// Deletes a comment, updates comment counts
  Future<void> deleteComment(String commentId) async {
    try {
      await _repository.deleteComment(_postId, commentId);
      
      // Remove comment locally
      state = state.copyWith(
        comments: state.comments.where((c) => c.id != commentId).toList(),
      );

      // Trigger posts list refresh to sync the commentsCount
      ref.read(loveCounselingViewModelProvider.notifier).refreshPosts();
    } catch (e) {
      state = state.copyWith(errorMessage: '댓글 삭제를 실패했습니다: ${e.toString()}');
      rethrow;
    }
  }
}

final postCommentsViewModelProvider = NotifierProvider.family
    .autoDispose<PostCommentsViewModel, PostCommentsState, String>(
  PostCommentsViewModel.new,
);
