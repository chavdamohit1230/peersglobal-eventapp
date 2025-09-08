import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:peersglobleeventapp/routers/route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final userId = prefs.getString('userId');

  runApp(MyApp(isLoggedIn: isLoggedIn, userId: userId));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? userId;

  const MyApp({super.key, required this.isLoggedIn, this.userId});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Peers Global Event App',
          routerConfig: AppRouter.getRouter(
            isLoggedIn: isLoggedIn,
            userId: userId,
          ),
        );
      },
    );
  }
}
