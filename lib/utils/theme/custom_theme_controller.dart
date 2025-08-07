import 'package:app4_receitas/utils/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// * GetxController
// Usado para gerenciar o estado
class CustomThemeController extends GetxController {
  // * GetX Reactive Variables
  // Usado para gerenciar o estado isDark
  // obs - é um método do GetX que torna a variável reativa
  // value - é usado para acessar o valor da variável reativa
  RxBool isDark = true.obs;
  CustomTheme myTheme = CustomTheme(
    color: const Color.fromARGB(255, 238, 118, 49),
  );
  ThemeData get customTheme => myTheme.customTheme;
  ThemeData get customThemeDark => myTheme.customThemeDark;
  ThemeMode get themeMode => isDark.value ? ThemeMode.dark : ThemeMode.light;

  void toogleTheme() {
    isDark.value = !isDark.value;
  }
}
