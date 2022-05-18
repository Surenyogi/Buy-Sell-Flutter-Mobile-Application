import 'package:get/get_connect.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onlinedeck/constants.dart';

class UserProvider extends GetConnect {
  Future<Response> login(String email, String password) async {
    return post('$kBaseUrl/login', {'email': email, 'password': password});
  }

  Future<Response> register(
      {required String email,
      required String password,
      required String name,
      required String phone,
      required String dob,
      required String address,
      required String city,
      required String state}) async {
    return post('$kBaseUrl/register', {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'dob': dob,
      'address': address,
      'city': city,
      'state': state
    });
  }

  Future<Response> getMyAds() async {
    final token = GetStorage().read('token');
    return get('$kBaseUrl/my-ads', headers: {
      'Authorization': 'Bearer $token',
    });
  }

  dynamic getMyProfile() {
    final profile = GetStorage().read('user');
    return profile;
  }

  Future<Response> updateProfile({
    required String name,
    required String email,
    required String dob,
    required String phone,
    required String address,
    required String city,
    required String state,
  }) async {
    final token = GetStorage().read('token');
    return put('$kBaseUrl/update-profile', {
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'dob': dob,
      'email': email
    }, headers: {
      'Authorization': 'Bearer $token'
    });
  }

  Future<Response> changePassword(
      String oldPassword, String newPassword) async {
    final token = GetStorage().read('token');
    return post('$kBaseUrl/change-password', {
      'oldPassword': oldPassword,
      'newPassword': newPassword
    }, headers: {
      'Authorization': 'Bearer $token',
    });
  }

  Future<Response> getAllUsers() async {
    final token = GetStorage().read('token');
    return get('$kBaseUrl/users', headers: {
      'Authorization': 'Bearer $token',
    });
  }

  Future<Response> removeUser(int id) async {
    final token = GetStorage().read('token');
    return delete('$kBaseUrl/users/$id', headers: {
      'Authorization': 'Bearer $token',
    });
  }

  Future<Response> resetPassword(String email, String dob, String password) {
    return post('$kBaseUrl/reset-password',
        {'email': email, 'dob': dob, 'password': password});
  }
}
