import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = ApiService();
  final hasSession = await apiService.loadSession();
  
  runApp(MyApp(isLoggedIn: hasSession));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UDLAP Tickets',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}

