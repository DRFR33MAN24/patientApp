import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale("ar"),
    const Locale("en"),
  ];

  static String getLang(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ar':
        return 'عربي';
      case 'fr':
      default:
        return 'French';
    }
  }
}
