


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:myocircle15screens/components/components_path.dart';
import 'package:myocircle15screens/components/custom_circular_progress_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/session_provider.dart';
import '../../services/api_service.dart';


class DailyCategoryData {
  final String date;
  final double lips;
  final double tongue;
  final double breathing;
  final double posture;

  DailyCategoryData({
    required this.date,
    required this.lips,
    required this.tongue,
    required this.breathing,
    required this.posture,
  });
}

class CategoryStatusData {
  final String category;
  final double completed;
  final double delayed;
  final double skipped;
  final double missed;

  CategoryStatusData({
    required this.category,
    required this.completed,
    required this.delayed,
    required this.skipped,
    required this.missed,
  });
}
class PatientReportScreen extends StatefulWidget {
  const PatientReportScreen({super.key});

  @override
  State<PatientReportScreen> createState() => _PatientReportScreenState();
}

class _PatientReportScreenState extends State<PatientReportScreen> {
  bool showDefault = true;
  bool isLoading = true;

  // User Data
  dynamic rank;
  dynamic myopoints;
  dynamic name;
  dynamic age;
  dynamic gender;

  // Overview Data
  double compliance = 0.0;
  double sessionDuration = 0.0;
  double dailyLogin = 0.0;
  double totalTimeSpent = 0.0;

  // Achievements Data
  int skillsUnlocked = 0;
  int pointsToNextSkill = 0;

  // Charts Data
  final List<LoginData> loginData = [];
  final List<ChartData> chartData = [];
  final List<SessionData> sessionData = [];
  final List<ExerciseData> exerciseData = [];
  final List<PerformanceData> performanceData = [];
  final List<OutcomeData> outcomeData = [];
  List<AccuracyData> accuracyData = [];
  final List therapistScoreData = [];
  final List symptomImprovementData = [];
  final List targetedExerciseData = [];
  final List assignedExerciseData = [];

  // Streak Data
  final Set<DateTime> loggedInDays = {};

