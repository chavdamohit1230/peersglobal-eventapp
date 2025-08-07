import 'package:go_router/go_router.dart';
import 'package:peersglobleeventapp/home_page.dart';
import 'package:peersglobleeventapp/loginscreen.dart';
import 'package:peersglobleeventapp/qr_scanResult.dart';
import 'package:peersglobleeventapp/registration_screen.dart';
import 'package:peersglobleeventapp/splashscreen.dart';
import 'package:peersglobleeventapp/userProfile_screen.dart';

class AppRouter{

  static final GoRouter router=GoRouter(routes:[
    GoRoute(path: "/",
      builder:(context, state) => Splashscreen(),
    ),

    GoRoute(path: "/loginscreen",
      builder:(context, state) =>Loginscreen(),
    ),
    GoRoute(path: "/registration_screen",
    builder: (context, state) => RegistrationScreen(),)
    ,
    GoRoute(path: "/home_page",
    builder:(context, state) =>HomePage(),),

    GoRoute(
      path: "/qr_scanResult/:qrCode",
      builder: (context, state) {
        final qrCode = state.pathParameters['qrCode']!;
        return QrScanresult(qrCode: qrCode);
      },
    ),

    GoRoute(
        path:'/userProfile_screen',
        builder: (context, state) => UserprofileScreen(),
    )


  ]);

}