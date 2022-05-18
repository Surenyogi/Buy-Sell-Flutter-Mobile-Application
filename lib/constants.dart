import 'package:flutter/material.dart';

//if running in emulator use localhost otherwise server IP
const String kBaseUrl = 'http://192.168.1.8:3000';

const Color kGrey = Color(0xFF66707A);

const MaterialColor kPrimary = MaterialColor(_kPrimaryValue, <int, Color>{
  50: Color(0xFFE3F5F7),
  100: Color(0xFFB9E6EB),
  200: Color(0xFF8AD6DD),
  300: Color(0xFF5BC5CF),
  400: Color(0xFF38B8C5),
  500: Color(_kPrimaryValue),
  600: Color(0xFF12A5B5),
  700: Color(0xFF0F9BAC),
  800: Color(0xFF0C92A4),
  900: Color(0xFF068296),
});

const int _kPrimaryValue = 0xFF15ACBB;

const MaterialColor mcgpalette0Accent =
    MaterialColor(_kPrimaryAccent, <int, Color>{
  100: Color(0xFFC2F6FF),
  200: Color(_kPrimaryAccent),
  400: Color(0xFF5CE6FF),
  700: Color(0xFF42E2FF),
});

const int _kPrimaryAccent = 0xFF8FEEFF;
