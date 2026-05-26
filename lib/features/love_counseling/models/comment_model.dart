import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String content;
  final String nickname;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.content,
    required this.nickname,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'content': content,
      'nickname': nickname,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as String,
      postId: map['postId'] as String,
      content: map['content'] as String,
      nickname: map['nickname'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
