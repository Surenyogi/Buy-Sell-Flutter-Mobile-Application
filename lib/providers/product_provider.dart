import 'package:flutter/foundation.dart';
import 'package:get/get_connect/connect.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onlinedeck/constants.dart';

class ProductProvider extends GetConnect {
  final token = GetStorage().read('token');

  Future<Response> addProduct(FormData formData) async {
    debugPrint('formData: $formData');
    return post('$kBaseUrl/products', formData, headers: {
      'Authorization': 'Bearer $token',
    });
  }

  Future<Response> getAllProducts({
    String? query = '',
    String? sort = 'default',
    int? category,
    String? minPrice,
    String? maxPrice,
    bool isFeatured = false,
  }) async {
    debugPrint("");
    return get('$kBaseUrl/products', query: {
      'name': query,
      'sort': sort,
      'categoryId': '$category',
      'featured': '$isFeatured',
      'minPrice': '$minPrice',
      'maxPrice': '$maxPrice',
    });
  }

  Future<Response> getFeaturedProducts() async {
    return get('$kBaseUrl/products/featured');
  }

  Future<Response> getRecentProducts() async {
    return get('$kBaseUrl/products/recent');
  }

  Future<Response> getCommentsByProductId(int productId) {
    final token = GetStorage().read('token');
    return get('$kBaseUrl/products/$productId/comments', headers: {
      'Authorization': 'Bearer $token',
    });
  }

  Future<Response> addComment(int productId, String comment) async {
    return post('$kBaseUrl/products/$productId/comments', {
      'comment': comment
    }, headers: {
      'Authorization': 'Bearer $token',
    });
  }

  Future<Response> deleteComment(int productId, int commentId) async {
    return delete('$kBaseUrl/products/$productId/comments/$commentId',
        headers: {
          'Authorization': 'Bearer $token',
        });
  }

  Future<Response> reportProduct(
      int productId, String reason, String? info) async {
    return post('$kBaseUrl/products/$productId/reports', {
      'reason': reason,
      'additionalInfo': info,
    }, headers: {
      'Authorization': 'Bearer $token',
    });
  }

  Future<Response> markProductSold(int productId) async {
    return post('$kBaseUrl/products/$productId/sell', null, headers: {
      'Authorization': 'Bearer $token',
    });
  }

  Future<Response> markProductFeatured(int productId, bool featured) async {
    return post('$kBaseUrl/products/$productId/featured', null, headers: {
      'Authorization': 'Bearer $token',
    }, query: {
      'featured': '$featured',
    });
  }

  Future<Response> deleteProduct(int productId) async {
    return delete('$kBaseUrl/products/$productId', headers: {
      'Authorization': 'Bearer $token',
    });
  }

  Future<Response> getProductReports(int productId) async {
    return get('$kBaseUrl/products/$productId/reports', headers: {
      'Authorization': 'Bearer $token',
    });
  }
}
