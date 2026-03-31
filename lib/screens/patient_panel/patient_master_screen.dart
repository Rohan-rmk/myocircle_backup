import 'package:flutter/material.dart';
import 'package:myocircle15screens/components/custom_switch.dart';
import 'package:myocircle15screens/providers/index_provider.dart';
import 'package:myocircle15screens/screens/patient_panel/menu_button_screens/change_avatar_screen.dart';
import 'package:myocircle15screens/screens/patient_panel/menu_button_screens/my_therapist_screen.dart';
import 'package:myocircle15screens/screens/patient_panel/menu_button_screens/reset_pin_screen.dart';
import 'package:myocircle15screens/screens/patient_panel/patient_exercises_screen.dart';
import 'package:myocircle15screens/screens/patient_panel/patient_home_screen.dart';
import 'package:myocircle15screens/screens/patient_panel/patient_messages_screen.dart';
import 'package:myocircle15screens/screens/patient_panel/patient_dashboard_screen.dart';
import 'package:myocircle15screens/screens/patient_panel/patient_report_screen.dart';
import 'package:myocircle15screens/screens/patient_panel/patient_score_screen.dart';
import 'package:myocircle15screens/screens/patient_panel/select_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../components/app_bar_row.dart';
import '../../components/components_path.dart';
import '../../components/patients_nav_bar.dart';
import '../../providers/session_provider.dart';
import '../../enums/patient_tab.dart';
import '../../utils/tab_visibility_util.dart';
import '../../services/api_service.dart';

class PatientMasterScreen extends StatefulWidget {
  const PatientMasterScreen({super.key});

  @override
  State<PatientMasterScreen> createState() => _PatientMasterScreenState();
}

