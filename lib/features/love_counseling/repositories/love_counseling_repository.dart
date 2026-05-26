import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/compatibility_info.dart';
import '../utils/nickname_generator.dart';

final loveCounselingRepositoryProvider = Provider((ref) {
  return LoveCounselingRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

class LoveCounselingRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  LoveCounselingRepository(this._firestore, this._auth);

  String? get _currentUserId => _auth.currentUser?.uid;

  /// Creates a post under Strict Anonymity
  Future<void> createPost({
    required String content,
    List<String> customTags = const [],
    CompatibilityInfo? compatibilityInfo,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception("로그인이 필요합니다.");

    final batch = _firestore.batch();
    
    // 1. Reference public post doc
    final postDocRef = _firestore.collection('posts').doc();
    final randomNickname = NicknameGenerator.generate();

    final allTags = <String>[...customTags];
    if (compatibilityInfo != null) {
      allTags.add(compatibilityInfo.tag);
    }

    final newPost = PostModel(
      id: postDocRef.id,
      content: content,
      nickname: randomNickname,
      createdAt: DateTime.now(),
      tags: allTags,
      compatibilityInfo: compatibilityInfo,
    );

    // 2. Reference private post ownership doc
    final ownershipRef = _firestore.collection('post_ownership').doc(postDocRef.id);

    // Write to both paths atomically
    batch.set(postDocRef, newPost.toMap());
    batch.set(ownershipRef, {
      'postId': postDocRef.id,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Adds an anonymous comment under Strict Anonymity
  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception("로그인이 필요합니다.");

    final batch = _firestore.batch();

    // 1. Reference comment document inside the post's subcollection
    final commentDocRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc();
        
    final randomNickname = NicknameGenerator.generate();

    final newComment = CommentModel(
      id: commentDocRef.id,
      postId: postId,
      content: content,
      nickname: randomNickname,
      createdAt: DateTime.now(),
    );

    // 2. Reference private comment ownership document
    final commentOwnershipRef = _firestore
        .collection('comment_ownership')
        .doc(commentDocRef.id);

    // 3. Post document reference to increment comment count
    final postRef = _firestore.collection('posts').doc(postId);

    // Write all atomically
    batch.set(commentDocRef, newComment.toMap());
    batch.set(commentOwnershipRef, {
      'commentId': commentDocRef.id,
      'postId': postId,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(postRef, {
      'commentsCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Fetches counseling posts (Newest First) with pagination support
  Future<List<PostModel>> getPosts({
    int limit = 20,
    DateTime? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfter([Timestamp.fromDate(startAfter)]);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => PostModel.fromMap(doc.data()))
        .toList();
  }

  /// ...
  Future<List<CommentModel>> getComments(String postId) async {
    final snapshot = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false) // Comments are read chronologically
        .get();

    return snapshot.docs
        .map((doc) => CommentModel.fromMap(doc.data()))
        .toList();
  }

  /// Checks if the current user owns the specified post
  Future<bool> isPostOwner(String postId) async {
    final userId = _currentUserId;
    if (userId == null) return false;

    try {
      final doc = await _firestore.collection('post_ownership').doc(postId).get();
      return doc.exists && doc.data()?['userId'] == userId;
    } catch (_) {
      return false;
    }
  }

  /// Checks if the current user owns the specified comment
  Future<bool> isCommentOwner(String commentId) async {
    final userId = _currentUserId;
    if (userId == null) return false;

    try {
      final doc = await _firestore.collection('comment_ownership').doc(commentId).get();
      return doc.exists && doc.data()?['userId'] == userId;
    } catch (_) {
      return false;
    }
  }

  /// Deletes a post along with its ownership record and decrements stats
  Future<void> deletePost(String postId) async {
    final isOwner = await isPostOwner(postId);
    if (!isOwner) throw Exception("삭제 권한이 없습니다.");

    final batch = _firestore.batch();
    final postRef = _firestore.collection('posts').doc(postId);
    final ownershipRef = _firestore.collection('post_ownership').doc(postId);

    batch.delete(postRef);
    batch.delete(ownershipRef);

    await batch.commit();
  }

  /// Deletes a comment, its ownership record, and decrements comment count
  Future<void> deleteComment(String postId, String commentId) async {
    final isOwner = await isCommentOwner(commentId);
    if (!isOwner) throw Exception("삭제 권한이 없습니다.");

    final batch = _firestore.batch();
    final commentRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);
    final commentOwnershipRef = _firestore.collection('comment_ownership').doc(commentId);
    final postRef = _firestore.collection('posts').doc(postId);

    batch.delete(commentRef);
    batch.delete(commentOwnershipRef);
    batch.update(postRef, {
      'commentsCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  /// Likes a post (only once per user)
  Future<void> likePost(String postId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception("로그인이 필요합니다.");

    final likeRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userId);

    final postRef = _firestore.collection('posts').doc(postId);

    await _firestore.runTransaction((transaction) async {
      final likeSnapshot = await transaction.get(likeRef);
      if (likeSnapshot.exists) {
        throw Exception("already_liked");
      }

      transaction.set(likeRef, {
        'likedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(postRef, {
        'likesCount': FieldValue.increment(1),
      });
    });
  }
}
