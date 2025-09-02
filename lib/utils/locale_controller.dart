import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocaleController extends GetxController {
  final _locale = const Locale('pt', 'BR').obs;

  Locale get locale => _locale.value;

  void changeLocale(Locale newLocale) {
    _locale.value = newLocale;
  }
}
