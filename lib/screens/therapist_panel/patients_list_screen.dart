import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scale_button/scale_button.dart';
import '../../components/components_path.dart';
import '../../components/custom_circular_progress_indicator.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  ScrollController patientsListScrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.transparent,
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
                        flex: 7,
                        child: Text(
                          "PATIENT LIST",
                          style: TextStyle(
                              fontFamily: "Alegreya_Sans",
                              fontSize: screenWidth / 18),
                        )),
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: ScaleButton(
                              child: Image.asset(
                                USER_ICON,
                                fit: BoxFit.cover,
                              ),
                              onTap: () {},
                            ),
                          ),
                          Expanded(flex: 1, child: SizedBox()),
                          Expanded(
                            flex: 2,
                            child: ScaleButton(
                              child: Image.asset(
                                MAGNIFIER_ICON,
                                fit: BoxFit.cover,
                              ),
                              onTap: () {},
                            ),
                          ),
                          Expanded(flex: 1, child: SizedBox()),
                          Expanded(
                            flex: 2,
                            child: ScaleButton(
                              child: Image.asset(
                                ARCHIVE_ICON,
                                fit: BoxFit.cover,
                              ),
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Padding(
              padding: EdgeInsets.only(top: screenWidth / 42),
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                    thumbColor: WidgetStatePropertyAll(Colors.black),
                    crossAxisMargin: screenWidth / 212),
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: patientsListScrollController,
                  thickness: screenWidth / 52,
                  radius: Radius.circular(0),
                  child: ListView.builder(
                      itemCount: 10,
                      controller: patientsListScrollController,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: screenWidth / 42,
                            left: screenWidth / 85,
                            right: screenWidth / 27,
                          ),
                          child: Container(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    top: 0,
                                    child: SvgPicture.asset(
                                      PATIENTS_LIST_CONTAINER,
                                      fit: BoxFit.fill,
                                    )),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: screenWidth / 23.5,
                                      right: screenWidth / 28,
                                      top: screenWidth / 53,
                                      bottom: screenWidth / 26.5),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            LayoutBuilder(builder:
                                                (context, constraints) {
                                              double size =
                                                  constraints.maxWidth;
                                              return Text(
                                                "salman khan",
                                                style: TextStyle(
                                                    color: Color(0xff3E52A8),
                                                    fontFamily:
                                                        "Alegreya_Sans_SC",
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: size / 15.5),
                                              );
                                            }),
                                            LayoutBuilder(builder:
                                                (context, constraints) {
                                              double size =
                                                  constraints.maxWidth;
                                              return Text(
                                                "14/F",
                                                style: TextStyle(
                                                    color: Color(0xff46555E),
                                                    fontFamily: "Alegreya_Sans",
                                                    fontSize: size / 18),
                                              );
                                            }),
                                            LayoutBuilder(builder:
                                                (context, constraints) {
                                              double size =
                                                  constraints.maxWidth;
                                              return Text(
                                                "Dx: Cleft Palate",
                                                style: TextStyle(
                                                    color: Color(0xff46555E),
                                                    fontFamily: "Alegreya_Sans",
                                                    fontSize: size / 18),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          ScaleButton(
                                            child: Image.asset(
                                              MESSAGE_ICON,
                                              fit: BoxFit.cover,
                                              height: screenWidth / 11,
                                            ),
                                            onTap: () {},
                                          ),
                                          SizedBox(
                                            width: screenWidth / 32,
                                          ),
                                          SizedBox(
                                              height: screenWidth / 8,
                                              width: screenWidth / 8,
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  GradientCircularProgressIndicator(
                                                    value: 0.60,
                                                    parentSize: screenWidth,
                                                    colors: [
                                                      Color(0xffA0F5F2),
                                                      Color(0xff2EB4B6),
                                                      Color(0xff41A2A1),
                                                    ],
                                                  ),
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
                                                          fontSize: size / 3),
                                                    );
                                                  }),
                                                ],
                                              )),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
