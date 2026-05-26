import 'package:cloud_firestore/cloud_firestore.dart';

class CompatibilityInfo {
  final String partnerId;
  final String partnerNickname;
  final int score;
  final String type; // e.g., 'chemistry', 'saju', 'personality'
  final String displayText;
  final String tag;
  final DateTime createdAt;

  CompatibilityInfo({
    required this.partnerId,
    required this.partnerNickname,
    required this.score,
    required this.type,
    required this.displayText,
    required this.tag,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'partnerId': partnerId,
      'partnerNickname': partnerNickname,
      'score': score,
      'type': type,
      'displayText': displayText,
      'tag': tag,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CompatibilityInfo.fromMap(Map<String, dynamic> map) {
    return CompatibilityInfo(
      partnerId: map['partnerId'] as String,
      partnerNickname: map['partnerNickname'] as String,
      score: (map['score'] as num).toInt(),
      type: map['type'] as String,
      displayText: map['displayText'] as String,
      tag: map['tag'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
