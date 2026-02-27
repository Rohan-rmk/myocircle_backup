import 'package:flutter/material.dart';
import 'package:myocircle15screens/components/components_path.dart';
import 'package:scale_button/scale_button.dart';
import '../../enums/patient_tab.dart';

class PatientsCustomNavBar extends StatelessWidget {
  final List<PatientTab> visibleTabs;
  final PatientTab currentTab;
  final Function(PatientTab) onTabSelected;

  const PatientsCustomNavBar({
    required this.visibleTabs,
    required this.currentTab,
    required this.onTabSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: visibleTabs.map((tab) {
        return Expanded(
          flex: 1,
          child: ScaleButton(
            onTap: () => onTabSelected(tab),
            child: Image.asset(getTabIcon(tab), width: double.infinity),
          ),
        );
      }).toList(),
    );
  }

  String getTabIcon(PatientTab tab) {
    switch (tab) {
      case PatientTab.home:
        return HOME_ICON;
      case PatientTab.dashboard:
        return DASHBOARD_ICON;
      case PatientTab.leaderboard:
        return LEADERBOARD_ICON;
      case PatientTab.exercise:
        return EXERCISE_ICON;
      case PatientTab.messages:
        return MESSAGES_ICON;
      case PatientTab.report:
        return REPORT_ICON;
    }
  }
}
