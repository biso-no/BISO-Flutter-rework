import 'package:flutter/material.dart';

Color parseHexColor(String hexColor) {
  var hex = hexColor.replaceAll('#', '').trim();
  if (hex.length == 6) {
    hex = 'FF$hex';
  }
  try {
    return Color(int.parse(hex, radix: 16));
  } catch (_) {
    return const Color(0xFF3DA9E0); // fallback to brand blue
  }
}


