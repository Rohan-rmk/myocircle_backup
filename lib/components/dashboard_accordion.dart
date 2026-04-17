import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myocircle15screens/components/custom_circular_progress_indicator.dart';
import '../../screens/patient_panel/select_profile_screen.dart';
import 'components_path.dart';
import '../../providers/index_provider.dart';
import 'package:provider/provider.dart';

class DashboardAccordion extends StatefulWidget {
  final String profileName;
  final String base64Avatar;
  final List<dynamic> exerciseDays;

  final int myoPoints;
  final int progress;
  final int rank;
  final bool notParent;

  const DashboardAccordion({
    super.key,
    required this.profileName,
    required this.base64Avatar,
    required this.exerciseDays,
    required this.myoPoints,
    required this.rank,
    required this.notParent,
    required this.progress,
  });

  @override
  State<DashboardAccordion> createState() => _DashboardAccordionState();
}

class _DashboardAccordionState extends State<DashboardAccordion> {
  late bool isExpanded;
  late PageController _pageController;
  int _currentPageIndex = 1; // Default to Today

  List<Map<String, dynamic>> getExercisesForIndex(int index) {
    if (widget.exerciseDays.isEmpty) return [];
    if (index >= widget.exerciseDays.length) return [];

    final dayData = widget.exerciseDays[index] as Map<String, dynamic>;
    final groups = dayData['exerciseGroups'] as List<dynamic>? ?? [];

    if (groups.isEmpty) return [];

    final firstGroup = groups[0] as Map<String, dynamic>;
    final exercises = firstGroup['exercises'] as List<dynamic>? ?? [];

    return exercises.map((e) {
      final ex = e as Map<String, dynamic>;
      return {
        "name": ex["name"] ?? "",
        "requiredTotalRepetitions": ex["requiredTotalRepetitions"] ?? 0,
        "isExerciseComplete": ex["isExerciseComplete"] ?? false,
      };
    }).toList();
  }

  List<Map<String, dynamic>> getSetWiseExercisesForIndex(int index) {
    if (widget.exerciseDays.isEmpty) return [];
    if (index >= widget.exerciseDays.length) return [];

    final dayData = widget.exerciseDays[index] as Map<String, dynamic>;
    final groups = dayData['exerciseGroups'] as List<dynamic>? ?? [];

    final List<Map<String, dynamic>> list = [];

    for (int i = 0; i < groups.length; i++) {
      final group = groups[i] as Map<String, dynamic>;
      final exercises = group['exercises'] as List<dynamic>? ?? [];

      // ✅ Add Header: Set 1 / Set 2 / Set 3
      list.add({
        "type": "header",
        "title": "Set ${i + 1}",
      });

      // ✅ Add Exercises (NOT loopExercises)
      for (final ex in exercises) {
        final exMap = ex as Map<String, dynamic>;

        list.add({
          "type": "item",
          "name": exMap['name'] ?? "",
          "requiredTotalRepetitions": exMap['requiredTotalRepetitions'] ?? 0,
          "isExerciseComplete": exMap['isExerciseComplete'] ?? false,
        });
      }
    }

    return list;
  }




  @override
  void initState() {
    super.initState();
    isExpanded = widget.notParent;
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double getContainerHeight(int index) {
    final count = getSetWiseExercisesForIndex(index).length;
    // return 250 + (count * 85);
    return 305 + (count * 85);
  }


  List<Map<String, dynamic>> flattenLoopExercisesForDay(Map<String, dynamic> dayData) {
    final List<Map<String, dynamic>> list = [];

    final groups = dayData['exerciseGroups'] as List<dynamic>? ?? [];

    for (final g in groups) {
      final exercises = g['exercises'] as List<dynamic>? ?? [];

      for (final ex in exercises) {
        final loopExercises = ex['loopExercises'] as List<dynamic>? ?? [];

        for (final loop in loopExercises) {
          list.add({
            "videoName": loop['name'] ?? "", // ✅ loop name
            "requiredTotalRepetitions": loop['requiredLoopCount'] ?? 0, // ✅ reps
            "isLoopComplete": loop['isLoopComplete'] ?? false, // ✅ completion
          });
        }
      }
    }

    return list;
  }



  String getDayTitle(int index) {
    if (widget.exerciseDays.isEmpty) return "No exercise assigned";
    if (index >= widget.exerciseDays.length) return "No exercise assigned";

    final dayData = widget.exerciseDays[index] as Map<String, dynamic>;
    final rawDate = dayData['dayDate'];

    // ❌ No date from API
    if (rawDate == null || rawDate.toString().trim().isEmpty) {
      return "No exercise assigned";
    }

    try {
      final date = DateTime.parse(rawDate); // 2026-01-29
      return DateFormat('dd-MMM-yyyy').format(date); // 29-Jan-2026
    } catch (e) {
      // ❌ Invalid date format
      return "No exercise assigned";
    }
  }




  Widget _buildDayContainer(int index) {
    final exercises = getSetWiseExercisesForIndex(index);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.3),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ✅ Title
          Text(
            getDayTitle(index),
            style: const TextStyle(
              fontFamily: "Alegreya_Sans",
              fontSize: 22,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // ✅ FULL HEIGHT SCROLL LIST
          ListView.builder(
            shrinkWrap: true, // ✅ take full height
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exercises.length,
            itemBuilder: (context, i) {
              final exercise = exercises[i];
              print("exercise*****");
              print(exercise);
              print("exercise*****");

              // ✅ Set Header
              if (exercise["type"] == "header") {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10, top: 10),
                  padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xff0D4081),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    exercise["title"] ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: "Alegreya_Sans",
                    ),
                  ),
                );
              }

