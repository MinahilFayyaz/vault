import 'package:flutter/material.dart';

class Language {
  String code;
  String name;
  String flagAsset;
  bool isSelected;

  Language({
    required this.code,
    required this.name,
    required this.flagAsset,
    this.isSelected = false,
  });

  // Convert Language to Locale
  Locale get locale => Locale(code);
}
