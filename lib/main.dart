import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'l10n/app_localizations.dart';
import 'screens/auth/admin_login_screen.dart';
import 'screens/auth/reset_password_request_screen.dart';
import 'screens/auth/reset_password_verify_screen.dart';
import 'screens/citizen/citizen_home_screen.dart';
import 'screens/citizen/citizen_login_screen.dart';
import 'screens/citizen/raise_complaint_screen.dart';
import 'screens/citizen/my_complaints_screen.dart';
import 'screens/citizen/schemes_screen.dart';
import 'screens/citizen/settings_screen.dart';
import 'screens/supervisor/supervisor_home_screen.dart';
import 'screens/supervisor/supervisor_complaints_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/supervisor/supervisor_attendance_screen.dart';
import 'screens/supervisor/supervisor_settings_screen.dart';
import 'screens/bdo/bdo_complaints_screen.dart';
import 'screens/bdo/bdo_settings_screen.dart';
import 'screens/bdo/inspection_log_screen.dart';
import 'screens/ceo/ceo_home_screen.dart';
import 'screens/ceo/ceo_complaints_screen.dart';
import 'screens/vdo/vdo_home_screen.dart';
import 'screens/vdo/vdo_complaints_screen.dart';
import 'screens/vdo/vdo_inspection_screen.dart';
import 'screens/vdo/new_inspection_screen.dart';
import 'screens/vdo/vdo_settings_screen.dart';
import 'screens/smd/smd_home_screen.dart';
import 'screens/smd/smd_complaints_screen.dart';
import 'screens/smd/smd_district_selection_screen.dart';
import 'providers/citizen_auth_provider.dart';
import 'providers/citizen_schemes_provider.dart';
import 'providers/citizen_events_provider.dart';
import 'providers/citizen_bookmarks_provider.dart';
import 'providers/citizen_complaints_provider.dart';
import 'providers/citizen_geography_provider.dart';
import 'providers/citizen_notifications_provider.dart';
import 'providers/citizen_user_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/supervisor_provider.dart';
import 'providers/supervisor_complaints_provider.dart';
import 'providers/supervisor_attendance_provider.dart';
import 'providers/vdo_provider.dart';
import 'providers/vdo_complaints_provider.dart';
import 'providers/vdo_inspection_provider.dart';
import 'providers/vdo_attendance_provider.dart';
import 'providers/bdo_provider.dart';
import 'providers/bdo_complaints_provider.dart';
import 'providers/bdo_inspection_provider.dart';
import 'providers/bdo_attendance_provider.dart';
import 'providers/ceo_provider.dart';
import 'providers/ceo_complaints_provider.dart';
import 'providers/ceo_inspection_provider.dart';
import 'providers/ceo_attendance_provider.dart';
import 'providers/smd_provider.dart';
import 'providers/smd_complaints_provider.dart';
import 'providers/smd_inspection_provider.dart';
import 'providers/smd_attendance_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Common providers
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // Citizen providers
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SchemesProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
        ChangeNotifierProvider(create: (_) => BookmarksProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintsProvider()),
        ChangeNotifierProvider(create: (_) => GeographyProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),

        // Supervisor providers
        ChangeNotifierProvider(create: (_) => SupervisorProvider()),
        ChangeNotifierProvider(create: (_) => SupervisorComplaintsProvider()),
        ChangeNotifierProvider(create: (_) => SupervisorAttendanceProvider()),

        // VDO providers
        ChangeNotifierProvider(create: (_) => VdoProvider()),
        ChangeNotifierProvider(create: (_) => VdoComplaintsProvider()),
        ChangeNotifierProvider(create: (_) => VdoInspectionProvider()),
        ChangeNotifierProvider(create: (_) => VdoAttendanceProvider()),

        // BDO providers
        ChangeNotifierProvider(create: (_) => BdoProvider()),
        ChangeNotifierProvider(create: (_) => BdoComplaintsProvider()),
        ChangeNotifierProvider(create: (_) => BdoInspectionProvider()),
        ChangeNotifierProvider(create: (_) => BdoAttendanceProvider()),

        // CEO providers
        ChangeNotifierProvider(create: (_) => CeoProvider()),
        ChangeNotifierProvider(create: (_) => CeoComplaintsProvider()),
        ChangeNotifierProvider(create: (_) => CeoInspectionProvider()),
        ChangeNotifierProvider(create: (_) => CeoAttendanceProvider()),

        // SMD providers
        ChangeNotifierProvider(create: (_) => SmdProvider()),
        ChangeNotifierProvider(create: (_) => SmdComplaintsProvider()),
        ChangeNotifierProvider(create: (_) => SmdInspectionProvider()),
        ChangeNotifierProvider(create: (_) => SmdAttendanceProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocaleProvider, ThemeProvider>(
      builder: (context, localeProvider, themeProvider, child) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Rajasthan Government App',
            theme: ThemeData(
              primarySwatch: Colors.orange,
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFFFD700), // Golden color
                brightness: Brightness.light,
              ),
              fontFamily: 'Noto Sans',
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.orange,
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFFFD700), // Golden color
                brightness: Brightness.dark,
              ),
              fontFamily: 'Noto Sans',
              scaffoldBackgroundColor: const Color(0xFF111827),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1F2937),
                elevation: 0,
              ),
            ),
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('hi'), // Hindi
            ],
            home: const SplashScreen(),
            routes: {
              '/onboarding': (context) => const OnboardingScreen(),
              '/landing': (context) => const LandingScreen(),
              '/citizen-login': (context) => const LoginScreen(),
              '/admin-login': (context) => const AdminLoginScreen(),
              '/reset-password-request': (context) =>
                  const ResetPasswordRequestScreen(),
              '/reset-password-verify': (context) =>
                  const ResetPasswordVerifyScreen(phoneNumber: ''),
              '/set-new-password': (context) =>
                  Scaffold(body: Center(child: Text('Set New Password'))),
              '/citizen-dashboard': (context) => CitizenHomeScreen(),
              '/supervisor-dashboard': (context) =>
                  const SupervisorHomeScreen(),
              '/supervisor-complaints': (context) =>
                  const SupervisorComplaintsScreen(),
              '/supervisor-attendance': (context) =>
                  const SupervisorAttendanceScreen(),
              '/supervisor-settings': (context) =>
                  const SupervisorSettingsScreen(),
              '/vdo-dashboard': (context) => const VdoHomeScreen(),
              '/vdo-inspection': (context) =>
                  const VdoInspectionScreen(),
              '/vdo-new-inspection': (context) =>
                  const NewInspectionScreen(),
              '/vdo-complaints': (context) =>
                  const VdoComplaintsScreen(),
              '/vdo-settings': (context) => const VdoSettingsScreen(),
              '/bdo-dashboard': (context) =>
                  Scaffold(body: Center(child: Text('BDO Dashboard'))),
              '/bdo-complaints': (context) => const BdoComplaintsScreen(),
              '/bdo-monitoring': (context) =>
                  Scaffold(body: Center(child: Text('BDO Inspection'))),
              '/bdo-settings': (context) => const BdoSettingsScreen(),
              '/ceo-dashboard': (context) => const CeoHomeScreen(),
              '/ceo-complaints': (context) => const CeoComplaintsScreen(),
              '/ceo-monitoring': (context) =>
                  Scaffold(body: Center(child: Text('CEO Inspection'))),
              '/ceo-settings': (context) =>
                  Scaffold(body: Center(child: Text('CEO Settings'))),
              '/smd-district-selection': (context) =>
                  const SmdDistrictSelectionScreen(),
              '/smd-dashboard': (context) => const SmdHomeScreen(),
              '/smd-complaints': (context) => const SmdComplaintsScreen(),
              '/smd-monitoring': (context) =>
                  Scaffold(body: Center(child: Text('SMD Inspection'))),
              '/smd-settings': (context) =>
                  Scaffold(body: Center(child: Text('SMD Settings'))),
              '/contractor-dashboard': (context) =>
                  const SupervisorHomeScreen(), // Contractors use supervisor dashboard
              '/select-gp': (context) =>
                  Scaffold(body: Center(child: Text('Select GP'))),
              '/gp-attendance': (context) {
                final args =
                    ModalRoute.of(context)!.settings.arguments
                        as Map<String, dynamic>?;
                return Scaffold(
                  appBar: AppBar(title: Text('GP Attendance')),
                  body: Center(
                    child: Text('Attendance for ${args?['gpName'] ?? ''}'),
                  ),
                );
              },
              '/gp-ranking': (context) =>
                  Scaffold(body: Center(child: Text('GP Ranking'))),
              '/select-location': (context) =>
                  Scaffold(body: Center(child: Text('Select Location'))),
              '/bdo-new-inspection': (context) {
                final args =
                    ModalRoute.of(context)!.settings.arguments
                        as Map<String, dynamic>?;
                return Scaffold(
                  appBar: AppBar(title: Text('New Inspection')),
                  body: Center(child: Text('GP: ${args?['gpName']}')),
                );
              },
              '/inspection-log': (context) => const InspectionLogScreen(),
              '/gp-inspection-details': (context) {
                final args =
                    ModalRoute.of(context)!.settings.arguments
                        as Map<String, dynamic>?;
                return Scaffold(
                  appBar: AppBar(title: Text('Inspection Details')),
                  body: Center(child: Text('GP: ${args?['gpName']}')),
                );
              },
              '/ceo-new-inspection': (context) {
                final args =
                    ModalRoute.of(context)!.settings.arguments
                        as Map<String, dynamic>?;
                return Scaffold(
                  appBar: AppBar(title: Text('New Inspection')),
                  body: Center(child: Text('GP: ${args?['gpName']}')),
                );
              },
              '/my-complaints': (context) => const MyComplaintsScreen(),
              '/schemes': (context) => const SchemesScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/profile': (context) =>
                  Scaffold(body: Center(child: Text('Profile'))),
              '/language': (context) =>
                  Scaffold(body: Center(child: Text('Language'))),
              '/bookmarks': (context) =>
                  Scaffold(body: Center(child: Text('Bookmarks'))),
              '/notifications': (context) =>
                  Scaffold(body: Center(child: Text('Notifications'))),
              '/create-complaint': (context) => const RaiseComplaintScreen(),
              '/complaint-location': (context) {
                final args =
                    ModalRoute.of(context)!.settings.arguments
                        as Map<String, dynamic>;
                return Scaffold(
                  appBar: AppBar(title: Text('Complaint Location')),
                  body: Center(child: Text('Location: ${args['location']}')),
                );
              },
            },
          ),
        );
      },
    );
  }
}
