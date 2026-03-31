// import 'package:flutter/material.dart';
// import 'package:simple_gradient_text/simple_gradient_text.dart';
//
// import '../../components/components_path.dart';
// import '../../main.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Delay splash screen for 3 seconds, then navigate to BridgeScreen
//     Future.delayed(Duration(seconds: 3), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => BridgeScreen()),
//       );
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(backgroundColor: Color(0xfff5f5f5),
//       body: SafeArea(
//         child: Center(
//           child: Column(mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset(height: 133,width: 199,LOGO_SPLASH,fit: BoxFit.cover,),
//               SizedBox(height: 10),
//               RichText(textAlign: TextAlign.center,
//                 text: TextSpan(
//                   style: TextStyle(letterSpacing: 3,fontWeight: FontWeight.w700,
//                     fontFamily: "Alegreya_SC",
//                     color: Color(0xFF3E52A8),
//                     fontSize: 40,
//                   ),
//                   children: [
//                     TextSpan(text: "M"),
//                     TextSpan(
//                       text: "YO", // Circle character
//                       style: TextStyle(fontSize: 32,fontWeight: FontWeight.w700,), // Larger font size for the circle
//                     ),
//                     TextSpan(text: "C"),
//                     TextSpan(
//                       text: "IRCLE", // Circle character
//                       style: TextStyle(fontSize: 32,fontWeight: FontWeight.w700,), // Larger font size for the circle
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 10,),
//               GradientText("Breathe - Sleep - Grow",gradientType: GradientType.linear,gradientDirection: GradientDirection.ttb,colors: [
//                 Color(0xffB4EC51),
//                 Color(0xff66862E),
//               ],style: TextStyle(fontFamily: "Alegreya_Sans",fontSize: 35,fontWeight: FontWeight.w500),),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

///
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../../components/components_path.dart';
import '../../main.dart';
import '../../utils/auto_update_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initApp();
    });
  }

  /// 🔥 MAIN FLOW
  Future<void> _initApp() async {
    await Future.delayed(const Duration(seconds: 2));

    /// 🔥 STEP 1: FORCE UPDATE CHECK
    bool canContinue = await AppUpdateService.checkForUpdate(context);

    if (!canContinue) return; // ❌ BLOCK APP

    /// 🔥 STEP 2: NAVIGATE
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BridgeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // 🚫 block back
      child: Scaffold(
        backgroundColor: const Color(0xfff5f5f5),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  LOGO_SPLASH,
                  height: 133,
                  width: 199,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),

                /// 🔥 APP NAME
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Alegreya_SC",
                      color: Color(0xFF3E52A8),
                      fontSize: 40,
                    ),
                    children: [
                      TextSpan(text: "M"),
                      TextSpan(
                        text: "YO",
                        style: TextStyle(fontSize: 32),
                      ),
                      TextSpan(text: "C"),
                      TextSpan(
                        text: "IRCLE",
                        style: TextStyle(fontSize: 32),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                /// 🔥 TAGLINE
                GradientText(
                  "Breathe - Sleep - Grow",
                  gradientType: GradientType.linear,
                  gradientDirection: GradientDirection.ttb,
                  colors: const [
                    Color(0xffB4EC51),
                    Color(0xff66862E),
                  ],
                  style: const TextStyle(
                    fontFamily: "Alegreya_Sans",
                    fontSize: 35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
///
