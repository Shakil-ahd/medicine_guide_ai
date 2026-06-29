import 'dart:async';
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicine_guide_ai/app.dart';
import 'package:medicine_guide_ai/core/services/database_helper.dart';
import 'package:medicine_guide_ai/core/services/notification_service.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.darkBg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[FlutterError] ${details.exceptionAsString()}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[PlatformError] $error\n$stack');
    return true;
  };

  await Future.wait([NotificationService.instance.init()]);

  final onboardingCompleted =
      await DatabaseHelper.instance.getSetting('onboarding_completed') ==
      'true';

  runApp(MyApp(onboardingCompleted: onboardingCompleted));
}
