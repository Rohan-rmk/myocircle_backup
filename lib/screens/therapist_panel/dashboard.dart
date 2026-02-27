import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../components/components_path.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(flex: 1,
            child: Column(
              children: [
                Expanded(child: Text("DASHBOARD",style: TextStyle(fontFamily: "Alegreya_Sans",color: Colors.black,fontSize: screenWidth/15),)),
                Expanded(child: Text("Welcome DR. Roshan",style: TextStyle(fontFamily: "Alegreya_Sans",color: Colors.black,fontSize: screenWidth/23),)),

              ],
            ),
          ),
        Expanded(flex: 10,
          child: GridView(physics: NeverScrollableScrollPhysics(),gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,mainAxisExtent: screenHeight/6),children: [
            LayoutBuilder(
              builder: (context,constraints) {
                return DashboardItem(title: "Active Patients",imageText: "6",constraints:constraints);
              }
            ),
            LayoutBuilder(
              builder: (context,constraints) {
                return DashboardItem(title: "Available Seats",imageText: "3",constraints:constraints);
              }
            ),
            LayoutBuilder(
              builder: (context,constraints) {
                return DashboardItem(title: "Upcoming Prescriptions",imageText: "4",constraints:constraints);
              }
            ),
            LayoutBuilder(
              builder: (context,constraints) {
                return DashboardItem(title: "Non-Performing Patients",imageText: "2",constraints:constraints);
              }
            ),
            LayoutBuilder(
              builder: (context,constraints) {
                return DashboardItem(title: "My Score",imageText: "275",constraints:constraints);
              }
            ),
            LayoutBuilder(
              builder: (context,constraints) {
                return DashboardItem(title: "Rewards",imageText: "50",constraints:constraints);
              }
            ),
            LayoutBuilder(
                builder: (context,constraints) {
                  return Stack(alignment: Alignment.center,fit: StackFit.expand,
                    children: [
                      Image.asset(COIN_CONTAINER,fit: BoxFit.contain,),
                      Container(alignment: Alignment.center,child: Text("TEST PATIENT",style: TextStyle(fontFamily: "Alegreya_SC",color: Colors.white,fontSize: constraints.maxHeight/11.5),)),
                    ],
                  );
                }
            ),
            LayoutBuilder(
                builder: (context,constraints) {
                  return Stack(alignment: Alignment.center,fit: StackFit.expand,
                    children: [
                      Image.asset(COIN_CONTAINER,fit: BoxFit.contain,),
                      Container(alignment: Alignment.center,child: Text("SPECIALIST",style: TextStyle(fontFamily: "Alegreya_SC",color: Colors.white,fontSize: constraints.maxHeight/11.5),)),
                    ],
                  );
                }
            ),
          ],),
        )
        ],
      ),
    );
  }
}


class DashboardItem extends StatelessWidget {
  final String imageText;
  final String title;
  final BoxConstraints constraints;

  const DashboardItem({
    Key? key,
    required this.imageText, required this.title, required this.constraints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center,fit: StackFit.expand,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Stack(alignment: Alignment.center,fit: StackFit.expand,
            children: [
              Image.asset(COIN_CONTAINER,fit: BoxFit.contain,),
              Container(alignment: Alignment.center,child: Text(imageText,style: TextStyle(fontFamily: "Alegreya_SC",color: Colors.white,fontSize: constraints.maxHeight/3.5),)),
            ],
          ),
        ),
        Positioned(bottom: 0,child: Text(title,style: TextStyle(fontFamily: "Alegreya_Sans",color: Colors.black,fontSize: constraints.maxHeight/10),)),
      ],
    );
  }
}
