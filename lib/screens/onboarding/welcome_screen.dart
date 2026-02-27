import 'package:flutter/material.dart';
import 'package:myocircle15screens/screens/onboarding/welcome_screen_2.dart';
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:myocircle15screens/services/api_service.dart';

import '../../components/components_path.dart';
import '../../components/profile_header.dart';
import '../../providers/session_provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String topContent = "Top Content is Loading";
  String bottomContent = "Bottom Content is Loading";
  String topContent2 = "";
  String bottomContent2 = "";
  String topContent3 = "";
  String bottomContent3 = "";
  void getAppContent() async {
    var getConsentTextResponse = await ApiService.getAppContent(
        Provider.of<SessionProvider>(context, listen: false)
            .userData?['user_token']!,
        context);
    if (getConsentTextResponse['code'] == "200") {
      if (mounted)
        setState(() {
          topContent = getConsentTextResponse["data"][0]['topContent'];
          bottomContent = getConsentTextResponse["data"][0]['bottomContent'];
          topContent2 = getConsentTextResponse["data"][1]['topContent'];
          bottomContent2 = getConsentTextResponse["data"][1]['bottomContent'];
          topContent3 = getConsentTextResponse["data"][2]['topContent'];
          bottomContent3 = getConsentTextResponse["data"][2]['bottomContent'];
        });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Provider.of<SessionProvider>(context, listen: false)
            .userData?['user_token'] !=
        null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getAppContent();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String? name =
        Provider.of<SessionProvider>(context).userData?['userProfileName'];
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    print(screenHeight);
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
          child: Column(
            children: [
              Column(
                children: [
                  Text(
                    "Welcome to MyoCircle",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: screenHeight / 35,
                        fontFamily: "Alegreya_Sans"),
                  ),
                  Text(
                    "${name}!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: screenHeight / 35,
                        fontFamily: "Alegreya_Sans"),
                  ),
                ],
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(left: 70),
                child: Image.asset(WELCOME_CHAR1),
              )),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Skeletonizer(
                    effect: ShimmerEffect(
                        duration: Duration(milliseconds: 1500),
                        baseColor: Colors.black12,
                        highlightColor: Colors.white10),
                    enabled: bottomContent == "Bottom Content is Loading",
                    child: Text(
                      bottomContent,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: screenHeight / 40,
                          fontFamily: "Alegreya_Sans"),
                    )),
              ),
              ScaleButton(
                  onTap: () {
                    //if (bottomContent != "Bottom Content is Loading")
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WelcomeScreen2(
                                  topContent2: topContent2,
                                  topContent3: topContent3,
                                  bottomContent2: bottomContent2,
                                  bottomContent3: bottomContent3,
                                )));
                  },
                  child: Image.asset(
                    NEXT_BTN,
                    fit: BoxFit.contain,
                    height: 70,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
