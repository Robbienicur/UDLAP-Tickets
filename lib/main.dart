import 'package:flutter/material.dart';
// REMOVIBLE-PRUEBA: import de google_mobile_ads para anuncios demo
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/auth/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  // REMOVIBLE-PRUEBA: bindings + init de AdMob para los anuncios demo
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UDLAP Tickets',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const LoginScreen(),
    );
  }
}
