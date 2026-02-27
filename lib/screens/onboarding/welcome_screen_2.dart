import 'package:flutter/material.dart';
import 'package:myocircle15screens/screens/onboarding/welcome_screen_3.dart';
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';
import 'package:myocircle15screens/services/api_service.dart';

import '../../components/components_path.dart';
import '../../components/profile_header.dart';
import '../../providers/session_provider.dart';

class WelcomeScreen2 extends StatefulWidget {
  final String topContent2;
  final String bottomContent2;
  final String topContent3;
  final String bottomContent3;
  const WelcomeScreen2(
      {super.key,
      required this.topContent2,
      required this.bottomContent2,
      required this.topContent3,
      required this.bottomContent3});

  @override
  State<WelcomeScreen2> createState() => _WelcomeScreen2State();
}

class _WelcomeScreen2State extends State<WelcomeScreen2> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    print("height $screenHeight");
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        actions: [
          Expanded(child: ProfileHeader()),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(flex: 2, child: SizedBox()),
                          Expanded(
                            flex: 4,
                            child: AspectRatio(
                              aspectRatio: 2 / 1.3,
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        screenHeight / 20),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(10, 10),
                                        blurRadius: 10,
                                      ),
                                    ],
                                    image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: AssetImage(WELCOME_CONTAINER2))),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Text(
                                          widget.topContent2,
                                          style: TextStyle(
                                              fontFamily: "Alegreya_Sans",
                                              fontSize: screenHeight / 50),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          LayoutBuilder(
                                              builder: (context, constraints) {
                                            return Image.asset(
                                                height:
                                                    constraints.maxWidth / 2,
                                                DOT_COLORED);
                                          }),
                                          LayoutBuilder(
                                              builder: (context, constraints) {
                                            return Image.asset(
                                                height:
                                                    constraints.maxWidth / 2,
                                                DOT_WHITE);
                                          }),
                                          LayoutBuilder(
                                              builder: (context, constraints) {
                                            return Image.asset(
                                                height:
                                                    constraints.maxWidth / 2,
                                                DOT_COLORED);
                                          }),
                                          LayoutBuilder(
                                              builder: (context, constraints) {
                                            return Image.asset(
                                                height:
                                                    constraints.maxWidth / 2.2,
                                                DOT_WHITE);
                                          }),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Text(
                                widget.bottomContent2,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: screenHeight / 40,
                                    fontFamily: "Alegreya_Sans"),
                              )),
                            ],
                          ),
                        ),
                        ScaleButton(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WelcomeScreen3(
                                            topContent3: widget.topContent3,
                                            bottomContent3:
                                                widget.bottomContent3,
                                          )));
                            },
                            child: Image.asset(
                              NEXT_BTN,
                              fit: BoxFit.contain,
                              height: 70,
                            )),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  top: 0,
                  child: FractionallySizedBox(
                    heightFactor: 0.8,
                    child: Row(
                      children: [
                        Image.asset(WELCOME_CHAR2),
                      ],
                    ),
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
