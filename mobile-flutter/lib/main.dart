import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_colors.dart';
import 'splash_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'core/services/notification_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  NotificationService.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'ACTIVA',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0EA982)),
        useMaterial3: true,
      ),
      home: SplashScreen(
        onFinished: () {
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (_) => const _AuthGate()),
          );
        },
      ),
    );
  }
}

class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    switch (authState.status) {
      case AuthStatus.initial:
      case AuthStatus.loading:
        return const Scaffold(
          backgroundColor: Color(0xFF0D1B2A),
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF22C16E),
              strokeWidth: 2.5,
            ),
          ),
        );

      case AuthStatus.authenticated:
        return const DashboardScreen();

      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return const OnboardingScreen();
    }
  }
}
