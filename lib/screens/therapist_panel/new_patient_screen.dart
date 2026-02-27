import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scale_button/scale_button.dart';
import '../../components/components_path.dart';
import '../../components/custom_circular_progress_indicator.dart';
import '../../components/custom_switch.dart';
import '../../components/custom_textfield.dart';

class NewPatientScreen extends StatefulWidget {
  const NewPatientScreen({super.key});

  @override
  State<NewPatientScreen> createState() => _NewPatientScreenState();
}

class _NewPatientScreenState extends State<NewPatientScreen> with TickerProviderStateMixin{
  @override
  void initState() {

    // TODO: implement initState
    super.initState();
  }

  final _controller = ValueNotifier<bool>(false);
  bool _isSwitchOn = false;
  final int textFHeightDivisor = 8;
  int selectedTab = 0;
  List<String> tabs = [
    "General","Medical History","Clinical Records","Diagnosis & Treatment","Progress Records","Prescription Builder","Communication","Patient Information",
  ];
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Expanded(flex: 1,
          child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("New Patient",style: TextStyle(fontFamily: "Alegreya_Sans",fontSize: screenWidth/18),),
            ],
          ),
        ),
        Expanded(flex: 1,
          child: ListView.builder(scrollDirection: Axis.horizontal,itemCount: tabs.length,itemBuilder: (context,index){
            return GestureDetector(onTap: (){
              setState(() {
                selectedTab = index;
              });
            },
              child: Container(padding: EdgeInsets.all(5),decoration: BoxDecoration(image: DecorationImage(image: selectedTab==index?AssetImage(NEW_PATIENT_CONTAINER2):AssetImage(NEW_PATIENT_CONTAINER1),fit: BoxFit.fill)),
                child: Center(child: Text(tabs[index],style: TextStyle(fontFamily: "Alegreya_Sans_SC",fontSize: screenHeight/50,fontWeight: FontWeight.w400),)),),
            );
          }),
        ),
        Expanded(flex: 14,
          child: Padding(
            padding: EdgeInsets.only(left: screenWidth/52,right: screenWidth/60),
            child: KeyboardVisibilityBuilder(
              builder: (context,isKeyboardOpen) {
                return Card(elevation: screenWidth/105,color: Color(0xffEEF2F0),
                  child: Align(alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        Expanded(flex: 13,
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Row(
                                      children: [
                                        Expanded(child: CustomTextField(textAlign: TextAlign.start,label: "First Name",readOnly: false,textFieldController: TextEditingController(text: "Amit"),size: screenHeight,maxLines: 1,)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Row(
                                      children: [
                                        Expanded(child: CustomTextField(textAlign: TextAlign.start,label: "Last Name",readOnly: false,textFieldController: TextEditingController(text: "Majumdar"),size: screenHeight,maxLines: 1,)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Row(
                                      children: [
                                        Expanded(flex: 2,child: SizedBox(height: screenWidth/textFHeightDivisor,child: CustomTextField(textAlign: TextAlign.start,label: "AGE",readOnly: false,textFieldController: TextEditingController(text: "28"),size: screenHeight,maxLines: 1,))),
                                        SizedBox(width: screenWidth/40,),
                                        Expanded(flex: 4,child: SizedBox(height: screenWidth/textFHeightDivisor,child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),border: Border.all(width: 1,color: Color(0xffAFB7AC)),boxShadow: [
                                          BoxShadow(offset: Offset(0, 4),blurRadius: screenWidth/105,color: Colors.black.withOpacity(0.25)),
                                        ]),
                                          child: ClipRRect(borderRadius: BorderRadius.circular(10),
                                            child: TextField(controller: TextEditingController(),style: TextStyle(
                                                fontSize: screenWidth/23.5,fontFamily: "Alegreya",color: Colors.black
                                            ),
                                              decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 5,vertical: 6),prefix: Row(mainAxisAlignment: MainAxisAlignment.center ,
                                                children: [
                                                  Text("M",style: TextStyle(
                                                      fontSize: screenWidth/23.5,fontFamily: "Alegreya",color: Colors.black
                                                  ),),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 4,right: 4),
                                                    child: CustomSwitch(value: _isSwitchOn, onChanged: (value){
                              
                                                    }),
                                                  ),
                                                  Text("F",style: TextStyle(
                                                      fontSize: screenWidth/23.5,fontFamily: "Alegreya",color: Colors.black
                                                  ),),
                                                ],
                                              ),filled: true,fillColor: Colors.white,label: Text("GENDER",style: TextStyle(
                                                  fontSize: screenWidth/23.5,color: Colors.black,fontWeight: FontWeight.w600,fontFamily: "Alegreya_Sans_SC"
                                              ),),floatingLabelAlignment: FloatingLabelAlignment.start,
                                                border: InputBorder.none,floatingLabelBehavior: FloatingLabelBehavior.always,
                                              ),
                                            ),
                                          ),
                                        ))),
                                        SizedBox(width: screenWidth/40,),
                                        Expanded(flex: 5,child: SizedBox(height: screenWidth/textFHeightDivisor,child: CustomTextField(textAlign: TextAlign.start,label: "DOB",readOnly: false,textFieldController: TextEditingController(text: "1990-12-25"),size: screenHeight,maxLines: 1,))),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Row(
                                      children: [
                                        Expanded(child: CustomTextField(textAlign: TextAlign.start,label: "Email",readOnly: false,textFieldController: TextEditingController(text: " "),size: screenHeight,maxLines: 1,)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Row(
                                      children: [
                                        Expanded(child: CustomTextField(textAlign: TextAlign.start,label: "Phone",readOnly: false,textFieldController: TextEditingController(text: "8388388388"),size: screenHeight,maxLines: 1,)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Row(
                                      children: [
                                        Expanded(child: CustomTextField(textAlign: TextAlign.start,label: "Referred By",readOnly: false,textFieldController: TextEditingController(text: "Dr. AK"),size: screenHeight,maxLines: 1,)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Row(
                                      children: [
                                        Expanded(child: CustomTextField(textAlign: TextAlign.start,label: "Diagnosis",readOnly: false,textFieldController: TextEditingController(text: "Mouth Breathing & TMJ disorder"),size: screenHeight,maxLines: 3,)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Row(
                                      children: [
                                        Expanded(child: CustomTextField(textAlign: TextAlign.start,label: "Treatment Duration",readOnly: false,textFieldController: TextEditingController(text: "6 Weeks"),size: screenHeight,maxLines: 1,)),
                                      ],
                                    ),
                                  ),
                              
                                ],
                              ),
                            ),
                          ),
                        ),

                        Expanded(flex: 2,
                          child: Row(
                            children: [
                              Expanded(flex: 2,child: ScaleButton(child: Image.asset(NEW_PATIENT_CONTINUE_BTN,fit: BoxFit.cover,))),
                              Expanded(flex: 2,child: ScaleButton(child: Image.asset(PRESCRIPTION_BTN,fit: BoxFit.cover,))),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            ),
          ),
        ),
      ],
    );
  }
}

