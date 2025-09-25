import 'package:go_router/go_router.dart';
import 'package:peersglobleeventapp/FloorPlanPage.dart';
import 'package:peersglobleeventapp/eventagenda.dart';
import 'package:peersglobleeventapp/home_page.dart';
import 'package:peersglobleeventapp/invitaion.dart';
import 'package:peersglobleeventapp/loginscreen.dart';
import 'package:peersglobleeventapp/people_knows.dart';
import 'package:peersglobleeventapp/qr_scanResult.dart';
import 'package:peersglobleeventapp/registration_screen.dart';
import 'package:peersglobleeventapp/splashscreen.dart';
import 'package:peersglobleeventapp/userProfile_screen.dart';
import 'package:peersglobleeventapp/modelClass/model/userregister_model.dart';

class AppRouter {
  static GoRouter getRouter({required bool isLoggedIn, String? userId}) {
    return GoRouter(
      initialLocation: isLoggedIn && userId != null ? "/home_page" : "/loginscreen",
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) => const Splashscreen(),
        ),

        GoRoute(
          path: "/loginscreen",
          builder: (context, state) => const Loginscreen(),
        ),
        GoRoute(path: "/floorplan",
        builder: (context, state) => FloorPlanPage(),),
        GoRoute(
          path: "/registration_screen",
          builder: (context, state) => const RegistrationScreen(),
        ),
        GoRoute(
          path: '/people_knows',
          builder: (context, state) {
          final currentUserId = state.extra != null && state.extra is Map<String, dynamic>
          ? (state.extra as Map<String, dynamic>)['currentUserId'] as String
              : "";

          return PeopleKnows(currentUserId: currentUserId);
          },
        ),
        GoRoute(path: "/invitaion",
          builder: (context, state) {
            final currentUserId = state.extra != null && state.extra is Map<String, dynamic>
                ? (state.extra as Map<String, dynamic>)['currentUserId'] as String
                : "";

            return Invitaion(currentUserId: currentUserId);
          },

        ),

        GoRoute(
          path: "/home_page",
          builder: (context, state) {
            // Agar login se aaya hai to state.extra use hoga
            if (state.extra != null) {
              final extra = state.extra as Map<String, dynamic>;
              final userId = extra['userId'] as String;
              final user = extra['user'] as UserRegister?;
              return HomePage(userId: userId, user: user);
            }

            // Agar SharedPreferences se aaya hai to sidha userId pass karo
            return HomePage(userId: userId ?? '');
          },
        ),

        GoRoute(
          path: "/qr_scanResult/:qrCode",
          builder: (context, state) {
            final qrCode = state.pathParameters['qrCode']!;
            return QrScanresult(qrCode: qrCode);
          },
        ),

        GoRoute(
          path: '/userProfile_screen',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final userId = extra['userId'] as String;
            final user = extra['user'] as UserRegister?;

            return UserprofileScreen(userId: userId, user: user);
          },
        ),

        GoRoute(path:'/eventagenda',
         builder: (context, state) => Eventagenda(),)
      ],
    );
  }
}
