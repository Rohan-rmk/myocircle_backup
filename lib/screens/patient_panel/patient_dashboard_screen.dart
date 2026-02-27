import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/dashboard_accordion.dart';
import '../../providers/session_provider.dart';
import '../../services/api_service.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  final Map<int, List<Map<String, dynamic>>> _exercisesToday = {};
  final Map<int, List<Map<String, dynamic>>> _exercisesYesterday = {};
  final Map<int, List<Map<String, dynamic>>> _exercisesTomorrow = {};
  final Map<int, int> _myoPoints = {};
  final Map<int, int> _progress = {};
  final Map<int, int> _rank = {};
  final Map<int, String?> _avatar = {};


  Map<String, dynamic>? findDayByDate(
      List<dynamic> exerciseDays,
      String dateType,
      ) {
    DateTime now = DateTime.now();
    DateTime target;

    if (dateType == "yesterday") {
      target = now.subtract(const Duration(days: 1));
    } else if (dateType == "today") {
      target = now;
    } else {
      target = now.add(const Duration(days: 1));
    }

    String targetDate = target.toIso8601String().substring(0, 10); // yyyy-MM-dd

    for (final d in exerciseDays) {
      final dayMap = d as Map<String, dynamic>;
      if (dayMap["dayDate"] == targetDate) {
        return dayMap;
      }
    }

    return null;
  }


  Future<Map<String, dynamic>> getDashboardDataForProfile(
      BuildContext context,
      int patientId,
      ) async {
    try {
      final response = await ApiService.getDashboardData(
        context: context,
        patientId: patientId,
        mode: 1,
      );

      print("✅ FULL Response => $response");

      // ✅ if ApiService already returns data map directly
      if (response.containsKey('myoPoints')) {
        return response;
      }

      // ✅ if ApiService returns {code:200, data:{...}}
      if (response['code'] == 200 && response['data'] != null) {
        return Map<String, dynamic>.from(response['data']);
      }

      return {};
    } catch (e) {
      print("❌ Error getDashboardDataForProfile => $e");
      return {};
    }
  }



  List<Map<String, dynamic>> processExercisesForDay(
      Map<String, dynamic> dayData,
      String dateType,
      ) {
    try {
      final List<Map<String, dynamic>> processedExercises = [];

      final exerciseDays = dayData['exerciseDays'] as List<dynamic>?;
      if (exerciseDays == null || exerciseDays.isEmpty) return [];

      // ✅ FIND correct day by date
      final day = findDayByDate(exerciseDays, dateType);
      if (day == null) return [];

      final exerciseGroups = day['exerciseGroups'] as List<dynamic>?;
      if (exerciseGroups == null || exerciseGroups.isEmpty) return [];

      // ✅ Get exercises from the first group only
      final firstGroup = exerciseGroups[0] as Map<String, dynamic>;
      final firstGroupExercises = firstGroup['exercises'] as List<dynamic>?;
      if (firstGroupExercises == null || firstGroupExercises.isEmpty) return [];

      // ✅ Count occurrences across all groups (Times/Day)
      final Map<int, int> exerciseSetCounts = {};

      for (final group in exerciseGroups) {
        final groupMap = group as Map<String, dynamic>;
        final exercises = groupMap['exercises'] as List<dynamic>?;

        if (exercises != null) {
          for (final exercise in exercises) {
            final exerciseMap = exercise as Map<String, dynamic>;
            final exerciseId = exerciseMap['exerciseID'] as int?;

            if (exerciseId != null) {
              exerciseSetCounts[exerciseId] =
                  (exerciseSetCounts[exerciseId] ?? 0) + 1;
            }
          }
        }
      }

      // ✅ Build list from first group
      for (final exercise in firstGroupExercises) {
        final exerciseMap = exercise as Map<String, dynamic>;
        final exerciseId = exerciseMap['exerciseID'] as int?;
        if (exerciseId == null) continue;

        final int setCount = exerciseSetCounts[exerciseId] ?? 1;
        final String name = exerciseMap['name']?.toString() ?? '';
        final int reps = exerciseMap['requiredTotalRepetitions'] as int? ?? 0;

        String completed;
        if (dateType == 'tomorrow') {
          completed = 'pending';
        } else {
          final bool isComplete = exerciseMap['isExerciseComplete'] as bool? ?? false;
          completed = isComplete ? 'yes' : 'no';
        }

        processedExercises.add({
          'name': name,
          'set': setCount,
          'reps': reps,
          'completed': completed,
        });
      }

      return processedExercises;
    } catch (e) {
      return [];
    }
  }


  List<Map<String, dynamic>> createTomorrowExercises(
      List<Map<String, dynamic>> todayExercises) {
    // Create a copy of today's exercises with 'pending' status
    return todayExercises.map((exercise) {
      return {
        'name': exercise['name'],
        'set': exercise['set'],
        'reps': exercise['reps'],
        'completed': 'pending',
      };
    }).toList();
  }
  final Map<int, List<dynamic>> _exerciseDays = {};

  Future<Map<String, dynamic>> getExerciseData(
      BuildContext context,
      int patientId,
      ) async {
    final dashboardData = await getDashboardDataForProfile(context, patientId);

    print("✅ Extracted DashboardData => $dashboardData");

    return {
      'exerciseDays': dashboardData['exerciseDays'] ?? [],
      'myoPoints': dashboardData['myoPoints'] ?? 0,
      'progress': dashboardData['progressPercent'] ?? 0,
      'rank': dashboardData['rank'] ?? 0,
      'avatar': dashboardData['profileImage'] ?? "",
    };
  }




  Future<void> getDashboardForAllProfiles(
    BuildContext context,
    List<Map<String, dynamic>> allProfiles,
  ) async {
    for (final profile in allProfiles) {
      final int profileId = profile['profileId'];

      final data = await getExerciseData(context, profileId);

      print("✅ Saving for profileId=$profileId  myo=${data['myoPoints']} rank=${data['rank']} progress=${data['progress']}");

      if (mounted) {
        setState(() {
          _exerciseDays[profileId] = data['exerciseDays'] ?? [];
          _myoPoints[profileId] = data['myoPoints'] ?? 0;
          _progress[profileId] = data['progress'] ?? 0;
          _rank[profileId] = data['rank'] ?? 0;
          _avatar[profileId] = data['avatar'];
        });
      }
    }

  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = Provider.of<SessionProvider>(context, listen: false);
      final userData = session.userData;
      final profileId = userData?['profileId'];
      final familyMembers = userData?['familyMembers'] ?? [];

      // Combine current user and family members into a deduplicated allProfiles list
      final Map<int, Map<String, dynamic>> profileMap = {};

      if (session.isPatient == true && profileId != null) {
        profileMap[profileId] = {
          'profileId': profileId,
          'userProfileName': userData?['userProfileName'] ?? 'Me',
        };
      }

      for (var member in familyMembers) {
        final int id = member['profileId'];
        profileMap[id] = member;
      }

      final allProfiles = profileMap.values.toList();

      if (allProfiles.isNotEmpty) {
        getDashboardForAllProfiles(context, allProfiles);
      }
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionProvider>(context);
    final userData = session.userData;
    final profileId = userData?['profileId'];
    final familyMembers = userData?['familyMembers'] ?? [];
    final notParent = !(familyMembers.length > 1);

    final Map<int, Map<String, dynamic>> profileMap = {};

    if (profileId != null && session.isPatient == true) {
      profileMap[profileId] = {
        'profileId': profileId,
        'userProfileName': userData?['userProfileName'] ?? 'Me',
      };
    }

    for (var member in familyMembers) {
      final int id = member['profileId'];
      profileMap[id] = member;
    }

    final allProfiles = profileMap.values.toList();

    if (allProfiles.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xffF6F5F3),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final int firstId = allProfiles[0]['profileId'];

    final bool isLoading = !_exerciseDays.containsKey(firstId) ||
        !_myoPoints.containsKey(firstId) ||
        !_progress.containsKey(firstId) ||
        !_rank.containsKey(firstId);

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xffF6F5F3),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF6F5F3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Column(
          children: allProfiles.map<Widget>((profile) {
            final int profileId = profile['profileId'];

            // ✅ CHANGE HERE
            final String profileName =
                profile['userProfileName'] ?? profile['profileName'] ?? '';

            return DashboardAccordion(
              profileName: profileName,
              base64Avatar: _avatar[profileId] ?? "",
              exerciseDays: _exerciseDays[profileId] ?? [],
              myoPoints: _myoPoints[profileId] ?? 0,
              rank: _rank[profileId] ?? 0,
              notParent: notParent,
              progress: _progress[profileId] ?? 0,
            );
          }).toList(),

        ),
      ),
    );
  }

}
