import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';
import 'package:myocircle15screens/services/api_service.dart';

import '../../components/components_path.dart';
import '../../components/profile_header.dart';
import '../../main.dart';
import '../../providers/first_time_user_provider.dart';
import '../../providers/session_provider.dart';
class WelcomeScreen3 extends StatefulWidget {
  final String topContent3;
  final String bottomContent3;
  const WelcomeScreen3({super.key, required this.topContent3, required this.bottomContent3});

  @override
  State<WelcomeScreen3> createState() => _WelcomeScreen3State();
}

class _WelcomeScreen3State extends State<WelcomeScreen3> {

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(backgroundColor: Color(0xfff5f5f5),appBar: AppBar(automaticallyImplyLeading: false,forceMaterialTransparency: true,actions: [
      Expanded(child: ProfileHeader()),
    ],),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Stack(alignment: Alignment.center,
              children: [
                Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(flex: 4,
                            child: AspectRatio(aspectRatio: 2/1.3,
                              child: Container(padding: EdgeInsets.all(20),decoration: BoxDecoration(borderRadius: BorderRadius.circular(screenHeight/20),boxShadow: [
                                BoxShadow(
                                  offset: Offset(10, 10),blurRadius: 10,
                                ),
                              ],image: DecorationImage(fit: BoxFit.fill,image: AssetImage(WELCOME_CONTAINER2))),
                                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(flex: 4,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Text(widget.topContent3,style: TextStyle(fontFamily: "Alegreya_Sans",fontSize:screenHeight/50),),
                                      ),
                                    ),
                                    Expanded(flex: 1,
                                      child: Column(mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          LayoutBuilder(
                                              builder: (context,constraints) {
                                                return Image.asset(height: constraints.maxWidth/2,DOT_COLORED);
                                              }
                                          ),
                                          LayoutBuilder(
                                              builder: (context,constraints) {
                                                return Image.asset(height: constraints.maxWidth/2,DOT_WHITE);
                                              }
                                          ),
                                          LayoutBuilder(
                                              builder: (context,constraints) {
                                                return Image.asset(height: constraints.maxWidth/2,DOT_COLORED);
                                              }
                                          ),
                                          LayoutBuilder(
                                              builder: (context,constraints) {
                                                return Image.asset(height: constraints.maxWidth/2.2,DOT_WHITE);
                                              }
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(flex: 2,child: SizedBox()),

                        ],
                      ),
                    ),

                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(child: Text(widget.bottomContent3,textAlign: TextAlign.center,style: TextStyle(fontSize: screenHeight/40,fontFamily: "Alegreya_Sans"),)),
                            ],
                          ),
                        ),
                        ScaleButton(
                            onTap: (){
                          Provider.of<FirstTimeUserProvider>(context, listen: false).setFirstTime(false);
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>BridgeScreen()));

                        },
                            child: Image.asset(CONTINUE_WELCOME_BTN,fit: BoxFit.contain,height: 70)),
                      ],
                    ),
                  ],
                ),

                Positioned(bottom: 100,right: 0,top: 0,
                  child: FractionallySizedBox(heightFactor: 0.8,
                    child: Row(
                      children: [
                        Image.asset(WELCOME_CHAR3),
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

