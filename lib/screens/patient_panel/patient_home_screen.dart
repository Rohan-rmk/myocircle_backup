import 'package:flutter/material.dart';
import 'package:myocircle15screens/components/custom_circular_progress_indicator.dart';
import 'package:myocircle15screens/components/golden_shadow.dart';
import 'package:myocircle15screens/screens/patient_panel/patient_avatar_preview_screen.dart';
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:myocircle15screens/services/api_service.dart';
import '../../components/custom_dropdown.dart';
import '../../components/components_path.dart';
import '../../components/shimmer_effect.dart';
import '../../components/gem.dart';
import '../../providers/index_provider.dart';
import '../../providers/session_provider.dart';
import '../../services/media_kit_stream_service.dart';
import 'select_profile_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({
    super.key,
  });

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int? selectedProfileId;
  dynamic userData;
  dynamic landingPageData;
  List<dynamic> familyMembers = [];
  bool isAdult = false;

  bool get isReadOnly {
    final profileId = userData['profileId'];
    return selectedProfileId != profileId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          _didLoad = true;
          landingPage();
        }
      });
    }
  }
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final session = context.read<SessionProvider>();

      // Safe reads
      landingPageData = session.landingPageData;
      familyMembers = session.userData?['familyMembers'] ?? [];

      final profileId = session.userData?['profileId'];
      final isPatient = session.userData?['isPatient'].toString() == "Yes";

      // ✅ SAFE provider mutations
      session.setNotPatient(isPatient);

      if (familyMembers.isEmpty && profileId != null) {
        session.setSelectedProfileId(profileId);
      }

      landingPage(); // API call
    });
  }
  // @override
  // void initState() {
  //   super.initState();
  //   landingPage();
  //   final session = Provider.of<SessionProvider>(context, listen: false);
  //   setState(() {
  //     landingPageData = session.landingPageData;
  //   });
  //   print("Landing Page Data: $landingPageData");
  //   if (landingPageData['Gems'][0]['AbilitiesURL'].toString().endsWith('png')) {
  //     print(
  //         "Is Adult: ${landingPageData['Gems'][0]['AbilitiesURL'].toString().endsWith('png')}");
  //     isAdult = true;
  //   }
  //   if (Provider.of<SessionProvider>(context, listen: false).landingPageData !=
  //       null) {
  //     extractUnLockedGems();
  //   }
  //   familyMembers = session.userData?['familyMembers'];
  //   dynamic profileId = session.userData?['profileId']!;
  //   bool isPatient = session.userData?['isPatient'].toString() == "Yes";
  //   session.setNotPatient(isPatient);
  //   if (familyMembers.isEmpty) {
  //     Provider.of<SessionProvider>(context, listen: false)
  //         .setSelectedProfileId(profileId);
  //   }
  //   final _showPopup = Provider.of<SessionProvider>(context, listen: false)
  //       .userData?['isapplianceNotification'];
  //   bool showPopup =
  //       Provider.of<SessionProvider>(context, listen: false).showPopup;
  //   Future.delayed(
  //     Duration(seconds: 2),
  //     () {
  //       if (showPopup && _showPopup != null) {
  //         showAppliancePopup(context);
  //         Provider.of<SessionProvider>(context, listen: false)
  //             .setPopupShown(false);
  //       }
  //     },
  //   );
  // }

  bool? _selectedChoice;
  void showAppliancePopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(20),
          child: Container(
            width: 350,
            height: 350, // Square 350x350 dimensions
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Icon Section - 45% of height (157.5px)
                Container(
                  height: 157.5, // 45% of 350
                  decoration: BoxDecoration(
                    color: Color(0xffF8FCFF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color(0xff3197DB).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.medical_information_rounded,
                        size: 50,
                        color: Color(0xff3197DB),
                      ),
                    ),
                  ),
                ),

                // Text Section - 20% of height (70px)
                Container(
                  height: 70, // 20% of 350
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Text(
                      "Did you wear the appliance as prescribed by your therapist yesterday?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff4B4B4B),
                        height: 1.4,
                        fontFamily: "Alegreya_Sans",
                      ),
                    ),
                  ),
                ),

                // Buttons Section - 35% of height (122.5px)
                Container(
                  height: 122.5, // 35% of 350
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Buttons Row
                      Row(
                        children: [
                          // Yes Button - Expanded to take equal space
                          Expanded(
                            child: Container(
                              height: 48,
                              margin: EdgeInsets.only(right: 8),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedChoice = true;
                                  });
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedChoice == true
                                      ? Color(0xff4CAF50) // Green when clicked
                                      : Colors.white, // White when unclicked
                                  foregroundColor: _selectedChoice == true
                                      ? Colors.white // White text when clicked
                                      : Color(
                                          0xff4CAF50,
                                        ), // Green text when unclicked
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                      color: Color(0xff4CAF50), // Green border
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "Yes",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: _selectedChoice == true
                                        ? FontWeight.w700 // Bold when clicked
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // No Button - Expanded to take equal space
                          Expanded(
                            child: Container(
                              height: 48,
                              margin: EdgeInsets.only(left: 8),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedChoice = false;
                                  });
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedChoice == false
                                      ? Color(0xffF44336) // Red when clicked
                                      : Colors.white, // White when unclicked
                                  foregroundColor: _selectedChoice == false
                                      ? Colors.white // White text when clicked
                                      : Color(
                                          0xffF44336,
                                        ), // Red text when unclicked
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                      color: Color(0xffF44336), // Red border
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "No",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: _selectedChoice == false
                                        ? FontWeight.w700 // Bold when clicked
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showGemsAbility(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context), // Tap anywhere outside closes
          child: Stack(
            children: [
              // Full screen transparent layer to detect taps
              Positioned.fill(
                child: Container(color: Colors.transparent),
              ),

              // ---------------- POPUP ----------------
              Center(
                child: GestureDetector(
                  onTap: () {}, // prevent popup taps from closing dialog
                  child: GoldenFlowShadow(
                    borderRadius: 24,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 30,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 180,
                            child: Image.network(imageUrl),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          AchievementShimmerText(
                            text: "Achievement Unlocked",
                            fontSize: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _didLoad = false;
  // Future<void> landingPage() async {
  //   final session = Provider.of<SessionProvider>(context, listen: false);
  //   final userData = session.userData;
  //   final _userToken = userData?['user_token'];
  //   final _userId = userData?['userId'];
  //
  //   // Always use the currently selected profile
  //   final profileIdToUse = session.selectedProfileId ?? userData?['profileId'];
  //
  //   // Always fetch fresh landing data (no if check)
  //   var getResponse = await ApiService.landingPage(
  //     context,
  //     _userToken,
  //     profileIdToUse,
  //     _userId,
  //   );
  //
  //   if (getResponse['code'] == 200 && mounted) {
  //     setState(() {
  //       session.setLandingPageData(getResponse['data']);
  //       extractUnLockedGems(); // optional if you want updated gems
  //     });
  //   }
  // }
  Future<void> landingPage() async {
    final session = context.read<SessionProvider>();
    final userData = session.userData;

    final token = userData?['user_token'];
    final userId = userData?['userId'];
    final profileId =
        session.selectedProfileId ?? userData?['profileId'];

    final response = await ApiService.landingPage(
      context,
      token,
      profileId,
      userId,
    );

    if (!mounted) return;

    if (response['code'] == 200) {
      session.setLandingPageData(response['data']);
      extractUnLockedGems(); // uses setState safely
    }
  }
  List<dynamic> unlockedGemsVideos = [];
  List<dynamic> unlockedGemsImages = [];
  List<dynamic> gemMotivationalMsgs = [];
  void extractUnLockedGems() {
    final landingPageData =
        Provider.of<SessionProvider>(context, listen: false).landingPageData;

    if (landingPageData != null && landingPageData['Gems'] != null) {
      List<dynamic> gems = landingPageData['Gems'];
      List<dynamic> unlockedGems = gems
          .where((gem) => gem['gemStatus']['isGemLocked'] == "UNLOCK")
          .toList();

      if (isAdult) {
        List<dynamic> gemImages =
            unlockedGems.map((gem) => gem['AbilitiesURL']).toList();
        setState(() {
          unlockedGemsImages = gemImages;
        });
      } else {
        List<dynamic> gemVideos =
            unlockedGems.map((gem) => gem['AbilitiesURL']).toList();
        setState(() {
          unlockedGemsVideos = gemVideos;
        });
      }
      List<dynamic> motivationalMsgs =
          gems.map((gem) => gem['motivationalMessage']).toList();
      setState(() {
        gemMotivationalMsgs = motivationalMsgs;
      });
    }
  }

  void showCompleteFirst(String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16),
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.3),
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                  offset: Offset(0.0, 2.0),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 30,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ScaleButton(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Image.asset(CLOSE_BTN, width: 30, height: 30),
                    ),
                  ),
                ),
                Image.asset(
                  EXERCISE_VIEW_AVATAR,
                  height: 120,
                  width: 120,
                ),
                Center(
                  child: Text(
                    "$message",
                    style: TextStyle(
                      fontFamily: "Alegreya_Sans",
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool showRewards = false;

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionProvider>(context, listen: false);
    final landingPageData = session.landingPageData;
    final progress = landingPageData?['progress']['score'] ?? 0;

    final userData = session.userData;
    print("Selected Profile: ${session.selectedProfileId}");
    print("isPatient: ${session.isPatient}");
    print("Userdata: $userData");
    final therapistName = userData?['therapistInfo']['firstName'] +
        ' ' +
        userData?['therapistInfo']['lastName'];
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xffF6F5F3),
                          Color(0xff1349D1),
                          Color(0xff1349D1),
                          Color(0xffF6F5F3),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(DOCTOR_AVATAR_BG),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  child: Image.asset(
                                    DOCTOR_TEST,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            // Top ring overlay
                            Positioned.fill(
                              child: Image.asset(
                                DOCTOR_AVATAR_RING,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Your therapist: $therapistName",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Alegreya_Sans"),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Skeletonizer(
                effect: ShimmerEffect(
                  duration: Duration(milliseconds: 1500),
                  baseColor: Colors.black12,
                  highlightColor: Colors.white10,
                ),
                enabled: landingPageData?['profileName'] == null,
                child: Consumer<SessionProvider>(
                  builder: (context, session, _) {
                    final userData = session.userData;
                    List familyMembers = userData?['familyMembers'] ?? [];
                    final family = userData?['familyMembers'] ?? [];
                    print("familyMembers: $familyMembers");
                    final isParentPatient = familyMembers.length > 1;

                    // if (!isParentPatient) {
                    //   print("familyMembers[0]['userProfileName']");
                    //   print(familyMembers[0]['userProfileName']);
                    //   print(familyMembers[0]['userProfileName']);
                    //   return (familyMembers.isNotEmpty)
                    //       ? Text(
                    //           "${familyMembers[0]['patientFirstName']}",
                    //           style: TextStyle(
                    //             fontSize: 24,
                    //             fontFamily: "Alegreya_Sans",
                    //             color: Color(0xff8E8E93),
                    //           ),
                    //         )
                    //       : Text(
                    //           "${userData?['userProfileName']}",
                    //           style: TextStyle(
                    //             fontSize: 24,
                    //             fontFamily: "Alegreya_Sans",
                    //             color: Color(0xff8E8E93),
                    //           ),
                    //         );
                    // }
                    // final List familyMembers = userData?['familyMembers'] ?? [];

// ✅ CASE 1: No family members at all
                    if (familyMembers.isEmpty) {
                      return Text(
                        "${userData?['userProfileName'] ?? ''}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontFamily: "Alegreya_Sans",
                          color: Color(0xff8E8E93),
                        ),
                      );
                    }

// ✅ CASE 2: Exactly one family member
                    if (familyMembers.length == 1) {
                      return Text(
                        "${familyMembers.first['patientFirstName'] ?? ''}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontFamily: "Alegreya_Sans",
                          color: Color(0xff8E8E93),
                        ),
                      );
                    }

// ✅ CASE 3: Multiple family members → dropdown below

                    final selectedProfileId =
                        session.selectedProfileId ?? userData?['profileId'];

                    final Set<int> seenIds = {};
                    final List<DropdownMenuItem<int>> dropdownItems = [];
                    for (final member in family) {
                      final int profileId = member['profileId'];
                      if (seenIds.add(profileId)) {
                        dropdownItems.add(
                          DropdownMenuItem<int>(
                            value: profileId,
                            child: Text(member['userProfileName']),
                          ),
                        );
                      }
                    }

                    final containsSelected = dropdownItems
                        .any((item) => item.value == selectedProfileId);
                    final int? safeValue = containsSelected
                        ? selectedProfileId
                        : dropdownItems.first.value;

                    return Theme(
                      data: Theme.of(context).copyWith(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        focusColor: Colors.transparent,
                      ),
                      child: SizedBox(
                        width: 200,
                        height: 100,
                        child: CustomDropdown<int>(
                          value: safeValue,
                          items: userData?['familyMembers']
                                  ?.map<int>((m) => m['profileId'] as int)
                                  .toList() ??
                              [],

                          // ----------------- ITEM BUILDER (Beautiful UI) -----------------
                          itemBuilder: (context, item, selected) {
                            final member = userData?['familyMembers']
                                ?.firstWhere((m) => m['profileId'] == item);

                            final name =
                                member?['userProfileName'] ?? "Unknown";
                            final age = member?['age'];

                            return Container(
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xAACFFAFE)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              child: Row(
                                children: [
                                  Container(
                                    height: 24,
                                    width: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: selected
                                          ? Color(0xFF0891B2)
                                          : Color(0xff999999),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                        (int.parse(age) >= 18)
                                            ? Icons.person_rounded
                                            : Icons.child_care_rounded,
                                        size: 20,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontFamily: "Alegreya_Sans",
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  selected
                                      ? Icon(
                                          Icons.check_rounded,
                                          size: 24,
                                          color: Color(0xFF0891B2),
                                        )
                                      : SizedBox(width: 24),
                                ],
                              ),
                            );
                          },

                          // ----------------- SELECTED ITEM BUILDER -----------------
                          selectedItemBuilder: (context, item, selected) {
                            final member = userData?['familyMembers']
                                ?.firstWhere((m) => m['profileId'] == item);

                            final name =
                                member?['userProfileName'] ?? "Unknown";

                            return Center(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontFamily: "Alegreya_Sans",
                                  color: Color(0xff8E8E93),
                                ),
                              ),
                            );
                          },

                          // ----------------- DROPDOWN STYLING -----------------
                          backgroundColor: Colors.white,
                          menuBackgroundColor: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                          buttonHeight: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 14),

                          // Beautiful caret
                          showCaret: true,
                          caretIcon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 26,
                            color: Colors.deepPurple,
                          ),

                          // ----------------- LOGIC (YOUR ORIGINAL CODE) -----------------
                          onChanged: (int? newProfileId) async {
                            if (newProfileId != null &&
                                newProfileId != session.selectedProfileId) {
                              session.setSelectedProfileId(newProfileId);

                              final _userToken = userData?['user_token'];
                              final _userId = userData?['userId'];

                              var getResponse = await ApiService.landingPage(
                                context,
                                _userToken,
                                newProfileId,
                                _userId,
                              );

                              if (getResponse['code'] == 200 &&
                                  context.mounted) {
                                session.setLandingPageData(getResponse['data']);
                              }
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: showRewards
                ? Column(
                    children: [],
                  )
                : Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black54,
                                                  blurRadius: 7,
                                                  spreadRadius: 1,
                                                  offset: Offset(-2, 4),
                                                )
                                              ]),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  height: 58,
                                                  width: 58,
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image: AssetImage(
                                                                AVATAR_CONTAINER_INNER))),
                                                    child: Skeletonizer(
                                                      enabled:
                                                          landingPageData ==
                                                              null,
                                                      child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                          child: landingPageData ==
                                                                      null ||
                                                                  landingPageData[
                                                                          'patientAvatarURL'] ==
                                                                      null
                                                              ? AspectRatio(
                                                                  aspectRatio:
                                                                      2 / 2,
                                                                  child: displayBase64Image(
                                                                      defaultBase64))
                                                              : Base64ImageWidget(
                                                                  key:
                                                                      UniqueKey(),
                                                                  base64String:
                                                                      landingPageData[
                                                                          'patientAvatarURL'])),
                                                    )),
                                              ),
                                              Image.asset(
                                                  AVATAR_CONTAINER_OUTER),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 17.5,
                                          vertical: 10,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                padding: EdgeInsets.all(5),
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    8,
                                                  ),
                                                  border: Border(
                                                    left: BorderSide(
                                                      color: Color(0xff1F8C85),
                                                      width: 5,
                                                    ),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(
                                                        .5,
                                                      ),
                                                      blurRadius: 4.0,
                                                      spreadRadius: 1.0,
                                                      offset: Offset(0.0, 2.0),
                                                    ),
                                                  ],
                                                ),
                                                alignment: Alignment.center,
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Center(
                                                        child: Text(
                                                          "${landingPageData?['score'] ?? 0}",
                                                          style: TextStyle(
                                                            fontFamily:
                                                                "Alegreya_Sans",
                                                            fontSize: 20,
                                                            color: Color(
                                                                0xff1F8C85),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Center(
                                                        child: Text(
                                                          "Myopoints",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "Alegreya_Sans",
                                                              fontSize: 16),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                padding: EdgeInsets.all(5),
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    8,
                                                  ),
                                                  border: Border(
                                                    left: BorderSide(
                                                      color: Color(0xff3197DB),
                                                      width: 5,
                                                    ),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(
                                                        .5,
                                                      ),
                                                      blurRadius: 4.0,
                                                      spreadRadius: 1.0,
                                                      offset: Offset(0.0, 2.0),
                                                    ),
                                                  ],
                                                ),
                                                alignment: Alignment.center,
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                        flex: 3,
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            SizedBox(
                                                              height:
                                                                  (progress < 100) ? 60 : 65,
                                                              width: (progress <
                                                                      100)
                                                                  ? 60
                                                                  : 65,
                                                              child:
                                                                  GradientCircularProgressIndicator(
                                                                value:
                                                                    progress /
                                                                        100,
                                                                parentSize:
                                                                    height /
                                                                        1.4,
                                                                colors: [
                                                                  Color(
                                                                      0xff3197DB),
                                                                  Color(
                                                                      0xff3197DB),
                                                                  Color(
                                                                      0xff3197DB),
                                                                ],
                                                              ),
                                                            ),
                                                            Text(
                                                              "$progress%",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "Alegreya_Sans",
                                                                fontSize: 20,
                                                                color: Color(
                                                                    0xff3197DB),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Center(
                                                        child: Text(
                                                          "Progress",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "Alegreya_Sans",
                                                              fontSize: 16),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Builder(
                                        builder: (context) {
                                          var gem;
                                          bool isLocked = true;
                                          if (landingPageData != null) {
                                            gem = landingPageData['Gems'][0];
                                            isLocked = gem['gemStatus']
                                                    ['isGemLocked'] ==
                                                "LOCK";
                                            print("object");
                                            print(gem);print(gem);print(gem);
                                          }
                                          return Center(
                                            child: Gem(
                                              // function: () {
                                              //   if (isLocked) {
                                              //     showCompleteFirst(
                                              //         gemMotivationalMsgs[0]);
                                              //   } else {
                                              //     isAdult
                                              //         ? showGemsAbility(context,
                                              //             unlockedGemsImages[0])
                                              //         : Navigator.push(
                                              //             context,
                                              //             MaterialPageRoute(
                                              //               builder: (context) =>
                                              //                   PatientAvatarPreviewScreen(
                                              //                 key: UniqueKey(),
                                              //                 index: 0,
                                              //                 refVideos:
                                              //                     unlockedGemsVideos,
                                              //               ),
                                              //             ),
                                              //           );
                                              //
                                              //   }
                                              // },
                                              function: () {
                                                final gem = landingPageData?['Gems'][0];
                                                final abilityId = gem['abilitiesID'];

                                                print("Ability ID: $abilityId");

                                                if (isLocked) {
                                                  showCompleteFirst(gemMotivationalMsgs[0]);
                                                } else {
                                                  if (isAdult) {
                                                    showGemsAbility(context, gem['AbilitiesURL']);
                                                  } else {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => GemVideoPlayerScreen(
                                                          abilityId: abilityId,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              size: height /
                                                  15, // Reduce this if needed to fit with padding
                                              id: 1,
                                              lockDelay: 1,
                                              heartDelay: 1,
                                              growDelay: 1,
                                              isLocked: isLocked ? true : false,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: Builder(builder: (context) {
                                          var gem;
                                          bool isLocked = true;
                                          if (landingPageData != null) {
                                            gem = landingPageData['Gems'][1];
                                            isLocked = gem['gemStatus']
                                                    ['isGemLocked'] ==
                                                "LOCK";
                                          }
                                          return Center(
                                              child: Gem(

                                                function: () {
                                                  final gem = landingPageData?['Gems'][1];
                                                  final abilityId = gem['abilitiesID'];

                                                  print("Ability ID: $abilityId");

                                                  if (isLocked) {
                                                    showCompleteFirst(gemMotivationalMsgs[1]);
                                                  } else {
                                                    if (isAdult) {
                                                      showGemsAbility(context, gem['AbilitiesURL']);
                                                    } else {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => GemVideoPlayerScreen(
                                                            abilityId: abilityId,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },


                                            // function: () {
                                            //   if (isLocked) {
                                            //     showCompleteFirst(
                                            //         gemMotivationalMsgs[1]);
                                            //   } else {
                                            //     isAdult
                                            //         ? showGemsAbility(context,
                                            //             unlockedGemsImages[1])
                                            //         : Navigator.push(
                                            //             context,
                                            //             MaterialPageRoute(
                                            //               builder: (context) =>
                                            //                   PatientAvatarPreviewScreen(
                                            //                 key: UniqueKey(),
                                            //                 index: 1,
                                            //                 refVideos:
                                            //                     unlockedGemsVideos,
                                            //               ),
                                            //             ),
                                            //           );
                                            //   }
                                            // },
                                            size: height / 15,
                                            id: 2,
                                            lockDelay: 1,
                                            heartDelay: 1,
                                            growDelay: 1,
                                            isLocked: isLocked ? true : false,
                                          ));
                                        })),
                                    Expanded(
                                        flex: 1,
                                        child: Builder(builder: (context) {
                                          var gem;
                                          bool isLocked = true;
                                          if (landingPageData != null) {
                                            gem = landingPageData['Gems'][2];
                                            isLocked = gem['gemStatus']
                                                    ['isGemLocked'] ==
                                                "LOCK";
                                          }
                                          return Center(
                                              child: Gem(


                                                function: () {
                                                  final gem = landingPageData?['Gems'][2]; // ✅ FIXED
                                                  final abilityId = gem['abilitiesID'];

                                                  print("Ability ID: $abilityId");

                                                  if (isLocked) {
                                                    showCompleteFirst(gemMotivationalMsgs[2]);
                                                  } else {
                                                    if (isAdult) {
                                                      showGemsAbility(context, gem['AbilitiesURL']);
                                                    } else {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => GemVideoPlayerScreen(
                                                            abilityId: abilityId,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },

                                            // function: () {
                                            //   if (isLocked) {
                                            //     showCompleteFirst(
                                            //         gemMotivationalMsgs[2]);
                                            //   } else {
                                            //     isAdult
                                            //         ? showGemsAbility(context,
                                            //             unlockedGemsImages[2])
                                            //         : Navigator.push(
                                            //             context,
                                            //             MaterialPageRoute(
                                            //               builder: (context) =>
                                            //                   PatientAvatarPreviewScreen(
                                            //                       key:
                                            //                           UniqueKey(),
                                            //                       index: 2,
                                            //                       refVideos:
                                            //                           unlockedGemsVideos),
                                            //             ),
                                            //           );
                                            //   }
                                            // },
                                            size: height / 15,
                                            id: 3,
                                            lockDelay: 1,
                                            heartDelay: 1,
                                            growDelay: 1,
                                            isLocked: isLocked ? true : false,
                                          ));
                                        })),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: List.generate(3, (rowIndex) {
                              return Expanded(
                                child: Row(
                                  children: List.generate(4, (colIndex) {
                                    int id = rowIndex * 4 +
                                        colIndex +
                                        4; // Start from id 4
                                    var gem;
                                    bool isLocked = true;
                                    if (landingPageData != null) {
                                      gem = landingPageData['Gems'][id - 1];
                                      isLocked = gem['gemStatus']
                                              ['isGemLocked'] ==
                                          "LOCK";
                                    }
                                    return Expanded(
                                      child: Gem(
                                        function: () {
                                          final gem = landingPageData?['Gems'][id - 1];

                                          print("Ability ID: ${gem['abilitiesID']}");

                                          if (isLocked) {
                                            showCompleteFirst(gemMotivationalMsgs[id - 1]);
                                          } else {
                                            final abilityId = gem['abilitiesID'];

                                            if (isAdult) {
                                              showGemsAbility(context, gem['AbilitiesURL']);
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => GemVideoPlayerScreen(
                                                    abilityId: abilityId,
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        // function: () {
                                        //   if (isLocked) {
                                        //     print(gemMotivationalMsgs);
                                        //     showCompleteFirst(
                                        //         gemMotivationalMsgs[id - 1]);
                                        //   } else {
                                        //     isAdult
                                        //         ? showGemsAbility(context,
                                        //             unlockedGemsImages[id - 1])
                                        //         : Navigator.push(
                                        //             context,
                                        //             MaterialPageRoute(
                                        //               builder: (context) =>
                                        //                   PatientAvatarPreviewScreen(
                                        //                 key: UniqueKey(),
                                        //                 index: id - 1,
                                        //                 refVideos:
                                        //                     unlockedGemsVideos,
                                        //               ),
                                        //             ),
                                        //           );
                                        //   }
                                        // },
                                        size: height / 15,
                                        id: id,
                                        lockDelay: 1,
                                        heartDelay: 1,
                                        growDelay: 1,
                                        isLocked: isLocked ? true : false,
                                      ),
                                    );
                                  }),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          SizedBox(height: 10),
          landingPageData == null
              ? SizedBox()
              : Expanded(
                  flex: 1,
                  child: Center(
                    child: ScaleButton(
                      onTap: () {
                        setState(() {
                          Provider.of<IndexProvider>(context, listen: false)
                              .setIndex(3);
                        });
                      },
                      child: Container(
                        height: height / 20,
                        width: width * 0.9,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Color(0xff356DF1).withOpacity(0.8),
                              Color(0xff4EE8C5).withOpacity(0.8),
                            ]),
                            borderRadius: BorderRadius.circular(50)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Start Exercise",
                              style: TextStyle(
                                  fontFamily: "Alegreya_Sans",
                                  fontSize: height / 34,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
