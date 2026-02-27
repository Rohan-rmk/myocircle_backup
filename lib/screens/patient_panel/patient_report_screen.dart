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
  Future<void> getLandingPageData(
      BuildContext context,
      String userToken,
      int profileId,
      int userId,
      ) async {
    final response =
    await ApiService.landingPage(context, userToken, profileId, userId);

    logApi(
      apiName: "Landing Page",
      request: {
        "profileId": profileId,
        "userId": userId,
      },
      response: response,
    );

    if (response['code'] == 200) {
      setState(() {
        myopoints = response['data']['score'];
        rank = response['data']['rank'];
        skillsUnlocked = response['data']['skillsUnlocked'] ?? 3;
        pointsToNextSkill = response['data']['pointsToNextSkill'] ?? 119;
      });
    }
  }

  // Overview Cards Data
  // Future<void> getOverviewData(
  //   BuildContext context,
  //   String userToken,
  //   String fromDate,
  //   String toDate,
  //   int profileId,
  //   int userId,
  // ) async {
  //   // Compliance Data
  //   final complianceResponse = await ApiService.getReportDataByType(context,
  //       userToken, fromDate, toDate, "OverAllCompletion", profileId, userId);
  //   if (complianceResponse is Map) {
  //     setState(() {
  //       compliance =
  //           (complianceResponse['completionPercentage'] ?? 0.0).toDouble();
  //     });
  //   }
  //
  //   // Session Duration Data
  //   final sessionDurationResponse = await ApiService.getReportDataByType(
  //       context,
  //       userToken,
  //       fromDate,
  //       toDate,
  //       "SessionDurationAll",
  //       profileId,
  //       userId);
  //   if (sessionDurationResponse is Map) {
  //     setState(() {
  //       sessionDuration =
  //           (sessionDurationResponse['sessionDuration'] ?? 0.0).toDouble();
  //     });
  //   }
  //
  //   // Daily Login Data
  //   final loginFrequencyResponse = await ApiService.getReportDataByType(context,
  //       userToken, fromDate, toDate, "LoginFrequency", profileId, userId);
  //   if (loginFrequencyResponse is Map) {
  //     setState(() {
  //       dailyLogin =
  //           (loginFrequencyResponse['sessionDuration'] ?? 0.0).toDouble();
  //     });
  //   }
  //
  //   // Total Time Spent (calculate from session duration data)
  //   final sessionDurationDatewise = await ApiService.getReportDataByType(
  //       context,
  //       userToken,
  //       fromDate,
  //       toDate,
  //       "SessionDurationDatewise",
  //       profileId,
  //       userId);
  //   if (sessionDurationDatewise is List) {
  //     double totalDuration = 0.0;
  //     for (final item in sessionDurationDatewise.cast<dynamic>()) {
  //       totalDuration += (item['avgSessionDuration'] ?? 0.0).toDouble();
  //     }
  //     setState(() {
  //       totalTimeSpent = (totalDuration / 60).toDouble(); // Convert to hours
  //     });
  //   }
  // }
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
        compliance =
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
  Future<void> getExerciseCompletionData(
    BuildContext context,
    String userToken,
    String fromDate,
    String toDate,
    int profileId,
    int userId,
  ) async {
    final exerciseOvResponse = await ApiService.getReportDataByType(
        context,
        userToken,
        fromDate,
        toDate,
        "ExercisewiseCompletionDatewise",
        profileId,
        userId);

    if (exerciseOvResponse is List && exerciseOvResponse.isNotEmpty) {
      // Use the most recent data
      final latestData = exerciseOvResponse.cast<dynamic>().last;
      List<ChartData> tempChartData = [];

      tempChartData.add(ChartData(
          'Completed',
          (latestData['completionPercentage'] ?? 0).toInt(),
          const Color(0xff25ADA4)));
      tempChartData.add(ChartData('Skipped',
          (latestData['skippedPercentage'] ?? 0).toInt(), Colors.orange));
      tempChartData.add(ChartData(
          'Missed', (latestData['missedPercentage'] ?? 0).toInt(), Colors.red));

      setState(() {
        chartData.clear();
        chartData.addAll(tempChartData);
      });
    }
  }

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
        userId);

    if (streakResponse is List) {
      Set<DateTime> tempLoggedInDays = {};
      for (final item in streakResponse.cast<dynamic>()) {
        final dateStr = item['exerciseDate'];
        final streak = item['streak'] ?? 0;

        // Only add days with positive streak
        if (streak > 0) {
          try {
            final dateParts = dateStr.split('-');
            if (dateParts.length == 3) {
              final streakDate = DateTime(int.parse(dateParts[2]),
                  int.parse(dateParts[1]), int.parse(dateParts[0]));
              tempLoggedInDays.add(streakDate);
            }
          } catch (e) {
            print("Error parsing streak date: $dateStr");
          }
        }
      }
      setState(() {
        loggedInDays.clear();
        loggedInDays.addAll(tempLoggedInDays);
      });
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
    if (targetedExerciseDataResponse != []) {
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

  DateTime today = DateTime.now();
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
            height: (showDefault) ? 2190 : 1510,
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
                                    "Session Duration",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    sessionDuration.toStringAsFixed(1),
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
                                    dailyLogin.toStringAsFixed(1),
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
                                    "Total time spent",
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
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        "$pointsToNextSkill",
                        style: const TextStyle(
                          color: Color(0xffF4320B),
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Points to Next Skill",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 30 Day Streak Calendar
        Container(
          padding: const EdgeInsets.all(16),
          height: 450,
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  "30 Day Streak",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TableCalendar(
                  firstDay: DateTime.utc(today.year, today.month, 1),
                  lastDay: DateTime.utc(today.year, today.month + 1, 0),
                  focusedDay: today,
                  calendarFormat: CalendarFormat.month,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronVisible: false,
                    rightChevronVisible: false,
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekendStyle: TextStyle(color: Colors.red),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return AspectRatio(
                        aspectRatio: 1.0,
                        child: Builder(
                          builder: (context) {
                            if (day.isAfter(today)) {
                              return Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              );
                            } else if (loggedInDays
                                .any((d) => isSameDay(d, day))) {
                              return Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xff25ADA4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return AspectRatio(
                        aspectRatio: 1.0,
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xff004701),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              color: Color(0xff004701),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
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
        Container(
          padding: const EdgeInsets.all(16),
          height: 300,
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
            child: therapistScoreData.isEmpty
                ? const Center(
                    child: Text(
                    "Exercise Performance Data not available.",
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
                        "Exercise Performance Scores",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildScoreRow(
                          'Lips', therapistScoreData[0], Color(0xff25ADA4)),
                      _buildScoreRow(
                          'Tongue', therapistScoreData[1], Color(0xff3498D8)),
                      _buildScoreRow('Breathing', therapistScoreData[2],
                          Color(0xff9B59B6)),
                      _buildScoreRow(
                          'Posture', therapistScoreData[3], Color(0xffE74C3C)),
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

        // Targeted Score Section
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
                      _buildExerciseRow(
                          'Lips', targetedExerciseData[0], Color(0xff25ADA4)),
                      _buildExerciseRow(
                          'Tongue', targetedExerciseData[1], Color(0xff3498D8)),
                      _buildExerciseRow('Breathing', targetedExerciseData[2],
                          Color(0xff9B59B6)),
                      _buildExerciseRow('Posture', targetedExerciseData[3],
                          Color(0xffE74C3C)),
                    ],
                  ),
          ),
        ),

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
