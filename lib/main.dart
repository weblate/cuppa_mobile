/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    main.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2022 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa: a simple tea timer app for Android and iOS

import 'package:Cuppa/data/localization.dart';
import 'package:Cuppa/data/prefs.dart';
import 'package:Cuppa/widgets/about_page.dart';
import 'package:Cuppa/widgets/platform_adaptive.dart';
import 'package:Cuppa/widgets/prefs_page.dart';
import 'package:Cuppa/widgets/timer_page.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Globals
bool timerActive = false;
late SharedPreferences sharedPrefs;
late TargetPlatform appPlatform;
late double deviceWidth;
late double deviceHeight;
bool isLocaleMetric = true;
final String appName = 'Cuppa';
final String appIcon = 'images/Cuppa_icon.png';
final String aboutCopyright = '\u00a9 Nathan Cosgray';
final String aboutURL = 'https://nathanatos.com';

// Package info
PackageInfo packageInfo = PackageInfo(
  appName: 'Unknown',
  packageName: 'Unknown',
  version: 'Unknown',
  buildNumber: 'Unknown',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPrefs = await SharedPreferences.getInstance();
  packageInfo = await PackageInfo.fromPlatform();

  runApp(CuppaApp());
}

// Create the app
class CuppaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    appPlatform = Theme.of(context).platform;

    // Load user settings
    Prefs.load();

    return ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: Consumer<AppProvider>(
            builder: (context, provider, child) => MaterialApp(
                builder: (context, child) {
                  // Get device dimensions
                  deviceWidth = MediaQuery.of(context).size.width;
                  deviceHeight = MediaQuery.of(context).size.height;

                  // Set scale factor
                  return MediaQuery(
                    child: child!,
                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  );
                },
                title: appName,
                debugShowCheckedModeBanner: false,
                // Configure app theme
                theme: getPlatformAdaptiveTheme(appPlatform),
                darkTheme: getPlatformAdaptiveDarkTheme(appPlatform),
                themeMode: Prefs.appThemes[appTheme],
                // Configure routes
                initialRoute: '/',
                routes: {
                  '/': (context) => TimerWidget(),
                  '/prefs': (context) => PrefsWidget(),
                  '/about': (context) => AboutWidget(),
                },
                // Localization
                locale: appLanguage != '' ? Locale(appLanguage, '') : null,
                supportedLocales:
                    supportedLanguages.keys.map<Locale>((String value) {
                  return Locale(value, '');
                }).toList(),
                localizationsDelegates: [
                  const AppLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  const FallbackMaterialLocalizationsDelegate(),
                  const FallbackCupertinoLocalizationsDelegate(),
                ],
                localeResolutionCallback: (locale, supportedLocales) {
                  if (locale != null) {
                    // Set metric locale based on country code
                    if (locale.countryCode == 'US') isLocaleMetric = false;

                    // Set language or default to English
                    for (var supportedLocale in supportedLocales) {
                      if (supportedLocale.languageCode == locale.languageCode) {
                        return supportedLocale;
                      }
                    }
                  }
                  return Locale('en', '');
                })));
  }
}

// Provider for settings changes
class AppProvider extends ChangeNotifier {
  void update() {
    // Save user settings
    Prefs.save();

    // Ensure UI elements get updated
    notifyListeners();
  }
}

// Format brew temperature as number with units
String formatTemp(i) {
  // Infer C or F based on temp range
  if (i <= 100)
    return i.toString() + '\u00b0C';
  else
    return i.toString() + '\u00b0F';
}

// Format brew remaining time as m:ss
String formatTimer(s) {
  // Build the time format string
  int mins = (s / 60).floor();
  int secs = s - (mins * 60);
  String secsString = secs.toString();
  if (secs < 10) secsString = '0' + secsString;
  return mins.toString() + ':' + secsString;
}
