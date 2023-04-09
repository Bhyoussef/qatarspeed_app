import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';
import 'package:qatar_speed/tools/res.dart';

/// light theme
ThemeData customLightTheme(BuildContext context,) {
  return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textSelectionTheme:
      const TextSelectionThemeData(cursorColor: Color.fromRGBO(37, 112, 252, 1)),
      errorColor: Colors.red,
      platform: defaultTargetPlatform,
      primaryColor: Colors.white,
      primaryIconTheme: const IconThemeData(color: Colors.black),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromRGBO(37, 112, 252, 1)),
      unselectedWidgetColor: Colors.grey,
      brightness: Brightness.light,
      fontFamily: GoogleFonts
          .montserrat()
          .fontFamily,
      secondaryHeaderColor: const Color.fromRGBO(37, 112, 252, 1),
      cardColor: const Color.fromRGBO(239, 242, 248, 1),
      iconTheme: const IconThemeData(color: Colors.black),
      tabBarTheme: TabBarTheme(
        unselectedLabelColor: Colors.black.withOpacity(.5),
      ),
      appBarTheme: const AppBarTheme(elevation: 0, color: Colors.white),
      textTheme: Typography
          .material2018(platform: defaultTargetPlatform)
          .white
          .copyWith(
        bodyText1: TextStyle(
            fontFamily: 'arial', fontSize: Res.isPhone ? 16.0 : 19.0),
        bodyText2: TextStyle(
            fontFamily: 'arial',
            height: .9,
            color: Colors.black,
            fontSize:
            Res.isPhone ? 15 : 19.0),
        labelLarge: TextStyle(
            fontFamily: 'arabic',
            color: Colors.black,
            fontSize: Res.isPhone ? 13.0 : 17.0,
            fontWeight: FontWeight.w900),
        labelSmall: TextStyle(
            fontFamily: 'arial',
            fontSize: Res.isPhone ? 12.0 : 16.0,
            fontWeight: FontWeight.w900),
        labelMedium: TextStyle(
            fontFamily: 'serif',
            fontSize: Res.isPhone ? 11.0 : 15.0),
        caption:
        TextStyle(
            color: Colors.white,
            fontFamily: 'fg',
            fontSize: Res.isPhone ? 10.0 : 15.0,
            fontWeight: FontWeight.w100),
        displayLarge: const TextStyle(color: Colors.black54, fontSize: 20.0),
        headline1: TextStyle(
            fontFamily: 'arial',
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: Res.isPhone ? 12.0 : 15.0),
        headline2: const TextStyle(color: Colors.black),
        headline3: const TextStyle(color: Colors.black, fontSize: 48),
        headline4: const TextStyle(color: Colors.black, fontSize: 34),
        headline5: const TextStyle(color: Colors.black, fontSize: 24),
        headline6: const TextStyle(color: Colors.black, fontSize: 20),
        subtitle1: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: Res.isPhone ? 11 : 16.0,
            fontFamily: 'arial'),
        subtitle2: const TextStyle(color: Colors.black, fontSize: 14),
        overline: const TextStyle(fontFamily: 'arial', color: Colors.black54),
        button: const TextStyle(color: Colors.black, fontSize: 16),
      ),
      dividerColor: Colors.grey);
}

///dark theme
ThemeData customDarkTheme(BuildContext context,) {
  return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.black,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Color.fromRGBO(105, 73, 199, 1),
      ),
      errorColor: const Color(0xFFCF6679),
      primaryColor: Colors.black,
      primaryIconTheme: const IconThemeData(color: Colors.grey),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromRGBO(31, 31, 31, 1)),
      platform: defaultTargetPlatform,
      unselectedWidgetColor: Colors.grey,
      brightness: Brightness.dark,
      secondaryHeaderColor: const Color.fromRGBO(31, 31, 50, 1),
      fontFamily: GoogleFonts
          .montserrat()
          .fontFamily,
      cardColor: const Color.fromRGBO(31, 31, 31, 1),
      tabBarTheme: TabBarTheme(
        unselectedLabelColor: Colors.white.withOpacity(.7),
      ),
      appBarTheme: const AppBarTheme(elevation: 0, color: Colors.black),
      textTheme: Typography
          .material2018(platform: defaultTargetPlatform)
          .white
          .copyWith(
        bodyText1: const TextStyle(color: Colors.white, fontSize: 16),
        bodyText2: const TextStyle(color: Colors.white, fontSize: 14),
        caption: const TextStyle(
            color: Color.fromRGBO(134, 171, 255, 1.0), fontSize: 12),
        headline1: const TextStyle(color: Colors.white, fontSize: 96),
        headline2: const TextStyle(color: Colors.white, fontSize: 60),
        headline3: const TextStyle(color: Colors.white, fontSize: 48),
        headline4: const TextStyle(color: Colors.white, fontSize: 34),
        headline5: const TextStyle(color: Colors.white, fontSize: 24),
        headline6: const TextStyle(color: Colors.white, fontSize: 20),
        subtitle1: const TextStyle(color: Colors.white, fontSize: 16),
        subtitle2: const TextStyle(color: Colors.white, fontSize: 14),
        overline: const TextStyle(color: Colors.white, fontSize: 10),
        button: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      dividerColor: Colors.white.withOpacity(.6));
}
