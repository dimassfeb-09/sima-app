import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:project/utils/here_map.dart';
import 'package:project/views/HomePage.dart';
import 'package:project/views/LoginPage.dart';
import 'package:project/views/MainPage.dart';
import 'package:project/views/SplashScreenPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'utils/colors.dart';
import 'utils/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  HereMapUtils().initialize(
    accessKeyId: dotenv.env['ACCESS_KEY_ID'] ?? '',
    accessKeySecret: dotenv.env['ACCESS_KEY_SECRET'] ?? '',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SIMA APP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF6F8F9)),
        useMaterial3: true,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: blueAccent,
          unselectedItemColor: grayAccent,
        ),
      ),
      home: const SplashScreenPage(), // Set SplashScreen as the home
    );
  }
}