              // ✅ Exercise Item
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                                decoration: const BoxDecoration(
                                  color: Color(0xff387AED),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Icon(Icons.play_arrow,
                                        color: Colors.white, size: 20),
                                    Expanded(
                                      child: Text(
                                        exercise['name'] ?? "",
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Alegreya_Sans",
                                          fontSize: MediaQuery.of(context).size.height * 0.02,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Color(0xff0D4081),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  "Reps ${exercise['requiredTotalRepetitions'] ?? 0}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: "Alegreya_Sans",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 80,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color(0xffD9D9D9),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Image.asset(
                          exercise['isExerciseComplete'] == true
                              ? COMPLETE
                              : INCOMPLETE,
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // ✅ Bottom Fixed Values
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 70,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xff0D4081),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${widget.myoPoints}",
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "MyoPoints",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 70,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xff0D4081),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${widget.rank}",
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Rank",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xff387AED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 90,
                        width: 90,
                        child: CircularProgressIndicator(
                          value: widget.progress / 100, // convert % to 0–1
                          strokeWidth: 8,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),

                      // 🔹 Center Text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${widget.progress}%",
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Progress",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  )
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ✅ Reports button BELOW values
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xff0D4081),
              fixedSize: const Size(190, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Provider.of<IndexProvider>(context, listen: false).setIndex(5);
              print("index5");
            },
            child: const Text(
              "Reports",
              style: TextStyle(
                fontFamily: "Alegreya_Sans",
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("📌 ${widget.profileName} -> "
        "MyoPoints: ${widget.myoPoints}, "
        "Rank: ${widget.rank}, "
        "Progress: ${widget.progress}%");
    return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xff4285F4), Color(0xff30D6C5)],
          ),
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.profileName,
                  style: const TextStyle(
                      fontSize: 25,
                      fontFamily: "Alegreya_Sans",
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                Container(
                  alignment: Alignment.center,
                  height: 80,
                  width: 80,
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
                                image: AssetImage(AVATAR_CONTAINER_INNER)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Base64ImageWidget(
                              key: UniqueKey(),
                              base64String: widget.base64Avatar,
                            ),
                          ),
                        ),
                      ),
                      Image.asset(AVATAR_CONTAINER_OUTER),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => isExpanded = !isExpanded),
                  child: Image.asset(
                    isExpanded ? SUSPEND : EXPAND,
                    height: 30,
                  ),
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 20),

              // Scrollable content to handle variable height
              SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Dynamic PageView
                    SizedBox(
                      height: getContainerHeight(_currentPageIndex),
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPageIndex = index;
                          });
                        },
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return _buildDayContainer(index);
                        },
                      ),
                    ),


                    // const SizedBox(height: 10),
                    // ElevatedButton(
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.white,
                    //     foregroundColor: Color(0xff0D4081),
                    //     fixedSize: Size(190, 50),
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 40, vertical: 10),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //   ),
                    //   onPressed: () {
                    //     setState(() {
                    //       Provider.of<IndexProvider>(context, listen: false)
                    //           .setIndex(5);
                    //     });
                    //   },
                    //   child: const Text("Reports",
                    //       style: TextStyle(
                    //           fontFamily: "Alegreya_Sans",
                    //           fontWeight: FontWeight.bold,
                    //           fontSize: 22)),
                    // ),

                    const SizedBox(height: 10),

                    // Page indicator dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [0, 1, 2].map((index) {
                        return Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 3, vertical: 10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPageIndex == index
                                ? Colors.white
                                : Color(0xffD9D9D9),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ));
  }
}
