import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // 👈 Import screenutil
import 'package:peersglobleeventapp/loginscreen.dart';
import 'package:peersglobleeventapp/splashscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // 👈 Base size (iPhone X)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Peers Global Event App',
          initialRoute: '/',
          routes: {
            '/': (context) => const Splashscreen(),
            '/loginscreen': (context) => const Loginscreen(),
          },
        );
      },
    );
  }
}
