import 'package:flutter/material.dart';
import 'package:scale_button/scale_button.dart';

import '../../../components/components_path.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  bool newTicket= false;
  bool selectedTicket = false;
  bool reply = false;
  List<String> messages = [
    "Users original message","Message from support","User message","Message from support","User message"
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          children: [
            if(reply) Expanded(
              child: Card(elevation: 5,surfaceTintColor: Color(0xffD2D4D7),color: Color(0xffD2D4D7),shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20))),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: Text("Reply",textAlign: TextAlign.center,style: TextStyle(fontFamily: "Alegreya_Sans",fontSize: 28,color: Colors.black),))
                        ],
                      ),
                      SizedBox(height: 5,),
                      Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: Text("Please describe the issue",textAlign: TextAlign.start,style: TextStyle(fontFamily: "Alegreya_Sans",fontSize: 18,color: Colors.black,fontWeight: FontWeight.w400),))
                        ],
                      ),
                      SizedBox(height: 5,),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(blurRadius: 4,offset: Offset(0, 4),color: Colors.black.withOpacity(0.25))
                          ],color: Colors.white,border: Border.all(color: Color(0xffAFB7AC),width: 1),borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(expands: true,maxLines: null,minLines: null,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                    ],
                  ),
                ),
              ),
            )
            else if(selectedTicket) Expanded(
        child: Card(elevation: 5,surfaceTintColor: Color(0xffD2D4D7),color: Color(0xffD2D4D7),shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20))),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Text("Ticket #655467",textAlign: TextAlign.center,style: TextStyle(fontFamily: "Alegreya_Sans",fontSize: 28,color: Colors.black),))
                ],
              ),
              SizedBox(height: 5,),
              Expanded(
                child: ListView.separated(itemCount: 5,itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(blurRadius: 4,offset: Offset(0, 4),color: Colors.black.withOpacity(0.25))
                    ],color: Colors.white,border: Border.all(color: Color(0xffAFB7AC),width: 1),borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(messages[index],textAlign: TextAlign.start,style: TextStyle(fontFamily: "Alegreya_Sans",fontSize: 18,color: Colors.black),),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }, separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    height: 11,
                  );
                },),
              ),
              SizedBox(height: 20,),


            ],
          ),
        ),
      ),
    )
          else  if(newTicket) Expanded(
        child: Card(elevation: 5,surfaceTintColor: Color(0xffD2D4D7),color: Color(0xffD2D4D7),shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20))),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Text("New Ticket",textAlign: TextAlign.center,style: TextStyle(fontFamily: "Alegreya_Sans",fontSize: 28,color: Colors.black),))
                ],
              ),
              SizedBox(height: 5,),

              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Text("Subject",textAlign: TextAlign.start,style: TextStyle(fontFamily: "Alegreya_Sans",fontSize: 18,color: Colors.black,fontWeight: FontWeight.w400),))
                ],
              ),
              SizedBox(height: 5,),
              Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(blurRadius: 4,offset: Offset(0, 4),color: Colors.black.withOpacity(0.25))
                ],color: Colors.white,border: Border.all(color: Color(0xffAFB7AC),width: 1),borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Text("Please describe the issue",textAlign: TextAlign.start,style: TextStyle(fontFamily: "Alegreya_Sans",fontSize: 18,color: Colors.black,fontWeight: FontWeight.w400),))
                ],
              ),
              SizedBox(height: 5,),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(blurRadius: 4,offset: Offset(0, 4),color: Colors.black.withOpacity(0.25))
                  ],color: Colors.white,border: Border.all(color: Color(0xffAFB7AC),width: 1),borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(expands: true,maxLines: null,minLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),

            ],
          ),
        ),
      ),
    )
            else
              Expanded(
              child: Card(elevation: 5,surfaceTintColor: Color(0xffD2D4D7),color: Color(0xffD2D4D7),shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20))),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: Text("Support",textAlign: TextAlign.center,style: TextStyle(fontFamily: "Alegreya_Sans",fontSize: 28,color: Colors.black),))
                        ],
                      ),
                      SizedBox(height: 5,),
                      Expanded(
                        child: ListView.separated(itemCount: 5,itemBuilder: (context, index) {
                          return ScaleButton(onTap: (){
                            setState(() {
                              selectedTicket = true;
                            });
                          },
                            child: Container(
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(blurRadius: 4,offset: Offset(0, 4),color: Colors.black.withOpacity(0.25))
                              ],color: Colors.white,border: Border.all(color: Color(0xffAFB7AC),width: 1),borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(flex: 7,
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text("Ticket Subject",textAlign: TextAlign.start,style: TextStyle(fontFamily: "Alegreya_Sans",fontSize: 18,color: Colors.black),),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text("Ticket Short Description",textAlign: TextAlign.start,style: TextStyle(fontFamily: "Alegreya_Sans",fontSize: 18,color: Colors.black),),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  index>2?Expanded(flex: 1 ,
                                    child: Container(decoration: BoxDecoration(shape: BoxShape.circle,color: Colors.black38),child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Image.asset(EXERCISE_CHECK),
                                    )),
                                  ):Expanded(flex: 2,
                                    child: Row(
                                      children: [
                                        Expanded(flex: 1,child: ScaleButton(onTap: (){

                                        },child: Image.asset(REPLY_ICON))),
                                        Expanded(flex: 1,child: index>0?SizedBox():Image.asset(DOT_COLORED)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ),
                          );
                        }, separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            height: 11,
                          );
                        },),
                      ),
                      SizedBox(height: 20,),

                    ],
                  ),
                ),
              ),
            ),
            if(reply)
              Row(mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: ScaleButton(onTap: (){
                        showComplete();
                      },child: Image.asset(SUPPORT_SAVE_BTN)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: ScaleButton(onTap: (){
                        setState(() {
                          reply = false;
                        });
                      },child: Image.asset(EXERCISE_VIEW_CANCEL_BTN)),
                    ),
                  ),],
              )
            else if(selectedTicket)
              Row(mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: ScaleButton(onTap: (){
                        setState(() {
                          selectedTicket = false;
                        });
                      },child: Image.asset(EXERCISE_VIEW_OK_BTN)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: ScaleButton(onTap: (){
                        setState(() {
                          reply = true;
                        });
                      },child: Image.asset(REPLY_BTN)),
                    ),
                  ),],
              )
            else if(newTicket)
              Row(mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: ScaleButton(onTap: (){
                        showComplete();
                      },child: Image.asset(EXERCISE_VIEW_SUBMIT_BTN)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: ScaleButton(onTap: (){
                        setState(() {
                          newTicket = false;
                        });
                      },child: Image.asset(EXERCISE_VIEW_CANCEL_BTN)),
                    ),
                  ),],
              )
              else
              Padding(
              padding: const EdgeInsets.only(left: 25),
              child: ScaleButton(onTap: (){
                setState(() {
                  newTicket = true;
                });
              },child: Image.asset(NEW_TICKET_BTN)),
            ),
          ],
        ),
      ),
    );
  }

  void showComplete(){
    showDialog(context: context, builder: (context){
      return Dialog(surfaceTintColor: Colors.transparent,backgroundColor: Colors.transparent,
        child: Column(mainAxisAlignment: MainAxisAlignment.center,mainAxisSize: MainAxisSize.min,
          children: [
            Container(decoration: BoxDecoration(image: DecorationImage(image: AssetImage(SUCCESS_CONTAINER),fit: BoxFit.fill)),
              child: Padding(
                padding: const EdgeInsets.only(left: 20,right: 20,top: 20),
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: Text("Success",textAlign: TextAlign.center,style: TextStyle(fontFamily: "Alegreya_Sans",fontSize: 28,color: Colors.black),)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: Text("Thank you for your request, we’ll be in touch shortly.",style: TextStyle(fontFamily: "Alegreya_Sans",fontSize: 24,color: Color(0xff676767)),)),
                          ],
                        )),
                        Column(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(height: 30,DOT_COLORED),
                            Image.asset(height: 30,DOT_WHITE),
                            Image.asset(height: 30,DOT_COLORED),
                            Image.asset(height: 30,DOT_WHITE),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: ScaleButton(onTap: (){
                        Navigator.pop(context);
                      },child: Image.asset(EXERCISE_VIEW_OK_BTN,fit: BoxFit.cover,)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
