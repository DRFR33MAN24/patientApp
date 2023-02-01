import 'package:flutter/material.dart';

class L10n{
  static final all = [
    const Locale("en"),
    const Locale("fr"),
    const Locale("ar","SA"),
  ];

  static String getLang(String code) {
    switch (code) {
      
      case 'en':
        return 'English';
      case 'ar':
        return 'Arabic';
      case 'fr':
      default:
        return 'French';
    }
  }

}