import 'dart:convert';

class Category {
  final int id;
  final String name;
  final String description;
  final String icon;
  final String createdAt;

  Category(this.id, this.name, this.description, this.icon, this.createdAt);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'createdAt': createdAt,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      map['id']?.toInt() ?? 0,
      map['name'] ?? '',
      map['description'] ?? '',
      map['icon'] ?? '',
      map['createdAt'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Category.fromJson(String source) =>
      Category.fromMap(json.decode(source));
}
