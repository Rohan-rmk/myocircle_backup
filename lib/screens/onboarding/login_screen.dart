import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:myocircle15screens/components/components_path.dart';
import 'package:myocircle15screens/components/onboarding_header.dart';
import 'package:myocircle15screens/main.dart';
import 'package:myocircle15screens/screens/onboarding/register_screen.dart';
import 'package:myocircle15screens/screens/patient_panel/patient_survey_screen.dart';
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';
import 'package:myocircle15screens/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/first_time_user_provider.dart';
import '../../providers/session_provider.dart';
import 'forgot_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _pinControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final ScrollController _scrollController = ScrollController();
  final List<FocusNode> _pinFocusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  FocusNode _emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  int? getPinAsInt() {
    String pin = _pinControllers.map((c) => c.text.trim()).join("");
    if (pin.isEmpty) return null;
    return int.tryParse(pin);
  }
  List<String> _prevPinValues = List.filled(4, '');
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
        bottom: AppBar(
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
      ),
      backgroundColor: const Color(0xfff5f5f5),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: KeyboardVisibilityBuilder(builder: (context, open) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 9,
                  child: Column(
                    mainAxisAlignment: open
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Patient Login',
                        style: TextStyle(
                          fontFamily: "Alegreya_Sans",
                          fontSize: 36,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8E8E93),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      Container(
                        width: 314,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF367394),
                              Color(0xff367393),
                              Color(0xFF1B8046)
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Email',
                                style: TextStyle(
                                  fontFamily: "Alegreya_Sans",
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Color(0xffF5F5F5),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: TextField(
                                  keyboardType: TextInputType.emailAddress,
                                  cursorColor: Color(0xff0D4081),
                                  focusNode: _emailFocus,
                                  onTapOutside: (event) {
                                    setState(() {
                                      _emailFocus.unfocus();
                                    });
                                  },
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    hintText: "Enter your email ID",
                                    hintStyle: TextStyle(
                                        fontFamily: "Alegreya_Sans",
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff8E8E93)),
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: "Alegreya_Sans"),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'PIN',
                                style: TextStyle(
                                  fontFamily: "Alegreya_Sans",
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(
                                  4,
                                  (index) => Container(
                                    width: 44,
                                    height: 66,
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(255, 255, 255, 0.9),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.4),
                                          blurRadius: 6,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: KeyboardListener(
                                        focusNode: FocusNode(),
                                        onKeyEvent: (event) {
                                          if (event is KeyDownEvent &&
                                              event.logicalKey == LogicalKeyboardKey.backspace && _pinControllers[index].text.isEmpty && index > 0) {
                                            _pinFocusNodes[index - 1].requestFocus();
                                          }
                                        },
                                        child: TextField(
                                          cursorColor: Color(0xff0D4081),
                                          controller: _pinControllers[index],
                                          focusNode: _pinFocusNodes[index],
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          obscureText: true,

                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontFamily: "Alegreya_Sans",
                                          ),

                                          decoration: const InputDecoration(
                                            counterText: "",
                                            border: InputBorder.none,
                                          ),

                                          onTapOutside: (event) {
                                            _pinFocusNodes[index].unfocus();
                                          },

                                          // 🔥 MAIN LOGIC
                                          onChanged: (value) {
                                            final prev = _prevPinValues[index];

                                            // 🔥 PASTE CASE
                                            if (value.length > 1) {
                                              final pasted = value.replaceAll(RegExp(r'[^0-9]'), '').split('');

                                              for (int i = 0; i < _pinControllers.length; i++) {
                                                _pinControllers[i].text =
                                                i < pasted.length ? pasted[i] : '';
                                                _prevPinValues[i] = _pinControllers[i].text;
                                              }

                                              int lastIndex = pasted.length >= 4 ? 3 : pasted.length;
                                              _pinFocusNodes[lastIndex].requestFocus();
                                              return;
                                            }

                                            // ✅ NORMAL INPUT
                                            if (value.isNotEmpty) {
                                              _prevPinValues[index] = value;

                                              if (index < 3) {
                                                _pinFocusNodes[index + 1].requestFocus();
                                              } else {
                                                _pinFocusNodes[index].unfocus();
                                              }
                                              return;
                                            }

                                            // 🔥 CONTINUOUS BACKSPACE
                                            if (value.isEmpty && prev.isNotEmpty) {
                                              _prevPinValues[index] = '';

                                              if (index > 0) {
                                                _pinFocusNodes[index - 1].requestFocus();

                                                // place cursor at end
                                                Future.microtask(() {
                                                  _pinControllers[index - 1].selection =
                                                      TextSelection.collapsed(offset: 1);
                                                });
                                              }
                                            }
                                          },

                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],

                                          autofillHints: const [AutofillHints.oneTimeCode],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                      open
                          ? const SizedBox()
                          : Padding(
                              padding: EdgeInsets.only(left: screenWidth / 17),
                              child: ScaleButton(
                                onTap: () async {
                                  if (_emailController.text.isNotEmpty) {
                                    if (getPinAsInt() != null) {
                                      var loginResponse =
                                          await ApiService.login(
                                        context,
                                        _emailController.text,
                                        getPinAsInt()!,
                                        true,
                                      );

                                      if (loginResponse['code'] == "200" &&
                                          loginResponse.containsKey('data')) {
                                        final session =
                                            Provider.of<SessionProvider>(
                                                context,
                                                listen: false);

                                        if (loginResponse['data']['isPatient'] == "Yes") {
                                          print("*****##");
                                          print(loginResponse['data']);
                                          print("*****##");
                                          String profileName = "";
                                          profileName = loginResponse['data']['profileName'];
                                          await session.setSelectedProfileId(loginResponse['data']['profileId']);
                                          await session.setSelectedProfileName(profileName);

                                        } else if (loginResponse['data']
                                                ['isPatient'] ==
                                            "No") {
                                          await session.setSelectedProfileId(
                                              loginResponse['data']
                                                      ['familyMembers'][0]
                                                  ['profileId']);
                                          print(
                                              "Login Selected ProfileId: ${loginResponse['data']['familyMembers'][0]['profileId']}");
                                          bool flag = false;
                                          await session.setNotPatient(flag);
                                        }
                                        print("login response: $loginResponse");
                                        Provider.of<SessionProvider>(context,
                                                listen: false)
                                            .setUserData(
                                                loginResponse['data'],
                                                _emailController.text,
                                                getPinAsInt()!);
                                        List<String> withNullValues = [];
                                        loginResponse['data']
                                            .forEach((key, value) {
                                          if (value == null) {
                                            withNullValues.add(key);
                                          }
                                        });
                                        if (withNullValues
                                            .contains("userProfileName")) {
                                          Provider.of<FirstTimeUserProvider>(
                                                  context,
                                                  listen: false)
                                              .setFirstTime(true);
                                        }
                                        Provider.of<FirstTimeUserProvider>(
                                                context,
                                                listen: false)
                                            .setAge(
                                                loginResponse['data']['age']);
                                        // after successful login; loginResponse['data'] contains userData
                                        final data = loginResponse['data']
                                            as Map<String, dynamic>?;

// Defensive default: if data is null, proceed to BridgeScreen
                                        if (data == null) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BridgeScreen()),
                                          );
                                          return;
                                        }

// Try to read familyMembers
                                        final familyMembersRaw =
                                            data['familyMembers'];
                                        bool anyMemberHasQuestions = false;

                                        if (familyMembersRaw is List) {
                                          for (var item in familyMembersRaw) {
                                            if (item is Map<String, dynamic>) {
                                              final fq =
                                                  item['feedbackQuestions'];
                                              // Consider non-null AND non-empty list as "has questions"
                                              if (fq != null) {
                                                if (fq is List &&
                                                    fq.isNotEmpty) {
                                                  anyMemberHasQuestions = true;
                                                  break;
                                                } else if (fq is! List) {
                                                  // If it's not a List but non-null (unexpected shape), treat as has questions
                                                  anyMemberHasQuestions = true;
                                                  break;
                                                }
                                              }
                                            }
                                          }
                                        } else {
                                          // familyMembers missing -> fallback to legacy top-level feedbackQuestions
                                          final topLevelFq =
                                              data['feedbackQuestions'];
                                          if (topLevelFq != null) {
                                            if (topLevelFq is List &&
                                                topLevelFq.isNotEmpty) {
                                              anyMemberHasQuestions = true;
                                            } else if (topLevelFq is! List) {
                                              anyMemberHasQuestions = true;
                                            }
                                          }
                                        }

// Navigate based on whether any member has feedbackQuestions
                                        if (anyMemberHasQuestions) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PatientSurveyScreen()),
                                          );
                                        } else {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BridgeScreen()),
                                          );
                                        }
                                      } else if (loginResponse['message'] ==
                                          "Pin is not valid.") {
                                        SnackbarHelper.showSnackbar(
                                          "Invalid PIN. Please try again.",
                                          color: Colors.red,
                                        );
                                      } else if (loginResponse['message'] ==
                                          "Email ID is not valid.") {
                                        SnackbarHelper.showSnackbar(
                                          "Email ID invalid or not registered.",
                                          color: Colors.red,
                                        );
                                      } else {
                                        SnackbarHelper.showSnackbar(
                                          loginResponse['message'] ??
                                              "Login failed. Please try again.",
                                          color: Colors.red,
                                        );
                                      }
                                    }
                                  }
                                },
                                child: Image.asset(
                                  LOGIN_BTN,
                                  width: 300,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 300,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF367394),
                                        borderRadius: BorderRadius.circular(25),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color.fromRGBO(0, 0, 0, 0.2),
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'LOGIN',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                      open
                          ? const SizedBox()
                          : GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen(),
                            ),
                          );
                        },
                            child: const Text(
                                'Forgot PIN',
                                style: TextStyle(
                                  fontFamily: "Alegreya_Sans",
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF017EB9),
                                ),
                                textAlign: TextAlign.center,
                              ),
                          ),
                    ],
                  ),
                ),
                open
                    ? const SizedBox()
                    : Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            const Text(
                              'New Here?',
                              style: TextStyle(
                                fontFamily: "Alegreya_Sans",
                                fontSize: 28,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF8E8E93),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterScreen()));
                              },
                              child: const Text(
                                'Click here to register',
                                style: TextStyle(
                                  fontFamily: "Alegreya_Sans",
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF017EB9),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var focusNode in _pinFocusNodes) {
      focusNode.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }
}
