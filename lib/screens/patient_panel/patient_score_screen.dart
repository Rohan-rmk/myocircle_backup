import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/components_path.dart';
import '../../components/custom_dropdown.dart';
import '../../providers/session_provider.dart';
import '../../services/api_service.dart';
import 'select_profile_screen.dart';

class PatientScoreScreen extends StatefulWidget {
  const PatientScoreScreen({super.key});

  @override
  State<PatientScoreScreen> createState() => _PatientScoreScreenState();
}

class _PatientScoreScreenState extends State<PatientScoreScreen> {
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          _didLoad = true;
          // getScoreData();
          getLeaderboardData();
        }
      });
    }
  }

  Map<String, dynamic> scoreData = {};
  List<dynamic> leaderboardData = [];

  int myScore = 0;
  int mySelfRank = 0;

  void getLeaderboardData() async {
    final session = Provider.of<SessionProvider>(context, listen: false);

    final _userToken = session.userData?['user_token'];
    final _userId = session.userData?['userId'];
    final _therapistId = session.userData?['therapistId'];
    final _profileId = session.userData?['profileId'];
    final _selectedProfileId = session.selectedProfileId;

    try {
      var getResponse = await ApiService.getLeaderboardData(
        context,
        _userToken,
        _selectedProfileId ?? _profileId,
        _userId,
        _therapistId,
      );

      if (getResponse['status'] == 200) {
        setState(() {
          // ✅ store top-level score & selfRank
          myScore = getResponse['score'] ?? 0;
          mySelfRank = getResponse['selfRank'] ?? 0;

          // ✅ store leaderboard list
          leaderboardData = getResponse['data'] ?? [];
        });

        print("✅ Score: $myScore");
        print("🏆 SelfRank: $mySelfRank");
      } else {
        print("⚠️ API error: ${getResponse['message']}");
      }
    } catch (e) {
      print("❌ Exception in getLeaderboardData: $e");
    }
  }

  bool _didLoad = false;
  ScrollController _listScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final landingPageData =
        Provider.of<SessionProvider>(context, listen: false).landingPageData;
    return Column(
      children: [
        Consumer<SessionProvider>(
          builder: (context, session, _) {
            final userData = session.userData;
            List familyMembers = userData?['familyMembers'] ?? [];
            final family = userData?['familyMembers'] ?? [];
            print("familyMembers: $familyMembers");
            final isParentPatient = familyMembers.length > 1;

            if (!isParentPatient) {
              return (familyMembers.isNotEmpty)
                  ? Text(
                      "${familyMembers[0]['userProfileName']}",
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: "Alegreya_Sans",
                        color: Color(0xff8E8E93),
                      ),
                    )
                  : Text(
                      "${userData?['userProfileName']}",
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: "Alegreya_Sans",
                        color: Color(0xff8E8E93),
                      ),
                    );
            }

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

            final containsSelected =
                dropdownItems.any((item) => item.value == selectedProfileId);
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
                height: 82,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
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

                      final name = member?['userProfileName'] ?? "Unknown";
                      final age = member?['age'];

                      return Container(
                        decoration: BoxDecoration(
                          color:
                              selected ? const Color(0xAACFFAFE) : Colors.white,
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

                      final name = member?['userProfileName'] ?? "Unknown";

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

                        if (getResponse['code'] == 200 && context.mounted) {
                          session.setLandingPageData(getResponse['data']);
                        }
                      }
                    },
                  ),
                ),
              ),
            );
          },
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    "MyoPoints",
                    style: TextStyle(fontSize: 21, fontFamily: "Alegreya_Sans"),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 85,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                  RANK_CONTAINER,
                                ),
                                fit: BoxFit.fill)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 17, top: 15),
                        child: Text(
                          myScore == "" ? "" : myScore.toString(),
                          style: TextStyle(
                            fontFamily: "Alegreya_Sans",
                            fontSize: 23,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
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
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(AVATAR_CONTAINER_INNER))),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Base64ImageWidget(
                                key: UniqueKey(),
                                base64String:
                                    landingPageData?['patientAvatarURL']))),
                  ),
                  Image.asset(AVATAR_CONTAINER_OUTER),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Rank",
                    style: TextStyle(fontSize: 21, fontFamily: "Alegreya_Sans"),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 85,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                  SCORE_CONTAINER,
                                ),
                                fit: BoxFit.fill)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 17, top: 15),
                        child: Text(
                          mySelfRank == "" ? "" : mySelfRank.toString(),
                          style: TextStyle(
                            fontFamily: "Alegreya_Sans",
                            fontSize: 23,
                            color: Colors.white,
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
        SizedBox(height: 20),
        Expanded(
          child: ScrollbarTheme(
            data: ScrollbarThemeData(
                thumbColor:
                    WidgetStatePropertyAll(Color(0xff000000).withOpacity(0.7)),
                thickness: WidgetStatePropertyAll(7)),
            child: Scrollbar(
              controller: _listScrollController,
              thumbVisibility: true,
              child: ListView.builder(
                itemCount: leaderboardData.isEmpty ? 0 : leaderboardData.length,
                controller: _listScrollController,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, bottom: 5, top: 5),
                    child: Stack(
                      children: [
                        Positioned(
                            top: 15,
                            bottom: 10,
                            left: 10,
                            right: 10,
                            child: Container(
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                    offset: Offset(10, 6),
                                    blurRadius: 4,
                                    spreadRadius: 2,
                                    color: Colors.black45)
                              ], borderRadius: BorderRadius.circular(50)),
                            )),
                        Positioned(
                            top: 10,
                            bottom: 10,
                            left: 30,
                            right: 30,
                            child: Image.asset(
                              index % 2 != 0
                                  ? PLAYER_SCORE_CONTAINER2
                                  : PLAYER_SCORE_CONTAINER,
                              fit: BoxFit.fill,
                            )),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: index % 2 != 0
                                  ? Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: AssetImage(
                                                          EXERCISE_AVATAR_FRAME_IN),
                                                      fit: BoxFit.fill)),
                                              child: AspectRatio(
                                                aspectRatio: 1,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 10),
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                      child: Base64ImageWidget(
                                                          base64String:
                                                              leaderboardData[
                                                                      index][
                                                                  'avatarImg'])),
                                                ),
                                              )),
                                        ),
                                        Image.asset(EXERCISE_AVATAR_FRAME_OUT),
                                      ],
                                    )
                                  : Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        EXERCISE_AVATAR_FRAME_IN1),
                                                    fit: BoxFit.fill)),
                                            child: AspectRatio(
                                              aspectRatio: 1,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10),
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    child: Base64ImageWidget(
                                                        base64String:
                                                            leaderboardData[
                                                                    index]
                                                                ['avatarImg'])),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Image.asset(EXERCISE_AVATAR_FRAME_OUT1),
                                      ],
                                    ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      textAlign: TextAlign.start,
                                      // "Player ${index + 2}",
                                      "${leaderboardData[index]['firstName']}",
                                      style: TextStyle(
                                          fontSize: 21,
                                          fontFamily: "Alegreya_Sans"),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      textAlign: TextAlign.end,
                                      "${leaderboardData[index]['score']}",
                                      style: TextStyle(
                                          fontSize: 21,
                                          fontFamily: "Alegreya_Sans"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Stack(
                                children: [
                                  Image.asset(index % 2 != 0
                                      ? PLAYER_RANK_CONTAINER2
                                      : PLAYER_RANK_CONTAINER),
                                  Positioned(
                                    left: 5,
                                    right: 0,
                                    top: 0,
                                    bottom: 12,
                                    child: Center(
                                      child: Text(
                                        "${leaderboardData[index]['rank']}",
                                        style: TextStyle(
                                            fontSize: 23,
                                            fontFamily: "Alegreya_Sans",
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        )
      ],
    );
  }
}
