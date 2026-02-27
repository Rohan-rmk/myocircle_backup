import 'package:flutter/material.dart';
import 'package:myocircle15screens/screens/therapist_panel/patients_list_screen.dart';
import 'package:myocircle15screens/screens/therapist_panel/summary_screen.dart';

import '../../components/app_bar_row.dart';
import '../../components/components_path.dart';
import '../../components/nav_bar.dart';
import 'dashboard.dart';
import 'new_patient_screen.dart';


class TherapistMasterScreen extends StatefulWidget {
  const TherapistMasterScreen({super.key});

  @override
  State<TherapistMasterScreen> createState() => _TherapistMasterScreenState();
}

class _TherapistMasterScreenState extends State<TherapistMasterScreen> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage(BACKGROUND_THERAPIST), // Add image in assets folder
        fit: BoxFit.cover, // Covers the whole screen
      ),
    ),
      child: SafeArea(
        child: Scaffold(backgroundColor: Colors.transparent,
          bottomNavigationBar: CustomNavBar(selectedIndex: selectedIndex, onTap: (index){
          setState(() {
            selectedIndex = index;
          });
        }),
          body: Column(
            children: [
              Expanded(flex: 1,child: CustomAppBarRow(menuButton: (){

              },)),
              Expanded(flex: 9,child:
              Builder(
                  builder: (context) {
                    switch(selectedIndex){
                      case 0:
                        return DashboardScreen();
                      case 2:
                        return NewPatientScreen();
                      case 3:
                        return PatientSummaryScreen();
                      default:
                        return PatientsListScreen();

                    }
                  }
              ),),
            ],
          ),
        ),
      ),
    );
  }
}
