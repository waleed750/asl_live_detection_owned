
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:asl_live_detection_owned/screens/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ASL Detection',
      theme: ThemeData(
        primaryColor: Color(0xff375079),
      ),
      home: LandingPage(),
    );
  }
}
