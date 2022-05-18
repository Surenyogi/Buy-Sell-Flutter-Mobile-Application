import 'dart:convert';

class Comment {
  int id;
  String comment;
  int productId;
  String? reply;
  String? replyCreatedAt;
  String createdAt;
  String updatedAt;
  Map<String, dynamic>? user;
  Comment({
    required this.id,
    required this.comment,
    required this.productId,
    this.reply,
    this.replyCreatedAt,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'comment': comment,
      'productId': productId,
      'reply': reply,
      'replyCreatedAt': replyCreatedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'user': user,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id']?.toInt() ?? 0,
      comment: map['comment'] ?? '',
      productId: map['productId']?.toInt() ?? 0,
      reply: map['reply'],
      replyCreatedAt: map['replyCreatedAt'],
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
      user: Map<String, dynamic>.from(map['user']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Comment.fromJson(String source) =>
      Comment.fromMap(json.decode(source));
}
