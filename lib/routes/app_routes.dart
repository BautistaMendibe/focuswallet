import 'package:flutter/material.dart';
import 'package:focuswallet/screens/dashboard_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';

Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/dashboard': (context) => const DashboardScreen(),
};
