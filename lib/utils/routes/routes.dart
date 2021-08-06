import 'package:boilerplate/ui/home/home.dart';
import 'package:boilerplate/ui/login/login.dart';
import 'package:boilerplate/ui/register/register.dart';
import 'package:boilerplate/ui/splash/splash.dart';
import 'package:flutter/material.dart';

class Routes {
  Routes._();

  //static variables
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String register = '/register';

  static final routes = <String, WidgetBuilder>{
    splash: (BuildContext context) => SplashScreen(),
    login: (BuildContext context) => LoginScreen(),
    home: (BuildContext context) => HomeScreen(),
    register: (BuildContext context) => RegisterScreen(),
  };
}
