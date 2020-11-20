import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whats_app/RouteGenerator.dart';
import 'Home.dart';
import 'Login.dart';
import 'dart:io';

final ThemeData iosTheme = ThemeData(
    primaryColor: Colors.grey[200],
    accentColor: Color(0xff25D366)
);

final ThemeData standardTheme = ThemeData(
    primaryColor: Color(0xff075E54),
    accentColor: Color(0xff25D366)
);


void main() {

  //WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    home: Login(),
    theme: Platform.isIOS ? iosTheme : standardTheme,
    initialRoute: "/",
    onGenerateRoute: RouteGenerator.generateRoute,
    debugShowCheckedModeBanner: false
  ));
}


