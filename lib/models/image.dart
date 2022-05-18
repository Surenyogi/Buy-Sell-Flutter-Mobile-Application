import 'dart:convert';

class Image {
  final String url;
  final String productId;
  Image({
    required this.url,
    required this.productId,
  });

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'productId': productId,
    };
  }

  factory Image.fromMap(Map<String, dynamic> map) {
    return Image(
      url: map['url'] ?? '',
      productId: map['productId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Image.fromJson(String source) => Image.fromMap(json.decode(source));
}
