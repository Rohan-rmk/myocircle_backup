import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myocircle15screens/components/profile_header.dart';
import 'package:scale_button/scale_button.dart';
import 'package:provider/provider.dart';

import '../../../components/components_path.dart';
import '../../../enums/patient_tab.dart';
import '../../../providers/index_provider.dart';
import '../../../services/api_service.dart';
import '../../../providers/session_provider.dart';

class ResetPinScreen extends StatefulWidget {
  const ResetPinScreen({super.key});

  @override
  State<ResetPinScreen> createState() => _ResetPinScreenState();
}

class _ResetPinScreenState extends State<ResetPinScreen> {
  final List<TextEditingController> _pinControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _pinFocusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );
  final List<TextEditingController> _codeControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _codeFocusNodes = List.generate(
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

  int? getCodeAsInt() {
    // Extract and merge texts from controllers
    String code = _codeControllers.map((c) => c.text.trim()).join("");

    // Ensure pin is not empty before parsing
    if (code.isEmpty) return null; // Return null if no input

    // Convert to int safely
    return int.tryParse(code);
  }

  bool allowPin = false;
  bool showSuccess = false;
  bool isLoading = false;
  List<String> _prevValues = List.filled(4, '');
  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionProvider>(context, listen: false);
    final profileId = session.userData?['profileId'];
    final userId = session.userData?['userId'];
    return Scaffold(
      backgroundColor: Color(0xfff6f5f3),
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   forceMaterialTransparency: true,
      //   actions: [
      //     Expanded(child: ProfileHeader()),
      //   ],
      // ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showSuccess)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF367394),
                          Color(0xFF367394),
                          Color(0xFF1B8046)
                        ],
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
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(50),
                          child: const Text(
                            'PIN updated successfully',
                            style: TextStyle(
                              fontFamily: "Alegreya_Sans",
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        ScaleButton(
                            onTap: () {
                              // Navigator.pop(context);
                              Provider.of<IndexProvider>(context, listen: false)
                                  .setIndex(PatientTab.home.index);
                            },
                            child: Image.asset(
                              EXERCISE_VIEW_OK_BTN,
                              fit: BoxFit.cover,
                            )),

                      ],
                    ),
                  ),
                ),
              )
            else if (allowPin)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF367394),
                          Color(0xFF367394),
                          Color(0xFF1B8046)
                        ],
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
                            'Enter new PIN',
                            style: TextStyle(
                              fontFamily: "Alegreya_Sans",
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              4,
                              (index) => Container(
                                height: 66,
                                width: 50,
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
                                          _pinControllers[index].text.isEmpty &&
                                          index > 0) {
                                        _pinFocusNodes[index - 1]
                                            .requestFocus();
                                      }
                                    },
                                    child: TextField(
                                      onTap: () {
                                        _pinControllers[index].clear();
                                      },
                                      onTapOutside: (event) {
                                        setState(() {
                                          _pinFocusNodes[index].unfocus();
                                        });
                                      },
                                      controller: _pinControllers[index],
                                      focusNode: _pinFocusNodes[index],
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      maxLength: 1,
                                      obscureText: true,
                                      obscuringCharacter: "●",
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: const InputDecoration(
                                        counterText: "",
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          if (index < 3) {
                                            FocusScope.of(context).requestFocus(
                                              _pinFocusNodes[index + 1],
                                            );
                                          } else {
                                            FocusScope.of(context).unfocus();
                                          }
                                        }
                                      },
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(1),
                                      ],
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
              )
            else
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF367394),
                          Color(0xFF367394),
                          Color(0xFF1B8046)
                        ],
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  textAlign: TextAlign.center,
                                  'Please enter the new pin',
                                  style: TextStyle(
                                    fontFamily: "Alegreya_Sans",
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              4,
                              (index) => Container(
                                height: 66,
                                width: 45,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
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
                                          _codeControllers[index]
                                              .text
                                              .isEmpty &&
                                          index > 0) {
                                        _codeFocusNodes[index - 1]
                                            .requestFocus();
                                      }
                                    },
                                    child: TextField(
                                      controller: _codeControllers[index],
                                      focusNode: _codeFocusNodes[index],
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      obscureText: true,
                                      obscuringCharacter: "●",

                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                      ),

                                      decoration: const InputDecoration(
                                        counterText: "",
                                        border: InputBorder.none,
                                      ),

                                      onTapOutside: (event) {
                                        _codeFocusNodes[index].unfocus();
                                      },

                                      onChanged: (value) {
                                        final prev = _prevValues[index];

                                        // 🔥 PASTE SUPPORT
                                        if (value.length > 1) {
                                          final pasted = value.replaceAll(RegExp(r'[^0-9]'), '').split('');

                                          for (int i = 0; i < _codeControllers.length; i++) {
                                            _codeControllers[i].text =
                                            i < pasted.length ? pasted[i] : '';
                                            _prevValues[i] = _codeControllers[i].text;
                                          }

                                          int lastIndex = pasted.length >= 4 ? 3 : pasted.length;
                                          _codeFocusNodes[lastIndex].requestFocus();
                                          return;
                                        }

                                        // ✅ FORWARD MOVE
                                        if (value.isNotEmpty) {
                                          _prevValues[index] = value;

                                          if (index < 3) {
                                            _codeFocusNodes[index + 1].requestFocus();
                                          } else {
                                            _codeFocusNodes[index].unfocus();
                                          }
                                          return;
                                        }

                                        // 🔥 BACKSPACE FIX (IMPORTANT)
                                        if (value.isEmpty && prev.isNotEmpty) {
                                          _prevValues[index] = '';

                                          if (index > 0) {
                                            _codeFocusNodes[index - 1].requestFocus();

                                            // cursor at end so continuous delete works
                                            Future.microtask(() {
                                              _codeControllers[index - 1].selection =
                                                  TextSelection.collapsed(offset: 1);
                                            });
                                          }
                                        }
                                      },

                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],

                                      autofillHints: const [AutofillHints.oneTimeCode],
                                    )
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
              ),
            if (showSuccess)
              SizedBox()
            else
              Row(mainAxisSize: MainAxisSize.min, children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ScaleButton(
                            onTap: () async {
                              if (allowPin) {
                                // Submit new PIN
                                if (getPinAsInt() != null) {
                                  bool allow = true;
                                  for (var controller in _pinControllers) {
                                    if (controller.text == "") {
                                      SnackbarHelper.showSnackbar(
                                          "Please enter full pin",
                                          color: Colors.red);
                                      allow = false;
                                      break;
                                    }
                                  }

                                  if (allow) {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    try {
                                      var setPinResponse =
                                          await ApiService.setPin(
                                              context,
                                              profileId,
                                              userId,
                                              getPinAsInt()!);

                                      setState(() {
                                        isLoading = false;
                                      });

                                      session.updatePin(getPinAsInt()!);

                                      if (setPinResponse['status'] == 200) {
                                        setState(() {
                                          showSuccess = true;
                                        });

                                        // Automatically navigate back after 2 seconds
                                        Future.delayed(Duration(seconds: 2),
                                            () {
                                          if (mounted) {
                                            Navigator.pop(context);
                                          }
                                        });
                                      } else {
                                        SnackbarHelper.showSnackbar(
                                            "Failed to update PIN: ${setPinResponse['message'] ?? 'Unknown error'}",
                                            color: Colors.red);
                                      }
                                    } catch (e) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      SnackbarHelper.showSnackbar(
                                          "Error updating PIN: $e",
                                          color: Colors.red);
                                    }
                                  }
                                } else {
                                  SnackbarHelper.showSnackbar(
                                      "Please enter pin correctly",
                                      color: Colors.red);
                                }
                              } else {
                                // First step - validate current PIN
                                if (getCodeAsInt() != null) {
                                  bool allow = true;
                                  for (var controller in _codeControllers) {
                                    if (controller.text == "") {
                                      SnackbarHelper.showSnackbar(
                                          "Please enter full pin",
                                          color: Colors.red);
                                      allow = false;
                                      break;
                                    }
                                  }

                                  if (allow) {
                                    // Here you might want to verify the current PIN before allowing change
                                    // For now, just proceed to the next step
                                    setState(() {
                                      allowPin = true;
                                    });
                                  }
                                } else {
                                  SnackbarHelper.showSnackbar(
                                      "Please enter pin correctly",
                                      color: Colors.red);
                                }
                              }
                            },
                            child: Image.asset(EXERCISE_VIEW_SUBMIT_BTN)),
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ScaleButton(
                      // onTap: () {
                      //   Navigator.pop(context);
                      // },
                    ///
                      onTap: () {
                      Provider.of<IndexProvider>(context, listen: false)
                          .setIndex(PatientTab.home.index);
                      },
                      ///
                      child: Image.asset(EXERCISE_VIEW_CANCEL_BTN)),
                ))
              ]),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var focusNode in _pinFocusNodes) {
      focusNode.dispose();
    }
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var focusNode in _codeFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
