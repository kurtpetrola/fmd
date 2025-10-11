//splash_screen.dart

import 'package:findmydorm/pages/selection_page.dart';
import 'package:flutter/material.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

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
      nextScreen: const SelectionPage(),
    );
  }
}
