import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../components/onboarding_header.dart';
import '../../forgot_pin_logic/enter_email_vm.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  DateTime? lastBackPressTime;
  int step = 1;

  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final pinController = TextEditingController();
  final confirmPinController = TextEditingController();

  bool isValidEmail(String email) {
    return RegExp(r'\S+@\S+\.\S+').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {

        final now = DateTime.now();

        if (lastBackPressTime == null ||
            now.difference(lastBackPressTime!) > const Duration(seconds: 2)) {

          lastBackPressTime = now;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Press back again to return to Login"),
              duration: Duration(seconds: 2),
            ),
          );

          return false;
        }

        Navigator.pop(context); // go to login
        return true;
      },
      child: Scaffold(
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

        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: 35,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Forgot PIN",
                  style: TextStyle(
                    fontFamily: "Alegreya_Sans",
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 45),
                /// CONTAINER
                Center(
                  child: Container(
                    width: 314,
                    padding: const EdgeInsets.all(20),
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
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [



                        const SizedBox(height: 20),

                        /// STEP 1
                        if (step == 1) ...[
                           Text(
                            'Enter your registered email',
                            style: TextStyle(
                              fontFamily: "Alegreya_Sans",
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.height / 47,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Enter Email",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],

                        /// STEP 2
                        if (step == 2) ...[
                          Text(
                            'Enter OTP (sent on email)',
                            style: TextStyle(
                              fontFamily: "Alegreya_Sans",
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.height / 47,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          TextField(
                            controller: otpController,
                            keyboardType: TextInputType.phone,
                            maxLength: 4,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Enter OTP",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],

                        /// STEP 3
                        /// STEP 3
                        if (step == 3) ...[
                          Text(
                            'Set New PIN',
                            style: TextStyle(
                              fontFamily: "Alegreya_Sans",
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.height / 40,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),

                          Consumer<ForgotPinProvider>(
                            builder: (context, provider, child) {

                              /// If only one family member → show name
                              if (provider.familyMembers.length <= 1) {
                                if (provider.familyMembers.isNotEmpty) {
                                  final member = provider.familyMembers.first;

                                  provider.selectedProfileId ??= member["profileId"];
                                  provider.selectedUserType ??= member["role"];

                                  return Text(
                                    member["firstName"],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Alegreya_Sans",
                                    ),
                                  );
                                }

                                return const SizedBox();
                              }

                              /// If multiple members → dropdown
                              return DropdownButtonHideUnderline(
                                child: DropdownButton2<int>(
                                  isExpanded: true,
                                  hint: const Text("Select Member"),
                                  value: provider.selectedProfileId,
                                  items: provider.familyMembers.map((member) {
                                    return DropdownMenuItem<int>(
                                      value: member["profileId"],
                                      child: Text(member["firstName"]),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    final selected = provider.familyMembers
                                        .firstWhere((m) => m["profileId"] == value);

                                    provider.selectedProfileId = selected["profileId"];
                                    provider.selectedUserType = selected["role"];

                                    provider.notifyListeners();
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          TextField(
                            controller: pinController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            obscureText: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Enter PIN",
                              counterText: "",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          TextField(
                            controller: confirmPinController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            obscureText: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Confirm PIN",
                              counterText: "",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 2),

                /// BUTTONS OUTSIDE CONTAINER

                if (step == 1)
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      final provider = context.read<ForgotPinProvider>();

                      if (!isValidEmail(emailController.text)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Enter valid email")),
                        );
                        return;
                      }

                      bool success = await provider.sendOtp(emailController.text);

                      if (success) {

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(provider.message ?? "OTP Sent")),
                        );
                        FocusScope.of(context).unfocus();
                        setState(() {
                          step = 2;
                        });

                      } else {

                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(provider.message ?? "Failed to send OTP"),
                            )
                        );

                      }
                    },
                    child: Image.asset("assets/forgot_pin/send-OTP-img.png"),
                  ),

                if (step == 2)
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      final provider = context.read<ForgotPinProvider>();

                      if (otpController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Enter OTP")),
                        );
                        return;
                      }

                      bool success = await provider.verifyOtp(
                        emailController.text,
                        otpController.text,
                      );

                      if (success) {

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(provider.message ?? "OTP Verified")),
                        );

                        setState(() {
                          step = 3;
                        });

                      } else {

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Invalid OTP")),
                        );

                      }
                    },
                    child: Image.asset("assets/forgot_pin/verify-OTP.png"),
                  ),

                if (step == 3)
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {

                      final provider = context.read<ForgotPinProvider>();

                      /// MEMBER VALIDATION
                      if (provider.selectedProfileId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please select member")),
                        );
                        return;
                      }

                      /// PIN EMPTY
                      if (pinController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter PIN")),
                        );
                        return;
                      }

                      /// PIN LENGTH
                      if (pinController.text.length != 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("PIN must be 4 digits")),
                        );
                        return;
                      }

                      /// CONFIRM PIN EMPTY
                      if (confirmPinController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please confirm PIN")),
                        );
                        return;
                      }

                      /// PIN MATCH
                      if (pinController.text != confirmPinController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("PIN and Confirm PIN must match")),
                        );
                        return;
                      }

                      bool success = await provider.resetPin(
                        int.parse(pinController.text),
                      );

                      if (success) {

                        showCupertinoDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              title: const Text("Success"),
                              content: const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text("PIN reset successfully."),
                              ),
                              actions: [
                                CupertinoDialogAction(
                                  isDefaultAction: true,
                                  onPressed: () {
                                    Navigator.pop(context); // close dialog
                                    Navigator.pop(context); // go back to login
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );

                        // Navigator.pop(context);

                      }  else {
                        ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                          content: Text(provider.message ?? "Failed to reset PIN"),
                          ),
                        );
                      }
                    },




                    child: Image.asset("assets/forgot_pin/reset-pin.png"),
                  ),
                SizedBox(height: 30),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Click here to login',
                    style: TextStyle(
                      fontFamily: "Alegreya_Sans",
                      fontSize: MediaQuery.of(context).size.height / 45,
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
      ),
    );
  }
}