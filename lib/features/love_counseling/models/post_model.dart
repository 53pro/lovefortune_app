import 'package:cloud_firestore/cloud_firestore.dart';
import 'compatibility_info.dart';

class PostModel {
  final String id;
  final String content;
  final String nickname;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final List<String> tags;
  final CompatibilityInfo? compatibilityInfo;

  PostModel({
    required this.id,
    required this.content,
    required this.nickname,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.tags,
    this.compatibilityInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'nickname': nickname,
      'createdAt': Timestamp.fromDate(createdAt),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'tags': tags,
      'compatibilityInfo': compatibilityInfo?.toMap(),
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] as String,
      content: map['content'] as String,
      nickname: map['nickname'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      likesCount: (map['likesCount'] as num? ?? 0).toInt(),
      commentsCount: (map['commentsCount'] as num? ?? 0).toInt(),
      tags: List<String>.from(map['tags'] ?? []),
      compatibilityInfo: map['compatibilityInfo'] != null
          ? CompatibilityInfo.fromMap(map['compatibilityInfo'] as Map<String, dynamic>)
          : null,
    );
  }
}
