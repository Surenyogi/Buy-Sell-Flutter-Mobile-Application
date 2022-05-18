import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatCurrency(String? price) {
  return NumberFormat("#,##0.00", "en_US")
      .format(double.parse((price ?? 0.0.toString())));
}

IconData getIcon(String name) {
  switch (name) {
    case 'appliance':
      return Icons.backup_table_rounded;
    case 'phone':
      return Icons.phone_android;
    case 'furniture':
      return Icons.table_bar;
    case 'Profile':
      return Icons.person;
    case 'electronic':
      return Icons.headphones_battery;
    case 'computer':
      return Icons.laptop;
    case 'real_estate':
      return Icons.home_work_outlined;
    case 'automoobile':
      return Icons.directions_car;
    case 'pets':
      return Icons.pets;
    case 'book':
      return Icons.book;
    case 'bike':
      return Icons.bike_scooter;
    default:
      return Icons.home;
  }
}

void showProgressDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );
}
