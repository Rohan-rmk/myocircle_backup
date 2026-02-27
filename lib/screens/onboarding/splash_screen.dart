import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../../components/components_path.dart';
import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay splash screen for 3 seconds, then navigate to BridgeScreen
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BridgeScreen()),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Color(0xfff5f5f5),
      body: SafeArea(
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(height: 133,width: 199,LOGO_SPLASH,fit: BoxFit.cover,),
              SizedBox(height: 10,),
              RichText(textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(letterSpacing: 3,fontWeight: FontWeight.w700,
                    fontFamily: "Alegreya_SC",
                    color: Color(0xFF3E52A8),
                    fontSize: 40,
                  ),
                  children: [
                    TextSpan(text: "M"),
                    TextSpan(
                      text: "YO", // Circle character
                      style: TextStyle(fontSize: 32,fontWeight: FontWeight.w700,), // Larger font size for the circle
                    ),
                    TextSpan(text: "C"),
                    TextSpan(
                      text: "IRCLE", // Circle character
                      style: TextStyle(fontSize: 32,fontWeight: FontWeight.w700,), // Larger font size for the circle
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              GradientText("Breathe - Sleep - Grow",gradientType: GradientType.linear,gradientDirection: GradientDirection.ttb,colors: [
                Color(0xffB4EC51),
                Color(0xff66862E),
              ],style: TextStyle(fontFamily: "Alegreya_Sans",fontSize: 35,fontWeight: FontWeight.w500),),
            ],
          ),
        ),
      ),
    );
  }
}
