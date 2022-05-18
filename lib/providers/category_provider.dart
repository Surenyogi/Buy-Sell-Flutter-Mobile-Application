import 'package:get/get_connect/connect.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onlinedeck/constants.dart';

class CategoryProvider extends GetConnect {
  final token = GetStorage().read('token');
  Future<Response> getAllCategories() async {
    return get('$kBaseUrl/categories');
  }

  Future<Response> addCategory(
      String name, String description, String icon) async {
    return post('$kBaseUrl/categories', {
      'name': name,
      'description': description,
      'icon': icon,
    }, headers: {
      'Authorization': 'Bearer $token',
    });
  }

  Future<Response> updateCategory(
      int id, String name, String description, String icon) async {
    return put('$kBaseUrl/categories/$id', {
      'name': name,
      'description': description,
      'icon': icon,
    }, headers: {
      'Authorization': 'Bearer $token',
    });
  }
}
