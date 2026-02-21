// splash_screen.dart

import 'package:flutter/material.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:findmydorm/presentation/pages/auth/auth_check_wrapper.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.fadeIn(
      backgroundColor: Colors.white,
      onInit: () {
        debugPrint("On Init");
      },
      onEnd: () {
        debugPrint("On End");
      },
      childWidget: SizedBox(
        height: 300,
        width: 300,
        child: Image.asset("assets/images/logo1.png"),
      ),
      onAnimationEnd: () => debugPrint("On Fade In End"),

      // Navigate directly to the AuthCheckWrapper
      nextScreen: const AuthCheckWrapper(),
    );
  }
}
