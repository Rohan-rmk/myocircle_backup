import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';
import 'package:myocircle15screens/services/api_service.dart';

import '../../components/components_path.dart';
import '../../components/onboarding_header.dart';
import '../../main.dart';
import '../../providers/first_time_user_provider.dart';
import '../../providers/session_provider.dart';

class SetupPinScreen extends StatefulWidget {
  final String uniqueId;
  final int userId;
  final int profileId;
  const SetupPinScreen(
      {super.key,
      required this.uniqueId,
      required this.userId,
      required this.profileId});

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  final List<TextEditingController> _pinControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _pinFocusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );
  @override
  void initState() {
    super.initState();
  }

  int? getPinAsInt() {
    // Extract and merge texts from controllers
    String pin = _pinControllers.map((c) => c.text.trim()).join("");

    // Ensure pin is not empty before parsing
    if (pin.isEmpty) return null; // Return null if no input

    // Convert to int safely
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
        backgroundColor: Color(0xfff5f5f5),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Login Card
                  Text(
                    'Setup Your PIN',
                    style: TextStyle(
                      fontFamily: "Alegreya_Sans",
                      fontSize: 36,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8E8E93),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      'Create a 4-digit PIN for logging in',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: "Alegreya_Sans",
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF888888),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  // PIN Container
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF367394), Color(0xFF1B8046)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'PIN',
                              style: TextStyle(
                                fontFamily: "Alegreya_Sans",
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                4,
                                (index) => Container(
                                  width: 44,
                                  height: 66,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 3,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: KeyboardListener(
                                      focusNode: FocusNode(),
                                      onKeyEvent: (event) {
                                        if (event is KeyDownEvent &&
                                            event.logicalKey ==
                                                LogicalKeyboardKey.backspace &&
                                            _pinControllers[index]
                                                .text
                                                .isEmpty &&
                                            index > 0) {
                                          _pinFocusNodes[index - 1]
                                              .requestFocus();
                                        }
                                      },
                                      child: TextField(
                                        cursorColor: Color(0xff0D4081),
                                        controller: _pinControllers[index],
                                        focusNode: _pinFocusNodes[index],
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        obscureText: true,
                                        obscuringCharacter: "●",

                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontFamily: "Alegreya_Sans",
                                        ),

                                        decoration: const InputDecoration(
                                          counterText: "",
                                          border: InputBorder.none,
                                        ),

                                        onTapOutside: (event) {
                                          _pinFocusNodes[index].unfocus();
                                        },

                                        onChanged: (value) {
                                          final prev = _prevPinValues[index];

                                          // 🔥 PASTE SUPPORT
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

                                          // ✅ FORWARD MOVE
                                          if (value.isNotEmpty) {
                                            _prevPinValues[index] = value;

                                            if (index < 3) {
                                              _pinFocusNodes[index + 1].requestFocus();
                                            } else {
                                              _pinFocusNodes[index].unfocus();
                                            }
                                            return;
                                          }

                                          // 🔥 CONTINUOUS BACKSPACE (KEY FIX)
                                          if (value.isEmpty && prev.isNotEmpty) {
                                            _prevPinValues[index] = '';

                                            if (index > 0) {
                                              _pinFocusNodes[index - 1].requestFocus();

                                              // put cursor at end so next backspace works
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
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Login Button
                  Padding(
                    padding: EdgeInsets.only(left: screenWidth / 17),
                    child: ScaleButton(
                      onTap: () async {
                        if (getPinAsInt() != null) {
                          bool allow = false;
                          for (var controller in _pinControllers) {
                            if (controller.text == "") {
                              SnackbarHelper.showSnackbar(
                                  "Please enter full pin",
                                  color: Colors.red);
                              return;
                            } else {
                              allow = true;
                            }
                          }
                          if (allow == true) {
                            var SetupPinResponse = await ApiService.setPin(
                                context,
                                widget.profileId,
                                widget.userId,
                                getPinAsInt()!);
                            if (SetupPinResponse['status'] == 200) {
                              var loginResponse = await ApiService.login(
                                  context,
                                  widget.uniqueId,
                                  getPinAsInt()!,
                                  true);
                              if (loginResponse['code'] == "200") {
                                Provider.of<SessionProvider>(context, listen: false).setUserData(loginResponse['data'], widget.uniqueId, getPinAsInt()!);
                                final session = Provider.of<SessionProvider>(context, listen: false);
                                List<String> withNullValues = [];
                                loginResponse['data'].forEach((key, value) {
                                  if (value == null) {
                                    withNullValues.add(key);
                                  }
                                });
                                withNullValues.add("firstTime");
                                Provider.of<FirstTimeUserProvider>(context,
                                        listen: false).setFirstTime(true);
                                Provider.of<FirstTimeUserProvider>(context,
                                        listen: false)
                                    .setAge(loginResponse['data']['age']);
                                // await session.setSelectedProfileId(widget.profileId);


                                final data = loginResponse['data'];

                                if (data['isPatient'] == "Yes") {
                                  await session.setSelectedProfileId(data['profileId']);
                                } else {
                                  await session.setSelectedProfileId(
                                    data['familyMembers'][0]['profileId'],
                                  );
                                }
                                debugPrint(
                                  "📌 selectedProfileId BEFORE navigation: ${session.selectedProfileId}",
                                );
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BridgeScreen()));
                              }
                            } else if (SetupPinResponse['status'] != 200) {
                              SnackbarHelper.showSnackbar(
                                SetupPinResponse['message'] ?? "Failed to set PIN",
                                color: Colors.red,
                              );
                              return;
                            }
                          }
                        } else {
                          SnackbarHelper.showSnackbar(
                              "Please enter pin correctly",
                              color: Colors.red);
                        }
                      },
                      child: Image.asset(
                        SUBMIT_BTN,
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
                  // Register Button
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var focusNode in _pinFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
