import 'dart:convert';

import 'package:onlinedeck/models/image.dart';

class Product {
  int id;
  String name;
  String description;
  List<Image>? images;
  double price;
  String type;
  int categoryId;
  String updatedAt;
  String createdAt;
  String status;
  String? expireAt;
  bool? featured;
  Map<String, dynamic> user;

  Product({
    required this.id,
    required this.name,
    required this.description,
    this.images,
    required this.price,
    required this.type,
    required this.categoryId,
    required this.updatedAt,
    required this.createdAt,
    required this.status,
    this.expireAt,
    this.featured,
    required this.user,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'images': images?.map((x) => x.toMap()).toList(),
      'price': price,
      'type': type,
      'categoryId': categoryId,
      'updatedAt': updatedAt,
      'createdAt': createdAt,
      'status': status,
      'expireAt': expireAt,
      'featured': featured,
      'user': user,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      images: map['images'] != null
          ? List<Image>.from(map['images']?.map((x) => Image.fromMap(x)))
          : null,
      price: map['price']?.toDouble() ?? 0.0,
      type: map['type'] ?? '',
      categoryId: map['categoryId']?.toInt() ?? 0,
      updatedAt: map['updatedAt'] ?? '',
      createdAt: map['createdAt'] ?? '',
      status: map['status'] ?? '',
      expireAt: map['expireAt'],
      featured: map['featured'],
      user: Map<String, dynamic>.from(map['user']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source));
}
