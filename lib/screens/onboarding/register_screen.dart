import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:myocircle15screens/components/components_path.dart';
import 'package:myocircle15screens/components/onboarding_header.dart';
import 'package:myocircle15screens/screens/onboarding/login_screen.dart';
import 'package:myocircle15screens/screens/onboarding/setup_pin_screen.dart';
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';
import 'package:myocircle15screens/services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _uniqueIdController = TextEditingController();
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final ScrollController _scrollController = ScrollController();
  final List<FocusNode> _codeFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  @override
  void initState() {
    super.initState();
  }

  int? getCodeAsInt() {
    // Extract and merge texts from controllers
    String pin = _codeControllers.map((c) => c.text.trim()).join("");

    // Ensure pin is not empty before parsing
    if (pin.isEmpty) return null; // Return null if no input

    // Convert to int safely
    return int.tryParse(pin);
  }
  List<String> _previousValues = List.filled(6, '');
  FocusNode _emailFocus = FocusNode();
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    print(screenHeight);
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
      backgroundColor: Color(0xfff5f5f5),
      resizeToAvoidBottomInset: false,
      body: KeyboardVisibilityBuilder(builder: (context, isKeyboardOpen) {
        return SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Register',
                          style: TextStyle(
                            fontFamily: "Alegreya_Sans",
                            fontSize: screenHeight / 26,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8E8E93),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30, right: 30),
                            child: Container(
                              height:
                                  250, // Adjusted width// Fixed height constraint
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
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  10,
                                  12,
                                  10,
                                ), // Adjusted padding
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Color(0xffF5F5F5),
                                                borderRadius: BorderRadius.circular(6),
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
                                                controller: _uniqueIdController,
                                                decoration:
                                                    const InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 10),
                                                  hintText:
                                                      "Enter your email ID",
                                                  hintStyle: TextStyle(
                                                      fontFamily:
                                                          "Alegreya_Sans",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color(0xff8E8E93)),
                                                  border: InputBorder.none,
                                                  // Reduced padding
                                                ),
                                                style: const TextStyle(
                                                    color: Colors.black),
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Center(
                                        child: Text(
                                          'Enter Activation Code sent to your email',
                                          style: TextStyle(
                                            fontFamily: "Alegreya_Sans",
                                            color: Colors.white,
                                            fontSize: screenHeight / 47,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: List.generate(
                                          6,
                                          (index) => Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 0.9),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Color.fromRGBO(
                                                          0, 0, 0, 0.4),
                                                      blurRadius:
                                                          4, // Reduced blur radius
                                                      offset: const Offset(
                                                        0,
                                                        3,
                                                      ), // Adjusted offset
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: KeyboardListener(
                                                    focusNode: FocusNode(),
                                                    onKeyEvent: (event) {
                                                      if (event is KeyDownEvent &&
                                                          event.logicalKey ==
                                                              LogicalKeyboardKey
                                                                  .backspace &&
                                                          _codeControllers[
                                                                  index].text.isEmpty &&
                                                          index > 0) {
                                                        _codeFocusNodes[index - 1].requestFocus();
                                                      }
                                                    },
                                                    child: TextField(
                                                      onTapOutside: (event) {
                                                        setState(() {
                                                          _codeFocusNodes[index]
                                                              .unfocus();
                                                        });
                                                      },
                                                      onTap: () {
                                                        // _codeControllers[index].clear();
                                                      },
                                                      cursorColor:
                                                          Color(0xff0D4081),
                                                      controller:
                                                          _codeControllers[index],
                                                      focusNode:
                                                          _codeFocusNodes[index],
                                                      textAlign:
                                                          TextAlign.center,
                                                      obscureText: true,
                                                      keyboardType: TextInputType.number,
                                                      obscuringCharacter: "●",

                                                      style: const TextStyle(
                                                        fontSize: 19,
                                                      ), // Slightly reduced font size
                                                      decoration:
                                                          const InputDecoration(
                                                        counterText: "",
                                                        border:
                                                            InputBorder.none,
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                      ),
                                                      // onChanged: (value) {
                                                      //   if (value.isNotEmpty) {
                                                      //     if (index < 5) {
                                                      //       FocusScope.of(
                                                      //               context)
                                                      //           .requestFocus(
                                                      //         _codeFocusNodes[
                                                      //             index + 1],
                                                      //       );
                                                      //     } else {
                                                      //       FocusScope.of(
                                                      //               context)
                                                      //           .unfocus();
                                                      //     }
                                                      //   }
                                                      // },
                                                      ///
                                                      onChanged: (value) {
                                                        final prev = _previousValues[index];

                                                        // 🔥 PASTE CASE
                                                        if (value.length > 1) {
                                                          final pasted = value.replaceAll(RegExp(r'[^0-9]'), '').split('');

                                                          for (int i = 0; i < _codeControllers.length; i++) {
                                                            _codeControllers[i].text =
                                                            i < pasted.length ? pasted[i] : '';
                                                            _previousValues[i] = _codeControllers[i].text;
                                                          }

                                                          int lastIndex = pasted.length >= 6 ? 5 : pasted.length;
                                                          _codeFocusNodes[lastIndex].requestFocus();
                                                          return;
                                                        }

                                                        // ✅ NORMAL INPUT
                                                        if (value.isNotEmpty) {
                                                          _previousValues[index] = value;

                                                          if (index < 5) {
                                                            _codeFocusNodes[index + 1].requestFocus();
                                                          } else {
                                                            _codeFocusNodes[index].unfocus();
                                                          }
                                                          return;
                                                        }

                                                        // 🔥 CONTINUOUS BACKSPACE FIX
                                                        if (value.isEmpty) {
                                                          _previousValues[index] = '';

                                                          if (index > 0) {
                                                            // Move to previous FIRST
                                                            _codeFocusNodes[index - 1].requestFocus();

                                                            // Delay ensures focus change happens before clearing
                                                            Future.microtask(() {
                                                              _codeControllers[index - 1].selection = TextSelection.collapsed(offset: 1);
                                                            });
                                                          }
                                                        }
                                                      },
                                                      ///
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .digitsOnly,
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        height: 5), // Reduced spacing
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Login Button
                Padding(
                  padding: EdgeInsets.only(left: screenWidth / 17),
                  child: ScaleButton(
                    onTap: () async {
                      if (_uniqueIdController.text != "") {
                        if (getCodeAsInt() != null) {
                          var RegisterResponse =
                              await ApiService.authenticateUser(context,
                                  _uniqueIdController.text, getCodeAsInt()!);
                          print(RegisterResponse);
                          if (RegisterResponse['status'] == 200) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SetupPinScreen(
                                  uniqueId: _uniqueIdController.text,
                                  userId: RegisterResponse['data']['userId'],
                                  profileId: RegisterResponse['data']
                                      ['profileId'],
                                ),
                              ),
                            );
                          } else if (RegisterResponse['status'] == "failure") {
                            if (RegisterResponse['message'] ==
                                "Verification code is not valid") {
                              SnackbarHelper.showSnackbar(
                                  "Invalid authentication code.",
                                  color: Colors.red);
                            } else if (RegisterResponse['message'] ==
                                "Unique ID not a valid.") {
                              SnackbarHelper.showSnackbar("Invalid email ID",
                                  color: Colors.red);
                            } else {
                              SnackbarHelper.showSnackbar(
                                  "${RegisterResponse['message']}",
                                  color: Colors.red);
                            }
                          }
                        } else {
                          SnackbarHelper.showSnackbar(
                              "Please enter pin correctly",
                              color: Colors.red);
                        }
                      } else {
                        SnackbarHelper.showSnackbar("Please enter unique id",
                            color: Colors.red);
                      }
                    },
                    child: Image.asset(
                      REGISTER_BTN,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Column(
                      children: [
                        Text(
                          'Already registered?',
                          style: TextStyle(
                            fontFamily: "Alegreya_Sans",
                            fontSize: screenHeight / 32,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8E8E93),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Click here to login',
                            style: TextStyle(
                              fontFamily: "Alegreya_Sans",
                              fontSize: screenHeight / 45,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF017EB9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _uniqueIdController.dispose();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var focusNode in _codeFocusNodes) {
      focusNode.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }
}
