import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onlinedeck/constants.dart';
import 'package:onlinedeck/views/admin/home/admin_home.dart';
import 'package:onlinedeck/views/auth/login.dart';
import 'package:onlinedeck/views/home.dart';

void main() async {
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final _firstLogin = GetStorage().read('firstLogin');
  final _admin = GetStorage().read('admin') as bool? ?? false;

  @override
  Widget build(BuildContext context) {
    debugPrint("Admin: $_admin");

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Online Deck',
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        primarySwatch: kPrimary,
      ),
      home: _firstLogin == null || _firstLogin == true
          ? const Login()
          : _admin
              ? const AdminHome()
              : const Home(),
    );
  }
}
