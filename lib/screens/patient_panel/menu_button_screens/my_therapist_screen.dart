import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myocircle15screens/components/profile_header.dart';
import 'package:myocircle15screens/providers/session_provider.dart';

import '../../../components/components_path.dart';
import 'package:provider/provider.dart';

class MyTherapistScreen extends StatefulWidget {
  const MyTherapistScreen({super.key});

  @override
  State<MyTherapistScreen> createState() => _MyTherapistScreenState();
}

class _MyTherapistScreenState extends State<MyTherapistScreen> {
  ScrollController _scrollController = ScrollController();
  bool showFull = false;
  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionProvider>(context, listen: false);
    final userData = session.userData;
    debugPrint("Therapist Info: ${userData?['therapistInfo']}");
    final mobileNo = userData?["therapistInfo"]["phoneNumber"];
    final therapistName = userData?['therapistInfo']['firstName'] +
        ' ' +
        userData?['therapistInfo']['lastName'];
    final therapistEmail = userData?['therapistInfo']['email'];
    final profileImg = userData?["therapistInfo"]["therapistProfileImage"];
    dynamic therapistAddress = userData?['therapistInfo']['address'];
    if (therapistAddress == null) therapistAddress = "Not Available";
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
        child: !showFull
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: Card(
                    elevation: 5,
                    surfaceTintColor: Color(0xffDBDCD9),
                    color: Color(0xffDBDCD9),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            // child: Container(
                            //   height: 150,
                            //   width: 150,
                            //   decoration: BoxDecoration(
                            //       shape: BoxShape.circle,
                            //       boxShadow: [
                            //         BoxShadow(
                            //           color: Colors.black54,
                            //           blurRadius: 10,
                            //           spreadRadius: 0,
                            //           offset: Offset(6, 6),
                            //         )
                            //       ]),
                            //   child: Padding(
                            //     padding: const EdgeInsets.all(4),
                            //     child: Container(
                            //         decoration: BoxDecoration(
                            //             image: DecorationImage(
                            //                 image: AssetImage(
                            //                   AVATAR_RING,
                            //                 ),
                            //                 fit: BoxFit.fill)),
                            //         child: Padding(
                            //           padding: const EdgeInsets.all(8.0),
                            //           // child: Image.asset(
                            //           //   DOCTOR_TEST,
                            //           //   fit: BoxFit.contain,
                            //           // ),
                            //           child: profileImg != null && profileImg.toString().isNotEmpty
                            //               ? Image.memory(
                            //             base64Decode(profileImg),
                            //             fit: BoxFit.contain,
                            //           )
                            //               : Image.asset(
                            //             DOCTOR_TEST,
                            //             fit: BoxFit.contain,
                            //           ),
                            //         )),
                            //   ),
                            // ),
                            child: Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black54,
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                    offset: Offset(6, 6),
                                  )
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(AVATAR_RING),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipOval(
                                      child: profileImg != null && profileImg.toString().isNotEmpty
                                          ? Image.memory(
                                        base64Decode(profileImg),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      )
                                          : Icon(Icons.person,color: Colors.white,size: 70)
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Text(
                                "$therapistName",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: "Alegreya_Sans", fontSize: 28),
                              ))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Text(
                                "MyoFunctional Therapist",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: "Alegreya_Sans", fontSize: 22),
                              ))
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Email: $therapistEmail",
                            style: TextStyle(
                                fontFamily: "Alegreya_Sans", fontSize: 20),
                          ),
                               Text(
                                    "Phone No.: ${userData?["therapistInfo"]["phoneNumber"]}",
                                style: TextStyle(
                                    fontFamily: "Alegreya_Sans", fontSize: 20),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : ScrollbarTheme(
                data: ScrollbarThemeData(
                    thumbColor: WidgetStatePropertyAll(Colors.black),
                    thickness: WidgetStatePropertyAll(7)),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Card(
                            elevation: 5,
                            surfaceTintColor: Color(0xffDBDCD9),
                            color: Color(0xffDBDCD9),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height: 150,
                                      width: 150,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black54,
                                              blurRadius: 10,
                                              spreadRadius: 0,
                                              offset: Offset(6, 6),
                                            )
                                          ]),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Container(
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                      AVATAR_RING,
                                                    ),
                                                    fit: BoxFit.fill)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Image.asset(
                                                DOCTOR_TEST,
                                                fit: BoxFit.contain,
                                              ),
                                            )),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                          child: Text(
                                        "Stacey Jones",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: "Alegreya_Sans",
                                            fontSize: 28),
                                      ))
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                          child: Text(
                                        "MyoFunctional Therapist",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: "Alegreya_Sans",
                                            fontSize: 22),
                                      ))
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                          child: Text(
                                        "Irvine Dental Associates",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: "Alegreya_Sans",
                                            fontSize: 20),
                                      ))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        "Experience: 7+ yrs",
                                        style: TextStyle(
                                            fontFamily: "Alegreya_Sans",
                                            fontSize: 20),
                                      ))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        "Qualification: BDS, MDS, CRP",
                                        style: TextStyle(
                                            fontFamily: "Alegreya_Sans",
                                            fontSize: 20),
                                      ))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        "Address: 123 Easy Street, Wilshire Blvd, Los Angeles, CA 940321",
                                        style: TextStyle(
                                            fontFamily: "Alegreya_Sans",
                                            fontSize: 20),
                                      ))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        "Tel: 661.556.3241",
                                        style: TextStyle(
                                            fontFamily: "Alegreya_Sans",
                                            fontSize: 20),
                                      ))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        "Email: stacey@ida.com",
                                        style: TextStyle(
                                            fontFamily: "Alegreya_Sans",
                                            fontSize: 20),
                                      ))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  """I am a board certified dentist licensed to practice in California & Nevada with 7 years of experience in pediatric myofunctional therapy. I also work with adult patients and families.\nAs a Myofunctional Therapist, I specialize in improving oral and facial muscle function to support better breathing, swallowing, and overall wellness. I help clients achieve lasting benefits in sleep, speech, and jaw function.
                        """,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "Jost",
                                      fontWeight: FontWeight.w300),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
