import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scale_button/scale_button.dart';
import '../../components/components_path.dart';
import '../../components/custom_circular_progress_indicator.dart';
import '../../components/custom_textfield.dart';

class PatientSummaryScreen extends StatefulWidget {
  const PatientSummaryScreen({super.key});

  @override
  State<PatientSummaryScreen> createState() => _PatientSummaryScreenState();
}

class _PatientSummaryScreenState extends State<PatientSummaryScreen> {
  ScrollController patientsListScrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                Color(0xFFFFFFFF),
                Color(0xFF999999),
              ])),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 12,
                        child: Text(
                          "SUMMARY",
                          style: TextStyle(
                              fontFamily: "Alegreya_Sans",
                              fontSize: screenWidth / 18),
                        )),
                    Expanded(
                      flex: 1,
                      child: ScaleButton(
                        child: Image.asset(
                          USER_ICON,
                          fit: BoxFit.cover,
                        ),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Padding(
              padding: EdgeInsets.only(
                  left: screenWidth / 52, right: screenWidth / 60),
              child: Card(
                elevation: screenWidth / 105,
                color: Color(0xffEEF2F0),
                child: Column(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 1,
                            child:
                                LayoutBuilder(builder: (context, constraints) {
                              return Text(
                                "salman khan",
                                style: TextStyle(
                                    color: Color(0xff3E52A8),
                                    fontFamily: "Alegreya_Sans_SC",
                                    fontWeight: FontWeight.w700,
                                    fontSize: constraints.maxWidth / 12),
                              );
                            }),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: AspectRatio(
                                          aspectRatio: 1 / 1,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        SUMMARY_CONTAINERS),
                                                    fit: BoxFit.contain)),
                                            padding:
                                                EdgeInsets.only(bottom: 10),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                LayoutBuilder(builder:
                                                    (context, constraints) {
                                                  double size =
                                                      constraints.maxWidth;
                                                  return SizedBox(
                                                      height: size / 1.5,
                                                      width: size / 1.5,
                                                      child:
                                                          GradientCircularProgressIndicator(
                                                        value: 0.60,
                                                        parentSize: screenWidth,
                                                        colors: [
                                                          Color(0xffA0F5F2),
                                                          Color(0xff2EB4B6),
                                                          Color(0xff41A2A1),
                                                        ],
                                                      ));
                                                }),
                                                LayoutBuilder(builder:
                                                    (context, constraints) {
                                                  double size =
                                                      constraints.maxWidth;
                                                  return Text(
                                                    "45%",
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff46555E),
                                                        fontFamily:
                                                            "Alegreya_Sans",
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: size / 4),
                                                  );
                                                }),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: Text(
                                            "Progress",
                                            style: TextStyle(
                                              fontFamily: "Alegreya_Sans",
                                              color: Colors.black,
                                              fontSize: screenWidth / 22,
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: AspectRatio(
                                          aspectRatio: 1 / 1,
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        SUMMARY_CONTAINERS),
                                                    fit: BoxFit.fill)),
                                            padding:
                                                EdgeInsets.only(bottom: 10),
                                            child: LayoutBuilder(builder:
                                                (context, constraints) {
                                              double size =
                                                  constraints.maxWidth;
                                              return Text(
                                                "280",
                                                style: TextStyle(
                                                    color: Color(0xff46555E),
                                                    fontFamily: "Alegreya_Sans",
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: size / 3),
                                              );
                                            }),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: Text(
                                            "Score",
                                            style: TextStyle(
                                              fontFamily: "Alegreya_Sans",
                                              color: Colors.black,
                                              fontSize: screenWidth / 22,
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: AspectRatio(
                                          aspectRatio: 1 / 1,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        SUMMARY_CONTAINERS),
                                                    fit: BoxFit.fill)),
                                            padding:
                                                EdgeInsets.only(bottom: 10),
                                            child: SizedBox(
                                                child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                LayoutBuilder(builder:
                                                    (context, constraints) {
                                                  double size =
                                                      constraints.maxWidth;
                                                  return Text(
                                                    "2",
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xffE42121),
                                                        fontFamily:
                                                            "Alegreya_Sans",
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: size / 3.5),
                                                  );
                                                }),
                                              ],
                                            )),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: Text(
                                            "Message",
                                            style: TextStyle(
                                              fontFamily: "Alegreya_Sans",
                                              color: Colors.black,
                                              fontSize: screenWidth / 22,
                                            ),
                                          )),
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
                      flex: 14,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 2,
                                        child: CustomTextField(
                                          textAlign: TextAlign.start,
                                          label: "AGE",
                                          readOnly: true,
                                          textFieldController:
                                              TextEditingController(text: "28"),
                                          size: screenHeight,
                                          maxLines: 1,
                                        )),
                                    SizedBox(
                                      width: screenWidth / 40,
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child: CustomTextField(
                                          textAlign: TextAlign.center,
                                          label: "GENDER",
                                          readOnly: true,
                                          textFieldController:
                                              TextEditingController(text: "F"),
                                          size: screenHeight,
                                          maxLines: 1,
                                        )),
                                    SizedBox(
                                      width: screenWidth / 40,
                                    ),
                                    Expanded(
                                        flex: 5,
                                        child: CustomTextField(
                                          textAlign: TextAlign.start,
                                          label: "DOB",
                                          readOnly: true,
                                          textFieldController:
                                              TextEditingController(
                                                  text: "1990-12-25"),
                                          size: screenHeight,
                                          maxLines: 1,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 6,
                                        child: CustomTextField(
                                          textAlign: TextAlign.start,
                                          label: "EMAIL",
                                          readOnly: true,
                                          textFieldController:
                                              TextEditingController(
                                                  text: "test@test.com"),
                                          size: screenHeight,
                                          maxLines: 1,
                                        )),
                                    SizedBox(
                                      width: screenWidth / 40,
                                    ),
                                    Expanded(
                                        flex: 4,
                                        child: CustomTextField(
                                          textAlign: TextAlign.start,
                                          label: "PHONE",
                                          readOnly: true,
                                          textFieldController:
                                              TextEditingController(
                                                  text: "111-222-2222"),
                                          size: screenHeight,
                                          maxLines: 1,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 4,
                                        child: Builder(builder: (context) {
                                          return CustomTextField(
                                            textAlign: TextAlign.start,
                                            label: "REGISTERED",
                                            readOnly: true,
                                            textFieldController:
                                                TextEditingController(
                                                    text: "2025-03-03"),
                                            size: screenHeight,
                                            maxLines: 1,
                                          );
                                        })),
                                    SizedBox(
                                      width: screenWidth / 40,
                                    ),
                                    Expanded(
                                        flex: 6,
                                        child: CustomTextField(
                                          textAlign: TextAlign.start,
                                          label: "REFERED BY",
                                          readOnly: true,
                                          textFieldController:
                                              TextEditingController(
                                                  text: "Dr. AK"),
                                          size: screenHeight,
                                          maxLines: 1,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: CustomTextField(
                                      textAlign: TextAlign.start,
                                      label: "DIAGNOSIS",
                                      readOnly: true,
                                      textFieldController:
                                          TextEditingController(
                                              text: "Snoring"),
                                      size: screenHeight,
                                      maxLines: 1,
                                    )),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 5,
                                        child: CustomTextField(
                                          textAlign: TextAlign.start,
                                          label: "PRESCRIPTION FILLED",
                                          readOnly: true,
                                          textFieldController:
                                              TextEditingController(
                                                  text: "2025-03-09"),
                                          size: screenHeight,
                                          maxLines: 1,
                                        )),
                                    SizedBox(
                                      width: screenWidth / 40,
                                    ),
                                    Expanded(
                                        flex: 5,
                                        child: CustomTextField(
                                          textAlign: TextAlign.start,
                                          label: "NEXT PRESCRIPTION",
                                          readOnly: true,
                                          textFieldController:
                                              TextEditingController(
                                                  text: "2025-03-09"),
                                          size: screenHeight,
                                          maxLines: 1,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 5,
                                        child: CustomTextField(
                                          textAlign: TextAlign.start,
                                          label: "TREATMENT DURATION",
                                          readOnly: true,
                                          textFieldController:
                                              TextEditingController(
                                                  text: "2 months"),
                                          size: screenHeight,
                                          maxLines: 1,
                                        )),
                                    SizedBox(
                                      width: screenWidth / 40,
                                    ),
                                    Spacer(
                                      flex: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 8,
                                        child: CustomTextField(
                                          textAlign: TextAlign.start,
                                          label: "SPECIALIST",
                                          readOnly: true,
                                          textFieldController:
                                              TextEditingController(
                                                  text: "Dr. Tulsi"),
                                          size: screenHeight,
                                          maxLines: 1,
                                        )),
                                    SizedBox(
                                      width: screenWidth / 40,
                                    ),
                                    Spacer(
                                      flex: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: ScaleButton(
                                  child: Image.asset(
                                SEND_MESSAGE_BTN,
                                fit: BoxFit.cover,
                              ))),
                          Expanded(
                              flex: 2,
                              child: ScaleButton(
                                  child: Image.asset(
                                EDIT_PATIENT_BTN,
                                fit: BoxFit.cover,
                              ))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
