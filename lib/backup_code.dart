// // import 'dart:async';
// // import 'dart:math';
// // import 'dart:math' as math;
// // import 'package:cached_video_player_plus/cached_video_player_plus.dart';
// // import 'package:video_player/video_player.dart';
// // import 'package:camera/camera.dart';
// // import 'package:confetti/confetti.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:myocircle15screens/components/custom_circular_counter.dart';
// // import 'package:myocircle15screens/main.dart';
// // import 'package:permission_handler/permission_handler.dart';
// // import 'package:provider/provider.dart';
// // import 'package:scale_button/scale_button.dart';
// //
// // import '../../components/components_path.dart';
// // import '../../providers/index_provider.dart';
// // import '../../providers/session_provider.dart';
// // import '../../services/api_service.dart';
// // import '../../services/applife_cycle_manager.dart';
// //
// // class ExerciseViewScreen extends StatefulWidget {
// //   final List<dynamic> exercises;
// //
// //   const ExerciseViewScreen({
// //     super.key,
// //     required this.exercises,
// //   });
// //
// //   @override
// //   State<ExerciseViewScreen> createState() => _ExerciseViewScreenState();
// // }
// //
// // class _ExerciseViewScreenState extends State<ExerciseViewScreen> {
// //   // Play/Pause functionality variables
// //   bool isPlaying = true;
// //   bool showOverlay = false;
// //   Timer? _overlayTimer;
// //   int selected = 0;
// //
// //   bool _showNextExerciseOverlay = false;
// //   int _nextExerciseCountdown = 5;
// //   Timer? _nextExerciseTimer;
// //   void _startNextExerciseCountdown(VoidCallback onFinish) {
// //     _nextExerciseTimer?.cancel();
// //
// //     setState(() {
// //       _showNextExerciseOverlay = true;
// //       _nextExerciseCountdown = 5;
// //     });
// //
// //     _nextExerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
// //       if (_nextExerciseCountdown == 1) {
// //         timer.cancel();
// //         _hideNextExerciseOverlay();
// //         onFinish();
// //       } else {
// //         setState(() {
// //           _nextExerciseCountdown--;
// //         });
// //       }
// //     });
// //   }
// //
// //   void _hideNextExerciseOverlay() {
// //     _nextExerciseTimer?.cancel();
// //     setState(() {
// //       _showNextExerciseOverlay = false;
// //     });
// //   }
// //
// //   bool _repHandled = false;
// //
// //   void _togglePlayPause() {
// //     if (!_videoReady || !_videoController.isInitialized) return;
// //
// //     setState(() {
// //       isPlaying = !isPlaying;
// //       showOverlay = !isPlaying;
// //     });
// //
// //     if (isPlaying) {
// //       _videoController.controller.play();
// //       _showOverlay();
// //     } else {
// //       _videoController.controller.pause();
// //       _cancelTimer();
// //     }
// //   }
// //
// //   void _showOverlay() {
// //     if (isPlaying) {
// //       setState(() {
// //         showOverlay = true;
// //       });
// //
// //       _cancelTimer();
// //       _overlayTimer = Timer(const Duration(seconds: 3), () {
// //         if (mounted && isPlaying) {
// //           setState(() {
// //             showOverlay = false;
// //           });
// //         }
// //       });
// //     }
// //   }
// //
// //   void _hideOverlay() {
// //     if (showOverlay) {
// //       setState(() {
// //         showOverlay = false;
// //       });
// //       _cancelTimer();
// //     }
// //   }
// //
// //   void _cancelTimer() {
// //     if (_overlayTimer != null) {
// //       _overlayTimer!.cancel();
// //       _overlayTimer = null;
// //     }
// //   }
// //
// //   bool _isSubmitting = false;
// //
// //   void _handleScreenTap() {
// //     if (isPlaying) {
// //       if (showOverlay) {
// //         _hideOverlay();
// //       } else {
// //         _showOverlay();
// //       }
// //     } else {
// //       setState(() {
// //         showOverlay = !showOverlay;
// //       });
// //       _cancelTimer();
// //     }
// //   }
// //
// //   bool _isCompletionDialogOpen = false;
// //
// //   void onComplete() {
// //     _videoController.controller.pause();
// //
// //     if (_isCompletionDialogOpen) return;
// //
// //     _isCompletionDialogOpen = true;
// //
// //     // ✅ Stop video before showing dialog
// //     if (_videoReady && _videoController.isInitialized) {
// //       _videoController.controller.pause();
// //     }
// //
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (dialogContext) {
// //         bool isDialogSubmitting = false;
// //
// //         return StatefulBuilder(
// //           builder: (context, setDialogState) {
// //             return Dialog(
// //               backgroundColor: Colors.transparent,
// //               surfaceTintColor: Colors.transparent,
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   // ✅ COMPLETE BUTTON
// //                   ScaleButton(
// //                     onTap: isDialogSubmitting
// //                         ? null
// //                         : () async {
// //                       setDialogState(() => isDialogSubmitting = true);
// //
// //                       // ✅ close dialog instantly
// //                       Navigator.pop(dialogContext);
// //
// //                       // ✅ API call
// //                       await sendExerciseResponse(false, 0);
// //                     },
// //                     child: Opacity(
// //                       opacity: isDialogSubmitting ? 0.4 : 1,
// //                       child: Container(
// //                         height: 140,
// //                         width: 140,
// //                         padding: const EdgeInsets.all(10),
// //                         decoration: BoxDecoration(
// //                           color: Colors.white,
// //                           borderRadius: BorderRadius.circular(25),
// //                           boxShadow: [
// //                             BoxShadow(
// //                               color: Colors.black.withOpacity(.3),
// //                               blurRadius: 4.0,
// //                               spreadRadius: 1.0,
// //                               offset: const Offset(0.0, 2.0),
// //                             ),
// //                           ],
// //                           border: const Border(
// //                             left: BorderSide(color: Color(0xff1F8C85), width: 4),
// //                           ),
// //                         ),
// //                         child: Column(
// //                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                           children: const [
// //                             Icon(Icons.check_circle_rounded,
// //                                 size: 50, color: Color(0xff1F8C85)),
// //                             Text(
// //                               "Complete",
// //                               style: TextStyle(
// //                                 fontFamily: "Alegreya_Sans",
// //                                 fontSize: 22,
// //                                 fontWeight: FontWeight.w500,
// //                               ),
// //                             )
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //
// //                   const SizedBox(width: 32),
// //
// //                   // ✅ NEED HELP BUTTON
// //                   ScaleButton(
// //                     onTap: isDialogSubmitting
// //                         ? null
// //                         : () {
// //                       setDialogState(() => isDialogSubmitting = true);
// //                       Navigator.pop(dialogContext);
// //                       completeExercise2().then((submitted) {
// //                         if (!mounted) return;
// //
// //                         setState(() {
// //                           selected = 0;
// //                         });
// //
// //                         _isCompletionDialogOpen = false;
// //
// //                         if (submitted == false) {
// //                           // user cancelled → reopen main dialog ONCE
// //                           onComplete();
// //                         }
// //                       });
// //
// //
// //
// //                     },
// //                     child: Opacity(
// //                       opacity: isDialogSubmitting ? 0.4 : 1,
// //                       child: Container(
// //                         height: 140,
// //                         width: 140,
// //                         padding: const EdgeInsets.all(10),
// //                         decoration: BoxDecoration(
// //                           color: Colors.white,
// //                           borderRadius: BorderRadius.circular(25),
// //                           boxShadow: [
// //                             BoxShadow(
// //                               color: Colors.black.withOpacity(.3),
// //                               blurRadius: 4.0,
// //                               spreadRadius: 1.0,
// //                               offset: const Offset(0.0, 2.0),
// //                             ),
// //                           ],
// //                           border: const Border(
// //                             left: BorderSide(width: 4, color: Color(0xff3197DB)),
// //                           ),
// //                         ),
// //                         child: Column(
// //                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                           children: const [
// //                             Icon(Icons.cancel_rounded,
// //                                 size: 50, color: Color(0xff3197DB)),
// //                             Text(
// //                               "I need help",
// //                               style: TextStyle(
// //                                 fontFamily: "Alegreya_Sans",
// //                                 fontSize: 22,
// //                                 fontWeight: FontWeight.w500,
// //                               ),
// //                             )
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             );
// //           },
// //         );
// //       },
// //     ).then((_) {
// //       // ✅ Allow dialog again after close
// //       _isCompletionDialogOpen = false;
// //     });
// //   }
// //
// //   void completeExercise() {
// //     showDialog(
// //         context: context,
// //         builder: (context) {
// //           return Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Container(
// //                 decoration: BoxDecoration(
// //                     image: DecorationImage(
// //                         image: AssetImage(
// //                           EXERCISE_VIEW_CONTAINER1,
// //                         ),
// //                         fit: BoxFit.fill)),
// //                 child: Padding(
// //                   padding: const EdgeInsets.all(20),
// //                   child: Stack(
// //                     alignment: Alignment.center,
// //                     children: [
// //                       Column(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.center,
// //                             children: [
// //                               Expanded(
// //                                   child: Text(
// //                                     "Complete your Exercise",
// //                                     textAlign: TextAlign.center,
// //                                     style: TextStyle(
// //                                         fontFamily: "Alegreya_Sans", fontSize: 28),
// //                                   )),
// //                             ],
// //                           ),
// //                           Row(children: [
// //                             Expanded(
// //                                 flex: 8,
// //                                 child: Text(
// //                                   "Your exercise will only be marked as complete after you select the tick or cross to give your feedback.",
// //                                   style: TextStyle(
// //                                       fontFamily: "Alegreya_Sans",
// //                                       fontSize: 28),
// //                                 )),
// //                             Expanded(
// //                               flex: 1,
// //                               child: Column(
// //                                 mainAxisAlignment: MainAxisAlignment.center,
// //                                 children: [
// //                                   Image.asset(height: 40, DOT_COLORED),
// //                                   Image.asset(height: 40, DOT_WHITE),
// //                                   Image.asset(height: 40, DOT_COLORED),
// //                                   Image.asset(height: 40, DOT_WHITE),
// //                                 ],
// //                               ),
// //                             ),
// //                           ]),
// //                           Padding(
// //                             padding: const EdgeInsets.only(left: 25),
// //                             child: Image.asset(EXERCISE_VIEW_OK_BTN),
// //                           ),
// //                         ],
// //                       ),
// //                       Positioned(
// //                           right: 10,
// //                           top: 10,
// //                           child: Image.asset(EXERCISE_VIEW_CLOSE_BTN)),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           );
// //         });
// //   }
// //
// //   void markEachExercise() {
// //     showDialog(
// //         context: context,
// //         builder: (context) {
// //           return Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Container(
// //                 decoration: BoxDecoration(
// //                     image: DecorationImage(
// //                         image: AssetImage(
// //                           EXERCISE_VIEW_CONTAINER1,
// //                         ),
// //                         fit: BoxFit.fill)),
// //                 child: Padding(
// //                   padding: const EdgeInsets.all(20),
// //                   child: Stack(
// //                     alignment: Alignment.center,
// //                     children: [
// //                       Column(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.center,
// //                             children: [
// //                               Expanded(
// //                                   child: Text(
// //                                     "",
// //                                     textAlign: TextAlign.center,
// //                                     style: TextStyle(
// //                                         fontFamily: "Alegreya_Sans", fontSize: 28),
// //                                   )),
// //                             ],
// //                           ),
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.start,
// //                             children: [
// //                               Expanded(
// //                                   flex: 8,
// //                                   child: Text(
// //                                     "Mark each exercise with a ✓ or ✗ to complete your quest and unlock your next challenge!",
// //                                     style: TextStyle(
// //                                         fontFamily: "Alegreya_Sans",
// //                                         fontSize: 28),
// //                                   )),
// //                               Expanded(
// //                                 flex: 1,
// //                                 child: Column(
// //                                   mainAxisAlignment: MainAxisAlignment.start,
// //                                   children: [
// //                                     Image.asset(height: 40, DOT_COLORED),
// //                                     Image.asset(height: 40, DOT_WHITE),
// //                                     Image.asset(height: 40, DOT_COLORED),
// //                                     Image.asset(height: 40, DOT_WHITE),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                           Padding(
// //                             padding: const EdgeInsets.only(left: 25),
// //                             child: Image.asset(EXERCISE_VIEW_OK_BTN),
// //                           ),
// //                         ],
// //                       ),
// //                       Positioned(
// //                           right: 10,
// //                           top: 10,
// //                           child: Image.asset(EXERCISE_VIEW_CLOSE_BTN)),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           );
// //         });
// //   }
// //
// //   String getLoopProgressText() {
// //     final currentExercise =
// //     exerciseGroups[currentGroupIndex]['exercises'][currentExerciseIndex];
// //
// //     final loops = currentExercise['loopExercises'] as List<dynamic>;
// //     final totalLoops = loops.length;
// //
// //     final currentLoopNumber = currentLoopIndex + 1; // ✅ start from 1
// //
// //     return "$currentLoopNumber/$totalLoops";
// //   }
// //   String getExerciseProgressText() {
// //     final exercises =
// //     exerciseGroups[currentGroupIndex]['exercises'] as List<dynamic>;
// //
// //     final totalExercises = exercises.length;
// //     final currentExerciseNumber = currentExerciseIndex + 1;
// //
// //     return "$currentExerciseNumber/$totalExercises";
// //   }
// //
// //
// //   String getGroupExerciseProgressText() {
// //     final currentGroup = exerciseGroups[currentGroupIndex];
// //     final exercises = currentGroup['exercises'] as List<dynamic>;
// //
// //     final total = exercises.length;
// //
// //     final completed =
// //         exercises.where((e) => e['isExerciseComplete'] == true).length;
// //
// //     return "$completed/$total";
// //   }
// //
// //   Future<bool?> completeExercise2() {
// //     selected = 1;
// //     return showDialog<bool>(
// //         context: context,
// //         builder: (context) {
// //           return StatefulBuilder(builder: (context, set) {
// //             return Dialog(
// //               insetPadding: EdgeInsets.all(0),
// //               backgroundColor: Colors.transparent,
// //               surfaceTintColor: Colors.transparent,
// //               child: Container(
// //                 width: 320,
// //                 height: 320,
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(16),
// //                 ),
// //                 child: Padding(
// //                   padding: const EdgeInsets.all(20),
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: [
// //                       Expanded(
// //                         flex: 1,
// //                         child: Container(
// //                           alignment: Alignment.centerRight,
// //                           child: ScaleButton(
// //                               onTap: () {
// //                                 Navigator.pop(context);
// //                               },
// //                               child: Image.asset(EXERCISE_VIEW_CLOSE_BTN)),
// //                         ),
// //                       ),
// //                       Expanded(
// //                         flex: 5,
// //                         child: Row(
// //                           mainAxisSize: MainAxisSize.min,
// //                           children: [
// //                             Expanded(
// //                               flex: 8,
// //                               child: Column(
// //                                 children: [
// //                                   Expanded(
// //                                     child: LayoutBuilder(
// //                                         builder: (context, constraints) {
// //                                           return RadioListTile(
// //                                               visualDensity: VisualDensity.compact,
// //                                               dense: true,
// //                                               contentPadding: EdgeInsets.zero,
// //                                               activeColor: Color(0xff203EC3),
// //                                               title: Text(
// //                                                 "Tiring",
// //                                                 style: TextStyle(
// //                                                     fontFamily: "Alegreya_Sans",
// //                                                     fontSize:
// //                                                     constraints.maxHeight /
// //                                                         2.4),
// //                                               ),
// //                                               value: 1,
// //                                               groupValue: selected,
// //                                               onChanged: (value) {
// //                                                 set(() {
// //                                                   selected = value!;
// //                                                 });
// //                                               });
// //                                         }),
// //                                   ),
// //                                   Expanded(
// //                                     child: LayoutBuilder(
// //                                         builder: (context, constraints) {
// //                                           return RadioListTile(
// //                                               visualDensity: VisualDensity.compact,
// //                                               dense: true,
// //                                               contentPadding: EdgeInsets.zero,
// //                                               activeColor: Color(0xff203EC3),
// //                                               title: Text(
// //                                                 "Difficult",
// //                                                 style: TextStyle(
// //                                                     fontFamily: "Alegreya_Sans",
// //                                                     fontSize:
// //                                                     constraints.maxHeight /
// //                                                         2.4),
// //                                               ),
// //                                               value: 2,
// //                                               groupValue: selected,
// //                                               onChanged: (value) {
// //                                                 set(() {
// //                                                   selected = value!;
// //                                                 });
// //                                               });
// //                                         }),
// //                                   ),
// //                                   Expanded(
// //                                     child: LayoutBuilder(
// //                                         builder: (context, constraints) {
// //                                           return RadioListTile(
// //                                               visualDensity: VisualDensity.compact,
// //                                               dense: true,
// //                                               contentPadding: EdgeInsets.zero,
// //                                               activeColor: Color(0xff203EC3),
// //                                               title: Text(
// //                                                 "Painful",
// //                                                 style: TextStyle(
// //                                                     fontFamily: "Alegreya_Sans",
// //                                                     fontSize:
// //                                                     constraints.maxHeight /
// //                                                         2.4),
// //                                               ),
// //                                               value: 3,
// //                                               groupValue: selected,
// //                                               onChanged: (value) {
// //                                                 set(() {
// //                                                   selected = value!;
// //                                                 });
// //                                               });
// //                                         }),
// //                                   ),
// //                                   Expanded(
// //                                     child: LayoutBuilder(
// //                                         builder: (context, constraints) {
// //                                           return RadioListTile(
// //                                               visualDensity: VisualDensity.compact,
// //                                               dense: true,
// //                                               contentPadding: EdgeInsets.zero,
// //                                               activeColor: Color(0xff203EC3),
// //                                               title: Text(
// //                                                 "Need Help",
// //                                                 style: TextStyle(
// //                                                     fontFamily: "Alegreya_Sans",
// //                                                     fontSize:
// //                                                     constraints.maxHeight /
// //                                                         2.4),
// //                                               ),
// //                                               value: 4,
// //                                               groupValue: selected,
// //                                               onChanged: (value) {
// //                                                 set(() {
// //                                                   selected = value!;
// //                                                 });
// //                                               });
// //                                         }),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                             Expanded(
// //                               flex: 1,
// //                               child: Column(
// //                                 mainAxisAlignment: MainAxisAlignment.center,
// //                                 children: [
// //                                   Expanded(child: Image.asset(DOT_COLORED)),
// //                                   Expanded(child: Image.asset(DOT_WHITE)),
// //                                   Expanded(child: Image.asset(DOT_COLORED)),
// //                                   Expanded(child: Image.asset(DOT_WHITE)),
// //                                 ],
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       Expanded(
// //                         flex: 3,
// //                         child: Row(
// //                           mainAxisSize: MainAxisSize.min,
// //                           children: [
// //                             Expanded(
// //                               child: Padding(
// //                                 padding: const EdgeInsets.only(left: 25),
// //                                 child: ScaleButton(
// //                                     onTap: () async {
// //                                       Navigator.pop(context, true); // ✅ submitted
// //                                       await sendExerciseResponse(false, selected);
// //                                     },
// //                                     child:
// //                                     Image.asset(EXERCISE_VIEW_SUBMIT_BTN)),
// //                               ),
// //                             ),
// //                             Expanded(
// //                               child: Padding(
// //                                 padding: const EdgeInsets.only(left: 25),
// //                                 child: ScaleButton(
// //                                   onTap: () {
// //
// //                                     Navigator.pop(context, false); // ❌ cancelled
// //                                   },
// //                                   child: Image.asset(EXERCISE_VIEW_CANCEL_BTN),
// //                                 ),
// //
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             );
// //           });
// //         });
// //   }
// //
// //   void congratsLeaderboard(final response, String reason) {
// //     late ConfettiController _controller;
// //     _controller = ConfettiController(duration: const Duration(seconds: 2));
// //     _controller.play();
// //     int countdown = 10;
// //     Timer? timer;
// //
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (context) {
// //         final height = MediaQuery.of(context).size.height;
// //         return StatefulBuilder(
// //           builder: (context, setStateInner) {
// //             if (timer == null) {
// //               timer = Timer.periodic(Duration(seconds: 1), (t) {
// //                 if (countdown > 0) {
// //                   setStateInner(() {
// //                     countdown--;
// //                   });
// //                 } else {
// //                   t.cancel();
// //                   Provider.of<IndexProvider>(context, listen: false).setIndex(2);
// //                   resetOrientation();
// //                   if (_cameraController != null) _cameraController?.dispose();
// //                   Navigator.pushReplacement(
// //                       context,
// //                       MaterialPageRoute(
// //                           builder: (context) => BridgeScreen()));
// //                 }
// //               });
// //             }
// //
// //             return Dialog(
// //               backgroundColor: Colors.transparent,
// //               surfaceTintColor: Colors.transparent,
// //               child: Container(
// //                 width: MediaQuery.of(context).size.width / 2,
// //                 decoration: BoxDecoration(
// //                   image: DecorationImage(
// //                     image: AssetImage(EXERCISE_VIEW_CONTAINER2),
// //                     fit: BoxFit.fill,
// //                   ),
// //                 ),
// //                 child: Stack(
// //                   alignment: Alignment.center,
// //                   children: [
// //                     if (reason == "")
// //                       Positioned(
// //                         top: 0,
// //                         child: ConfettiWidget(
// //                           blastDirectionality: BlastDirectionality.explosive,
// //                           confettiController: _controller,
// //                           blastDirection: pi / 2,
// //                           emissionFrequency: 0.05,
// //                           maximumSize: Size(7, 7),
// //                           minimumSize: Size(4, 4),
// //                           numberOfParticles: 20,
// //                           maxBlastForce: 20,
// //                           minBlastForce: 10,
// //                           gravity: 0.3,
// //                           colors: [
// //                             Colors.red,
// //                             Colors.blue,
// //                             Colors.green,
// //                             Colors.orange,
// //                             Colors.purple,
// //                             Colors.pink,
// //                             Colors.yellow,
// //                             Colors.lightBlue,
// //                           ],
// //                         ),
// //                       ),
// //                     Padding(
// //                       padding: const EdgeInsets.all(20),
// //                       child: Padding(
// //                         padding: const EdgeInsets.only(left: 8, bottom: 9),
// //                         child: Column(
// //                           children: [
// //                             Expanded(child: Image.asset(EXERCISE_VIEW_AVATAR)),
// //                             reason == ""
// //                                 ? Text("Congratulations",
// //                                 style: TextStyle(
// //                                     fontFamily: "Alegreya_Sans",
// //                                     fontSize: height / 15))
// //                                 : Text("No Worries",
// //                                 style: TextStyle(
// //                                     fontFamily: "Alegreya_Sans",
// //                                     fontSize: height / 15)),
// //                             Text(
// //                               "Current Score: ${response['data']['score']} Points",
// //                               style: TextStyle(
// //                                   fontFamily: "Alegreya_Sans",
// //                                   fontSize: height / 23.5),
// //                             ),
// //                             SizedBox(height: 20),
// //                             Expanded(
// //                               child: ScaleButton(
// //                                 onTap: () {
// //                                   Provider.of<IndexProvider>(context,
// //                                       listen: false)
// //                                       .setIndex(2);
// //                                   resetOrientation();
// //                                   if (_cameraController != null)
// //                                     _cameraController?.dispose();
// //                                   Navigator.pushReplacement(
// //                                       context,
// //                                       MaterialPageRoute(
// //                                           builder: (context) =>
// //                                               BridgeScreen()));
// //                                 },
// //                                 child: Container(
// //                                   decoration: BoxDecoration(
// //                                     borderRadius: BorderRadius.circular(50),
// //                                     gradient: LinearGradient(
// //                                       colors: [
// //                                         Color(0xff59A3CB),
// //                                         Color(0xff116594),
// //                                       ],
// //                                     ),
// //                                   ),
// //                                   child: Padding(
// //                                     padding: const EdgeInsets.only(
// //                                         left: 20, right: 20),
// //                                     child: LayoutBuilder(
// //                                       builder: (context, constraints) {
// //                                         return Row(
// //                                           mainAxisAlignment:
// //                                           MainAxisAlignment.spaceBetween,
// //                                           children: [
// //                                             Text("Leaderboard",
// //                                                 style: TextStyle(
// //                                                     fontFamily:
// //                                                     "Alegreya_Sans",
// //                                                     fontSize:
// //                                                     constraints.maxHeight /
// //                                                         5,
// //                                                     color: Colors.white)),
// //                                             Row(
// //                                               children: [
// //                                                 Transform(
// //                                                   alignment: Alignment.center,
// //                                                   transform: Matrix4.rotationY(
// //                                                       3.14159),
// //                                                   child: SizedBox(
// //                                                     height:
// //                                                     constraints.maxHeight /
// //                                                         2.3,
// //                                                     width:
// //                                                     constraints.maxHeight /
// //                                                         2.3,
// //                                                     child:
// //                                                     TweenAnimationBuilder<
// //                                                         double>(
// //                                                       tween: Tween(
// //                                                           begin: 1.0, end: 0.0),
// //                                                       duration:
// //                                                       Duration(seconds: 10),
// //                                                       builder: (context, value,
// //                                                           child) {
// //                                                         return CircularProgressIndicator(
// //                                                           value: value,
// //                                                           color: Colors.white,
// //                                                         );
// //                                                       },
// //                                                     ),
// //                                                   ),
// //                                                 ),
// //                                                 SizedBox(width: 15),
// //                                                 Text(
// //                                                   "0:${countdown.toString().padLeft(2, '0')}",
// //                                                   style: TextStyle(
// //                                                       fontFamily:
// //                                                       "Alegreya_Sans",
// //                                                       fontSize:
// //                                                       constraints.maxHeight /
// //                                                           5,
// //                                                       color: Colors.white),
// //                                                 ),
// //                                               ],
// //                                             ),
// //                                           ],
// //                                         );
// //                                       },
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             );
// //           },
// //         );
// //       },
// //     ).then((_) {
// //       _controller.dispose();
// //       timer?.cancel();
// //     });
// //   }
// //
// //   void nextGroupStartDialog() {
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (BuildContext context) {
// //         return Dialog(
// //           backgroundColor: Colors.transparent,
// //           surfaceTintColor: Colors.transparent,
// //           child: Container(
// //             padding: EdgeInsets.all(16),
// //             height: 280,
// //             width: 290,
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(20),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black.withOpacity(.5),
// //                   blurRadius: 4.0,
// //                   spreadRadius: 1.0,
// //                   offset: Offset(0.0, 2.0),
// //                 ),
// //               ],
// //             ),
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Container(
// //                   height: 120,
// //                   width: 120,
// //                   decoration: BoxDecoration(
// //                     image: DecorationImage(
// //                       image: AssetImage(EXERCISE_VIEW_AVATAR),
// //                     ),
// //                   ),
// //                 ),
// //                 Text("Set Completed",
// //                     style:
// //                     TextStyle(fontFamily: "Alegreya_Sans", fontSize: 20)),
// //                 Text("Ready for next set?",
// //                     style:
// //                     TextStyle(fontFamily: "Alegreya_Sans", fontSize: 16)),
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       flex: 1,
// //                       child: ScaleButton(
// //                         onTap: () async {
// //                           await _disposeVideo();
// //                           Navigator.pop(context);
// //                           _moveToNextGroup();
// //                         },
// //                         child: Container(
// //                           width: double.infinity,
// //                           padding: EdgeInsets.all(5),
// //                           decoration: BoxDecoration(
// //                             gradient: LinearGradient(
// //                               colors: [Color(0xff59A3CB), Color(0xff116594)],
// //                             ),
// //                             borderRadius: BorderRadius.circular(8),
// //                           ),
// //                           child: Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               Text("Next Set",
// //                                   style: TextStyle(
// //                                       fontSize: 16,
// //                                       fontWeight: FontWeight.bold,
// //                                       fontFamily: "Alegreya_Sans",
// //                                       color: Colors.white)),
// //                               Icon(Icons.skip_next_rounded,
// //                                   size: 20, color: Colors.white),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                     SizedBox(width: 10),
// //                     Expanded(
// //                       flex: 1,
// //                       child: ScaleButton(
// //                         onTap: () {
// //                           Provider.of<IndexProvider>(context, listen: false)
// //                               .setIndex(2);
// //                           resetOrientation();
// //                           if (_cameraController != null)
// //                             _cameraController?.dispose();
// //                           Navigator.pushReplacement(
// //                             context,
// //                             MaterialPageRoute(
// //                               builder: (context) => BridgeScreen(),
// //                             ),
// //                           );
// //                         },
// //                         child: Container(
// //                           width: double.infinity,
// //                           padding: EdgeInsets.all(5),
// //                           decoration: BoxDecoration(
// //                             gradient: LinearGradient(
// //                               colors: [Color(0xff3249B8), Color(0xff5F32B8)],
// //                             ),
// //                             borderRadius: BorderRadius.circular(8),
// //                           ),
// //                           child: Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               Text("Leaderboard",
// //                                   style: TextStyle(
// //                                       fontSize: 16,
// //                                       fontWeight: FontWeight.bold,
// //                                       fontFamily: "Alegreya_Sans",
// //                                       color: Colors.white)),
// //                               Icon(Icons.leaderboard_rounded,
// //                                   size: 20, color: Colors.white),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   @override
// //   void didChangeAppLifecycleState(AppLifecycleState state) {
// //     if (_cameraController == null || !_cameraController!.value.isInitialized) {
// //       return;
// //     }
// //     if (state == AppLifecycleState.inactive) {
// //       _cameraController?.dispose();
// //     } else if (state == AppLifecycleState.resumed) {
// //       if (_cameraController != null) {
// //         _initCamera();
// //       }
// //     }
// //   }
// //
// //   bool canPop = false;
// //
// //   int activityCounts = 0;
// //   void setOrientation() async {
// //     await SystemChrome.setPreferredOrientations([
// //       DeviceOrientation.landscapeLeft,
// //       DeviceOrientation.landscapeRight,
// //     ]);
// //     await _initCamera();
// //   }
// //
// //   void resetOrientation() async {
// //     await SystemChrome.setPreferredOrientations([
// //       DeviceOrientation.portraitUp,
// //       DeviceOrientation.portraitDown,
// //     ]);
// //   }
// //
// //   // New state variables for the new flow
// //   late List<dynamic> exerciseGroups;
// //   int currentGroupIndex = 0;
// //   int currentExerciseIndex = 0;
// //   int currentLoopIndex = 0;
// //   int currentRep = 0;
// //   int totalRepsForCurrentLoop = 0;
// //   bool _isPlayingRepsVideo = false;
// //   int completedReps = 0;
// //   int completedTicks = 0;
// //   String currentEducationalVideoUrl = "";
// //   String currentExerciseVideoUrl = "";
// //   int currentScheduleId = 0;
// //   late int currentGroupNo;
// //
// //   bool _videoReady = false;
// //   VoidCallback? _videoListener;
// //
// //   String currentExerciseName = "";
// //   String currentLoopName = "";
// //
// //   // ✅ video controller
// //   late CachedVideoPlayerPlus _videoController;
// //   late final session = Provider.of<SessionProvider>(context, listen: false);
// //   late final int profileId = session.userData?['profileId'];
// //   late final int? selectedProfile = session.selectedProfileId; // adjust name if needed
// //
// //   late final bool shouldCallApi = profileId == selectedProfile;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //
// //     setOrientation();
// //     exerciseGroups = widget.exercises;
// //
// //     _findFirstIncompleteExercise();
// //
// //     activityCounts = ActivityMonitor.count;
// //
// //     /// ✅ Start loading video properly
// //     _loadVideo();
// //
// //   }
// //
// //   void _findFirstIncompleteExercise() {
// //     bool found = false;
// //
// //     for (int groupIdx = 0; groupIdx < exerciseGroups.length; groupIdx++) {
// //       final group = exerciseGroups[groupIdx];
// //       final exercises = group['exercises'] as List<dynamic>;
// //
// //       for (int exIdx = 0; exIdx < exercises.length; exIdx++) {
// //         final exercise = exercises[exIdx];
// //
// //         if (!exercise['isExerciseComplete']) {
// //           final loopExercises = exercise['loopExercises'] as List<dynamic>;
// //           for (int loopIdx = 0; loopIdx < loopExercises.length; loopIdx++) {
// //             final loopExercise = loopExercises[loopIdx];
// //
// //             if (!loopExercise['isLoopComplete']) {
// //               setState(() {
// //                 currentExerciseName = exercise['name'] ?? "Exercise";
// //                 currentLoopName = loopExercise['name'] ?? "Loop";
// //
// //                 currentGroupIndex = groupIdx;
// //                 currentExerciseIndex = exIdx;
// //                 currentLoopIndex = loopIdx;
// //                 currentGroupNo = group['exerciseGroupID'];
// //                 currentEducationalVideoUrl =
// //                 exercise['explainerVideo']['videoURL'];
// //                 currentExerciseVideoUrl = loopExercise['videoURL'];
// //                 currentScheduleId = loopExercise['prescriptionScheduleID'];
// //                 totalRepsForCurrentLoop = loopExercise['requiredLoopCount'];
// //                 _isPlayingRepsVideo = false;
// //                 completedReps = 0;
// //                 completedTicks = 0;
// //               });
// //               found = true;
// //               break;
// //             }
// //           }
// //
// //           if (found) break;
// //         }
// //         if (found) break;
// //       }
// //       if (found) break;
// //     }
// //
// //     if (!found && exerciseGroups.isNotEmpty) {
// //       final firstGroup = exerciseGroups[0];
// //       final firstExercise = firstGroup['exercises'][0];
// //       final firstLoop = firstExercise['loopExercises'][0];
// //
// //       setState(() {
// //         currentGroupIndex = 0;
// //         currentExerciseIndex = 0;
// //         currentLoopIndex = 0;
// //         currentGroupNo = firstGroup['exerciseGroupID'];
// //         currentEducationalVideoUrl = firstExercise['explainerVideo']['videoURL'];
// //         currentExerciseVideoUrl = firstLoop['videoURL'];
// //         currentScheduleId = firstLoop['prescriptionScheduleID'];
// //         totalRepsForCurrentLoop = firstLoop['requiredLoopCount'];
// //         _isPlayingRepsVideo = false;
// //         completedReps = 0;
// //         completedTicks = 0;
// //       });
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     _overlayTimer?.cancel();
// //
// //     if (_videoReady) {
// //       _disposeVideo();
// //     }
// //
// //     resetOrientation();
// //     _cameraController?.dispose();
// //     _nextExerciseTimer?.cancel();
// //
// //     super.dispose();
// //   }
// //
// //   // ✅✅ FIX 1: safe dispose + try catch
// //   Future<void> _disposeVideo() async {
// //     if (!_videoReady) return;
// //
// //     try {
// //       if (_videoListener != null) {
// //         try {
// //           _videoController.controller.removeListener(_videoListener!);
// //         } catch (_) {}
// //       }
// //
// //       try {
// //         if (_videoController.isInitialized) {
// //           await _videoController.controller.pause();
// //         }
// //       } catch (_) {}
// //
// //       try {
// //         await _videoController.dispose();
// //       } catch (_) {}
// //     } catch (e) {
// //       debugPrint("Dispose error: $e");
// //     }
// //
// //     _videoListener = null;
// //     _videoReady = false;
// //   }
// //
// //   int scheduleId = 0;
// //   String reason = "";
// //
// //   Future<void> sendExerciseResponse(bool shouldPop, int selected) async {
// //     if (_isSubmitting) return;
// //     _isSubmitting = true;
// //
// //     Map<String, dynamic>? response;
// //
// //     try {
// //       // 🔹 build reason
// //       reason = "";
// //       if (selected == 1) reason = "Tiring";
// //       if (selected == 2) reason = "Difficult";
// //       if (selected == 3) reason = "Painful";
// //       if (selected == 4) reason = "Need help";
// //
// //       final session = Provider.of<SessionProvider>(context, listen: false);
// //
// //       final int profileId = session.userData?['profileId'];
// //       final int? selectedProfileId = session.selectedProfileId; // <-- adjust name if needed
// //
// //       final bool shouldCallApi = profileId == selectedProfileId;
// //
// //       // 🔹 API CALL (only when allowed)
// //       if (shouldCallApi) {
// //         response = await ApiService.updateExerciseResponse(
// //           context: context,
// //           userToken: session.userData?['user_token']!,
// //           userId: session.userData?['userId']!,
// //           profileId: profileId,
// //           scheduleId: currentScheduleId,
// //           reason: reason,
// //         );
// //
// //         if (!mounted) return;
// //
// //         if (response['code'] != 200) {
// //           return; // ❌ stop only if API fails
// //         }
// //       }
// //
// //       // 🔹 FLOW CONTINUES (API or no API)
// //       _markCurrentLoopComplete();
// //
// //       if (_hasMoreLoopsInCurrentExercise()) {
// //         _moveToNextLoopInSameExercise();
// //         await _loadRepsVideo();
// //         return;
// //       }
// //
// //       _markCurrentExerciseComplete();
// //
// //       if (_hasMoreExercisesInCurrentGroup()) {
// //         _startNextExerciseCountdown(() async {
// //           _moveToNextExerciseInSameGroup();
// //           await _loadVideo();
// //         });
// //         return;
// //       }
// //
// //       // 🔹 GROUP COMPLETED
// //       if (_hasMoreGroups()) {
// //         nextGroupStartDialog();
// //         return;
// //       }
// //
// //       // 🔹 ALL GROUPS COMPLETED
// //       congratsLeaderboard(
// //         response ?? {"data": {"score": 0}},
// //         reason,
// //       );
// //
// //     } catch (e) {
// //       debugPrint("sendExerciseResponse Error: $e");
// //     } finally {
// //       _isSubmitting = false;
// //     }
// //   }
// //
// //
// //   void _markCurrentLoopComplete() {
// //     setState(() {
// //       exerciseGroups[currentGroupIndex]['exercises'][currentExerciseIndex]
// //       ['loopExercises'][currentLoopIndex]['isLoopComplete'] = true;
// //     });
// //   }
// //
// //   void _markCurrentExerciseComplete() {
// //     setState(() {
// //       exerciseGroups[currentGroupIndex]['exercises'][currentExerciseIndex]
// //       ['isExerciseComplete'] = true;
// //     });
// //   }
// //
// //   bool _hasMoreLoopsInCurrentExercise() {
// //     final currentExercise = exerciseGroups[currentGroupIndex]['exercises']
// //     [currentExerciseIndex];
// //     final loopExercises = currentExercise['loopExercises'] as List<dynamic>;
// //     return currentLoopIndex < loopExercises.length - 1;
// //   }
// //
// //   bool _hasMoreExercisesInCurrentGroup() {
// //     final currentGroup = exerciseGroups[currentGroupIndex];
// //     final exercises = currentGroup['exercises'] as List<dynamic>;
// //     return currentExerciseIndex < exercises.length - 1;
// //   }
// //
// //   bool _hasMoreGroups() {
// //     return currentGroupIndex < exerciseGroups.length - 1;
// //   }
// //
// //   void _moveToNextLoopInSameExercise() {
// //     setState(() {
// //       currentLoopIndex++;
// //       final nextLoop = exerciseGroups[currentGroupIndex]['exercises']
// //       [currentExerciseIndex]['loopExercises'][currentLoopIndex];
// //       currentExerciseVideoUrl = nextLoop['videoURL'];
// //       currentScheduleId = nextLoop['prescriptionScheduleID'];
// //       totalRepsForCurrentLoop = nextLoop['requiredLoopCount'];
// //       currentLoopName = nextLoop['name'] ?? "Loop Exercise";
// //
// //       completedReps = 0;
// //       completedTicks = 0;
// //       _isPlayingRepsVideo = true;
// //     });
// //   }
// //
// //   void _moveToNextExerciseInSameGroup() {
// //     setState(() {
// //       currentExerciseIndex++;
// //       currentLoopIndex = 0;
// //
// //       final nextExercise =
// //       exerciseGroups[currentGroupIndex]['exercises'][currentExerciseIndex];
// //       final nextLoop = nextExercise['loopExercises'][0];
// //
// //       currentExerciseName = nextExercise['name'] ?? "Exercise";
// //       currentLoopName = nextLoop['name'] ?? "Loop Exercise";
// //
// //       currentEducationalVideoUrl = nextExercise['explainerVideo']['videoURL'];
// //       currentExerciseVideoUrl = nextLoop['videoURL'];
// //       currentScheduleId = nextLoop['prescriptionScheduleID'];
// //       totalRepsForCurrentLoop = nextLoop['requiredLoopCount'];
// //
// //       completedReps = 0;
// //       completedTicks = 0;
// //       _isPlayingRepsVideo = false;
// //     });
// //   }
// //
// //   void _moveToNextGroup() {
// //     setState(() {
// //       currentGroupIndex++;
// //       currentExerciseIndex = 0;
// //       currentLoopIndex = 0;
// //
// //       final nextGroup = exerciseGroups[currentGroupIndex];
// //       final nextExercise = nextGroup['exercises'][0];
// //       final nextLoop = nextExercise['loopExercises'][0];
// //
// //       // ✅ FIX: update names
// //       currentExerciseName = nextExercise['name'] ?? "Exercise";
// //       currentLoopName = nextLoop['name'] ?? "Loop Exercise";
// //
// //       currentGroupNo = nextGroup['exerciseGroupID'];
// //       currentEducationalVideoUrl =
// //       nextExercise['explainerVideo']['videoURL'];
// //       currentExerciseVideoUrl = nextLoop['videoURL'];
// //       currentScheduleId = nextLoop['prescriptionScheduleID'];
// //       totalRepsForCurrentLoop = nextLoop['requiredLoopCount'];
// //
// //       completedReps = 0;
// //       completedTicks = 0;
// //       _isPlayingRepsVideo = false;
// //     });
// //
// //     _loadVideo(); // ✅ keep this AFTER setState
// //   }
// //
// //   void backButtonDialog() {
// //     if (_videoReady && _videoController.isInitialized) {
// //       _videoController.controller.pause();
// //     }
// //
// //     showDialog(
// //       barrierDismissible: false,
// //       context: context,
// //       builder: (context) {
// //         return Dialog(
// //           insetPadding: EdgeInsets.zero,
// //           backgroundColor: Colors.transparent,
// //           child: Container(
// //             padding: EdgeInsets.all(16),
// //             height: 320,
// //             width: 320,
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(20),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black.withOpacity(.5),
// //                   blurRadius: 4.0,
// //                   spreadRadius: 1.0,
// //                   offset: Offset(0.0, 2.0),
// //                 ),
// //               ],
// //             ),
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Container(
// //                   height: 120,
// //                   width: 120,
// //                   decoration: BoxDecoration(
// //                     image: DecorationImage(
// //                       image: AssetImage(EXERCISE_VIEW_AVATAR),
// //                     ),
// //                   ),
// //                 ),
// //                 Text(
// //                   "We noticed you're leaving before finishing.\nYou can always come back and complete the exerise.",
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(fontFamily: "Alegreya_Sans", fontSize: 16),
// //                 ),
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       flex: 1,
// //                       child: ScaleButton(
// //                         onTap: () {
// //                           Navigator.pop(context);
// //                           if (_videoReady && _videoController.isInitialized) {
// //                             _videoController.controller.play();
// //                           }
// //                         },
// //                         child: Container(
// //                           width: double.infinity,
// //                           padding: EdgeInsets.all(12),
// //                           decoration: BoxDecoration(
// //                             gradient: LinearGradient(
// //                               colors: [Color(0xff59A3CB), Color(0xff116594)],
// //                             ),
// //                             borderRadius: BorderRadius.circular(12),
// //                           ),
// //                           child: Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               Text("Stay",
// //                                   style: TextStyle(
// //                                       fontFamily: "Alegreya_Sans",
// //                                       fontSize: 16,
// //                                       color: Colors.white)),
// //                               Icon(Icons.play_arrow,
// //                                   size: 16, color: Colors.white),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                     SizedBox(width: 16),
// //                     Expanded(
// //                       flex: 1,
// //                       child: ScaleButton(
// //                         onTap: () async {
// //                           if (_cameraController != null) {
// //                             _cameraController?.dispose();
// //                           }
// //                           await _disposeVideo();
// //                           Navigator.pop(context);
// //                           resetOrientation();
// //                           Provider.of<IndexProvider>(context, listen: false)
// //                               .setIndex(0);
// //                           Navigator.pushReplacement(
// //                             context,
// //                             MaterialPageRoute(
// //                                 builder: (context) => BridgeScreen()),
// //                           );
// //                         },
// //                         child: Container(
// //                           width: double.infinity,
// //                           padding: EdgeInsets.all(12),
// //                           decoration: BoxDecoration(
// //                             gradient: LinearGradient(
// //                               colors: [Color(0xff3249B8), Color(0xff5F32B8)],
// //                             ),
// //                             borderRadius: BorderRadius.circular(12),
// //                           ),
// //                           child: Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               Text("Leave",
// //                                   style: TextStyle(
// //                                       fontFamily: "Alegreya_Sans",
// //                                       fontSize: 16,
// //                                       color: Colors.white)),
// //                               Icon(Icons.home,
// //                                   size: 16, color: Colors.white),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 )
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   Future<void> _handleSkip() async {
// //     if (!_isPlayingRepsVideo) {
// //       _loadRepsVideo();
// //     } else {
// //       try {
// //         if (_videoListener != null) {
// //           _videoController.controller.removeListener(_videoListener!);
// //         }
// //       } catch (_) {}
// //
// //       await _disposeVideo();
// //       onComplete();
// //     }
// //   }
// //
// //   // ✅✅ FIX 2: Educational video init with try/catch
// //   Future<void> _loadVideo() async {
// //     if (!mounted) return;
// //
// //     if (currentEducationalVideoUrl.isEmpty) return;
// //
// //     await _disposeVideo();
// //
// //     try {
// //       _videoController = CachedVideoPlayerPlus.networkUrl(
// //         Uri.parse(currentEducationalVideoUrl),
// //       );
// //
// //       await _videoController.initialize();
// //
// //       if (!mounted) return;
// //
// //       _videoReady = true;
// //
// //       setState(() {
// //         _isPlayingRepsVideo = false;
// //         isPlaying = true;
// //         showOverlay = false;
// //       });
// //
// //       _videoListener = () {
// //         try {
// //           if (!_videoController.isInitialized) return;
// //
// //           final pos = _videoController.controller.value.position;
// //           final dur = _videoController.controller.value.duration;
// //
// //           if (dur != Duration.zero && pos >= dur) {
// //             _loadRepsVideo();
// //           }
// //         } catch (e) {
// //           debugPrint("Listener crash (educational): $e");
// //         }
// //       };
// //
// //       _videoController.controller.addListener(_videoListener!);
// //       await _videoController.controller.play();
// //     } catch (e) {
// //       debugPrint("Video init failed (educational): $e");
// //       // ✅ stop red screen
// //       _videoReady = false;
// //     }
// //   }
// //
// //   // ✅✅ FIX 3: Reps video init with try/catch
// //   Future<void> _loadRepsVideo() async {
// //     if (currentExerciseVideoUrl.isEmpty) return;
// //
// //     await _disposeVideo();
// //
// //     try {
// //       _videoController = CachedVideoPlayerPlus.networkUrl(
// //         Uri.parse(currentExerciseVideoUrl),
// //       );
// //
// //       await _videoController.initialize();
// //
// //       if (!mounted) return;
// //
// //       _videoReady = true;
// //
// //       setState(() {
// //         _isPlayingRepsVideo = true;
// //         completedReps = 0;
// //         completedTicks = 0;
// //         isPlaying = true;
// //         showOverlay = false;
// //       });
// //
// //       _videoListener = () {
// //         if (!_videoController.isInitialized) return;
// //
// //         final pos = _videoController.controller.value.position;
// //         final dur = _videoController.controller.value.duration;
// //
// //         // small tolerance to avoid multi-fire
// //         if (dur != Duration.zero && pos >= dur - const Duration(milliseconds: 200)) {
// //           if (_repHandled) return;
// //           _repHandled = true;
// //
// //           if (completedReps < totalRepsForCurrentLoop - 1) {
// //             setState(() {
// //               completedReps++;
// //             });
// //
// //             _videoController.controller.seekTo(Duration.zero).then((_) {
// //               _repHandled = false;
// //               _videoController.controller.play();
// //             });
// //           } else {
// //             _videoController.controller.removeListener(_videoListener!);
// //             _videoController.controller.pause();
// //             onComplete();
// //           }
// //         }
// //       };
// //
// //
// //       _videoController.controller.addListener(_videoListener!);
// //       await _videoController.controller.play();
// //     } catch (e) {
// //       debugPrint("Video init failed (reps): $e");
// //       _videoReady = false;
// //     }
// //   }
// //
// //   CameraController? _cameraController;
// //   late List<CameraDescription> _cameras;
// //   bool _isInitialized = false;
// //
// //   Future<void> _initCamera() async {
// //     var status = await Permission.camera.request();
// //     if (!status.isGranted) return;
// //
// //     _cameras = await availableCameras();
// //     final frontCamera = _cameras.firstWhere(
// //           (camera) => camera.lensDirection == CameraLensDirection.front,
// //     );
// //
// //     _cameraController = CameraController(frontCamera, ResolutionPreset.high);
// //     await _cameraController!.initialize();
// //
// //     setState(() {
// //       _isInitialized = true;
// //     });
// //   }
// //
// //   bool enableCamera = true;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return PopScope(
// //       canPop: canPop,
// //       onPopInvokedWithResult: (bool, result) {
// //         onComplete();
// //         if (_videoReady &&
// //             _videoController.isInitialized &&
// //             _videoController.controller.value.isPlaying) {
// //           _videoController.controller.pause();
// //         }
// //       },
// //       child: Scaffold(
// //         backgroundColor: Colors.black,
// //         body: SafeArea(
// //           child: Center(
// //             child: Stack(
// //               alignment: Alignment.center,
// //               children: [
// //                 // Main content when video is ready
// //                 if (!_videoReady)
// //                   const Center(child: CircularProgressIndicator()),
// //
// //                 Padding(
// //                   padding: const EdgeInsets.only(left: 20, right: 20),
// //                   child: Row(
// //                     children: [
// //                       // Video Player Section
// //                       Expanded(
// //                         flex: 2,
// //                         child: Stack(
// //                           alignment: Alignment.center,
// //                           children: [
// //                             GestureDetector(
// //                               onTap: _handleScreenTap,
// //                               child: AspectRatio(
// //                                 aspectRatio: 2 / 1,
// //                                 child: Stack(
// //                                   children: [
// //                                     if (_videoReady &&
// //                                         _videoController.isInitialized)
// //                                       VideoPlayer(_videoController.controller),
// //
// //                                     Positioned(
// //                                       top: 10,
// //                                       right: 10,
// //                                       child: Align(
// //                                         child: Container(
// //                                           padding: const EdgeInsets.symmetric(
// //                                               horizontal: 12, vertical: 8),
// //                                           decoration: BoxDecoration(
// //                                             color:
// //                                             Colors.black.withOpacity(0.5),
// //                                             borderRadius:
// //                                             BorderRadius.circular(10),
// //                                           ),
// //                                           child: Column(
// //                                             crossAxisAlignment:
// //                                             CrossAxisAlignment.end,
// //                                             mainAxisSize: MainAxisSize.min,
// //                                             children: [
// //                                               Text(
// //                                                 currentExerciseName,
// //                                                 style: const TextStyle(
// //                                                   color: Colors.white,
// //                                                   fontSize: 16,
// //                                                   fontWeight: FontWeight.w600,
// //                                                   fontFamily: "Alegreya_Sans",
// //                                                 ),
// //                                               ),
// //
// //                                               const SizedBox(height: 2),
// //
// //                                               Text(
// //                                                 "Exercise ${getExerciseProgressText()}",
// //                                                 style: const TextStyle(
// //                                                   color: Colors.white70,
// //                                                   fontSize: 14,
// //                                                   fontFamily: "Alegreya_Sans",
// //                                                 ),
// //                                               ),
// //
// //                                               if (_isPlayingRepsVideo) ...[
// //                                                 const SizedBox(height: 3),
// //
// //                                                 Text(
// //                                                   currentLoopName,
// //                                                   style: const TextStyle(
// //                                                     color: Colors.white70,
// //                                                     fontSize: 14,
// //                                                     fontWeight: FontWeight.w500,
// //                                                     fontFamily: "Alegreya_Sans",
// //                                                   ),
// //                                                 ),
// //
// //                                                 Text(
// //                                                   "Loop ${getLoopProgressText()}",
// //                                                   style: const TextStyle(
// //                                                     color: Colors.white,
// //                                                     fontSize: 14,
// //                                                     fontWeight: FontWeight.w600,
// //                                                     fontFamily: "Alegreya_Sans",
// //                                                   ),
// //                                                 ),
// //                                               ],
// //                                             ],
// //
// //                                           ),
// //                                         ),
// //                                       ),
// //                                     ),
// //
// //                                     // overlay buttons (your same)
// //                                     if (showOverlay && isPlaying)
// //                                       GestureDetector(
// //                                         onTap: _hideOverlay,
// //                                         child: Container(
// //                                           width: double.infinity,
// //                                           height: double.infinity,
// //                                           color: Colors.black.withOpacity(0.5),
// //                                           child: Center(
// //                                             child: SizedBox(
// //                                               width: 300,
// //                                               child: Row(
// //                                                 mainAxisAlignment:
// //                                                 MainAxisAlignment
// //                                                     .spaceBetween,
// //                                                 children: [
// //                                                   SizedBox(width: 50),
// //                                                   GestureDetector(
// //                                                     onTap: _togglePlayPause,
// //                                                     child: Container(
// //                                                       width: 65,
// //                                                       height: 65,
// //                                                       decoration: BoxDecoration(
// //                                                         color: Colors.black
// //                                                             .withOpacity(0.5),
// //                                                         shape: BoxShape.circle,
// //                                                         border: Border.all(
// //                                                           color: Colors.white
// //                                                               .withOpacity(0.8),
// //                                                           width: 2,
// //                                                         ),
// //                                                       ),
// //                                                       child: Icon(
// //                                                         Icons.pause_rounded,
// //                                                         size: 40,
// //                                                         color: Colors.white,
// //                                                       ),
// //                                                     ),
// //                                                   ),
// //                                                   GestureDetector(
// //                                                     onTap: _handleSkip,
// //                                                     child: Container(
// //                                                       width: 50,
// //                                                       height: 50,
// //                                                       decoration: BoxDecoration(
// //                                                         color: Colors.black
// //                                                             .withOpacity(0.5),
// //                                                         shape: BoxShape.circle,
// //                                                         border: Border.all(
// //                                                           color: Colors.white
// //                                                               .withOpacity(0.8),
// //                                                           width: 2,
// //                                                         ),
// //                                                       ),
// //                                                       child: Icon(
// //                                                         Icons.skip_next_rounded,
// //                                                         size: 30,
// //                                                         color: Colors.white,
// //                                                       ),
// //                                                     ),
// //                                                   ),
// //                                                 ],
// //                                               ),
// //                                             ),
// //                                           ),
// //                                         ),
// //                                       ),
// //
// //                                     if (!isPlaying && showOverlay)
// //                                       Center(
// //                                         child: SizedBox(
// //                                           width: 300,
// //                                           child: Row(
// //                                             mainAxisAlignment:
// //                                             MainAxisAlignment.spaceBetween,
// //                                             children: [
// //                                               SizedBox(width: 50),
// //                                               GestureDetector(
// //                                                 onTap: _togglePlayPause,
// //                                                 child: Container(
// //                                                   width: 65,
// //                                                   height: 65,
// //                                                   decoration: BoxDecoration(
// //                                                     color: Colors.black
// //                                                         .withOpacity(0.5),
// //                                                     shape: BoxShape.circle,
// //                                                     border: Border.all(
// //                                                       color: Colors.white
// //                                                           .withOpacity(0.8),
// //                                                       width: 2,
// //                                                     ),
// //                                                   ),
// //                                                   child: Icon(
// //                                                     Icons.play_arrow_rounded,
// //                                                     size: 40,
// //                                                     color: Colors.white,
// //                                                   ),
// //                                                 ),
// //                                               ),
// //                                               GestureDetector(
// //                                                 onTap: _handleSkip,
// //                                                 child: Container(
// //                                                   width: 50,
// //                                                   height: 50,
// //                                                   decoration: BoxDecoration(
// //                                                     color: Colors.black
// //                                                         .withOpacity(0.5),
// //                                                     shape: BoxShape.circle,
// //                                                     border: Border.all(
// //                                                       color: Colors.white
// //                                                           .withOpacity(0.8),
// //                                                       width: 2,
// //                                                     ),
// //                                                   ),
// //                                                   child: Icon(
// //                                                     Icons.skip_next_rounded,
// //                                                     size: 30,
// //                                                     color: Colors.white,
// //                                                   ),
// //                                                 ),
// //                                               ),
// //                                             ],
// //                                           ),
// //                                         ),
// //                                       ),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //
// //                       SizedBox(width: 20),
// //
// //                       _isInitialized && enableCamera
// //                           ? Expanded(
// //                         flex: 2,
// //                         child: AspectRatio(
// //                           aspectRatio: 1,
// //                           child: Transform(
// //                             alignment: Alignment.center,
// //                             transform: Matrix4.rotationY(math.pi),
// //                             child: CameraPreview(_cameraController!),
// //                           ),
// //                         ),
// //                       )
// //                           : SizedBox(),
// //                     ],
// //                   ),
// //                 ),
// //
// //                 Positioned(
// //                   top: 0,
// //                   right: 0,
// //                   bottom: 0,
// //                   left: 0,
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(8.0),
// //                     child: Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: [
// //                         Column(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             SizedBox(height: 55, width: 55),
// //                             _isPlayingRepsVideo
// //                                 ? Container(
// //                               height: 100,
// //                               width: 100,
// //                               decoration: BoxDecoration(
// //                                 color: Color(0xff000000).withOpacity(0.8),
// //                                 borderRadius: BorderRadius.circular(20),
// //                                 border: Border.all(
// //                                     color: Color(0xFF00E5FF)),
// //                               ),
// //                               alignment: Alignment.center,
// //                               child: CircularTickCounter(
// //                                 totalTicks: 30,
// //                                 completedTicks: (((completedReps + 1) / totalRepsForCurrentLoop) * 30)
// //                                     .floor()
// //                                     .clamp(1, 30),
// //                                 completedReps: completedReps + 1,
// //                                 totalReps: totalRepsForCurrentLoop,
// //                                 size: 100,
// //                                 label: "REP",
// //                               ),
// //
// //
// //                             )
// //                                 : SizedBox(height: 55, width: 55),
// //                           ],
// //                         ),
// //                         Column(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             ScaleButton(
// //                               onTap: backButtonDialog,
// //                               child: Container(
// //                                   height: 45,
// //                                   width: 45,
// //                                   decoration: BoxDecoration(
// //                                       shape: BoxShape.circle,
// //                                       color: Colors.white),
// //                                   alignment: Alignment.center,
// //                                   child: Icon(Icons.clear_rounded,
// //                                       size: 30, color: Color(0xff054A9E))),
// //                             ),
// //                             ScaleButton(
// //                               onTap: () {
// //                                 setState(() {
// //                                   enableCamera = !enableCamera;
// //                                 });
// //                               },
// //                               child: Image.asset(
// //                                 height: 55,
// //                                 width: 55,
// //                                 EXERCISES_CAMERA_BUTTON,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //
// //                 if (_showNextExerciseOverlay)
// //                   Positioned.fill(
// //                     child: Container(
// //                       color: Colors.black.withOpacity(0.7),
// //                       child: Center(
// //                         child: Column(
// //                           mainAxisSize: MainAxisSize.min,
// //                           children: [
// //                             Text(
// //                               "Next exercise starts in",
// //                               style: TextStyle(
// //                                 color: Colors.white,
// //                                 fontSize: 20,
// //                                 fontFamily: "Alegreya_Sans",
// //                               ),
// //                             ),
// //                             const SizedBox(height: 10),
// //                             Text(
// //                               "$_nextExerciseCountdown",
// //                               style: TextStyle(
// //                                 color: Colors.white,
// //                                 fontSize: 48,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                             const SizedBox(height: 20),
// //                             ScaleButton(
// //                               onTap: () async {
// //                                 _hideNextExerciseOverlay();
// //                                 _moveToNextExerciseInSameGroup();
// //                                 await _loadVideo();
// //                               },
// //                               child: Container(
// //                                 padding:
// //                                 const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
// //                                 decoration: BoxDecoration(
// //                                   gradient: const LinearGradient(
// //                                     colors: [Color(0xff59A3CB), Color(0xff116594)],
// //                                   ),
// //                                   borderRadius: BorderRadius.circular(30),
// //                                 ),
// //                                 child: const Text(
// //                                   "Next Exercise",
// //                                   style: TextStyle(
// //                                     color: Colors.white,
// //                                     fontSize: 18,
// //                                     fontFamily: "Alegreya_Sans",
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// ///
//
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
// ///
//
//
//
//
//
// import 'dart:async';
// import 'dart:math';
// import 'dart:math' as math;
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';
// import 'package:camera/camera.dart';
// import 'package:confetti/confetti.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:myocircle15screens/components/custom_circular_counter.dart';
// import 'package:myocircle15screens/main.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
// import 'package:scale_button/scale_button.dart';
//
// import '../../components/components_path.dart';
// import '../../providers/index_provider.dart';
// import '../../providers/session_provider.dart';
// import '../../services/api_service.dart';
// import '../../services/applife_cycle_manager.dart';
//
// class ExerciseViewScreen extends StatefulWidget {
//   final List<dynamic> exercises;
//
//   const ExerciseViewScreen({
//     super.key,
//     required this.exercises,
//   });
//
//   @override
//   State<ExerciseViewScreen> createState() => _ExerciseViewScreenState();
// }
//
// class _ExerciseViewScreenState extends State<ExerciseViewScreen> with WidgetsBindingObserver {
//   // Play/Pause functionality variables
//   bool isPlaying = true;
//   bool showOverlay = false;
//   Timer? _overlayTimer;
//   int selected = 0;
//
//
//   late final Player _player = Player();
//   late final VideoController _videoController = VideoController(_player);
//
//
//   bool _videoReady = false;
//
//   String buildStreamUrl({
//     required int videoId,
//     required String type,
//   }) {
//     return "https://api.myocircle.com/myoc/api/auth/stream"
//         "?videoId=$videoId"
//         "&type=$type"
//         "&playName=master.m3u8";
//   }
//
//   bool _showNextExerciseOverlay = false;
//   int _nextExerciseCountdown = 5;
//   Timer? _nextExerciseTimer;
//   void _startNextExerciseCountdown(VoidCallback onFinish) {
//     _nextExerciseTimer?.cancel();
//
//     setState(() {
//       _showNextExerciseOverlay = true;
//       _nextExerciseCountdown = 5;
//     });
//
//     _nextExerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_nextExerciseCountdown == 1) {
//         timer.cancel();
//         _hideNextExerciseOverlay();
//         onFinish();
//       } else {
//         setState(() {
//           _nextExerciseCountdown--;
//         });
//       }
//     });
//   }
//
//   void _hideNextExerciseOverlay() {
//     _nextExerciseTimer?.cancel();
//     setState(() {
//       _showNextExerciseOverlay = false;
//     });
//   }
//
//   bool _repHandled = false;
//
//   void _togglePlayPause() {
//     if (!_videoReady) return;
//
//     setState(() {
//       isPlaying = !isPlaying;
//       showOverlay = !isPlaying;
//     });
//
//     if (isPlaying) {
//       _player.play();      // ✅ media_kit
//       _showOverlay();
//     } else {
//       _player.pause();     // ✅ media_kit
//       _cancelTimer();
//     }
//   }
//
//   void _showOverlay() {
//     if (isPlaying) {
//       setState(() {
//         showOverlay = true;
//       });
//
//       _cancelTimer();
//       _overlayTimer = Timer(const Duration(seconds: 3), () {
//         if (mounted && isPlaying) {
//           setState(() {
//             showOverlay = false;
//           });
//         }
//       });
//     }
//   }
//   Future<bool?> completeExercise2() {
//     selected = 1;
//     return showDialog<bool>(
//         context: context,
//         builder: (context) {
//           return StatefulBuilder(builder: (context, set) {
//             return Dialog(
//               insetPadding: EdgeInsets.all(0),
//               backgroundColor: Colors.transparent,
//               surfaceTintColor: Colors.transparent,
//               child: Container(
//                 width: 320,
//                 height: 320,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Expanded(
//                         flex: 1,
//                         child: Container(
//                           alignment: Alignment.centerRight,
//                           child: ScaleButton(
//                               onTap: () {
//                                 Navigator.pop(context);
//                               },
//                               child: Image.asset(EXERCISE_VIEW_CLOSE_BTN)),
//                         ),
//                       ),
//                       Expanded(
//                         flex: 5,
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Expanded(
//                               flex: 8,
//                               child: Column(
//                                 children: [
//                                   Expanded(
//                                     child: LayoutBuilder(
//                                         builder: (context, constraints) {
//                                           return RadioListTile(
//                                               visualDensity: VisualDensity.compact,
//                                               dense: true,
//                                               contentPadding: EdgeInsets.zero,
//                                               activeColor: Color(0xff203EC3),
//                                               title: Text(
//                                                 "Tiring",
//                                                 style: TextStyle(
//                                                     fontFamily: "Alegreya_Sans",
//                                                     fontSize:
//                                                     constraints.maxHeight /
//                                                         2.4),
//                                               ),
//                                               value: 1,
//                                               groupValue: selected,
//                                               onChanged: (value) {
//                                                 set(() {
//                                                   selected = value!;
//                                                 });
//                                               });
//                                         }),
//                                   ),
//                                   Expanded(
//                                     child: LayoutBuilder(
//                                         builder: (context, constraints) {
//                                           return RadioListTile(
//                                               visualDensity: VisualDensity.compact,
//                                               dense: true,
//                                               contentPadding: EdgeInsets.zero,
//                                               activeColor: Color(0xff203EC3),
//                                               title: Text(
//                                                 "Difficult",
//                                                 style: TextStyle(
//                                                     fontFamily: "Alegreya_Sans",
//                                                     fontSize:
//                                                     constraints.maxHeight /
//                                                         2.4),
//                                               ),
//                                               value: 2,
//                                               groupValue: selected,
//                                               onChanged: (value) {
//                                                 set(() {
//                                                   selected = value!;
//                                                 });
//                                               });
//                                         }),
//                                   ),
//                                   Expanded(
//                                     child: LayoutBuilder(
//                                         builder: (context, constraints) {
//                                           return RadioListTile(
//                                               visualDensity: VisualDensity.compact,
//                                               dense: true,
//                                               contentPadding: EdgeInsets.zero,
//                                               activeColor: Color(0xff203EC3),
//                                               title: Text(
//                                                 "Painful",
//                                                 style: TextStyle(
//                                                     fontFamily: "Alegreya_Sans",
//                                                     fontSize:
//                                                     constraints.maxHeight /
//                                                         2.4),
//                                               ),
//                                               value: 3,
//                                               groupValue: selected,
//                                               onChanged: (value) {
//                                                 set(() {
//                                                   selected = value!;
//                                                 });
//                                               });
//                                         }),
//                                   ),
//                                   Expanded(
//                                     child: LayoutBuilder(
//                                         builder: (context, constraints) {
//                                           return RadioListTile(
//                                               visualDensity: VisualDensity.compact,
//                                               dense: true,
//                                               contentPadding: EdgeInsets.zero,
//                                               activeColor: Color(0xff203EC3),
//                                               title: Text(
//                                                 "Need Help",
//                                                 style: TextStyle(
//                                                     fontFamily: "Alegreya_Sans",
//                                                     fontSize:
//                                                     constraints.maxHeight /
//                                                         2.4),
//                                               ),
//                                               value: 4,
//                                               groupValue: selected,
//                                               onChanged: (value) {
//                                                 set(() {
//                                                   selected = value!;
//                                                 });
//                                               });
//                                         }),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Expanded(
//                               flex: 1,
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Expanded(child: Image.asset(DOT_COLORED)),
//                                   Expanded(child: Image.asset(DOT_WHITE)),
//                                   Expanded(child: Image.asset(DOT_COLORED)),
//                                   Expanded(child: Image.asset(DOT_WHITE)),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         flex: 3,
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Expanded(
//                               child: Padding(
//                                 padding: const EdgeInsets.only(left: 25),
//                                 child: ScaleButton(
//                                     onTap: () async {
//                                       Navigator.pop(context, true); // ✅ submitted
//                                       await sendExerciseResponse(false, selected);
//                                     },
//                                     child:
//                                     Image.asset(EXERCISE_VIEW_SUBMIT_BTN)),
//                               ),
//                             ),
//                             Expanded(
//                               child: Padding(
//                                 padding: const EdgeInsets.only(left: 25),
//                                 child: ScaleButton(
//                                   onTap: () {
//
//                                     Navigator.pop(context, false); // ❌ cancelled
//                                   },
//                                   child: Image.asset(EXERCISE_VIEW_CANCEL_BTN),
//                                 ),
//
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           });
//         });
//   }
//   void _hideOverlay() {
//     if (showOverlay) {
//       setState(() {
//         showOverlay = false;
//       });
//       _cancelTimer();
//     }
//   }
//
//   void _cancelTimer() {
//     if (_overlayTimer != null) {
//       _overlayTimer!.cancel();
//       _overlayTimer = null;
//     }
//   }
//
//   bool _isSubmitting = false;
//
//   void _handleScreenTap() {
//     if (isPlaying) {
//       if (showOverlay) {
//         _hideOverlay();
//       } else {
//         _showOverlay();
//       }
//     } else {
//       setState(() {
//         showOverlay = !showOverlay;
//       });
//       _cancelTimer();
//     }
//   }
//
//   bool _isCompletionDialogOpen = false;
//
//   void onComplete() {
//     if (_videoReady) {
//       _player.pause();   // ✅ correct for media_kit
//     }
//
//     if (_isCompletionDialogOpen) return;
//
//     _isCompletionDialogOpen = true;
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) {
//         bool isDialogSubmitting = false;
//
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return Dialog(
//               backgroundColor: Colors.transparent,
//               surfaceTintColor: Colors.transparent,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // COMPLETE BUTTON
//                   ScaleButton(
//                     onTap: isDialogSubmitting
//                         ? null
//                         : () async {
//                       setDialogState(() => isDialogSubmitting = true);
//                       Navigator.pop(dialogContext);
//                       await sendExerciseResponse(false, 0);
//                     },
//                     child: Opacity(
//                       opacity: isDialogSubmitting ? 0.4 : 1,
//                       child: Container(
//                         height: 140,
//                         width: 140,
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(25),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(.3),
//                               blurRadius: 4.0,
//                               spreadRadius: 1.0,
//                               offset: const Offset(0.0, 2.0),
//                             ),
//                           ],
//                           border: const Border(
//                             left: BorderSide(color: Color(0xff1F8C85), width: 4),
//                           ),
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: const [
//                             Icon(Icons.check_circle_rounded,
//                                 size: 50, color: Color(0xff1F8C85)),
//                             Text(
//                               "Complete",
//                               style: TextStyle(
//                                 fontFamily: "Alegreya_Sans",
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(width: 32),
//
//                   // NEED HELP BUTTON
//                   // ✅ NEED HELP BUTTON
//                   ScaleButton(
//                     onTap: isDialogSubmitting
//                         ? null
//                         : () {
//                       setDialogState(() => isDialogSubmitting = true);
//
//                       Navigator.pop(dialogContext);   // close main dialog
//
//                       completeExercise2();             // ✅ OPEN SMALL DIALOG HERE
//                     },
//                     child: Opacity(
//                       opacity: isDialogSubmitting ? 0.4 : 1,
//                       child: Container(
//                         height: 140,
//                         width: 140,
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(25),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(.3),
//                               blurRadius: 4.0,
//                               spreadRadius: 1.0,
//                               offset: const Offset(0.0, 2.0),
//                             ),
//                           ],
//                           border: const Border(
//                             left: BorderSide(width: 4, color: Color(0xff3197DB)),
//                           ),
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: const [
//                             Icon(Icons.cancel_rounded,
//                                 size: 50, color: Color(0xff3197DB)),
//                             Text(
//                               "I need help",
//                               style: TextStyle(
//                                 fontFamily: "Alegreya_Sans",
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     ).then((_) {
//       _isCompletionDialogOpen = false;
//     });
//   }
//
//   void completeExercise() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return Dialog(
//           insetPadding: EdgeInsets.zero,
//           backgroundColor: Colors.transparent,
//           surfaceTintColor: Colors.transparent,
//           child: Container(
//             width: 320,        // ✅ fixed width
//             height: 320,       // ✅ fixed height
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage(EXERCISE_VIEW_CONTAINER1),
//                 fit: BoxFit.fill,
//               ),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "Complete your Exercise",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontFamily: "Alegreya_Sans",
//                           fontSize: 22,
//                         ),
//                       ),
//
//                       Text(
//                         "Your exercise will only be marked as complete after you select the tick or cross to give your feedback.",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontFamily: "Alegreya_Sans",
//                           fontSize: 16,
//                         ),
//                       ),
//
//                       ScaleButton(
//                         onTap: () {
//                           Navigator.pop(context);
//                         },
//                         child: Image.asset(EXERCISE_VIEW_OK_BTN),
//                       ),
//                     ],
//                   ),
//
//                   Positioned(
//                     right: 10,
//                     top: 10,
//                     child: GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: Image.asset(EXERCISE_VIEW_CLOSE_BTN),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void markEachExercise() {
//     showDialog(
//         context: context,
//         builder: (context) {
//           return Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                     image: DecorationImage(
//                         image: AssetImage(
//                           EXERCISE_VIEW_CONTAINER1,
//                         ),
//                         fit: BoxFit.fill)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Expanded(
//                                   child: Text(
//                                     "",
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                         fontFamily: "Alegreya_Sans", fontSize: 28),
//                                   )),
//                             ],
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Expanded(
//                                   flex: 8,
//                                   child: Text(
//                                     "Mark each exercise with a ✓ or ✗ to complete your quest and unlock your next challenge!",
//                                     style: TextStyle(
//                                         fontFamily: "Alegreya_Sans",
//                                         fontSize: 28),
//                                   )),
//                               Expanded(
//                                 flex: 1,
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Image.asset(height: 40, DOT_COLORED),
//                                     Image.asset(height: 40, DOT_WHITE),
//                                     Image.asset(height: 40, DOT_COLORED),
//                                     Image.asset(height: 40, DOT_WHITE),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(left: 25),
//                             child: Image.asset(EXERCISE_VIEW_OK_BTN),
//                           ),
//                         ],
//                       ),
//                       Positioned(
//                           right: 10,
//                           top: 10,
//                           child: Image.asset(EXERCISE_VIEW_CLOSE_BTN)),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           );
//         });
//   }
//
//   String getLoopProgressText() {
//     final currentExercise =
//     exerciseGroups[currentGroupIndex]['exercises'][currentExerciseIndex];
//
//     final loops = currentExercise['loopExercises'] as List<dynamic>;
//     final totalLoops = loops.length;
//
//     final currentLoopNumber = currentLoopIndex + 1; // ✅ start from 1
//
//     return "$currentLoopNumber/$totalLoops";
//   }
//   String getExerciseProgressText() {
//     final exercises =
//     exerciseGroups[currentGroupIndex]['exercises'] as List<dynamic>;
//
//     final totalExercises = exercises.length;
//     final currentExerciseNumber = currentExerciseIndex + 1;
//
//     return "$currentExerciseNumber/$totalExercises";
//   }
//
//
//   String getGroupExerciseProgressText() {
//     final currentGroup = exerciseGroups[currentGroupIndex];
//     final exercises = currentGroup['exercises'] as List<dynamic>;
//
//     final total = exercises.length;
//
//     final completed =
//         exercises.where((e) => e['isExerciseComplete'] == true).length;
//
//     return "$completed/$total";
//   }
//
//
//
//   void congratsLeaderboard(final response, String reason) {
//     late ConfettiController _controller;
//     _controller = ConfettiController(duration: const Duration(seconds: 2));
//     _controller.play();
//     int countdown = 10;
//     Timer? timer;
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         final height = MediaQuery.of(context).size.height;
//         return StatefulBuilder(
//           builder: (context, setStateInner) {
//             if (timer == null) {
//               timer = Timer.periodic(Duration(seconds: 1), (t) {
//                 if (countdown > 0) {
//                   setStateInner(() {
//                     countdown--;
//                   });
//                 } else {
//                   t.cancel();
//                   Provider.of<IndexProvider>(context, listen: false).setIndex(2);
//                   resetOrientation();
//                   if (_cameraController != null) _cameraController?.dispose();
//                   Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => BridgeScreen()));
//                 }
//               });
//             }
//
//             return Dialog(
//               backgroundColor: Colors.transparent,
//               surfaceTintColor: Colors.transparent,
//               child: Container(
//                 width: MediaQuery.of(context).size.width / 2,
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage(EXERCISE_VIEW_CONTAINER2),
//                     fit: BoxFit.fill,
//                   ),
//                 ),
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     if (reason == "")
//                       Positioned(
//                         top: 0,
//                         child: ConfettiWidget(
//                           blastDirectionality: BlastDirectionality.explosive,
//                           confettiController: _controller,
//                           blastDirection: pi / 2,
//                           emissionFrequency: 0.05,
//                           maximumSize: Size(7, 7),
//                           minimumSize: Size(4, 4),
//                           numberOfParticles: 20,
//                           maxBlastForce: 20,
//                           minBlastForce: 10,
//                           gravity: 0.3,
//                           colors: [
//                             Colors.red,
//                             Colors.blue,
//                             Colors.green,
//                             Colors.orange,
//                             Colors.purple,
//                             Colors.pink,
//                             Colors.yellow,
//                             Colors.lightBlue,
//                           ],
//                         ),
//                       ),
//                     Padding(
//                       padding: const EdgeInsets.all(20),
//                       child: Padding(
//                         padding: const EdgeInsets.only(left: 8, bottom: 9),
//                         child: Column(
//                           children: [
//                             Expanded(child: Image.asset(EXERCISE_VIEW_AVATAR)),
//                             reason == ""
//                                 ? Text("Congratulations",
//                                 style: TextStyle(
//                                     fontFamily: "Alegreya_Sans",
//                                     fontSize: height / 15))
//                                 : Text("No Worries",
//                                 style: TextStyle(
//                                     fontFamily: "Alegreya_Sans",
//                                     fontSize: height / 15)),
//                             Text(
//                               "Current Score: ${response['data']['score']} Points",
//                               style: TextStyle(
//                                   fontFamily: "Alegreya_Sans",
//                                   fontSize: height / 23.5),
//                             ),
//                             SizedBox(height: 20),
//                             Expanded(
//                               child: ScaleButton(
//                                 onTap: () {
//                                   Provider.of<IndexProvider>(context,
//                                       listen: false)
//                                       .setIndex(2);
//                                   resetOrientation();
//                                   if (_cameraController != null)
//                                     _cameraController?.dispose();
//                                   Navigator.pushReplacement(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) =>
//                                               BridgeScreen()));
//                                 },
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(50),
//                                     gradient: LinearGradient(
//                                       colors: [
//                                         Color(0xff59A3CB),
//                                         Color(0xff116594),
//                                       ],
//                                     ),
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(
//                                         left: 20, right: 20),
//                                     child: LayoutBuilder(
//                                       builder: (context, constraints) {
//                                         return Row(
//                                           mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Text("Leaderboard",
//                                                 style: TextStyle(
//                                                     fontFamily:
//                                                     "Alegreya_Sans",
//                                                     fontSize:
//                                                     constraints.maxHeight /
//                                                         5,
//                                                     color: Colors.white)),
//                                             Row(
//                                               children: [
//                                                 Transform(
//                                                   alignment: Alignment.center,
//                                                   transform: Matrix4.rotationY(
//                                                       3.14159),
//                                                   child: SizedBox(
//                                                     height:
//                                                     constraints.maxHeight /
//                                                         2.3,
//                                                     width:
//                                                     constraints.maxHeight /
//                                                         2.3,
//                                                     child:
//                                                     TweenAnimationBuilder<
//                                                         double>(
//                                                       tween: Tween(
//                                                           begin: 1.0, end: 0.0),
//                                                       duration:
//                                                       Duration(seconds: 10),
//                                                       builder: (context, value,
//                                                           child) {
//                                                         return CircularProgressIndicator(
//                                                           value: value,
//                                                           color: Colors.white,
//                                                         );
//                                                       },
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 SizedBox(width: 15),
//                                                 Text(
//                                                   "0:${countdown.toString().padLeft(2, '0')}",
//                                                   style: TextStyle(
//                                                       fontFamily:
//                                                       "Alegreya_Sans",
//                                                       fontSize:
//                                                       constraints.maxHeight /
//                                                           5,
//                                                       color: Colors.white),
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     ).then((_) {
//       _controller.dispose();
//       timer?.cancel();
//     });
//   }
//
//   void nextGroupStartDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           surfaceTintColor: Colors.transparent,
//           child: Container(
//             padding: EdgeInsets.all(16),
//             height: 280,
//             width: 290,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(.5),
//                   blurRadius: 4.0,
//                   spreadRadius: 1.0,
//                   offset: Offset(0.0, 2.0),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   height: 120,
//                   width: 120,
//                   decoration: BoxDecoration(
//                     image: DecorationImage(
//                       image: AssetImage(EXERCISE_VIEW_AVATAR),
//                     ),
//                   ),
//                 ),
//                 Text("Set Completed",
//                     style:
//                     TextStyle(fontFamily: "Alegreya_Sans", fontSize: 20)),
//                 Text("Ready for next set?",
//                     style:
//                     TextStyle(fontFamily: "Alegreya_Sans", fontSize: 16)),
//                 Row(
//                   children: [
//                     Expanded(
//                       flex: 1,
//                       child: ScaleButton(
//                         onTap: () async {
//                           await _disposeVideo();
//                           Navigator.pop(context);
//                           _moveToNextGroup();
//                         },
//                         child: Container(
//                           width: double.infinity,
//                           padding: EdgeInsets.all(5),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [Color(0xff59A3CB), Color(0xff116594)],
//                             ),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text("Next Set",
//                                   style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       fontFamily: "Alegreya_Sans",
//                                       color: Colors.white)),
//                               Icon(Icons.skip_next_rounded,
//                                   size: 20, color: Colors.white),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 10),
//                     Expanded(
//                       flex: 1,
//                       child: ScaleButton(
//                         onTap: () {
//                           Provider.of<IndexProvider>(context, listen: false)
//                               .setIndex(2);
//                           resetOrientation();
//                           if (_cameraController != null)
//                             _cameraController?.dispose();
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => BridgeScreen(),
//                             ),
//                           );
//                         },
//                         child: Container(
//                           width: double.infinity,
//                           padding: EdgeInsets.all(5),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [Color(0xff3249B8), Color(0xff5F32B8)],
//                             ),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text("Leaderboard",
//                                   style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       fontFamily: "Alegreya_Sans",
//                                       color: Colors.white)),
//                               Icon(Icons.leaderboard_rounded,
//                                   size: 20, color: Colors.white),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       return;
//     }
//     if (state == AppLifecycleState.inactive) {
//       _cameraController?.dispose();
//     } else if (state == AppLifecycleState.resumed) {
//       if (_cameraController != null) {
//         _initCamera();
//       }
//     }
//   }
//
//   bool canPop = false;
//
//   int activityCounts = 0;
//   void setOrientation() async {
//     await SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//     // await _initCamera();
//   }
//
//   void resetOrientation() async {
//     await SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);
//   }
//
//   // New state variables for the new flow
//   late List<dynamic> exerciseGroups;
//   int currentGroupIndex = 0;
//   int currentExerciseIndex = 0;
//   int currentLoopIndex = 0;
//   int currentRep = 0;
//   int totalRepsForCurrentLoop = 0;
//   bool _isPlayingRepsVideo = false;
//   int completedReps = 0;
//   int completedTicks = 0;
//   String currentEducationalVideoUrl = "";
//   String currentExerciseVideoUrl = "";
//   int currentScheduleId = 0;
//   late int currentGroupNo;
//
//
//   VoidCallback? _videoListener;
//
//   String currentExerciseName = "";
//   String currentLoopName = "";
//
//   // ✅ video controller
//
//   late final session = Provider.of<SessionProvider>(context, listen: false);
//   late final int profileId = session.userData?['profileId'];
//   late final int? selectedProfile = session.selectedProfileId; // adjust name if needed
//
//   late final bool shouldCallApi = profileId == selectedProfile;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     setOrientation();
//     exerciseGroups = widget.exercises;
//
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _initCamera();   // ✅ CORRECT PLACE
//
//       _findFirstIncompleteExercise();
//
//       await Future.delayed(const Duration(milliseconds: 100));
//
//       await _loadVideo();
//     });
//   }
//
//   void _findFirstIncompleteExercise() {
//     bool found = false;
//
//     for (int groupIdx = 0; groupIdx < exerciseGroups.length; groupIdx++) {
//       final group = exerciseGroups[groupIdx];
//       final exercises = group['exercises'] as List<dynamic>;
//
//       for (int exIdx = 0; exIdx < exercises.length; exIdx++) {
//         final exercise = exercises[exIdx];
//
//         if (!exercise['isExerciseComplete']) {
//           final loopExercises = exercise['loopExercises'] as List<dynamic>;
//           for (int loopIdx = 0; loopIdx < loopExercises.length; loopIdx++) {
//             final loopExercise = loopExercises[loopIdx];
//
//             if (!loopExercise['isLoopComplete']) {
//               setState(() {
//                 currentExerciseName = exercise['name'] ?? "Exercise";
//                 currentLoopName = loopExercise['name'] ?? "Loop";
//
//                 currentGroupIndex = groupIdx;
//                 currentExerciseIndex = exIdx;
//                 currentLoopIndex = loopIdx;
//                 currentGroupNo = group['exerciseGroupID'];
//                 currentEducationalVideoUrl =
//                 exercise['explainerVideo']['videoURL'];
//                 currentExerciseVideoUrl = loopExercise['videoURL'];
//                 currentScheduleId = loopExercise['prescriptionScheduleID'];
//                 totalRepsForCurrentLoop = loopExercise['requiredLoopCount'];
//                 _isPlayingRepsVideo = false;
//                 completedReps = 0;
//                 completedTicks = 0;
//               });
//               found = true;
//               break;
//             }
//           }
//
//           if (found) break;
//         }
//         if (found) break;
//       }
//       if (found) break;
//     }
//
//     if (!found && exerciseGroups.isNotEmpty) {
//       final firstGroup = exerciseGroups[0];
//       final firstExercise = firstGroup['exercises'][0];
//       final firstLoop = firstExercise['loopExercises'][0];
//
//       setState(() {
//         currentGroupIndex = 0;
//         currentExerciseIndex = 0;
//         currentLoopIndex = 0;
//         currentGroupNo = firstGroup['exerciseGroupID'];
//         currentEducationalVideoUrl = firstExercise['explainerVideo']['videoURL'];
//         currentExerciseVideoUrl = firstLoop['videoURL'];
//         currentScheduleId = firstLoop['prescriptionScheduleID'];
//         totalRepsForCurrentLoop = firstLoop['requiredLoopCount'];
//         _isPlayingRepsVideo = false;
//         completedReps = 0;
//         completedTicks = 0;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _player.dispose();
//     _overlayTimer?.cancel();
//
//     if (_videoReady) {
//       _disposeVideo();
//     }
//
//     resetOrientation();
//     _cameraController?.dispose();
//     _nextExerciseTimer?.cancel();
//
//     super.dispose();
//   }
//
//   // ✅✅ FIX 1: safe dispose + try catch
//   Future<void> _disposeVideo() async {
//     try {
//       await _player.pause();
//       await _player.stop();
//       await _player.seek(Duration.zero);
//     } catch (_) {}
//   }
//
//   int scheduleId = 0;
//   String reason = "";
//
//   Future<void> sendExerciseResponse(bool shouldPop, int selected) async {
//     if (_isSubmitting) return;
//     _isSubmitting = true;
//
//     Map<String, dynamic>? response;
//
//     try {
//       // 🔹 build reason
//       reason = "";
//       if (selected == 1) reason = "Tiring";
//       if (selected == 2) reason = "Difficult";
//       if (selected == 3) reason = "Painful";
//       if (selected == 4) reason = "Need help";
//
//       final session = Provider.of<SessionProvider>(context, listen: false);
//
//       final int profileId = session.userData?['profileId'];
//       final int? selectedProfileId = session.selectedProfileId; // <-- adjust name if needed
//
//       final bool shouldCallApi = profileId == selectedProfileId;
//
//       // 🔹 API CALL (only when allowed)
//       if (shouldCallApi) {
//         response = await ApiService.updateExerciseResponse(
//           context: context,
//           userToken: session.userData?['user_token']!,
//           userId: session.userData?['userId']!,
//           profileId: profileId,
//           scheduleId: currentScheduleId,
//           reason: reason,
//         );
//
//         if (!mounted) return;
//
//         if (response['code'] != 200) {
//           return; // ❌ stop only if API fails
//         }
//       }
//
//       // 🔹 FLOW CONTINUES (API or no API)
//       _markCurrentLoopComplete();
//
//       if (_hasMoreLoopsInCurrentExercise()) {
//         _moveToNextLoopInSameExercise();
//         await _loadRepsVideo();
//         return;
//       }
//
//       _markCurrentExerciseComplete();
//
//       if (_hasMoreExercisesInCurrentGroup()) {
//         _startNextExerciseCountdown(() async {
//           _moveToNextExerciseInSameGroup();
//           await _loadVideo();
//         });
//         return;
//       }
//
//       // 🔹 GROUP COMPLETED
//       if (_hasMoreGroups()) {
//         nextGroupStartDialog();
//         return;
//       }
//
//       // 🔹 ALL GROUPS COMPLETED
//       congratsLeaderboard(
//         response ?? {"data": {"score": 0}},
//         reason,
//       );
//
//     } catch (e) {
//       debugPrint("sendExerciseResponse Error: $e");
//     } finally {
//       _isSubmitting = false;
//     }
//   }
//
//
//   void _markCurrentLoopComplete() {
//     setState(() {
//       exerciseGroups[currentGroupIndex]['exercises'][currentExerciseIndex]
//       ['loopExercises'][currentLoopIndex]['isLoopComplete'] = true;
//     });
//   }
//
//   void _markCurrentExerciseComplete() {
//     setState(() {
//       exerciseGroups[currentGroupIndex]['exercises'][currentExerciseIndex]
//       ['isExerciseComplete'] = true;
//     });
//   }
//
//   bool _hasMoreLoopsInCurrentExercise() {
//     final currentExercise = exerciseGroups[currentGroupIndex]['exercises']
//     [currentExerciseIndex];
//     final loopExercises = currentExercise['loopExercises'] as List<dynamic>;
//     return currentLoopIndex < loopExercises.length - 1;
//   }
//
//   bool _hasMoreExercisesInCurrentGroup() {
//     final currentGroup = exerciseGroups[currentGroupIndex];
//     final exercises = currentGroup['exercises'] as List<dynamic>;
//     return currentExerciseIndex < exercises.length - 1;
//   }
//
//   bool _hasMoreGroups() {
//     return currentGroupIndex < exerciseGroups.length - 1;
//   }
//
//   void _moveToNextLoopInSameExercise() {
//     setState(() {
//       currentLoopIndex++;
//       final nextLoop = exerciseGroups[currentGroupIndex]['exercises']
//       [currentExerciseIndex]['loopExercises'][currentLoopIndex];
//       currentExerciseVideoUrl = nextLoop['videoURL'];
//       currentScheduleId = nextLoop['prescriptionScheduleID'];
//       totalRepsForCurrentLoop = nextLoop['requiredLoopCount'];
//       currentLoopName = nextLoop['name'] ?? "Loop Exercise";
//
//       completedReps = 0;
//       completedTicks = 0;
//       _isPlayingRepsVideo = true;
//     });
//   }
//
//   void _moveToNextExerciseInSameGroup() {
//     setState(() {
//       currentExerciseIndex++;
//       currentLoopIndex = 0;
//
//       final nextExercise =
//       exerciseGroups[currentGroupIndex]['exercises'][currentExerciseIndex];
//       final nextLoop = nextExercise['loopExercises'][0];
//
//       currentExerciseName = nextExercise['name'] ?? "Exercise";
//       currentLoopName = nextLoop['name'] ?? "Loop Exercise";
//
//       currentEducationalVideoUrl = nextExercise['explainerVideo']['videoURL'];
//       currentExerciseVideoUrl = nextLoop['videoURL'];
//       currentScheduleId = nextLoop['prescriptionScheduleID'];
//       totalRepsForCurrentLoop = nextLoop['requiredLoopCount'];
//
//       completedReps = 0;
//       completedTicks = 0;
//       _isPlayingRepsVideo = false;
//     });
//   }
//
//   void _moveToNextGroup() {
//     setState(() {
//       currentGroupIndex++;
//       currentExerciseIndex = 0;
//       currentLoopIndex = 0;
//
//       final nextGroup = exerciseGroups[currentGroupIndex];
//       final nextExercise = nextGroup['exercises'][0];
//       final nextLoop = nextExercise['loopExercises'][0];
//
//       // ✅ FIX: update names
//       currentExerciseName = nextExercise['name'] ?? "Exercise";
//       currentLoopName = nextLoop['name'] ?? "Loop Exercise";
//
//       currentGroupNo = nextGroup['exerciseGroupID'];
//       currentEducationalVideoUrl =
//       nextExercise['explainerVideo']['videoURL'];
//       currentExerciseVideoUrl = nextLoop['videoURL'];
//       currentScheduleId = nextLoop['prescriptionScheduleID'];
//       totalRepsForCurrentLoop = nextLoop['requiredLoopCount'];
//
//       completedReps = 0;
//       completedTicks = 0;
//       _isPlayingRepsVideo = false;
//     });
//
//     _loadVideo(); // ✅ keep this AFTER setState
//   }
//
//   void backButtonDialog() {
//     if (_videoReady) {
//       _player.pause();   // ✅ media_kit way
//     }
//
//     showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (context) {
//         return Dialog(
//           insetPadding: EdgeInsets.zero,
//           backgroundColor: Colors.transparent,
//           child: Container(
//             padding: EdgeInsets.all(16),
//             height: 320,
//             width: 320,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(.5),
//                   blurRadius: 4.0,
//                   spreadRadius: 1.0,
//                   offset: Offset(0.0, 2.0),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   height: 120,
//                   width: 120,
//                   decoration: BoxDecoration(
//                     image: DecorationImage(
//                       image: AssetImage(EXERCISE_VIEW_AVATAR),
//                     ),
//                   ),
//                 ),
//                 Text(
//                   "We noticed you're leaving before finishing.\nYou can always come back and complete the exercise.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontFamily: "Alegreya_Sans", fontSize: 16),
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [Color(0xff59A3CB), Color(0xff116594)],
//                           ),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: const [
//                             Text(
//                               "Stay",
//                               style: TextStyle(
//                                 fontFamily: "Alegreya_Sans",
//                                 fontSize: 16,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             Icon(Icons.play_arrow, size: 16, color: Colors.white),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 16),
//                     Expanded(
//                       child: ScaleButton(
//                         onTap: () async {
//                           if (_cameraController != null) {
//                             _cameraController?.dispose();
//                           }
//
//                           await _disposeVideo();
//
//                           Navigator.pop(context);
//                           resetOrientation();
//
//                           Provider.of<IndexProvider>(context, listen: false)
//                               .setIndex(0);
//
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => BridgeScreen(),
//                             ),
//                           );
//                         },
//                         child: Container(
//                           width: double.infinity,
//                           padding: EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [Color(0xff3249B8), Color(0xff5F32B8)],
//                             ),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text("Leave",
//                                   style: TextStyle(
//                                       fontFamily: "Alegreya_Sans",
//                                       fontSize: 16,
//                                       color: Colors.white)),
//                               Icon(Icons.home,
//                                   size: 16, color: Colors.white),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Future<void> _handleSkip() async {
//     if (!_isPlayingRepsVideo) {
//       _loadRepsVideo();
//     } else {
//       await _disposeVideo();
//       onComplete();
//     }
//   }
//
//   // ✅✅ FIX 2: Educational video init with try/catch
//   Future<void> _loadVideo() async {
//     await _disposeVideo(); // ✅ IMPORTANT
//
//     final exercise =
//     exerciseGroups[currentGroupIndex]['exercises'][currentExerciseIndex];
//
//     final int? videoId = exercise['explainerVideo']?['videoID'];
//
//     if (videoId == null) {
//       debugPrint("❌ EDUCATIONAL videoId is NULL");
//       return;
//     }
//
//     final url = buildStreamUrl(
//       videoId: videoId,
//       type: "educational",
//     );
//
//     try {
//       await _player.open(Media(url), play: true);
//
//       setState(() {
//         _videoReady = true;
//         _isPlayingRepsVideo = false;
//       });
//     } catch (e) {
//       debugPrint("❌ Educational video error: $e");
//     }
//   }
//
//   // ✅✅ FIX 3: Reps video init with try/catch
//   Future<void> _loadRepsVideo() async {
//     await _disposeVideo();
//
//     final loop =
//     exerciseGroups[currentGroupIndex]['exercises'][currentExerciseIndex]
//     ['loopExercises'][currentLoopIndex];
//
//     final int? videoId = loop['loopExerciseID'];
//
//     if (videoId == null) return;
//
//     final url = buildStreamUrl(
//       videoId: videoId,
//       type: "loop",
//     );
//
//     try {
//       await _player.open(Media(url), play: true);
//
//       setState(() {
//         _videoReady = true;
//         _isPlayingRepsVideo = true;
//         completedReps = 0;
//       });
//
//       // ✅ IMPORTANT FIX: track position instead of completed
//       _player.stream.position.listen((position) {
//         final duration = _player.state.duration;
//
//         if (duration != null &&
//             position >= duration - const Duration(milliseconds: 300)) {
//
//           if (_repHandled) return;
//           _repHandled = true;
//
//           if (completedReps < totalRepsForCurrentLoop - 1) {
//             setState(() {
//               completedReps++;
//             });
//
//             _player.seek(Duration.zero);
//             _player.play();
//
//             Future.delayed(const Duration(milliseconds: 300), () {
//               _repHandled = false;
//             });
//
//           } else {
//             onComplete();
//           }
//         }
//       });
//
//     } catch (e) {
//       debugPrint("❌ Loop video error: $e");
//     }
//   }
//
//   CameraController? _cameraController;
//   late List<CameraDescription> _cameras;
//   bool _isInitialized = false;
//
//   Future<void> _initCamera() async {
//     try {
//       _cameras = await availableCameras();
//
//       final frontCamera = _cameras.firstWhere(
//             (camera) => camera.lensDirection == CameraLensDirection.front,
//       );
//
//       _cameraController = CameraController(
//         frontCamera,
//         ResolutionPreset.medium,
//         enableAudio: false,
//       );
//
//       await _cameraController!.initialize();
//
//       if (!mounted) return;
//
//       setState(() {
//         _isInitialized = true;
//       });
//
//     } catch (e) {
//       debugPrint("❌ Camera init error: $e");
//     }
//   }
//
//   bool enableCamera = true;
//
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: canPop,
//       onPopInvokedWithResult: (bool didPop, result) {
//         onComplete();
//
//         if (_videoReady) {
//           _player.pause();   // ✅ media_kit way
//         }
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: SafeArea(
//           child: Center(
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 // Main content when video is ready
//                 if (!_videoReady)
//                   const Center(child: CircularProgressIndicator()),
//
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20, right: 20),
//                   child: Row(
//                     children: [
//                       // Video Player Section
//                       Expanded(
//                         flex: 2,
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             GestureDetector(
//                               onTap: _handleScreenTap,
//                               child: AspectRatio(
//                                 aspectRatio: 2 / 1,
//                                 child: Stack(
//                                   children: [
//                                     if (_videoReady)
//                                       AspectRatio(
//                                         aspectRatio: 16 / 9,
//                                         child: Video(
//                                           controller: _videoController,
//                                           controls: AdaptiveVideoControls,
//                                         ),
//                                       ),
//
//                                     Positioned(
//                                       top: 10,
//                                       right: 10,
//                                       child: Align(
//                                         child: Container(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 12, vertical: 8),
//                                           decoration: BoxDecoration(
//                                             color:
//                                             Colors.black.withOpacity(0.5),
//                                             borderRadius:
//                                             BorderRadius.circular(10),
//                                           ),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                             CrossAxisAlignment.end,
//                                             mainAxisSize: MainAxisSize.min,
//                                             children: [
//                                               Text(
//                                                 currentExerciseName,
//                                                 style: const TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.w600,
//                                                   fontFamily: "Alegreya_Sans",
//                                                 ),
//                                               ),
//
//                                               const SizedBox(height: 2),
//
//                                               Text(
//                                                 "Exercise ${getExerciseProgressText()}",
//                                                 style: const TextStyle(
//                                                   color: Colors.white70,
//                                                   fontSize: 14,
//                                                   fontFamily: "Alegreya_Sans",
//                                                 ),
//                                               ),
//
//                                               if (_isPlayingRepsVideo) ...[
//                                                 const SizedBox(height: 3),
//
//                                                 Text(
//                                                   currentLoopName,
//                                                   style: const TextStyle(
//                                                     color: Colors.white70,
//                                                     fontSize: 14,
//                                                     fontWeight: FontWeight.w500,
//                                                     fontFamily: "Alegreya_Sans",
//                                                   ),
//                                                 ),
//
//                                                 Text(
//                                                   "Loop ${getLoopProgressText()}",
//                                                   style: const TextStyle(
//                                                     color: Colors.white,
//                                                     fontSize: 14,
//                                                     fontWeight: FontWeight.w600,
//                                                     fontFamily: "Alegreya_Sans",
//                                                   ),
//                                                 ),
//                                               ],
//                                             ],
//
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//
//                                     // overlay buttons (your same)
//                                     if (showOverlay && isPlaying)
//                                       GestureDetector(
//                                         onTap: _hideOverlay,
//                                         child: Container(
//                                           width: double.infinity,
//                                           height: double.infinity,
//                                           color: Colors.black.withOpacity(0.5),
//                                           child: Center(
//                                             child: SizedBox(
//                                               width: 300,
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                 MainAxisAlignment
//                                                     .spaceBetween,
//                                                 children: [
//                                                   SizedBox(width: 50),
//                                                   GestureDetector(
//                                                     onTap: _togglePlayPause,
//                                                     child: Container(
//                                                       width: 65,
//                                                       height: 65,
//                                                       decoration: BoxDecoration(
//                                                         color: Colors.black
//                                                             .withOpacity(0.5),
//                                                         shape: BoxShape.circle,
//                                                         border: Border.all(
//                                                           color: Colors.white
//                                                               .withOpacity(0.8),
//                                                           width: 2,
//                                                         ),
//                                                       ),
//                                                       child: Icon(
//                                                         Icons.pause_rounded,
//                                                         size: 40,
//                                                         color: Colors.white,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   GestureDetector(
//                                                     onTap: _handleSkip,
//                                                     child: Container(
//                                                       width: 50,
//                                                       height: 50,
//                                                       decoration: BoxDecoration(
//                                                         color: Colors.black
//                                                             .withOpacity(0.5),
//                                                         shape: BoxShape.circle,
//                                                         border: Border.all(
//                                                           color: Colors.white
//                                                               .withOpacity(0.8),
//                                                           width: 2,
//                                                         ),
//                                                       ),
//                                                       child: Icon(
//                                                         Icons.skip_next_rounded,
//                                                         size: 30,
//                                                         color: Colors.white,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//
//                                     if (!isPlaying && showOverlay)
//                                       Center(
//                                         child: SizedBox(
//                                           width: 300,
//                                           child: Row(
//                                             mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               SizedBox(width: 50),
//                                               GestureDetector(
//                                                 onTap: _togglePlayPause,
//                                                 child: Container(
//                                                   width: 65,
//                                                   height: 65,
//                                                   decoration: BoxDecoration(
//                                                     color: Colors.black
//                                                         .withOpacity(0.5),
//                                                     shape: BoxShape.circle,
//                                                     border: Border.all(
//                                                       color: Colors.white
//                                                           .withOpacity(0.8),
//                                                       width: 2,
//                                                     ),
//                                                   ),
//                                                   child: Icon(
//                                                     Icons.play_arrow_rounded,
//                                                     size: 40,
//                                                     color: Colors.white,
//                                                   ),
//                                                 ),
//                                               ),
//                                               GestureDetector(
//                                                 onTap: _handleSkip,
//                                                 child: Container(
//                                                   width: 50,
//                                                   height: 50,
//                                                   decoration: BoxDecoration(
//                                                     color: Colors.black
//                                                         .withOpacity(0.5),
//                                                     shape: BoxShape.circle,
//                                                     border: Border.all(
//                                                       color: Colors.white
//                                                           .withOpacity(0.8),
//                                                       width: 2,
//                                                     ),
//                                                   ),
//                                                   child: Icon(
//                                                     Icons.skip_next_rounded,
//                                                     size: 30,
//                                                     color: Colors.white,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       SizedBox(width: 20),
//
//                       _isInitialized && enableCamera
//                           ? Expanded(
//                         flex: 2,
//                         child: AspectRatio(
//                           aspectRatio: 1,
//                           child: Transform(
//                             alignment: Alignment.center,
//                             transform: Matrix4.rotationY(math.pi),
//                             child: CameraPreview(_cameraController!),
//                           ),
//                         ),
//                       )
//                           : SizedBox(),
//                     ],
//                   ),
//                 ),
//
//                 Positioned(
//                   top: 0,
//                   right: 0,
//                   bottom: 0,
//                   left: 0,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             SizedBox(height: 55, width: 55),
//                             _isPlayingRepsVideo
//                                 ? Container(
//                               height: 100,
//                               width: 100,
//                               decoration: BoxDecoration(
//                                 color: Color(0xff000000).withOpacity(0.8),
//                                 borderRadius: BorderRadius.circular(20),
//                                 border: Border.all(
//                                     color: Color(0xFF00E5FF)),
//                               ),
//                               alignment: Alignment.center,
//                               child: CircularTickCounter(
//                                 totalTicks: 30,
//                                 completedTicks: (((completedReps + 1) / totalRepsForCurrentLoop) * 30)
//                                     .floor()
//                                     .clamp(1, 30),
//                                 completedReps: completedReps + 1,
//                                 totalReps: totalRepsForCurrentLoop,
//                                 size: 100,
//                                 label: "REP",
//                               ),
//
//
//                             )
//                                 : SizedBox(height: 55, width: 55),
//                           ],
//                         ),
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             ScaleButton(
//                               onTap: backButtonDialog,
//                               child: Container(
//                                   height: 45,
//                                   width: 45,
//                                   decoration: BoxDecoration(
//                                       shape: BoxShape.circle,
//                                       color: Colors.white),
//                                   alignment: Alignment.center,
//                                   child: Icon(Icons.clear_rounded,
//                                       size: 30, color: Color(0xff054A9E))),
//                             ),
//                             ScaleButton(
//                               onTap: () {
//                                 setState(() {
//                                   enableCamera = !enableCamera;
//                                 });
//                               },
//                               child: Image.asset(
//                                 height: 55,
//                                 width: 55,
//                                 EXERCISES_CAMERA_BUTTON,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 if (_showNextExerciseOverlay)
//                   Positioned.fill(
//                     child: Container(
//                       color: Colors.black.withOpacity(0.7),
//                       child: Center(
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               "Next exercise starts in",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 20,
//                                 fontFamily: "Alegreya_Sans",
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             Text(
//                               "$_nextExerciseCountdown",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 48,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             ScaleButton(
//                               onTap: () async {
//                                 _hideNextExerciseOverlay();
//                                 _moveToNextExerciseInSameGroup();
//                                 await _loadVideo();
//                               },
//                               child: Container(
//                                 padding:
//                                 const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//                                 decoration: BoxDecoration(
//                                   gradient: const LinearGradient(
//                                     colors: [Color(0xff59A3CB), Color(0xff116594)],
//                                   ),
//                                   borderRadius: BorderRadius.circular(30),
//                                 ),
//                                 child: const Text(
//                                   "Next Exercise",
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 18,
//                                     fontFamily: "Alegreya_Sans",
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }