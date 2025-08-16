// --- lib/core/models/conflict_topic_model.dart (신규 생성) ---
// Firebase에서 가져올 갈등 주제의 데이터 구조를 정의합니다.
class ConflictTopicModel {
  final String id;
  final String category;
  final String topic;

  ConflictTopicModel({
    required this.id,
    required this.category,
    required this.topic,
  });

  factory ConflictTopicModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ConflictTopicModel(
      id: documentId,
      category: map['category'] as String,
      topic: map['topic'] as String,
    );
  }
}