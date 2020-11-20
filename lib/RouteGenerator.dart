import 'package:flutter/material.dart';

import 'Home.dart';
import 'Login.dart';
import 'Messages.dart';
import 'Settings.dart';
import 'Signup.dart';

class RouteGenerator {

  static Route<dynamic> generateRoute(RouteSettings settings) {

    final args = settings.arguments;

    switch(settings.name) {
      case "/":
        return MaterialPageRoute(  builder: (_) => Login()  );
      case "/login":
        return MaterialPageRoute(  builder: (_) => Login()  );
      case "/signup":
        return MaterialPageRoute(  builder: (_) => Signup()  );
      case "/home":
        return MaterialPageRoute(  builder: (_) => Home()  );
      case "/settings":
        return MaterialPageRoute(  builder: (_) => Settings()  );
      case "/messages":
        return MaterialPageRoute(  builder: (_) => Messages(args)  );
      default:
        _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
        builder: (_) {
          return Scaffold(

            appBar: AppBar(title: Text("Screen not found!"),),
            body: Center(child: Text("Screen not found!"),),
          );
        }
    );
  }
}