import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'web_config.dart';
import 'l10n/l10n.dart';
import 'utils/language_manager.dart';
import 'state/app_state.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/patient/patient_home.dart';
import 'screens/caregiver/caregiver_home.dart';
import 'screens/clinician/clinician_home.dart';
import 'screens/admin/admin_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure web renderer
  WebConfig.configureWebRenderer();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  AppState.instance.initialize();
  runApp(const NeuroGuardApp());
}

class NeuroGuardApp extends StatefulWidget {
  const NeuroGuardApp({Key? key}) : super(key: key);

  @override
  State<NeuroGuardApp> createState() => _NeuroGuardAppState();
}

class _NeuroGuardAppState extends State<NeuroGuardApp> {
  bool _dark = false;
  bool _seenOnboarding = false;

  void _toggleTheme() => setState(() => _dark = !_dark);
  void _setSeenOnboarding() => setState(() => _seenOnboarding = true);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeuroGuard',
      debugShowCheckedModeBanner: false,
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      locale: LanguageManager().currentLocale.value,
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: L10n.localizationsDelegates,
      localeResolutionCallback: L10n.localeResolutionCallback,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        scaffoldBackgroundColor: Colors.grey[50],
        fontFamily: 'Arial', // Use Arial for better Arabic support
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Arial'),
          bodyMedium: TextStyle(fontFamily: 'Arial'),
          bodySmall: TextStyle(fontFamily: 'Arial'),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal, brightness: Brightness.dark),
        fontFamily: 'Arial', // Use Arial for better Arabic support
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Arial'),
          bodyMedium: TextStyle(fontFamily: 'Arial'),
          bodySmall: TextStyle(fontFamily: 'Arial'),
        ),
      ),
      home: Builder(builder: (ctx) {
        if (!_seenOnboarding) {
          return OnboardingScreen(onFinish: _setSeenOnboarding);
        }
        return ValueListenableBuilder<Map<String, dynamic>?>(
          key: ValueKey(AppState.instance.currentUser.value?['uid']),
          valueListenable: AppState.instance.currentUser,
          builder: (context, user, _) {
            if (user == null) {
              return AuthScreen(onToggleTheme: _toggleTheme);
            }
            final role = (user['role'] ?? 'patient').toString();
            if (role == 'patient')
              return PatientHome(key: ValueKey(user['uid']));
            if (role == 'caregiver')
              return CaregiverHome(key: ValueKey(user['uid']));
            if (role == 'clinician')
              return ClinicianHome(key: ValueKey(user['uid']));
            return AdminHome(key: ValueKey(user['uid']));
          },
        );
      }),
    );
  }
}