class _PatientMasterScreenState extends State<PatientMasterScreen> {
  List<Map<String, dynamic>> listItems = [
    {"name": "Reset Pin", "icon": MENU_KEY_ICON},
    {"name": "Change Avatar", "icon": MENU_AVATAR_ICON},
    {
      "name": "My Reports",
      "icon": MENU_REPORTS_ICON,
    },
    {
      "name": "My Therapist",
      "icon": MENU_THERAPIST_ICON,
    },
    {
      "name": "Selfie Mode",
    },
    {
      "name": "Logout",
      "icon": MENU_LOGOUT_ICON,
    },
  ];
  bool isSelfie = false;
  // void showProfile(){
  //   final landingPageData = Provider.of<sessionProvider>(context,listen: false).landingPageData;
  //   showDialog(barrierColor: Colors.transparent,context: context, builder: (context){
  //     return Column(mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(65),bottomLeft: Radius.circular(65))),
  //           child: Column(mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Container(height: 100,width: 100,decoration: BoxDecoration(shape: BoxShape.circle,boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black54,blurRadius:7,spreadRadius: 1,offset: Offset(-2,4),
  //                   )
  //                 ]),
  //                   child: Stack(alignment: Alignment.center,
  //                     children: [
  //                       Padding(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Container(decoration: BoxDecoration(image: DecorationImage(image: AssetImage(AVATAR_CONTAINER_INNER))),child: Skeletonizer(enabled:landingPageData==null,
  //                           child: ClipRRect(borderRadius: BorderRadius.circular(50),child:landingPageData==null || landingPageData['patientAvatarURL']==null?AspectRatio(aspectRatio: 2/2,child: displayBase64Image(defaultBase64)):Base64ImageWidget(base64String: landingPageData['patientAvatarURL'])
  //                           ),
  //                         )),
  //                       ),
  //                       Image.asset(AVATAR_CONTAINER_OUTER),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //               Text(
  //                 "${landingPageData?['profileName']}",
  //                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400,fontFamily: "Alegreya_Sans",color: Color(0xff8E8E93)),
  //               ),
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     child: TextButton(onPressed: (){
  //
  //                     },
  //                       child: Column(
  //                         children: [
  //                           Image.asset(listItems[0]['icon']),
  //                           Text(
  //                             listItems[0]['name'],
  //                             style: TextStyle(fontSize: 20, fontFamily: "Alegreya_Sans",fontWeight: FontWeight.w400,color:  Color(0xff8E8E93)),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: TextButton(onPressed: (){
  //
  //                     },
  //                       child: Column(
  //                         children: [
  //                           Text(
  //                             listItems[0]['name'],
  //                             style: TextStyle(fontSize: 20, fontFamily: "Alegreya_Sans",fontWeight: FontWeight.w400,color:  Color(0xff8E8E93)),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: TextButton(onPressed: (){
  //
  //                     },
  //                       child: Column(
  //                         children: [
  //                           Text(
  //                             listItems[0]['name'],
  //                             style: TextStyle(fontSize: 20, fontFamily: "Alegreya_Sans",fontWeight: FontWeight.w400,color:  Color(0xff8E8E93)),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     child: TextButton(onPressed: (){
  //
  //                     },
  //                       child: Column(
  //                         children: [
  //                           Text(
  //                             listItems[0]['name'],
  //                             style: TextStyle(fontSize: 20, fontFamily: "Alegreya_Sans",fontWeight: FontWeight.w400,color:  Color(0xff8E8E93)),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: TextButton(onPressed: (){
  //
  //                     },
  //                       child: Column(
  //                         children: [
  //                           Text(
  //                             listItems[0]['name'],
  //                             style: TextStyle(fontSize: 20, fontFamily: "Alegreya_Sans",fontWeight: FontWeight.w400,color:  Color(0xff8E8E93)),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: TextButton(onPressed: (){
  //
  //                     },
  //                       child: Column(
  //                         children: [
  //                           Text(
  //                             listItems[0]['name'],
  //                             style: TextStyle(fontSize: 20, fontFamily: "Alegreya_Sans",fontWeight: FontWeight.w400,color:  Color(0xff8E8E93)),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     child: SizedBox()
  //                   ),
  //                   Expanded(
  //                     child: TextButton(onPressed: (){
  //
  //                     },
  //                       child: Column(
  //                         children: [
  //                           Text(
  //                             listItems[0]['name'],
  //                             style: TextStyle(fontSize: 20, fontFamily: "Alegreya_Sans",fontWeight: FontWeight.w400,color:  Color(0xff8E8E93)),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: SizedBox()
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     );
  //   });
  // }
  bool showProfile = false;
  bool showResetPin = false;
  int selectedMenuIndex = -1;

  Future<void> performLogout() async {
    final session = Provider.of<SessionProvider>(context, listen: false);
    final userData = session.userData;
    final _userToken = userData?['user_token'];
    final _userId = userData?['userId'];
    final _profileId = userData?['profileId'];
    final _sessionId = userData?['sessionId'];

    final response = await ApiService.logout(
      context,
      _userToken,
      _profileId,
      _sessionId,
      _userId,
    );

    if (response["status"] == 200) {
      print("Logout successful");
    }
    setState(() {
      Provider.of<SessionProvider>(context, listen: false).resetAll();
      Provider.of<IndexProvider>(context, listen: false).setIndex(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context);
    final data = sessionProvider.userData;

    // 🔐 HARD STOP — logout already happened
    if (data == null) {
      return const SizedBox(); // or Loader
    }

    final landingPageData = sessionProvider.landingPageData;

    final int age =
        int.tryParse(data['age']?.toString() ?? '0') ?? 20;

    final String patientStatus =
        data['patientStatus']?.toString() ?? 'active';

    final int selectedIndex =
        Provider.of<IndexProvider>(context).selectedIndex;

    final PatientTab currentTab =
    PatientTab.values[selectedIndex];

    final List<PatientTab> visibleTabs = TabVisibilityUtil.getTabs(
      patientStatus: patientStatus,
      age: age,
      screenName:
      TabVisibilityUtil.getScreenNameFromTab(currentTab),
    );


    return Container(
      decoration: BoxDecoration(
        image: selectedIndex == 0
            ? null
            : DecorationImage(
                image: AssetImage(BACKGROUND_LATTE), fit: BoxFit.cover),
        gradient: selectedIndex != 0
            ? null
            : LinearGradient(colors: [
                Color(0xffFFFFFF),
                Color(0xffE6E6E6),
                Color(0xffD2D4D7),
                Color(0xffCECAC7),
              ]),
      ),
      child: PopScope(
        canPop: showProfile == false,
        onPopInvokedWithResult: (bool, dynamic) {
          if (selectedMenuIndex != -1) {
            setState(() {
              selectedMenuIndex = -1;
            });
          } else {
            setState(() {
              showProfile = false;
            });
          }
        },
        child: SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Color(0xffF6F5F3),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: CustomAppBarRow(
                      menuButton: () {
                        setState(() {
                          showProfile = !showProfile;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: Builder(
                      builder: (context) {
                        switch (selectedMenuIndex) {
                          case 0:
                            return ResetPinScreen();
                          case 3:
                            return MyTherapistScreen();
                          default:
                            return Stack(
                              children: [
                                Builder(
                                  builder: (context) {
                                    switch (currentTab) {
                                      case PatientTab.home:
                                        return PatientHomeScreen();
                                      case PatientTab.leaderboard:
                                        return PatientScoreScreen();
                                      case PatientTab.dashboard:
                                        return PatientDashboardScreen();
                                      case PatientTab.messages:
                                        return Center(
                                            child: PatientMessagesScreen());
                                      case PatientTab.exercise:
                                        return PatientExercisesScreen();
                                      case PatientTab.report:
                                        return PatientReportScreen();

///
                                      case PatientTab.resetPin:
                                        return ResetPinScreen();

                                      case PatientTab.changeAvatar:
                                        return ChangeAvatarScreen();

                                      case PatientTab.therapist:
                                        return MyTherapistScreen();
                                        ///
                                    }
                                  },
                                ),
                                ///
                                if (showProfile)
                                  Positioned.fill(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          showProfile = false; // ✅ close on outside tap
                                        });
                                      },
                                      child: Container(
                                        color: Colors.black.withOpacity(0.3), // optional dim background
                                        child: SafeArea(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GestureDetector(
                                                onTap: () {}, // ❗ prevent closing when clicking inside
                                                child: Card(
                                                  color: Colors.white,
                                                  surfaceTintColor: Colors.white,
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.only(
                                                      bottomRight: Radius.circular(50),
                                                      bottomLeft: Radius.circular(50),
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      /// ❌ CLOSE BUTTON
                                                      Positioned(
                                                        right: 10,
                                                        top: 10,
                                                        child: ScaleButton(
                                                          onTap: () {
                                                            setState(() {
                                                              showProfile = false;
                                                            });
                                                          },
                                                          child: Image.asset(EXERCISE_VIEW_CLOSE_BTN),
                                                        ),
                                                      ),

                                                      /// ✅ CONTENT
                                                      Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          /// PROFILE IMAGE
                                                          Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Container(
                                                              height: 100,
                                                              width: 100,
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors.black54,
                                                                    blurRadius: 7,
                                                                    spreadRadius: 1,
                                                                    offset: Offset(-2, 4),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: Stack(
                                                                alignment: Alignment.center,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Container(
                                                                      decoration: BoxDecoration(
                                                                        image: DecorationImage(
                                                                          image: AssetImage(
                                                                              AVATAR_CONTAINER_INNER),
                                                                        ),
                                                                      ),
                                                                      child: Skeletonizer(
                                                                        enabled:
                                                                        landingPageData == null,
                                                                        child: ClipRRect(
                                                                          borderRadius:
                                                                          BorderRadius.circular(50),
                                                                          child: landingPageData == null ||
                                                                              landingPageData[
                                                                              'patientAvatarURL'] ==
                                                                                  null
                                                                              ? AspectRatio(
                                                                            aspectRatio: 2 / 2,
                                                                            child:
                                                                            displayBase64Image(
                                                                                defaultBase64),
                                                                          )
                                                                              : Base64ImageWidget(
                                                                            key: UniqueKey(),
                                                                            base64String:
                                                                            landingPageData[
                                                                            'patientAvatarURL'],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Image.asset(AVATAR_CONTAINER_OUTER),
                                                                ],
                                                              ),
                                                            ),
                                                          ),

                                                          /// NAME
                                                          Text(
                                                            "${landingPageData?['profileName']}",
                                                            style: const TextStyle(
                                                              fontSize: 22,
                                                              fontWeight: FontWeight.w400,
                                                              fontFamily: "Alegreya_Sans",
                                                              color: Color(0xff8E8E93),
                                                            ),
                                                          ),

                                                          /// ROW 1
                                                          Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              _menuItem(
                                                                icon: listItems[0]['icon'],
                                                                title: listItems[0]['name'],
                                                                onTap: () {
                                                                  setState(() {
                                                                    showProfile = false;
                                                                  });
                                                                  // Navigator.push(
                                                                  //   context,
                                                                  //   MaterialPageRoute(
                                                                  //     builder: (_) => ResetPinScreen(),
                                                                  //   ),
                                                                  // );
                                                                  ///
                                                                  Provider.of<IndexProvider>(context, listen: false)
                                                                      .setIndex(PatientTab.resetPin.index);
                                                                  ///
                                                                },
                                                              ),
                                                              _menuItem(
                                                                icon: listItems[1]['icon'],
                                                                title: listItems[1]['name'],
                                                                onTap: () {
                                                                  setState(() {
                                                                    showProfile = false;
                                                                  });
                                                                  // Navigator.push(
                                                                  //   context,
                                                                  //   MaterialPageRoute(
                                                                  //     builder: (_) =>
                                                                  //         ChangeAvatarScreen(),
                                                                  //   ),
                                                                  // );
                                                                  ///
                                                                  Provider.of<IndexProvider>(context, listen: false)
                                                                      .setIndex(PatientTab.changeAvatar.index);
                                                                  ///
                                                                },
                                                              ),
                                                              _menuItem(
                                                                icon: listItems[2]['icon'],
                                                                title: listItems[2]['name'],
                                                                onTap: () {
                                                                  setState(() {
                                                                    showProfile = false;
                                                                  });
                                                                  Provider.of<IndexProvider>(context,
                                                                      listen: false)
                                                                      .setIndex(5);
                                                                },
                                                              ),
                                                            ],
                                                          ),

                                                          /// ROW 2
                                                          Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              _menuItem(
                                                                icon: listItems[3]['icon'],
                                                                title: listItems[3]['name'],
                                                                // onTap: () {
                                                                //   setState(() {
                                                                //     showProfile = false;
                                                                //   });
                                                                //   Navigator.push(
                                                                //     context,
                                                                //     MaterialPageRoute(
                                                                //       builder: (_) =>
                                                                //           MyTherapistScreen(),
                                                                //     ),
                                                                //   );
                                                                // },
                                                                ///
                                                                  onTap: () {
                                                                    setState(() {
                                                                      showProfile = false;
                                                                    });

                                                                    Provider.of<IndexProvider>(context, listen: false)
                                                                        .setIndex(PatientTab.therapist.index);
                                                                  }
                                                                ///
                                                              ),

                                                              /// SELFIE SWITCH
                                                              Expanded(
                                                                child: Column(
                                                                  children: [
                                                                    SizedBox(
                                                                      height: 70,
                                                                      width: 70,
                                                                      child: CustomSwitch(
                                                                        value: isSelfie,
                                                                        onChanged: (value) {
                                                                          setState(() {
                                                                            isSelfie = value;
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      listItems[4]['name'],
                                                                      style: const TextStyle(
                                                                        fontSize: 16,
                                                                        fontFamily: "Alegreya_Sans",
                                                                        color: Color(0xff8E8E93),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),

                                                              _menuItem(
                                                                icon: listItems[5]['icon'],
                                                                title: listItems[5]['name'],
                                                                onTap: performLogout,
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ///
                              ],
                            );
                        }
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: PatientsCustomNavBar(
                      visibleTabs: visibleTabs,
                      currentTab: currentTab,
                      onTabSelected: (PatientTab tab) {
                        setState(() {
                          final index = PatientTab.values.indexOf(tab);
                          Provider.of<IndexProvider>(context, listen: false)
                              .setIndex(index);
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
Widget _menuItem({
  required String icon,
  required String title,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: TextButton(
      onPressed: onTap,
      child: Column(
        children: [
          SizedBox(height: 70, width: 70, child: Image.asset(icon)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: "Alegreya_Sans",
              color: Color(0xff8E8E93),
            ),
          ),
        ],
      ),
    ),
  );
}
