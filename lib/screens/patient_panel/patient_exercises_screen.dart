import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myocircle15screens/screens/patient_panel/exercise_view_screen.dart';
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'select_profile_screen.dart';
import '../../components/components_path.dart';
import '../../components/custom_circular_progress_indicator.dart';
import '../../providers/index_provider.dart';
import '../../providers/session_provider.dart';
import '../../services/api_service.dart';

class PatientExercisesScreen extends StatefulWidget {
  const PatientExercisesScreen({super.key});

  @override
  State<PatientExercisesScreen> createState() => _PatientExercisesScreenState();
}

class _PatientExercisesScreenState extends State<PatientExercisesScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          _didLoad = true;
          getDailyExercises();
        }
      });
    }
  }

  bool isParent = false;
  @override
  void initState() {
    super.initState();
    final profileId = Provider.of<SessionProvider>(context, listen: false)
        .userData?['profileId']!;
    final selectedProfile =
        Provider.of<SessionProvider>(context, listen: false).selectedProfileId;
    print("profileId");
    print(profileId);
    print(selectedProfile);
    print("selectedProfile");
    if (profileId != selectedProfile) {
      isParent = true;
    }
  }

  bool _didLoad = false;
  Map<String, dynamic> exerciseData = {};
  Map<String, dynamic> selectedExercise = {};

  // void getDailyExercises() async {
  //   final selectedProfileId =
  //       Provider.of<SessionProvider>(context, listen: false).selectedProfileId;
  //
  //   final profileId = Provider.of<SessionProvider>(context, listen: false)
  //       .userData?['profileId'];
  //
  //   int patientId = selectedProfileId != null
  //       ? int.parse(selectedProfileId.toString())
  //       : profileId;
  //
  //   final response = await ApiService.getDailyExerciseList(
  //     context: context,
  //     patientId: patientId,
  //     mode: 2,
  //   );
  //
  //   print("API Response = $response");
  //
  //   /// ✅ Here response is your JSON map
  //   /// likely contains patientID, exerciseDays, etc.
  //   if (mounted) {
  //     setState(() {
  //       exerciseData = response;
  //     });
  //   }
  // }
  ///
  bool isLoading = true;
  void getDailyExercises() async {
    final selectedProfileId =
        Provider.of<SessionProvider>(context, listen: false).selectedProfileId;

    final profileId =
    Provider.of<SessionProvider>(context, listen: false).userData?['profileId'];

    int patientId = selectedProfileId != null
        ? int.parse(selectedProfileId.toString())
        : profileId;

    final response = await ApiService.getDailyExerciseList(
      context: context,
      patientId: patientId,
      mode: 2,
    );

    if (mounted) {
      setState(() {
        exerciseData = response;
        isLoading = false; // ✅ loading finished
      });
    }
  }
  ///


  ScrollController _listScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {


    final landingPageData =
        Provider.of<SessionProvider>(context, listen: false).landingPageData;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    print('width$width');
    print('Exercise Data: $exerciseData');
    // if (isLoading) {
    //   return const Scaffold(
    //     backgroundColor: Color(0xFFF6F5F3),
    //     body: Center(
    //       child: CircularProgressIndicator(),
    //     ),
    //   );
    // }

    // Extract exercise days and groups from new API response
    final List<dynamic> exerciseDays = exerciseData['exerciseDays'] ?? [];

    final Map<String, dynamic>? latestDay =
    exerciseDays.isNotEmpty ? exerciseDays.last : null;

    final List<dynamic> exerciseGroups =
        latestDay?['exerciseGroups'] ?? [];
    ///

    ///
    /// Finds the first incomplete exercise across all groups
    Map<String, int>? getGlobalFirstIncompleteExercise(
        List<dynamic> exerciseGroups) {
      for (int g = 0; g < exerciseGroups.length; g++) {
        final exercises = exerciseGroups[g]['exercises'] ?? [];
        for (int e = 0; e < exercises.length; e++) {
          if (exercises[e]['isExerciseComplete'] == false) {
            return {
              'groupIndex': g,
              'exerciseIndex': e,
            };
          }
        }
      }
      return null; // All exercises complete
    }

    final globalFirstIncomplete =
    getGlobalFirstIncompleteExercise(exerciseGroups);

    // Get patient info from new API response
    final int myoPoints = exerciseData['myoPoints'] ?? 0;
    final int progressPercent = exerciseData['progressPercent'] ?? 0;
    final String profileName = exerciseData['patientFirstName'] ?? '';
    final String profileImage = exerciseData['profileImage'] ?? '';

    // Function to get first incomplete exercise index in a group
    int getFirstIncompleteExerciseIndex(List<dynamic> exercises) {
      for (int i = 0; i < exercises.length; i++) {
        if (exercises[i]['isExerciseComplete'] == false) {
          return i;
        }
      }
      return -1; // All exercises are complete
    }

    // if (exerciseData.isEmpty) {
    //   return Scaffold(
    //     backgroundColor: const Color(0xFFF6F5F3),
    //     body: const Center(child: CircularProgressIndicator()),
    //   );
    // }


    // if (exerciseGroups.isEmpty) {
    //   return Scaffold(
    //     backgroundColor: const Color(0xFFF6F5F3),
    //     body: const Center(child: Text("No exercises found")),
    //   );
    // }
    ///



    ///


    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool, dynamic) {
        if (selectedExercise.isNotEmpty) {
          setState(() {
            selectedExercise = {};
          });
        } else {
          Provider.of<IndexProvider>(context, listen: false).setIndex(0);
        }
      },
      child: !selectedExercise.isEmpty
          ? Padding(
              padding: EdgeInsetsGeometry.all(16),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xffFEFDFE),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.5),
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                      offset: Offset(0.0, 2.0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.network(
                            selectedExercise['thumbNailURL'] ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Icon(Icons.image, size: 50),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 40,
                      alignment: Alignment.centerRight,
                      child: ScaleButton(
                          onTap: () {
                            setState(() {
                              if (selectedExercise.isNotEmpty) {
                                selectedExercise = {};
                              }
                            });
                          },
                          child: Image.asset(CLOSE_BTN, height: 30, width: 30)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          // Text(
                          //   selectedExercise['description'] ?? '',
                          //   style: TextStyle(
                          //     letterSpacing: 5,
                          //     fontFamily: "Alegreya_Sans",
                          //     fontSize: 32,
                          //     color: Color(0xff3E52A8),
                          //   ),
                          // ),
                          Text(
                            selectedExercise['name'] ?? '',
                            style: TextStyle(
                              fontFamily: "Alegreya_Sans",
                              fontSize: 20,
                              color: Color(0xff3E52A8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsetsGeometry.only(bottom: 40),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          width: 120,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border(
                              left: BorderSide(
                                  color: Color(0xff1F8C85), width: 5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.5),
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
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    "${selectedExercise['requiredTotalRepetitions'] ?? 0}",
                                    style: TextStyle(
                                      fontFamily: "Alegreya_Sans",
                                      fontSize: 23,
                                      color: Color(0xff1F8C85),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    "Reps",
                                    style: TextStyle(
                                      fontFamily: "Alegreya_Sans",
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: ScaleButton(
                          child: MaterialButton(
                            onPressed: () {
                              print("Selected Exercise: $selectedExercise");
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExerciseViewScreen(
                                    exercises: exerciseGroups,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: height / 20,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xff356DF1).withOpacity(0.8),
                                    Color(0xff4EE8C5).withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Start Exercise",
                                    style: TextStyle(
                                      fontFamily: "Alegreya_Sans",
                                      fontSize: height / 34,
                                      color: Colors.white,
                                    ),
                                  ),
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
            )
          : ScrollbarTheme(
              data: ScrollbarThemeData(
                  thumbColor: WidgetStatePropertyAll(Colors.black),
                  thickness: WidgetStatePropertyAll(7)),
              child: Scrollbar(
                controller: _listScrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _listScrollController,
                  child: Column(
                    children: [
                      Text(
                        profileName,
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: "Alegreya_Sans",
                          fontWeight: FontWeight.w500,
                          color: Color(0xff8E8E93),
                        ),
                      ),
                      Container(
                        height: 120,
                        width: 120,
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
                                              AVATAR_CONTAINER_INNER))),
                                  child: Skeletonizer(
                                      enabled: landingPageData == null &&
                                          profileImage.isEmpty,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: (landingPageData == null &&
                                                profileImage.isEmpty)
                                            ? AspectRatio(
                                                aspectRatio: 2 / 2,
                                                child: displayBase64Image(
                                                    defaultBase64))
                                            : Base64ImageWidget(
                                                key: UniqueKey(),
                                                base64String: profileImage
                                                        .isNotEmpty
                                                    ? profileImage
                                                    : landingPageData?[
                                                            'patientAvatarURL'] ??
                                                        '',
                                              ),
                                      )),
                                )),
                            Image.asset(AVATAR_CONTAINER_OUTER),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        height: 128,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              padding: EdgeInsets.all(5),
                              width: 120,
                              height: 88,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
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
                                    color: Colors.black.withOpacity(
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
                                        "$myoPoints",
                                        style: TextStyle(
                                          fontFamily: "Alegreya_Sans",
                                          fontSize: 20,
                                          color: Color(0xff1F8C85),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        "MyoPoints",
                                        style: TextStyle(
                                            fontFamily: "Alegreya_Sans",
                                            fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(5),
                              width: 120,
                              height: 88,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
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
                                    color: Colors.black.withOpacity(
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
                                        alignment: Alignment.center,
                                        children: [
                                          SizedBox(
                                            height: (progressPercent < 100)
                                                ? 60
                                                : 65,
                                            width: (progressPercent < 100)
                                                ? 60
                                                : 65,
                                            child:
                                                GradientCircularProgressIndicator(
                                              value: progressPercent / 100,
                                              parentSize: height / 1.4,
                                              colors: [
                                                Color(0xff3197DB),
                                                Color(0xff3197DB),
                                                Color(0xff3197DB),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            "$progressPercent%",
                                            style: TextStyle(
                                              fontFamily: "Alegreya_Sans",
                                              fontSize: 20,
                                              color: Color(0xff3197DB),
                                              fontWeight: FontWeight.bold,
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
                                            fontFamily: "Alegreya_Sans",
                                            fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Display day information if available
                      exerciseDays.isNotEmpty &&
                              exerciseDays[0]['originalExerciseDate'] != null
                          ? Text(
                        DateFormat("dd-MMM-yyyy").format(
                          DateTime.parse(exerciseDays[0]['originalExerciseDate']),
                        ),
                        style: TextStyle(
                          // fontFamily: "Alegreya_Sans",
                          fontSize: MediaQuery.of(context).size.height * 0.025,
                          fontWeight: FontWeight.w500,
                        ),
                      )

                          : exerciseGroups.isNotEmpty &&
                                  exerciseGroups[0]['date'] != null
                              ? Text(
                                  // "Date ${DateFormat('dd').format(DateTime.parse(exerciseGroups[0]['date']))}",
                                  exerciseGroups[0]['date'],
                                  style: TextStyle(
                                      // fontFamily: "Alegreya_Sans",
                                      fontSize: MediaQuery.of(context).size.height * 0.025,
                                      fontWeight: FontWeight.w500),
                                )
                              : SizedBox(),
                      if (exerciseGroups.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Center(
                            child: Text(
                              "No Exercise Assigned",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ) else
                      // Loop through exercise groups
                      for (var groupIndex = 0; groupIndex < exerciseGroups.length; groupIndex++) ...[

                        Text(
                          "SET ${exerciseGroups[groupIndex]['exerciseGroupID']}",
                          style: TextStyle(
                              // fontFamily: "Alegreya_Sans",
                              fontSize: MediaQuery.of(context).size.height * 0.025,
                              fontWeight: FontWeight.w500),
                        ),

                        // Get first incomplete exercise index for this group
                        // Loop through exercises in each group
                        ...List.generate(
                          exerciseGroups[groupIndex]['exercises']?.length ?? 0,
                          (exerciseIndex) {
                            final exercise = exerciseGroups[groupIndex]
                                ['exercises'][exerciseIndex];
                            final exercisesInGroup =
                                exerciseGroups[groupIndex]['exercises'];


                            // Determine if this exercise should show GO, TICK, or LOCK
                            bool isGoExercise = false;
                            bool isTickExercise = false;
                            bool isLockExercise = false;

                            if (isParent) {
                              print(isParent);
                              print(isParent);
                              print(isParent);
                              print(isParent);
                              print(isParent);
                              print(isParent);
                              print(isParent);
                              print(isParent);
                              print(isParent);
                              print(isParent);
                              // Parent sees GO everywhere
                              isGoExercise = true;
                            } else if (exercise['isExerciseComplete'] == true) {
                              isTickExercise = true;
                            } else if (globalFirstIncomplete != null &&
                                globalFirstIncomplete['groupIndex'] == groupIndex &&
                                globalFirstIncomplete['exerciseIndex'] == exerciseIndex) {
                              // ✅ ONLY ONE GO BUTTON IN ENTIRE LIST
                              isGoExercise = true;
                            } else {
                              isLockExercise = true;
                            }

                            // Determine if exercise is tappable
                            bool isTappable = isParent || isGoExercise;


                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 5, bottom: 5),
                              child: ScaleButton(
                                onTap: isTappable
                                    ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ExerciseViewScreen(
                                        exercises: exerciseGroups,
                                      ),
                                    ),
                                  );
                                }
                                    : null,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 15,
                                      bottom: 10,
                                      left: 10,
                                      right: 10,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              offset: Offset(10, 6),
                                              blurRadius: 4,
                                              spreadRadius: 2,
                                              color: Colors.black45,
                                            )
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      bottom: 10,
                                      left: 30,
                                      right: 30,
                                      child: Image.asset(
                                        exerciseIndex % 2 != 0
                                            ? PLAYER_SCORE_CONTAINER2
                                            : PLAYER_SCORE_CONTAINER,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Stack(
                                            children: [
                                              Image.asset(
                                                exerciseIndex % 2 != 0
                                                    ? PLAYER_RANK_CONTAINER2
                                                    : PLAYER_RANK_CONTAINER,
                                              ),
                                              Positioned(
                                                left: 5,
                                                right: 0,
                                                top: 0,
                                                bottom: 10,
                                                child: Center(
                                                  child: Text(
                                                    "${exerciseIndex + 1}",
                                                    style: TextStyle(
                                                      fontSize: 23,
                                                      fontFamily:
                                                          "Alegreya_Sans",
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  children: [

                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            exercise['name'] ??
                                                                '',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  "Alegreya_Sans",
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
                                        Expanded(
                                          flex: 1,
                                          child: Stack(
                                            children: [
                                              Image.asset(
                                                exerciseIndex % 2 != 0
                                                    ? PLAYER_RANK_CONTAINER2
                                                    : PLAYER_RANK_CONTAINER,
                                              ),
                                              Positioned(
                                                left: 5,
                                                right: 0,
                                                top: 0,
                                                bottom: 8,
                                                child: Center(
                                                  child: isGoExercise
                                                      ? Text(
                                                          "GO",
                                                          style: TextStyle(
                                                            fontSize: 23,
                                                            fontFamily:
                                                                "Alegreya_Sans",
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        )
                                                      : isTickExercise
                                                          ? Image.asset(
                                                              CHECK,
                                                              height: 50,
                                                              width: 50,
                                                            )
                                                          : Image.asset(
                                                              LOCK,
                                                              height: 50,
                                                              width: 50,
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
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
