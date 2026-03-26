import '../enums/patient_tab.dart';

class TabVisibilityUtil {
  static List<PatientTab> getTabs({
    required final patientStatus,
    required int age,
    required String screenName,
  }) {
    // Determine if patient is minor or adult
    bool isMinor = age < 18;
    if (patientStatus == 'inactive') {
      if (isMinor) {
        return [
          PatientTab.report,
        ];
      } else {
        return [PatientTab.report, PatientTab.messages];
      }
    }

    if (isMinor) {
      switch (screenName) {
        case "PatientDashboardScreen":
          return [
            PatientTab.home,
            PatientTab.exercise,
            PatientTab.report,
            PatientTab.leaderboard,
          ];
        default:
          return [
            PatientTab.home,
            PatientTab.exercise,
            PatientTab.dashboard,
            PatientTab.leaderboard,
          ];
      }
    }

    switch (screenName) {
      case "PatientHomeScreen":
        return [
          PatientTab.home,
          PatientTab.leaderboard,
          PatientTab.dashboard,
          PatientTab.messages,
        ];
      case "PatientScoreScreen":
        return [
          PatientTab.home,
          PatientTab.exercise,
          PatientTab.dashboard,
          PatientTab.messages,
        ];
      case "PatientDashboardScreen":
        return [
          PatientTab.home,
          PatientTab.exercise,
          PatientTab.leaderboard,
          PatientTab.messages,
        ];
      case "PatientExercisesScreen":
        return [
          PatientTab.home,
          PatientTab.leaderboard,
          PatientTab.dashboard,
          PatientTab.messages,
        ];
      case "PatientMessagesScreen":
        return [
          PatientTab.home,
          PatientTab.exercise,
          PatientTab.leaderboard,
          PatientTab.dashboard,
        ];
      case "PatientReportScreen":
        return [
          PatientTab.home,
          PatientTab.exercise,
          PatientTab.leaderboard,
          PatientTab.messages,
        ];
      default:
        return [
          PatientTab.home,
          PatientTab.exercise,
          PatientTab.leaderboard,
          PatientTab.dashboard,
        ];
    }
  }

  static PatientTab getTabByIndex(int index) {
    return PatientTab.values[index];
  }

  static int getIndexByTab(PatientTab tab) {
    return PatientTab.values.indexOf(tab);
  }

  // static String getScreenNameFromTab(PatientTab tab) {
  //   switch (tab) {
  //     case PatientTab.home:
  //       return "PatientHomeScreen";
  //     case PatientTab.leaderboard:
  //       return "PatientScoreScreen";
  //     case PatientTab.dashboard:
  //       return "PatientDashboardScreen";
  //     case PatientTab.messages:
  //       return "PatientMessagesScreen";
  //     case PatientTab.exercise:
  //       return "PatientExercisesScreen";
  //     case PatientTab.report:
  //       return "PatientReportScreen";
  //   }
  // }
///
  static String getScreenNameFromTab(PatientTab tab) {
    switch (tab) {
      case PatientTab.home:
        return "PatientHomeScreen";

      case PatientTab.leaderboard:
        return "PatientScoreScreen";

      case PatientTab.dashboard:
        return "PatientDashboardScreen";

      case PatientTab.messages:
        return "PatientMessagesScreen";

      case PatientTab.exercise:
        return "PatientExercisesScreen";

      case PatientTab.report:
        return "PatientReportScreen";

      case PatientTab.resetPin:
        return "ResetPinScreen";

      case PatientTab.changeAvatar:
        return "ChangeAvatarScreen";

      case PatientTab.therapist:
        return "MyTherapistScreen";
    }
  }
///
}
