import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myocircle15screens/main.dart';
import 'package:myocircle15screens/screens/onboarding/setup_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:myocircle15screens/services/api_service.dart';

import '../../components/components_path.dart';
import '../../components/onboarding_header.dart';
import '../../providers/first_time_user_provider.dart';
import '../../providers/session_provider.dart';
import 'login_screen.dart';

class TosScreen extends StatefulWidget {
  const TosScreen({super.key});

  @override
  State<TosScreen> createState() => _TosScreenState();
}

class _TosScreenState extends State<TosScreen> {
  String consentText = "";
  String consentPlaceholder = """
  These Terms and Conditions ("Terms") govern your use of our mobile application and services. By accessing or using Myocircle app you agree to comply with these Terms. If you do not agree, please do not use the App.
  These Terms and Conditions ("Terms") govern your use of our mobile application and services. By accessing or using Myocircle app you agree to comply with these Terms. If you do not agree, please do not use the App.
  These Terms and Conditions ("Terms") govern your use of our mobile application and services. By accessing or using Myocircle app you agree to comply with these Terms. If you do not agree, please do not use the App.
  These Terms and Conditions ("Terms") govern your use of our mobile application and services. By accessing or using Myocircle app you agree to comply with these Terms. If you do not agree, please do not use the App.
  """;

  bool _isChecked1 = false;
  bool _isChecked2 = false;
  bool? _applianceSelected; // null = not answered, true = Yes, false = No
  bool _didLoad = false;

  final ScrollController _scrollController = ScrollController();

  void getConsentText() async {
    var getConsentTextResponse = await ApiService.getConsentText(
        Provider.of<SessionProvider>(context, listen: false)
            .userData?['user_token']!,
        context);
    if (getConsentTextResponse['status'] == 200) {
      if (mounted) {
        for (final data in getConsentTextResponse['data']) {
          consentText += "\n## ${data['consentTitle']}\n";
          consentText += data['consentText'][0];
        }
        setState(() {});
      }
    }
  }

