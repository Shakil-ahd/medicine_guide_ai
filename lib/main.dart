import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicine_guide_ai/core/services/database_helper.dart';
import 'package:medicine_guide_ai/core/services/notification_service.dart';
import 'package:medicine_guide_ai/core/theme/theme.dart';
import 'package:medicine_guide_ai/features/dashboard/presentation/bloc/navigation_bloc.dart';
import 'package:medicine_guide_ai/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:medicine_guide_ai/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  
  // Check onboarding status from SQLite Database
  final onboardingCompleted = await DatabaseHelper.instance.getSetting('onboarding_completed') == 'true';
  
  runApp(MyApp(onboardingCompleted: onboardingCompleted));
}

class MyApp extends StatelessWidget {
  final bool onboardingCompleted;
  
  const MyApp({super.key, required this.onboardingCompleted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'মেডিসিন গাইড এআই',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: onboardingCompleted
          ? BlocProvider(
              create: (context) => NavigationBloc(),
              child: const DashboardScreen(),
            )
          : const OnboardingScreen(),
    );
  }
}
