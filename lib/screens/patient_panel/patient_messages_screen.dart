import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myocircle15screens/components/components_path.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../providers/session_provider.dart';
import '../../components/custom_dropdown.dart';
import '../../services/api_service.dart';
import 'select_profile_screen.dart';

class PatientMessagesScreen extends StatefulWidget {
  const PatientMessagesScreen({super.key});

  @override
  State<PatientMessagesScreen> createState() => _PatientMessagesScreenState();
}

class _PatientMessagesScreenState extends State<PatientMessagesScreen> {
  List<dynamic> _messages = [];
  Timer? _timer;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Delay the initial fetch until after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMessages();
    });

    _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (mounted) {
        _fetchMessages();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _fetchMessages() async {
    final session = Provider.of<SessionProvider>(context, listen: false);
    final userData = session.userData;
    final userToken = userData?['user_token'];
    final userId = userData?['userId'];
    final profileId = session.selectedProfileId;

    if (userToken == null || userId == null || profileId == null) return;
    final response = await ApiService.getMessage(
      context,
      userToken,
      profileId,
      userId,
    );

    if (response['status'] == 200 && mounted) {
      setState(() {
        _messages = response['data']['messages'] ?? [];
      });
      // Scroll to bottom after messages are loaded
      _scrollToBottom();
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final session = Provider.of<SessionProvider>(context, listen: false);
    final userData = session.userData;
    final userToken = userData?['user_token'];
    final userId = userData?['userId'];
    final profileId = session.selectedProfileId;

    if (userToken == null || userId == null || profileId == null) return;

    final response = await ApiService.sendMessage(
      context,
      userToken,
      profileId,
      userId,
      text,
    );

    if (response['status'] == 200) {
      _messageController.clear();
      await _fetchMessages();
      // Scroll to bottom after sending message
      _scrollToBottom();
    }
  }

  Widget _buildTherapistMessage(String message, dynamic landingPageData) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(MESSAGE_CONTAINER),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      message,
                      style: const TextStyle(
                          fontSize: 16, fontFamily: "Alegreya_Sans"),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Container(
              height: 70,
              width: 70,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 7,
                    spreadRadius: 1,
                    offset: Offset(8, 8),
                  )
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(DOCTOR_AVATAR_BG),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Image.asset(DOCTOR_TEST, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Image.asset(DOCTOR_AVATAR_RING, fit: BoxFit.fill),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientMessage(String message, dynamic landingPageData) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Container(
              height: 80,
              width: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 7,
                    spreadRadius: 1,
                    offset: Offset(-2, 4),
                  )
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(AVATAR_CONTAINER_INNER),
                        ),
                      ),
                      child: Skeletonizer(
                        enabled: landingPageData == null,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: landingPageData == null
                              ? AspectRatio(
                                  aspectRatio: 2 / 2,
                                  child: displayBase64Image(defaultBase64),
                                )
                              : Base64ImageWidget(
                                  key: UniqueKey(),
                                  base64String:
                                      landingPageData['patientAvatarURL'],
                                ),
                        ),
                      ),
                    ),
                  ),
                  Image.asset(AVATAR_CONTAINER_OUTER),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(MESSAGE_CONTAINER2),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    message,
                    style: const TextStyle(
                        fontSize: 16, fontFamily: "Alegreya_Sans"),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionProvider>(context, listen: false);
    final landingPageData = session.landingPageData;
    final userData = session.userData;
    final familyMembers = userData?['familyMembers'];
    final therapistProfileImage = userData?['therapistProfileImage'];
    String therapistName = userData?['therapistInfo']['firstName'] +
        ' ' +
        userData?['therapistInfo']['lastName'];

    return Column(
      children: [
        Container(
          height: 45,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Color(0xffF6F5F3),
              Color(0xff1349D1),
              Color(0xff1349D1),
              Color(0xffF6F5F3),
            ]),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 2, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 45,
                  width: 45,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(AVATAR_RING), // ring background
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: ClipOval(
                          child: (userData?['therapistInfo']?['therapistProfileImage'] != null &&
                              userData!['therapistInfo']['therapistProfileImage']
                                  .toString()
                                  .isNotEmpty)
                              ? Image.memory(
                            base64Decode(
                              userData['therapistInfo']['therapistProfileImage'].contains(',')
                                  ? userData['therapistInfo']['therapistProfileImage']
                                  .split(',')
                                  .last
                                  : userData['therapistInfo']['therapistProfileImage'],
                            ),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                              : Image.asset(
                            DOCTOR_TEST,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Your therapist: ${therapistName}",
                  style: TextStyle(
                      fontSize: 16,
                      color: Color(0xffFFFFFF),
                      fontWeight: FontWeight.bold,
                      fontFamily: "Alegreya_Sans"),
                ),
              ],
            ),
          ),
        ),
        if (familyMembers.length > 1)
          Container(
            height: 50,
            child: Skeletonizer(
              effect: ShimmerEffect(
                duration: Duration(milliseconds: 1500),
                baseColor: Colors.black12,
                highlightColor: Colors.white10,
              ),
              enabled: landingPageData?['profileName'] == null,
              child: Consumer<SessionProvider>(
                builder: (context, session, _) {
                  final userData = session.userData;
                  final family = userData?['familyMembers'] ?? [];
                  final selectedProfileId =
                      session.selectedProfileId ?? userData?['profileId'];

                  final Set<int> seenIds = {};
                  final List<DropdownMenuItem<int>> dropdownItems = [];
                  for (final member in family) {
                    final int profileId = member['profileId'];
                    if (seenIds.add(profileId)) {
                      dropdownItems.add(
                        DropdownMenuItem<int>(
                          value: profileId,
                          child: Text(member['userProfileName']),
                        ),
                      );
                    }
                  }

                  final containsSelected = dropdownItems
                      .any((item) => item.value == selectedProfileId);
                  final int? safeValue = containsSelected
                      ? selectedProfileId
                      : dropdownItems.first.value;

                  return Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      focusColor: Colors.transparent,
                    ),
                    child: SizedBox(
                      width: 200,
                      height: 82,
                      child: Container(
                        padding: EdgeInsets.only(top: 8),
                        child: CustomDropdown<int>(
                          value: safeValue,
                          items: userData?['familyMembers']
                                  ?.map<int>((m) => m['profileId'] as int)
                                  .toList() ??
                              [],

                          // ----------------- ITEM BUILDER (Beautiful UI) -----------------
                          itemBuilder: (context, item, selected) {
                            final member = userData?['familyMembers']
                                ?.firstWhere((m) => m['profileId'] == item);

                            final name =
                                member?['userProfileName'] ?? "Unknown";
                            final age = member?['age'];

                            return Container(
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xAACFFAFE)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              child: Row(
                                children: [
                                  Container(
                                    height: 24,
                                    width: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: selected
                                          ? Color(0xFF0891B2)
                                          : Color(0xff999999),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                        (int.parse(age) >= 18)
                                            ? Icons.person_rounded
                                            : Icons.child_care_rounded,
                                        size: 20,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontFamily: "Alegreya_Sans",
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  selected
                                      ? Icon(
                                          Icons.check_rounded,
                                          size: 24,
                                          color: Color(0xFF0891B2),
                                        )
                                      : SizedBox(width: 24),
                                ],
                              ),
                            );
                          },

                          // ----------------- SELECTED ITEM BUILDER -----------------
                          selectedItemBuilder: (context, item, selected) {
                            final member = userData?['familyMembers']
                                ?.firstWhere((m) => m['profileId'] == item);

                            final name =
                                member?['userProfileName'] ?? "Unknown";

                            return Center(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontFamily: "Alegreya_Sans",
                                  color: Color(0xff8E8E93),
                                ),
                              ),
                            );
                          },

                          // ----------------- DROPDOWN STYLING -----------------
                          backgroundColor: Colors.white,
                          menuBackgroundColor: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                          buttonHeight: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 14),

                          // Beautiful caret
                          showCaret: true,
                          caretIcon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 26,
                            color: Colors.deepPurple,
                          ),

                          // ----------------- LOGIC (YOUR ORIGINAL CODE) -----------------
                          onChanged: (int? newProfileId) async {
                            if (newProfileId != null &&
                                newProfileId != session.selectedProfileId) {
                              session.setSelectedProfileId(newProfileId);
                              _fetchMessages();

                              final _userToken = userData?['user_token'];
                              final _userId = userData?['userId'];

                              var getResponse = await ApiService.landingPage(
                                context,
                                _userToken,
                                newProfileId,
                                _userId,
                              );

                              if (getResponse['code'] == 200 &&
                                  context.mounted) {
                                session.setLandingPageData(getResponse['data']);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            controller: _scrollController, // Add scroll controller
            reverse: true, // This makes the list start from the bottom
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              // Reverse the index to show most recent at bottom
              final reversedIndex = _messages.length - 1 - index;
              final msg = _messages[reversedIndex];
              final from = msg['from'];
              final text = msg['message'] ?? '';

              if (from == "Therapist") {
                return _buildTherapistMessage(text, landingPageData);
              } else {
                return _buildPatientMessage(text, landingPageData);
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              // gradient: const LinearGradient(
              //   colors: [Color(0xff999999), Color(0xff999999)],
              // ),
              gradient: LinearGradient(colors: [
                Color(0xff1349D1),
                Color(0xffF6F5F3),
                Color(0xff1349D1),
              ]),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 9,
                    child: TextField(
                      cursorColor: Color(0xff0D4081),
                      controller: _messageController,
                      decoration: InputDecoration(
                        filled: true,
                        // fillColor: const Color(0xffE6E6E6),
                        fillColor: Colors.blue.shade100,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: _sendMessage,
                      child: Image.asset(SEND_BTN,color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
