// splash_screen.dart

import 'package:flutter/material.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:go_router/go_router.dart';

/// The initial loading screen shown during application launch.
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
      asyncNavigationCallback: () async {
        await Future.delayed(const Duration(milliseconds: 2000));
        if (context.mounted) {
          context.go('/auth-check');
        }
      },
    );
  }
}