  // Dynamic Exercise Data
  final List<ExerciseScore> exerciseScores = [];
  final List<Color> exerciseColors = [
    const Color(0xff25ADA4),
    const Color(0xff3498D8),
    const Color(0xff9B59B6),
    const Color(0xffE74C3C),
    const Color(0xffF1C209),
    const Color(0xffE67E22),
    const Color(0xff1ABC9C),
    const Color(0xff9B59B6),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getApiData(context);
    });
  }
  List assignedScoresData = [];
  List targetedMuscleData = [];



  void getApiData(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final session = Provider.of<SessionProvider>(context, listen: false);
    final userData = session.userData;
    final userToken = userData?['user_token'];
    final userId = userData?['userId'];
    final profileId = session.selectedProfileId!;

    // Set user basic info
    setState(() {
      if (userData?['isParent'] == "Yes") {
        for (var member in userData?['familyMembers']) {
          if (member['profileId'] == profileId) {
            name = member?['userProfileName'];
            age = member?['age'];
            gender = member?['gender'].toLowerCase();
          }
        }
      } else {
        name = userData?['userProfileName'];
        age = userData?['age'];
        gender = userData?['gender'].toLowerCase();
      }
      gender = gender[0].toUpperCase() + gender.substring(1).toLowerCase();
    });

    try {
      // Calculate date range (last 30 days for comprehensive data)
      String fromDate =
          _formatApiDate(DateTime.now().subtract(const Duration(days: 30)));
      String fromDate_ =
          _formatApiDate(DateTime.now().subtract(const Duration(days: 7)));
      String toDate = _formatApiDate(DateTime.now());

      // Call all APIs in parallel for better performance
      await Future.wait(
        [
          // Landing Page data
          getLandingPageData(context, userToken, profileId, userId),
          getCategoryWiseStatusData(
            context,
            userToken,
            fromDate,
            toDate,
            profileId,
            userId,
          ),
          generateAssignedExerciseData(
            context,
            userToken,
            fromDate,
            toDate,
            profileId,
            userId,
          ),
          getDailyCategoryData(
            context,
            userToken,
            fromDate,
            toDate,
            profileId,
            userId,
          ),
          // Overview Cards Data
          getOverviewData(
              context, userToken, fromDate, toDate, profileId, userId),

          // Charts Data
          getLoginFrequencyData(
              context, userToken, fromDate_, toDate, profileId, userId),
          getSessionDurationData(
              context, userToken, fromDate_, toDate, profileId, userId),
          getExerciseCompletionData(
              context, userToken, fromDate, toDate, profileId, userId),
          getStreakData(
              context, userToken, fromDate, toDate, profileId, userId),

          // Performance Data
          getPerformanceOverviewData(
              context, userToken, fromDate_, toDate, profileId, userId),
          generatePerformData(context, userToken, fromDate, toDate, "TargetedMuscle", profileId, userId),
          generatePerformDataCompliance(context, userToken, fromDate, toDate, "Compliance", profileId, userId),
          generatePerformDataDailyLogin(context, userToken, fromDate, toDate, "DailyLogin", profileId, userId),
          generatePerformDataSessionDuration(context, userToken, fromDate, toDate, "SessionDurationAll", profileId, userId),
          generatePerformDataLoginFrequency(context, userToken, fromDate, toDate, "LoginFrequency", profileId, userId),
          generateTherapistScoreData(
            context,
            userToken,
            fromDate_,
            toDate,
            profileId,
            userId,
          ),
          generateSymptomImprovementData(
            context,
            userToken,
            fromDate,
            toDate,
            profileId,
            userId,
          ),
          generateTargetedExerciseData(
            context,
            userToken,
            fromDate,
            toDate,
            profileId,
            userId,
          ),

          generateAccuracyData(
              context, userToken, fromDate, toDate, profileId, userId)
        ],
      );
    } catch (e) {
      print("Error fetching report data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Landing Page Data
  // Future<void> getLandingPageData(
  //   BuildContext context,
  //   String userToken,
  //   int profileId,
  //   int userId,
  // ) async {
  //   final response =
  //       await ApiService.landingPage(context, userToken, profileId, userId);
  //   if (response['code'] == 200) {
  //     setState(() {
  //       myopoints = response['data']['score'];
  //       rank = response['data']['rank'];
  //       skillsUnlocked = response['data']['skillsUnlocked'] ?? 3;
  //       pointsToNextSkill = response['data']['pointsToNextSkill'] ?? 119;
  //     });
  //   }
  // }
  int _safeInt(dynamic value) {
    print("Checking value = $value | Type = ${value.runtimeType}");

    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is List) return 0;

    return 0;
  }
  Future<void> getLandingPageData(
      BuildContext context,
      String userToken,
      int profileId,
      int userId,
      ) async {
    try {
      // ===== PRINT URL / PAYLOAD =====
      print("======================================");
      print("ACHIEVEMENTS API");
      print("URL: ${ApiService.baseUrl}/landingPagev1");
      print("Headers: user_token = $userToken");
      print("Payload:");
      print({
        "profileId": profileId,
        "userId": userId,
      });
      print("======================================");

      final response = await ApiService.landingPage(
        context,
        userToken,
        profileId,
        userId,
      );

      // ===== PRINT FULL RESPONSE =====
      print("Landing Full Response = $response");
      print("Response Type = ${response.runtimeType}");

      if (response['code'] == 200) {
        final data = response['data'];
        print("Gems = ${data['Gems']}");
        print("Gems Type = ${data['Gems'].runtimeType}");

        print("progress = ${data['progress']}");
        print("progress Type = ${data['progress'].runtimeType}");
        setState(() {
          myopoints = _safeInt(data['score']);
          rank = _safeInt(data['rank']);

          skillsUnlocked = (data['Gems'] is List)
              ? (data['Gems'] as List)
              .where((gem) =>
          gem is Map &&
              gem['gemStatus'] is Map &&
              gem['gemStatus']['isGemLocked'] == 'UNLOCK')
              .length
              : 0;

          pointsToNextSkill =
          (data['progress'] is Map)
              ? _safeInt(data['progress']['score'])
              : _safeInt(data['progress']);
        });

        print(data);
      } else {
        print("Landing API Failed = ${response['code']}");
      }
    } catch (e) {
      print("Landing API Error = $e");
    }
  }


  double overallCompletion = 0.0;
  Future<void> getOverviewData(
      BuildContext context,
      String userToken,
      String fromDate,
      String toDate,
      int profileId,
      int userId,
      ) async {

    final complianceResponse = await ApiService.getReportDataByType(
      context,
      userToken,
      fromDate,
      toDate,
      "OverAllCompletion",
      profileId,
      userId,
    );

    logApi(
      apiName: "OverAllCompletion",
      request: {
        "fromDate": fromDate,
        "toDate": toDate,
        "profileId": profileId,
        "userId": userId,
      },
      response: complianceResponse,
    );

    if (complianceResponse is Map) {
      setState(() {
        overallCompletion =
            (complianceResponse['completionPercentage'] ?? 0.0).toDouble();
      });
    }
  }

  // Login Frequency Data for Chart
  // Future<void> getLoginFrequencyData(
  //   BuildContext context,
  //   String userToken,
  //   String fromDate,
  //   String toDate,
  //   int profileId,
  //   int userId,
  // ) async {
  //   final loginFreqResponse = await ApiService.getReportDataByType(
  //       context,
  //       userToken,
  //       fromDate,
  //       toDate,
  //       "LoginFrequencyDateWise",
  //       profileId,
  //       userId);
  //
  //   if (loginFreqResponse is List) {
  //     List<LoginData> tempLoginData = [];
  //     for (final item in loginFreqResponse.cast<dynamic>()) {
  //       final date = item['date'];
  //       final loginCount = item['loginCount'];
  //       tempLoginData.add(LoginData(date, loginCount));
  //
  //       // Add to streak calendar
  //       try {
  //         final dateParts = date.split('-');
  //         if (dateParts.length == 3) {
  //           final streakDate = DateTime(int.parse(dateParts[2]),
  //               int.parse(dateParts[1]), int.parse(dateParts[0]));
  //           loggedInDays.add(streakDate);
  //         }
  //       } catch (e) {
  //         print("Error parsing date for streak: $date");
  //       }
  //     }
  //     setState(() {
  //       loginData.clear();
  //       loginData.addAll(tempLoginData);
  //     });
  //   }
  // }

  Future<void> getLoginFrequencyData(
      BuildContext context,
      String userToken,
      String fromDate,
      String toDate,
      int profileId,
      int userId,
      ) async {

    final response = await ApiService.getReportDataByType(
      context,
      userToken,
      fromDate,
      toDate,
      "LoginFrequencyDateWise",
      profileId,
      userId,
    );

    logApi(
      apiName: "LoginFrequencyDateWise",
      request: {
        "fromDate": fromDate,
        "toDate": toDate,
        "profileId": profileId,
        "userId": userId,
      },
      response: response,
    );

    if (response is List) {
      setState(() {
        loginData.clear();
        loginData.addAll(
          response.map((e) => LoginData(
            e['date'],
            e['loginCount'],
          )),
        );
      });
    }
  }

  List<DailyCategoryData> dailyChartData = [];

  Future<void> getDailyCategoryData( context,
  userToken,
  fromDate,
  toDate,
  profileId,
  userId,) async {
  final response = await ApiService.getReportDataByType(
  context,
  userToken,
  fromDate,
  toDate,
  "DailyExerciseCompletionByCategoryandDate",
  profileId,
  userId,
  );

  print("RAW RESPONSE = ${jsonEncode(response)}");

  if (response is List) {
  Map<String, Map<String, double>> groupedData = {};

  for (var item in response) {
  String date = item['exercise_day'];
  String category = item['category'];
  double value = (item['completion_percentage'] ?? 0).toDouble();

  groupedData.putIfAbsent(date, () => {});

  groupedData[date]![category] = value;
  }

  /// Convert to list
  List<DailyCategoryData> tempList = [];

  groupedData.forEach((date, categories) {
  tempList.add(
  DailyCategoryData(
  date: date,
  lips: categories['Lips'] ?? 0,
  tongue: categories['Tongue'] ?? 0,
  breathing: categories['Breathing'] ?? 0,
  posture: categories['Posture'] ?? 0,
  ),
  );
  });

  setState(() {
  dailyChartData = tempList;
  });

  print("FINAL GROUPED DATA = $dailyChartData");
  }
  }
  // Session Duration Data for Chart
  Future<void> getSessionDurationData(
    BuildContext context,
    String userToken,
    String fromDate,
    String toDate,
    int profileId,
    int userId,
  ) async {
    final sessionDurResponse = await ApiService.getReportDataByType(
        context,
        userToken,
        fromDate,
        toDate,
        "SessionDurationDatewise",
        profileId,
        userId);

    if (sessionDurResponse is List) {
      List<SessionData> tempSessionData = [];
      for (final item in sessionDurResponse.cast<dynamic>()) {
        final date = item['sessionDate'];
        final duration = (item['avgSessionDuration'] ?? 0.0).toDouble();
        tempSessionData.add(SessionData(date, duration));
      }
      setState(() {
        sessionData.clear();
        sessionData.addAll(tempSessionData);
      });
    }
  }

  // Exercise Completion Data for Pie Chart
  // Future<void> getExerciseCompletionData(
  //   BuildContext context,
  //   String userToken,
  //   String fromDate,
  //   String toDate,
  //   int profileId,
  //   int userId,
  // ) async {
  //   final exerciseOvResponse = await ApiService.getReportDataByType(
  //       context,
  //       userToken,
  //       fromDate,
  //       toDate,
  //       "ExercisewiseCompletionDatewise",
  //       profileId,
  //       userId);
  //
  //   if (exerciseOvResponse is List && exerciseOvResponse.isNotEmpty) {
  //     // Use the most recent data
  //     final latestData = exerciseOvResponse.cast<dynamic>().last;
  //     List<ChartData> tempChartData = [];
  //
  //     tempChartData.add(ChartData(
  //         'Completed',
  //         (latestData['completionPercentage'] ?? 0).toInt(),
  //         const Color(0xff25ADA4)));
  //     tempChartData.add(ChartData('Skipped',
  //         (latestData['skippedPercentage'] ?? 0).toInt(), Colors.orange));
  //     tempChartData.add(ChartData(
  //         'Missed', (latestData['missedPercentage'] ?? 0).toInt(), Colors.red));
  //
  //     setState(() {
  //       chartData.clear();
  //       chartData.addAll(tempChartData);
  //     });
  //   }
  // }
  ///

  List<CategoryStatusData> categoryStatusData = [];
  Future<void> getCategoryWiseStatusData(
      BuildContext context,
      String userToken,
      String fromDate,
      String toDate,
      int profileId,
      int userId,
      ) async {

    /// 🔥 PRINT PAYLOAD
    print("=====================================");
    print("API: CategoryWisecompletedDelayedKkippedMissed");
    print("Payload:");
    print({
      "fromDate": fromDate,
      "toDate": toDate,
      "profileId": profileId,
      "userId": userId,
    });
    print("=====================================");

    final response = await ApiService.getReportDataByType(
      context,
      userToken,
      fromDate,
      toDate,
      "CategoryWisecompletedDelayedKkippedMissed",
      profileId,
      userId,
    );

    /// 🔥 PRINT RESPONSE
    print("Category Status FULL Response = ${jsonEncode(response)}");

    if (response is List) {
      for (var item in response) {
        print("---- CATEGORY ----");
        print("Category: ${item['category']}");
        print("Completed: ${item['completed_percentage']}");
        print("Delayed: ${item['delayed_percentage']}");
        print("Skipped: ${item['skipped_percentage']}");
        print("Missed: ${item['missed_percentage']}");
      }

      setState(() {
        categoryStatusData = response.map((e) {
          return CategoryStatusData(
            category: e['category'],
            completed: (e['completed_percentage'] ?? 0).toDouble(),
            delayed: (e['delayed_percentage'] ?? 0).toDouble(),
            skipped: (e['skipped_percentage'] ?? 0).toDouble(),
            missed: (e['missed_percentage'] ?? 0).toDouble(),
          );
        }).toList();
      });
    }
  }
  ///
  Future<void> getExerciseCompletionData(
      BuildContext context,
      String userToken,
      String fromDate,
      String toDate,
      int profileId,
      int userId,
      ) async {
    final response = await ApiService.getReportDataByType(
      context,
      userToken,
      fromDate,
      toDate,
      "OverAllCompletion",
      profileId,
      userId,
    );

    print("Exercise Overview Full Response = $response");

    if (response is Map) {
      setState(() {
        chartData.clear();

        chartData.add(
          ChartData(
            'Completed',
            (response['completionPercentage'] ?? 0).toInt(),
            const Color(0xff25ADA4),
          ),
        );

        chartData.add(
          ChartData(
            'Skipped',
            (response['SkippedPercentage'] ?? 0).toInt(),
            Colors.orange,
          ),
        );

        chartData.add(
          ChartData(
            'Missed',
            (response['missedPercentage'] ?? 0).toInt(),
            Colors.red,
          ),
        );

        chartData.add(
          ChartData(
            'Delayed',
            (response['actualMissedPercentage'] ?? 0).toInt(),
            Colors.blue,
          ),
        );
      });

      print("Chart Data Count = ${chartData.length}");
    }
  }
  ///
  Set<DateTime> tempLoggedInDays = {};
  // Streak Data for Calendar
  Future<void> getStreakData(
      BuildContext context,
      String userToken,
      String fromDate,
      String toDate,
      int profileId,
      int userId,
      ) async {

    final streakResponse = await ApiService.getReportDataByType(
      context,
      userToken,
      fromDate,
      toDate,
      "StreakConsistencyDatewise",
      profileId,
      userId,
    );

    /// ✅ PRINT FULL RESPONSE
    print("🔥 STREAK API RESPONSE = $streakResponse");

    if (streakResponse is List) {
      Set<DateTime> tempLoggedInDays = {};

      for (final item in streakResponse) {

        /// ✅ PRINT EACH ITEM
        print("➡️ ITEM = $item");

        final dateStr = item['exerciseDate'].toString();
        final streak = item['streak'] ?? 0;

        print("📅 Date = $dateStr | 🔥 Streak = $streak");

        if (streak > 0) {
          try {
            final parts = dateStr.split('/'); // MM/dd

            if (parts.length == 2) {
              final month = int.parse(parts[0]);
              final day = int.parse(parts[1]);
              final year = DateTime.now().year;

              final streakDate = DateTime(year, month, day);

              /// ✅ PRINT FINAL DATE USED IN CALENDAR
              print("✅ Highlighting Date = $streakDate");

              tempLoggedInDays.add(streakDate);
            }
          } catch (e) {
            print("❌ Date Parse Error = $dateStr");
          }
        }
      }

      setState(() {
        loggedInDays.clear();
        loggedInDays.addAll(tempLoggedInDays);
      });

      /// ✅ FINAL DATA USED BY TABLE CALENDAR
      print("🎯 FINAL loggedInDays = $loggedInDays");
    }
  }

  // Performance Overview Data
  Future<void> getPerformanceOverviewData(
    BuildContext context,
    String userToken,
    String fromDate,
    String toDate,
    int profileId,
    int userId,
  ) async {
    // Get exercise-wise completion for performance scores
    final exerciseCompletionResponse = await ApiService.getReportDataByType(
        context,
        userToken,
        fromDate,
        toDate,
        "ExercisewiseCompletionPer",
        profileId,
        userId);

    if (exerciseCompletionResponse is List) {
      List<ExerciseScore> tempExerciseScores = [];
      List<ExerciseData> tempExerciseData = [];

      for (int i = 0; i < exerciseCompletionResponse.length; i++) {
        final item = exerciseCompletionResponse.cast<dynamic>()[i];
        final videoTitle = item['videoTitle'] ?? 'Exercise ${i + 1}';
        final completionPercentage =
            (item['completionPercentage'] ?? 0).toDouble();
        final score = completionPercentage / 10; // Convert to 0-10 scale

        // Assign color based on index (cycle through colors if more exercises than colors)
        Color exerciseColor = exerciseColors[i % exerciseColors.length];

        tempExerciseScores.add(ExerciseScore(
          name: videoTitle,
          score: score,
          color: exerciseColor,
        ));

        tempExerciseData
            .add(ExerciseData(videoTitle, completionPercentage.toInt()));
      }

      setState(() {
        exerciseScores.clear();
        exerciseScores.addAll(tempExerciseScores);
        exerciseData.clear();
        exerciseData.addAll(tempExerciseData);
      });
    }

    // Generate performance data for the last 7 days
    await generatePerformanceData(
        context, userToken, fromDate, toDate, profileId, userId);
  }

  // Generate Performance Data for last 7 days
  Future<void> generatePerformanceData(
    BuildContext context,
    String userToken,
    String fromDate,
    String toDate,
    int profileId,
    int userId,
  ) async {
    List<PerformanceData> tempPerformanceData = [];

    for (int i = 6; i >= 0; i--) {
      DateTime day = DateTime.now().subtract(Duration(days: i));
      String formattedDate = DateFormat('dd/MM').format(day);

      // Create performance data based on actual exercise scores with variation
      Map<String, int> exerciseScoresForDay = {};
      for (final exercise in exerciseScores) {
        final baseScore = exercise.score;
        final variedScore =
            (baseScore + _getRandomVariation()).clamp(0, 10).toInt();
        exerciseScoresForDay[exercise.name] = variedScore;
      }

      tempPerformanceData.add(PerformanceData(
        date: formattedDate,
        exerciseScores: exerciseScoresForDay,
      ));
    }

    setState(() {
      performanceData.clear();
      performanceData.addAll(tempPerformanceData);
    });
  }

  Future<void> generatePerformData(
    BuildContext context,
    String userToken,
    String fromDate,
    String toDate,
    String reportType,
    int profileId,
    int userId,
  ) async {
    final performanceDataResponse = await ApiService.getReportDataByType(
        context,
        userToken,
        fromDate,
        toDate,
        'ExerciseAccuracys',
        profileId,
        userId);
    print("Performance Data: $performanceDataResponse");
  }

  /// Compliance
  Future<void> generatePerformDataCompliance(
      BuildContext context,
      String userToken,
      String fromDate,
      String toDate,
      String reportType,
      int profileId,
      int userId,
      ) async {
    final response = await ApiService.getReportDataByType(
      context,
      userToken,
      fromDate,
      toDate,
      'Compliance',
      profileId,
      userId,
    );

    print("compliance Data: $response");

    // ✅ EXTRACT & ASSIGN
    if (response is Map && response['compliance'] != null) {
      setState(() {
        compliance = (response['compliance'] as num).toDouble();
      });
    }
  }
  /// Daily Login
  Future<void> generatePerformDataDailyLogin(
      BuildContext context,
      String userToken,
      String fromDate,
      String toDate,
      String reportType,
      int profileId,
      int userId,
      ) async {
    final response = await ApiService.getReportDataByType(
      context,
      userToken,
      fromDate,
      toDate,
      'DailyLogin',
      profileId,
      userId,
    );

    print("DailyLogin Data: $response");

    // ✅ EXTRACT & ASSIGN
    if (response is Map && response['dailyLogins'] != null) {
      setState(() {
        dailyLogin = (response['dailyLogins'] as num).toDouble();
      });
    }
  }
  /// Session Duration
  Future<void> generatePerformDataSessionDuration(
      BuildContext context,
      String userToken,
      String fromDate,
      String toDate,
      String reportType,
      int profileId,
      int userId,
      ) async {
    final response = await ApiService.getReportDataByType(
      context,
      userToken,
      fromDate,
      toDate,
      'SessionDurationAll',
      profileId,
      userId,
    );

    print("sessionDuration Data: $response");

    // ✅ EXTRACT & ASSIGN
    if (response is Map && response['sessionDuration'] != null) {
      setState(() {
        sessionDuration = (response['sessionDuration'] as num).toDouble();
      });
    }
  }

  ///
  Future<void> generatePerformDataLoginFrequency(
      BuildContext context,
      String userToken,
      String fromDate,
      String toDate,
      String reportType,
      int profileId,
      int userId,
      ) async {
    final response = await ApiService.getReportDataByType(
      context,
      userToken,
      fromDate,
      toDate,
      'LoginFrequency',
      profileId,
      userId,
    );

    print("totalTimeSpent Data: $response");

    // ✅ EXTRACT & ASSIGN
    if (response is Map && response['sessionDuration'] != null) {
      setState(() {
        totalTimeSpent = (response['sessionDuration'] as num).toDouble();
      });
    }
  }

  Future<void> generateTherapistScoreData(
    BuildContext context,
    String userToken,
    String fromDate,
    String toDate,
    int profileId,
    int userId,
  ) async {
    final therapistScoreDataResponse = await ApiService.getReportDataByType(
        context,
        userToken,
        fromDate,
        toDate,
        "AssignedScores",
        profileId,
        userId);
    print("Therapist Assigned Score: ${therapistScoreDataResponse}");
    if (therapistScoreDataResponse != []) {
      therapistScoreData.add(therapistScoreDataResponse[0]['lips'] ?? 'NA');
      therapistScoreData.add(therapistScoreDataResponse[0]['tongue'] ?? 'NA');
      therapistScoreData
          .add(therapistScoreDataResponse[0]['breathing'] ?? 'NA');
      therapistScoreData.add(therapistScoreDataResponse[0]['posture'] ?? 'NA');
    }
    print("Therapist Data List: $therapistScoreData");
  }

  Future<void> generateSymptomImprovementData(
    BuildContext context,
    String userToken,
    String fromDate,
    String toDate,
    int profileId,
    int userId,
  ) async {
    final symptomImprovementDataResponse = await ApiService.getReportDataByType(
      context,
      userToken,
      fromDate,
      toDate,
      "SymptomImprovement",
      profileId,
      userId,
    );
    print("Symptom Improvement Score: ${symptomImprovementDataResponse}");
    if (symptomImprovementDataResponse != []) {
      symptomImprovementData
          .add(symptomImprovementDataResponse[0]['lips'] ?? '0');
      symptomImprovementData
          .add(symptomImprovementDataResponse[0]['tongue'] ?? '0');
      symptomImprovementData
          .add(symptomImprovementDataResponse[0]['breathing'] ?? '0');
      symptomImprovementData
          .add(symptomImprovementDataResponse[0]['posture'] ?? '0');
    }
    print("Therapist Data List: $symptomImprovementData");
  }

  ///
  Future<void> generateAssignedExerciseData(
      BuildContext context,
      String userToken,
      String fromDate,
      String toDate,
      int profileId,
      int userId,
      ) async {
    final targetedExerciseDataResponse = await ApiService.getReportDataByType(
      context,
      userToken,
      fromDate,
      toDate,
      "AssignedScores",
      profileId,
      userId,
    );
    print("AssignedScores: ${targetedExerciseDataResponse}");
    if (targetedExerciseDataResponse is List &&
        targetedExerciseDataResponse.isNotEmpty) {
      assignedExerciseData.add(targetedExerciseDataResponse[0]['lips'] ?? 'NA');
      assignedExerciseData.add(targetedExerciseDataResponse[0]['tongue'] ?? 'NA');
      assignedExerciseData.add(targetedExerciseDataResponse[0]['breathing'] ?? 'NA');
      assignedExerciseData.add(targetedExerciseDataResponse[0]['posture'] ?? 'NA');
    }
    print("Therapist Data List: $targetedExerciseData");
  }
  ///

  Future<void> generateTargetedExerciseData(
    BuildContext context,
    String userToken,
    String fromDate,
    String toDate,
    int profileId,
    int userId,
  ) async {
    final targetedExerciseDataResponse = await ApiService.getReportDataByType(
      context,
      userToken,
      fromDate,
      toDate,
      "TargetedMuscle",
      profileId,
      userId,
    );
    print("Targeted Muscle Score: ${targetedExerciseDataResponse}");
    if (targetedExerciseDataResponse is List &&
        targetedExerciseDataResponse.isNotEmpty) {
      targetedExerciseData.add(targetedExerciseDataResponse[0]['lips'] ?? 'NA');
      targetedExerciseData
          .add(targetedExerciseDataResponse[0]['tongue'] ?? 'NA');
      targetedExerciseData
          .add(targetedExerciseDataResponse[0]['breathing'] ?? 'NA');
      targetedExerciseData
          .add(targetedExerciseDataResponse[0]['posture'] ?? 'NA');
    }
    print("Therapist Data List: $targetedExerciseData");
  }

  Future<void> generateAccuracyData(
    BuildContext context,
    String userToken,
    String fromDate,
    String toDate,
    int profileId,
    int userId,
  ) async {
    final accuracyDataResponse = await ApiService.getReportDataByType(context,
        userToken, fromDate, toDate, 'ExerciseAccuracys', profileId, userId);
    print("Accuracy Data: $accuracyDataResponse");
    if (accuracyDataResponse != []) {
      accuracyData = [
        AccuracyData('Lips', double.parse(accuracyDataResponse[0]['lips'])),
        AccuracyData('Tongue', double.parse(accuracyDataResponse[0]['tongue'])),
        AccuracyData(
            'Breathing', double.parse(accuracyDataResponse[0]['breathing'])),
        AccuracyData(
            'Posture', double.parse(accuracyDataResponse[0]['posture'])),
      ];
    }
  }

  double _getRandomVariation() {
    return (DateTime.now().microsecondsSinceEpoch % 3) - 1.5;
  }

  String _formatApiDate(DateTime d) {
    return DateFormat('MM/dd/yyyy').format(d);
  }

  DateTime today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Get outcome data (currently using dummy data - replace with API when available)
  List<OutcomeData> get outcomeDataList {
    return List.generate(7, (i) {
      final day = DateTime.now().subtract(Duration(days: 6 - i));
      final date = DateFormat('dd/MM').format(day);
      return OutcomeData(
        date: date,
        difficulty: [2, 1, 3, 2, 4, 3, 2][i],
        tiring: [1, 2, 2, 3, 2, 2, 1][i],
        fatigue: [3, 2, 4, 3, 3, 4, 2][i],
        needHelp: [1, 0, 2, 1, 1, 2, 1][i],
      );
    });
  }

  // Widget buildDayBox(DateTime day, {bool isToday = false}) {
  //   final hasStreak = loggedInDays.any((d) => isSameDay(d, day));
  //
  //   if (day.isAfter(today)) {
  //     return Container(
  //       margin: const EdgeInsets.all(4),
  //       decoration: BoxDecoration(
  //         color: hasStreak
  //             ? Colors.green
  //             : Colors.white,
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       alignment: Alignment.center,
  //       child: Text(
  //         '${day.day}',
  //         style: TextStyle(
  //           color: hasStreak ? Colors.white : Colors.black,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //     );
  //   }
  //
  //   return Container(
  //     margin: const EdgeInsets.all(4),
  //     decoration: BoxDecoration(
  //       color: hasStreak
  //           ? Colors.green
  //           : Colors.white,
  //       border: Border.all(
  //         color: isToday
  //             ? const Color(0xff004701)
  //             : Colors.grey.shade300,
  //         width: isToday ? 2 : 1,
  //       ),
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     alignment: Alignment.center,
  //       child: Text(
  //         '${day.day}',
  //         style: TextStyle(
  //           color: hasStreak
  //               ? Colors.white
  //               : Colors.black,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //   );
  // }
///
  List<DateTime> getLast30Days() {
    final today = DateTime.now();

    return List.generate(30, (index) {
      return DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: 30 - index)); // ✅ ends at today
    });
  }

  Widget buildStreakGrid() {
    final days = getLast30Days();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "30-Day Streak",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final day = days[index];

              final hasStreak =
              loggedInDays.any((d) => isSameDay(d, day));

              return Container(
                decoration: BoxDecoration(
                  color: hasStreak
                      ? Colors.green
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  "${day.day}",
                  style: TextStyle(
                    color: hasStreak ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildDayBox(DateTime day, {bool isToday = false}) {
    final hasStreak = loggedInDays.any((d) => isSameDay(d, day));

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: hasStreak ? Colors.green : Colors.white, // ✅ GREEN if streak
        border: Border.all(
          color: isToday ? const Color(0xff004701) : Colors.grey.shade300,
          width: isToday ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: hasStreak ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  ///

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xffF6F5F3),
        body: Center(
          child: Text(
            'Loading Reports...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff2662EB),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF6F5F3),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                  offset: const Offset(0.0, 2.0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header Section
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xff356DF1),
                        Color(0xff4EE8C5),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$name",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "$gender • Age $age • Treatment week 2/4",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),

                // Tab Control
                Container(
                  height: 80,
                  width: double.infinity,
                  color: const Color(0xffF3F4F6),
                  child: Center(
                    child: CustomSlidingSegmentedControl<int>(
                      initialValue: 1,
                      children: {
                        1: Text(
                          'Overview & Engagement',
                          style: TextStyle(
                            color: (showDefault)
                                ? const Color(0xff2662EB)
                                : Colors.black,
                          ),
                        ),
                        2: Text(
                          'Performance',
                          style: TextStyle(
                            color: (!showDefault)
                                ? const Color(0xff2662EB)
                                : Colors.black,
                          ),
                        ),
                      },
                      decoration: BoxDecoration(
                        color: const Color(0xffF3F4F6),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                      thumbDecoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                        border: const Border(
                          bottom: BorderSide(
                            color: Color(0xff2662EB),
                            width: 2,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.3),
                            blurRadius: 4.0,
                            spreadRadius: 1.0,
                            offset: const Offset(0.0, 2.0),
                          ),
                        ],
                      ),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInToLinear,
                      onValueChanged: (v) {
                        setState(() {
                          showDefault = v == 1;
                        });
                      },
                    ),
                  ),
                ),

                // Content based on selected tab
                (showDefault) ? _buildOverviewTab() : _buildPerformanceTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Column(
      children: [
        // Overview Cards
        Container(
          padding: const EdgeInsets.all(16),
          height: 200,
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: const Border(
                            left: BorderSide(
                              color: Color(0xff25ADA4),
                              width: 3,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.3),
                              blurRadius: 4.0,
                              spreadRadius: 1.0,
                              offset: const Offset(0.0, 2.0),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Compliance",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    compliance.toStringAsFixed(0),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff25ADA4),
                                    ),
                                  ),
                                  const Text(
                                    "%",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 10),
                              child: Image.asset(
                                COMPLIANCE,
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: const Border(
                            left: BorderSide(
                              color: Color(0xff9F60B9),
                              width: 3,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.3),
                              blurRadius: 4.0,
                              spreadRadius: 1.0,
                              offset: const Offset(0.0, 2.0),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Total time spent",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    sessionDuration.toStringAsFixed(2),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff9F60B9),
                                    ),
                                  ),
                                  const Text(
                                    "minutes average",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 10),
                              child: Image.asset(
                                CLOCK,
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: const Border(
                            left: BorderSide(
                              color: Color(0xff3197DB),
                              width: 3,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.3),
                              blurRadius: 4.0,
                              spreadRadius: 1.0,
                              offset: const Offset(0.0, 2.0),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Daily Login",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    dailyLogin.toStringAsFixed(2),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff3197DB),
                                    ),
                                  ),
                                  const Text(
                                    "avg/day",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 10),
                              child: Image.asset(
                                USER,
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: const Border(
                            left: BorderSide(
                              color: Color(0xffF1C209),
                              width: 3,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.3),
                              blurRadius: 4.0,
                              spreadRadius: 1.0,
                              offset: const Offset(0.0, 2.0),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Session Duration",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    totalTimeSpent.toStringAsFixed(2),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xffF1C209),
                                    ),
                                  ),
                                  const Text(
                                    "hours",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 10),
                              child: Image.asset(
                                DURATION,
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Achievements Section
        Container(
          padding: const EdgeInsets.all(16),
          height: 340,
          child: Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.3),
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0.0, 2.0),
                ),
              ],
            ),
            child: Column(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    "Achievements",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        "$myopoints",
                        style: const TextStyle(
                          color: Color(0xff2662EB),
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "MyoPoints",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        "$rank",
                        style: const TextStyle(
                          color: Color(0xff25ADA4),
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Rank",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        "$skillsUnlocked",
                        style: const TextStyle(
                          color: Color(0xff9233EA),
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Skills Unlocked",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Expanded(
                //   flex: 2,
                //   child: Column(
                //     children: [
                //       Text(
                //         "$pointsToNextSkill",
                //         style: const TextStyle(
                //           color: Color(0xffF4320B),
                //           fontSize: 25,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //       const Text(
                //         "Points to Next Skill",
                //         style: TextStyle(fontSize: 12),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),

        // 30 Day Streak Calendar
        Container(
          padding: const EdgeInsets.all(16),
          height: 350,
          child: Container(
            padding: const EdgeInsets.all(7.5),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.3),
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0.0, 2.0),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "30 Day Streak",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // TableCalendar(
                //   firstDay: DateTime.utc(today.year, today.month, 1),
                //   lastDay: DateTime.utc(today.year, today.month + 1, 0),
                //   focusedDay: today,
                //   calendarFormat: CalendarFormat.month,
                //   headerStyle: const HeaderStyle(
                //     formatButtonVisible: false,
                //     titleCentered: true,
                //     leftChevronVisible: false,
                //     rightChevronVisible: false,
                //   ),
                //   daysOfWeekStyle: const DaysOfWeekStyle(
                //     weekendStyle: TextStyle(color: Colors.red),
                //   ),
                //   calendarBuilders: CalendarBuilders(
                //     defaultBuilder: (context, day, focusedDay) {
                //       return buildDayBox(day);
                //     },
                //
                //     todayBuilder: (context, day, focusedDay) {
                //       return buildDayBox(day, isToday: true);
                //     },
                //
                //     outsideBuilder: (context, day, focusedDay) {
                //       return buildDayBox(day);
                //     },
                //   ),
                // ),
                buildStreakGrid(),
              ],
            ),
          ),
        ),

        // Exercise Overview Pie Chart
        Container(
          padding: const EdgeInsets.all(16),
          height: 340,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.3),
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0.0, 2.0),
                ),
              ],
            ),
            child: Center(
              child: chartData.isEmpty
                  ? const Center(
                      child: Text(
                      'No exercise data available',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Alegreya_Sans",
                        fontSize: 18,
                      ),
                    ))
                  : SfCircularChart(
                      title: const ChartTitle(text: 'Exercise Overview'),
                      legend: const Legend(
                        isVisible: true,
                        overflowMode: LegendItemOverflowMode.wrap,
                        position: LegendPosition.bottom,
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CircularSeries>[
                        PieSeries<ChartData, String>(
                          dataSource: chartData,
                          xValueMapper: (ChartData data, _) => data.category,
                          yValueMapper: (ChartData data, _) => data.value,
                          pointColorMapper: (ChartData data, _) => data.color,
                          dataLabelMapper: (ChartData data, _) =>
                              '${data.category}: ${data.value}%',
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside,
                            connectorLineSettings: ConnectorLineSettings(
                              type: ConnectorType.curve,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),

        // Daily Logins Chart
        Container(
          padding: const EdgeInsets.all(16),
          height: 340,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.3),
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0.0, 2.0),
                ),
              ],
            ),
            child: Center(
              child: loginData.isEmpty
                  ? const Center(
                      child: Text(
                      'No login data available',
                      style: TextStyle(
                        fontFamily: "Alegreya_Sans",
                        fontSize: 18,
                      ),
                    ))
                  : SfCartesianChart(
                      title: const ChartTitle(text: 'Daily Logins Chart'),
                      legend: const Legend(isVisible: false),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      primaryXAxis: CategoryAxis(
                        title: const AxisTitle(text: 'Date'),
                        labelRotation: -45,
                        labelIntersectAction: AxisLabelIntersectAction.none,
                        labelStyle: const TextStyle(fontSize: 10),
                      ),
                      primaryYAxis: const NumericAxis(
                        title: AxisTitle(text: 'Login Count'),
                        minimum: 0,
                        interval: 2,
                      ),
                      series: <CartesianSeries>[
                        ColumnSeries<LoginData, String>(
                          dataSource: loginData,
                          xValueMapper: (LoginData data, _) => data.date,
                          yValueMapper: (LoginData data, _) => data.count,
                          dataLabelSettings:
                              const DataLabelSettings(isVisible: true),
                          color: const Color(0xff1E3A8A),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6)),
                          width: 0.4,
                        ),
                      ],
                    ),
            ),
          ),
        ),

        // Average Session Duration Chart
        Container(
          padding: const EdgeInsets.all(16),
          height: 340,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.3),
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0.0, 2.0),
                ),
              ],
            ),
            child: Center(
              child: sessionData.isEmpty
                  ? const Center(
                      child: Text(
                      'No session duration data available',
                      style: TextStyle(
                        fontFamily: "Alegreya_Sans",
                        fontSize: 18,
                      ),
                    ))
                  : SfCartesianChart(
                      title: const ChartTitle(text: 'Average Session Duration'),
                      legend: const Legend(isVisible: false),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      primaryXAxis: CategoryAxis(
                        title: const AxisTitle(text: 'Date'),
                        labelRotation: -45,
                        labelIntersectAction: AxisLabelIntersectAction.none,
                        labelStyle: const TextStyle(fontSize: 10),
                      ),
                      primaryYAxis: const NumericAxis(
                        title: AxisTitle(text: 'Duration (minutes)'),
                        minimum: 0,
                        interval: 5,
                      ),
                      series: <CartesianSeries>[
                        SplineSeries<SessionData, String>(
                          dataSource: sessionData,
                          xValueMapper: (SessionData data, _) => data.date,
                          yValueMapper: (SessionData data, _) => data.duration,
                          markerSettings: const MarkerSettings(
                            isVisible: true,
                            height: 8,
                            width: 8,
                            shape: DataMarkerType.circle,
                          ),
                          dataLabelSettings:
                              const DataLabelSettings(isVisible: true),
                          color: const Color(0xff25ADA4),
                          splineType: SplineType.natural,
                          width: 3,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceTab() {
    return Column(
      children: [
        // Therapist Assigned Scores - Horizontal Bars
        // Container(
        //   padding: const EdgeInsets.all(16),
        //   height: 300,
        //   width: double.infinity,
        //   child: Container(
        //     padding: const EdgeInsets.all(10),
        //     width: double.infinity,
        //     decoration: BoxDecoration(
        //       color: Colors.white,
        //       borderRadius: BorderRadius.circular(8),
        //       boxShadow: [
        //         BoxShadow(
        //           color: Colors.black.withOpacity(.3),
        //           blurRadius: 4.0,
        //           spreadRadius: 1.0,
        //           offset: const Offset(0.0, 2.0),
        //         ),
        //       ],
        //     ),
        //     child: therapistScoreData.isEmpty
        //         ? const Center(
        //             child: Text(
        //             "Exercise Performance Data not available.",
        //             textAlign: TextAlign.center,
        //             style: TextStyle(
        //               fontFamily: "Alegreya_Sans",
        //               fontSize: 18,
        //             ),
        //           ))
        //         : Column(
        //             mainAxisAlignment: MainAxisAlignment.spaceAround,
        //             children: [
        //               const Text(
        //                 "Exercise Performance Scores",
        //                 style: TextStyle(
        //                   fontSize: 20,
        //                   fontWeight: FontWeight.bold,
        //                 ),
        //               ),
        //               _buildScoreRow(
        //                   'Lips', therapistScoreData[0], Color(0xff25ADA4)),
        //               _buildScoreRow(
        //                   'Tongue', therapistScoreData[1], Color(0xff3498D8)),
        //               _buildScoreRow('Breathing', therapistScoreData[2],
        //                   Color(0xff9B59B6)),
        //               _buildScoreRow(
        //                   'Posture', therapistScoreData[3], Color(0xffE74C3C)),
        //             ],
        //           ),
        //   ),
        // ),
        Container(
          padding: const EdgeInsets.all(16),
          height: 340,
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.3),
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0.0, 2.0),
                ),
              ],
            ),
            child: assignedExerciseData.isEmpty
                ? const Center(
                child: Text(
                  "Assigned Scores Data not available",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Alegreya_Sans",
                    fontSize: 18,
                  ),
                ))
                : Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  "Assigned Scores Score",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildExerciseRow('Lips', assignedExerciseData[0], Color(0xff25ADA4)),
                _buildExerciseRow('Tongue', assignedExerciseData[1], Color(0xff3498D8)),
                _buildExerciseRow('Breathing', assignedExerciseData[2], Color(0xff9B59B6)),
                _buildExerciseRow('Posture', assignedExerciseData[3], Color(0xffE74C3C)),
              ],
            ),
          ),
        ),
        // Exercise Scores - Circular Progress
        Container(
          padding: const EdgeInsets.all(16),
          height: 350,
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.3),
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0.0, 2.0),
                ),
              ],
            ),
            child: symptomImprovementData.isEmpty
                ? const Center(
                    child: Text(
                    "Symptom Improvement Data not available",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Alegreya_Sans",
                      fontSize: 18,
                    ),
                  ))
                : Column(
                    children: [
                      const Expanded(
                        flex: 1,
                        child: Text(
                          "Symptom Improvement",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            _buildCircularScore('Lips',
                                symptomImprovementData[0], Color(0xff25ADA4)),
                            _buildCircularScore('Tongue',
                                symptomImprovementData[1], Color(0xff3498D8)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            _buildCircularScore('Breathing',
                                symptomImprovementData[2], Color(0xff9B59B6)),
                            _buildCircularScore('Posture',
                                symptomImprovementData[3], Color(0xffE74C3C)),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        // Exercise Accuracy Chart
        Container(
          padding: const EdgeInsets.all(16),
          height: 340,
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.3),
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0.0, 2.0),
                ),
              ],
            ),
            child: Center(
              child: accuracyData.isEmpty
                  ? const Center(
                      child: Text(
                      'No exercise accuracy data available',
                      style:
                          TextStyle(fontFamily: "Alegreya_Sans", fontSize: 18),
                    ))
                  : SfCartesianChart(
                      title: const ChartTitle(text: 'Exercise Accuracy'),
                      legend: const Legend(isVisible: false),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      primaryXAxis: const CategoryAxis(
                        title: AxisTitle(text: 'Exercises'),
                        labelRotation: -15,
                        labelStyle: TextStyle(fontSize: 10),
                      ),
                      primaryYAxis: const NumericAxis(
                        title: AxisTitle(text: 'Accuracy'),
                        minimum: 0,
                        maximum: 10,
                        interval: 1,
                      ),
                      series: <CartesianSeries>[
                        ColumnSeries<AccuracyData, String>(
                          dataSource: accuracyData,
                          xValueMapper: (AccuracyData data, _) => data.exercise,
                          yValueMapper: (AccuracyData data, _) => data.score,
                          dataLabelSettings:
                              const DataLabelSettings(isVisible: true),
                          pointColorMapper: (AccuracyData data, _) {
                            final index = accuracyData
                                .indexWhere((e) => e.exercise == data.exercise);
                            return exerciseColors[
                                index % exerciseColors.length];
                          },
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                        ),
                      ],
                    ),
            ),
          ),
        ),

        ///
        Container(
          padding: const EdgeInsets.all(16),
          height: 340,
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.3),
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0.0, 2.0),
                ),
              ],
            ),
            child: targetedExerciseData.isEmpty
                ? const Center(
                child: Text(
                  "Targeted Muscle Data not available",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Alegreya_Sans",
                    fontSize: 18,
                  ),
                ))
                : Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  "Targeted Muscle Score",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildExerciseRow('Lips', targetedExerciseData[0], Color(0xff25ADA4)),
                _buildExerciseRow('Tongue', targetedExerciseData[1], Color(0xff3498D8)),
                _buildExerciseRow('Breathing', targetedExerciseData[2], Color(0xff9B59B6)),
                _buildExerciseRow('Posture', targetedExerciseData[3], Color(0xffE74C3C)),
              ],
            ),
          ),
        ),
        ///
        SfCartesianChart(
          title: const ChartTitle(
            text: "Exercise Performance by Category and Date",
          ),
          legend: const Legend(isVisible: true),
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(
            minimum: 0,
            maximum: 100,
            interval: 20,
          ),
          series: <CartesianSeries>[
            ColumnSeries<DailyCategoryData, String>(
              name: 'Lips',
              dataSource: dailyChartData,
              xValueMapper: (d, _) => d.date,
              yValueMapper: (d, _) => d.lips,
              color: Colors.green,
            ),
            ColumnSeries<DailyCategoryData, String>(
              name: 'Tongue',
              dataSource: dailyChartData,
              xValueMapper: (d, _) => d.date,
              yValueMapper: (d, _) => d.tongue,
              color: Colors.blue,
            ),
            ColumnSeries<DailyCategoryData, String>(
              name: 'Breathing',
              dataSource: dailyChartData,
              xValueMapper: (d, _) => d.date,
              yValueMapper: (d, _) => d.breathing,
              color: Colors.purple,
            ),
            ColumnSeries<DailyCategoryData, String>(
              name: 'Posture',
              dataSource: dailyChartData,
              xValueMapper: (d, _) => d.date,
              yValueMapper: (d, _) => d.posture,
              color: Colors.red,
            ),
          ],
        ),
        ///
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: Container(
            height: 300,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: categoryStatusData.isEmpty
                ? const Center(child: Text("No category data available"))
                : SfCartesianChart(
              title: const ChartTitle(
                text: "Category Wise Exercise Status Distribution (%)",
              ),
              legend: const Legend(
                isVisible: true,
                position: LegendPosition.top,
              ),
              primaryXAxis: CategoryAxis(),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 100,
                interval: 20,
              ),
              series: <CartesianSeries>[
                StackedColumnSeries<CategoryStatusData, String>(
                  name: 'Completed',
                  dataSource: categoryStatusData,
                  xValueMapper: (data, _) => data.category,
                  yValueMapper: (data, _) => data.completed,
                  color: Colors.green,
                ),
                StackedColumnSeries<CategoryStatusData, String>(
                  name: 'Delayed',
                  dataSource: categoryStatusData,
                  xValueMapper: (data, _) => data.category,
                  yValueMapper: (data, _) => data.delayed,
                  color: Colors.blue,
                ),
                StackedColumnSeries<CategoryStatusData, String>(
                  name: 'Skipped',
                  dataSource: categoryStatusData,
                  xValueMapper: (data, _) => data.category,
                  yValueMapper: (data, _) => data.skipped,
                  color: Colors.orange,
                ),
                StackedColumnSeries<CategoryStatusData, String>(
                  name: 'Missed',
                  dataSource: categoryStatusData,
                  xValueMapper: (data, _) => data.category,
                  yValueMapper: (data, _) => data.missed,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),




        ///

        // Exercise Performance Chart
        /*Container(
          padding: const EdgeInsets.all(16),
          height: 450,
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.3),
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0.0, 2.0),
                ),
              ],
            ),
            child: Center(
              child: performanceData.isEmpty || exerciseScores.isEmpty
                  ? const Center(child: Text('No performance data available'))
                  : SfCartesianChart(
                      title: const ChartTitle(
                          text: 'Exercise Performance (Last 7 Days)'),
                      legend: const Legend(
                        isVisible: true,
                        position: LegendPosition.bottom,
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      primaryXAxis: const CategoryAxis(
                        title: AxisTitle(text: 'Date'),
                        labelIntersectAction: AxisLabelIntersectAction.none,
                      ),
                      primaryYAxis: const NumericAxis(
                        title: AxisTitle(text: 'Performance (out of 10)'),
                        minimum: 0,
                        maximum: 10,
                        interval: 1,
                      ),
                      series: <CartesianSeries>[
                        for (int i = 0; i < exerciseScores.length && i < 4; i++)
                          BarSeries<PerformanceData, String>(
                            name: exerciseScores[i].name,
                            dataSource: performanceData,
                            xValueMapper: (d, _) => d.date,
                            yValueMapper: (d, _) =>
                                d.exerciseScores[exerciseScores[i].name] ?? 0,
                            dataLabelSettings:
                                const DataLabelSettings(isVisible: true),
                            color: exerciseScores[i].color,
                          ),
                      ],
                    ),
            ),
          ),
        ),
        */

        // Patient Reported Outcomes Chart
        /*Container(
          padding: const EdgeInsets.all(16),
          height: 400,
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.3),
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0.0, 2.0),
                ),
              ],
            ),
            child: Center(
              child: outcomeDataList.isEmpty
                  ? const Center(child: Text('No outcome data available'))
                  : SfCartesianChart(
                      title:
                          const ChartTitle(text: 'Patient Reported Outcomes'),
                      legend: const Legend(
                        isVisible: true,
                        position: LegendPosition.bottom,
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      primaryXAxis: const CategoryAxis(
                        title: AxisTitle(text: 'Date'),
                        labelRotation: -45,
                        labelStyle: TextStyle(fontSize: 10),
                      ),
                      primaryYAxis: const NumericAxis(
                        title: AxisTitle(text: 'Count'),
                        minimum: 0,
                        interval: 1,
                      ),
                      series: <CartesianSeries<OutcomeData, String>>[
                        SplineSeries<OutcomeData, String>(
                          name: 'Difficulty',
                          dataSource: outcomeDataList,
                          xValueMapper: (d, _) => d.date,
                          yValueMapper: (d, _) => d.difficulty,
                          markerSettings: const MarkerSettings(isVisible: true),
                          color: const Color(0xff25ADA4),
                        ),
                        SplineSeries<OutcomeData, String>(
                          name: 'Tiring',
                          dataSource: outcomeDataList,
                          xValueMapper: (d, _) => d.date,
                          yValueMapper: (d, _) => d.tiring,
                          markerSettings: const MarkerSettings(isVisible: true),
                          color: const Color(0xff3498D8),
                        ),
                        SplineSeries<OutcomeData, String>(
                          name: 'Fatigue',
                          dataSource: outcomeDataList,
                          xValueMapper: (d, _) => d.date,
                          yValueMapper: (d, _) => d.fatigue,
                          markerSettings: const MarkerSettings(isVisible: true),
                          color: const Color(0xff9B59B6),
                        ),
                        SplineSeries<OutcomeData, String>(
                          name: 'Need Help',
                          dataSource: outcomeDataList,
                          xValueMapper: (d, _) => d.date,
                          yValueMapper: (d, _) => d.needHelp,
                          markerSettings: const MarkerSettings(isVisible: true),
                          color: const Color(0xffE74C3C),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      */
      ],
    );
  }

  Widget _buildScoreRow(String title, String score, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 3),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text("${score}/10", style: const TextStyle(fontSize: 14)),
          ],
        ),
        Container(
          height: 3,
          width: double.infinity,
          color: color,
        ),
      ],
    );
  }

  Widget _buildCircularScore(String title, String score, Color color) {
    return Expanded(
      flex: 1,
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 80,
                  width: 80,
                  child: GradientCircularProgressIndicator(
                    // value: int.parse(score) / 10,
                    value: (int.tryParse((score ?? '').trim())?.toDouble() ?? 0.0) / 10,
                    parentSize: MediaQuery.of(context).size.height,
                    colors: [color, color, color],
                  ),
                ),
                Text(score)
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseRow(String title, String score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text("${score}/10", style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

// Data Model Classes
class ChartData {
  final String category;
  final int value;
  final Color color;

  ChartData(this.category, this.value, this.color);
}

class LoginData {
  final String date;
  final int count;

  LoginData(this.date, this.count);
}

class SessionData {
  final String date;
  final double duration;

  SessionData(this.date, this.duration);
}

class ExerciseData {
  final String exercise;
  final int accuracy;

  ExerciseData(this.exercise, this.accuracy);
}

class ExerciseScore {
  final String name;
  final double score;
  final Color color;

  ExerciseScore({
    required this.name,
    required this.score,
    required this.color,
  });
}

class PerformanceData {
  final String date;
  final Map<String, int> exerciseScores;

  PerformanceData({
    required this.date,
    required this.exerciseScores,
  });
}

class OutcomeData {
  final String date;
  final int difficulty;
  final int tiring;
  final int fatigue;
  final int needHelp;

  OutcomeData({
    required this.date,
    required this.difficulty,
    required this.tiring,
    required this.fatigue,
    required this.needHelp,
  });
}

class AccuracyData {
  final String exercise;
  final double score;

  AccuracyData(this.exercise, this.score);
}

