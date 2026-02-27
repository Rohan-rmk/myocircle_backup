import 'package:flutter/material.dart';
import 'package:myocircle15screens/components/components_path.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomNavBar({Key? key, required this.selectedIndex, required this.onTap}) : super(key: key);

  @override 
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashFactory: NoSplash.splashFactory,  // Removes ripple effect
        highlightColor: Colors.transparent,),
      child: BottomNavigationBar(showSelectedLabels: false,showUnselectedLabels: false,type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,backgroundColor: Colors.transparent,elevation: 0,
        onTap: onTap,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [

          BottomNavigationBarItem(label: 'dashboard',
            icon:  LayoutBuilder(
                builder: (context,constraints) {
                  return Container(width: constraints.maxWidth,child: Padding(
                    padding: EdgeInsets.only(right: constraints.maxWidth-constraints.maxWidth*0.85),
                    child: Image.asset(NAV_DASHBOARD,fit: BoxFit.contain,),
                  ));
                }
            ),
          ),
          BottomNavigationBarItem(label: 'patients',
            icon:  LayoutBuilder(
                builder: (context,constraints) {
                  return Container(width: constraints.maxWidth,child: Padding(
                    padding: EdgeInsets.only(right: constraints.maxWidth-constraints.maxWidth*0.85),
                    child: Image.asset(NAV_PATIENTS,fit: BoxFit.contain,),
                  ));
                }
            ),
          ),
          BottomNavigationBarItem(label: 'videos',
            icon:  LayoutBuilder(
                builder: (context,constraints) {
                  return Container(width: constraints.maxWidth,child: Image.asset(NAV_VIDEOS,fit: BoxFit.contain,));
                }
            ),
          ),
          BottomNavigationBarItem(label: 'review',
            icon:  LayoutBuilder(
                builder: (context,constraints) {
                  return Container(width: constraints.maxWidth,child: Padding(
                    padding: EdgeInsets.only(left: constraints.maxWidth-constraints.maxWidth*0.85),
                    child: Image.asset(NAV_REVIEW,fit: BoxFit.contain,),
                  ));
                }
            ),
          ),
        ],
      ),
    );
  }
}