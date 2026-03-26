import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:myocircle15screens/providers/avatar_provider.dart';
import 'package:myocircle15screens/providers/first_time_user_provider.dart';
import 'package:myocircle15screens/providers/index_provider.dart';
import 'package:myocircle15screens/providers/session_provider.dart';
import 'package:myocircle15screens/screens/onboarding/avatar_preview_screen.dart';
import 'package:myocircle15screens/screens/onboarding/login_screen.dart';
import 'package:myocircle15screens/screens/onboarding/register_screen.dart';
import 'package:myocircle15screens/screens/onboarding/setup_pin_screen.dart';
import 'package:myocircle15screens/screens/onboarding/setup_profile_screen.dart';
import 'package:myocircle15screens/screens/onboarding/tos_screen.dart';
import 'package:myocircle15screens/screens/onboarding/welcome_screen.dart';
import 'package:myocircle15screens/screens/patient_panel/menu_button_screens/my_therapist_screen.dart';
import 'package:myocircle15screens/screens/patient_panel/menu_button_screens/reset_pin_screen.dart';
import 'package:myocircle15screens/screens/patient_panel/patient_score_screen.dart';
import 'package:myocircle15screens/screens/patient_panel/select_profile_screen.dart';
import 'package:myocircle15screens/screens/patient_panel/patient_avatar_preview_screen.dart';
import 'package:myocircle15screens/screens/patient_panel/patient_master_screen.dart';
import 'package:myocircle15screens/services/api_service.dart';
import 'package:myocircle15screens/services/applife_cycle_manager.dart';
import 'package:myocircle15screens/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'forgot_pin_logic/enter_email_vm.dart';
import 'screens/onboarding/splash_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  HttpOverrides.global =
      MyHttpOverrides(); // Disabling SSL verification for dev

  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await NotificationManager.initialize();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ✅ Initialize SessionProvider and load saved selectedProfileId
  final sessionProvider = SessionProvider();
  await sessionProvider.loadSelectedProfileId();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AvatarProvider()),
      ChangeNotifierProvider(create: (_) => SessionProvider()),
      ChangeNotifierProvider(create: (_) => FirstTimeUserProvider()),
      ChangeNotifierProvider(create: (_) => IndexProvider()),
      ChangeNotifierProvider(create: (_) => ForgotPinProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: SnackbarHelper.snackbarKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        canvasColor: Color(0xFFF6F5F3),
        cardColor: Color(0xFFF6F5F3),
      ),
      home: const SplashScreen(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}

class BridgeScreen extends StatefulWidget {
  const BridgeScreen({super.key});

  @override
  State<BridgeScreen> createState() => _BridgeScreenState();
}

class _BridgeScreenState extends State<BridgeScreen> {
  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionProvider>(context);
    final data = session.userData;
    print(data);
    print("BridgeScreenData");
    final userToken = data?['user_token'];
    final isFirstTime = Provider.of<FirstTimeUserProvider>(context).isFirstTime;

    return userToken == null
        ? const LoginScreen()
        : Builder(
            builder: (context) {
              print("*********");
              print(data?["consentStatus"]);
              print(data?["avatarImg"]);
              print(isFirstTime);
              print("*********");
              if (data?["consentStatus"] == null) {
                return const TosScreen();
              } else if (data?["avatarImg"] == null || data?["avatarImg"] == "" && data?["isPatient"] =="Yes") {
                return const SetupProfileScreen();
              } else if (isFirstTime) {
                return const WelcomeScreen();
              } else {
                return const PatientMasterScreen();
              }
            },
          );
  }
}