  void recordConsent() async {
    var recordConsentResponse = await ApiService.recordConsent(
        context,
        Provider.of<SessionProvider>(context, listen: false)
            .userData?['user_token']!,
        Provider.of<SessionProvider>(context, listen: false)
            .userData?['profileId']!,
        Provider.of<SessionProvider>(context, listen: false)
            .userData?['userId']!,
        _isChecked1 ? "Yes" : "No");

    if (recordConsentResponse['status'] == 200) {
      var loginResponse = await ApiService.login(
          context,
          Provider.of<SessionProvider>(context, listen: false).uniqueId!,
          Provider.of<SessionProvider>(context, listen: false).pin!,
          false);
      if (loginResponse['code'] == "200") {
        Provider.of<SessionProvider>(context, listen: false).setUserData(
            loginResponse['data'],
            Provider.of<SessionProvider>(context, listen: false).uniqueId!,
            Provider.of<SessionProvider>(context, listen: false).pin!);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BridgeScreen()));
      }
    }
  }

  void recordConsentApplianceYes() async {
    final userData = Provider.of<SessionProvider>(context, listen: false).userData!;
    Provider.of<SessionProvider>(context, listen: false)
        .userData?['user_token'].toString();
    Provider.of<SessionProvider>(context, listen: false)
        .userData?['profileId']!;
    Provider.of<SessionProvider>(context, listen: false)
        .userData?['userId']!;
    final response = await ApiService.recordConsentAppliance(
      context: context,
      userToken: userData['user_token'].toString(),
      userId: userData['userId'],
      profileId: userData['profileId'],
      termsAccepted: "Agree",
    );
    print("&&&&&&&&");
    print(userData['user_token']);
    print(userData['userId']);
    print(userData['profileId']);
    if (response["status"] == 200) {
      print(response["message"]); // "Consent recorded successfully"
    } else {
      print("Error recording consent: ${response["message"]}");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      if (Provider.of<SessionProvider>(context, listen: false)
              .userData?['user_token'] !=
          null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _didLoad = true;
          getConsentText();
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        actions: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: OnboardingHeader(),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              Expanded(
                flex: 12,
                child: Column(
                  children: [
                    const Text(
                      "Terms & Conditions",
                      style: TextStyle(
                          fontSize: 28,
                          fontFamily: "Alegreya_SC",
                          fontWeight: FontWeight.w500,
                          color: Color(0xff8E8E93)),
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      child: Card(
                        elevation: 7,
                        shadowColor: Colors.black,
                        color: Colors.white,
                        surfaceTintColor: Colors.white,
                        child: Skeletonizer(
                          enabled: consentText == "",
                          child: Markdown(
                            controller: _scrollController,
                            data: consentText == ""
                                ? consentPlaceholder
                                : consentText,
                            styleSheet: MarkdownStyleSheet(
                              h1: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff979797),
                                  fontFamily: "Alegreya_Sans"),
                              h2: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff979797),
                                  fontFamily: "Alegreya_Sans"),
                              h3: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff979797),
                                  fontFamily: "Alegreya_Sans"),
                              p: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff979797),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Alegreya_Sans"),
                              strong: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontFamily: "Alegreya_Sans"),
                              em: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.teal,
                                  fontFamily: "Alegreya_Sans"),
                              blockquote: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontFamily: "Alegreya_Sans"),
                              code: const TextStyle(
                                  backgroundColor: Colors.black12,
                                  fontSize: 12,
                                  fontFamily: "Alegreya_Sans"),
                              listBullet: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange,
                                  fontFamily: "Alegreya_Sans"),
                              a: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontFamily: "Alegreya_Sans"),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 5),
                      child: Column(
                        children: [
                          gradientCheckboxContainer(
                            checked: _isChecked1,
                            onChanged: (val) =>
                                setState(() => _isChecked1 = val ?? false),
                            text:
                                "I consent to using the selfie camera for practice",
                          ),
                          const SizedBox(height: 5),
                          gradientCheckboxContainer(
                            checked: _isChecked2,
                            onChanged: (val) =>
                                setState(() => _isChecked2 = val ?? false),
                            text: "I agree to the Terms & Conditions",
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color.fromRGBO(186, 217, 199, 1),
                                  width: 1),
                              gradient: const LinearGradient(colors: [
                                Color(0xff367394),
                                Color(0xff1B8046),
                              ]),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  flex: 4,
                                  child: Text(
                                    "Appliance Prescribed",
                                    style: TextStyle(
                                      fontFamily: "Jost",
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      buildApplianceButton(
                                        label: "Yes",
                                        selected: _applianceSelected == true,
                                        selectedColor: Colors.green,
                                        onTap: () {
                                          setState(() {
                                            _applianceSelected = true;
                                          });
                                          recordConsentApplianceYes();
                                        },
                                      ),
                                      buildApplianceButton(
                                        label: "No",
                                        selected: _applianceSelected == false,
                                        selectedColor: Colors.red,
                                        onTap: () {
                                          setState(() {
                                            _applianceSelected = false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(left: screenWidth / 17),
                  child: SizedBox(
                    height: 120,
                    child: ScaleButton(
                      onTap: () {
                        if (consentText !=
                            "Loading Consent Text, Please Wait!") {
                          if (!_isChecked2) {
                            SnackbarHelper.showSnackbar(
                                "Please accept the Terms of Service");
                            return;
                          }
                          if (_applianceSelected == null) {
                            SnackbarHelper.showSnackbar(
                                "Please select if an appliance is prescribed");
                            return;
                          }
                          recordConsent();
                        } else {
                          SnackbarHelper.showSnackbar("Please wait");
                        }
                      },
                      child: Image.asset(
                        CONTINUE_BTN,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable gradient checkbox widget
  Widget gradientCheckboxContainer({
    required bool checked,
    required Function(bool?) onChanged,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color.fromRGBO(186, 217, 199, 1), width: 1),
        gradient: const LinearGradient(
          colors: [Color(0xff367394), Color(0xff1B8046)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Transform.scale(
              scale: 1,
              child: Checkbox(
                side: BorderSide.none,
                checkColor: Colors.black,
                fillColor: const WidgetStatePropertyAll(Colors.white),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                value: checked,
                onChanged: onChanged,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Text(
              text,
              style: const TextStyle(
                  fontFamily: "Jost", fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Appliance Yes/No button builder
  Widget buildApplianceButton({
    required String label,
    required bool selected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selectedColor, width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : selectedColor,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontFamily: "Jost",
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
