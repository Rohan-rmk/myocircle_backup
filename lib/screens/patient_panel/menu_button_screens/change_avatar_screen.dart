import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myocircle15screens/providers/session_provider.dart';
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'dart:io';
import 'package:myocircle15screens/services/api_service.dart';

import '../../../components/components_path.dart';
import '../../../components/profile_header.dart';
import '../../../enums/patient_tab.dart';
import '../../../providers/first_time_user_provider.dart';
import '../../../providers/index_provider.dart';
import '../../onboarding/setup_profile_screen.dart';
import '../patient_master_screen.dart';

class ChangeAvatarScreen extends StatefulWidget {
  const ChangeAvatarScreen({super.key});

  @override
  State<ChangeAvatarScreen> createState() => _ChangeAvatarScreenState();
}

class _ChangeAvatarScreenState extends State<ChangeAvatarScreen> {
  File? _image; // Variable to store the selected image

  final ImagePicker _picker = ImagePicker(); // Instance of ImagePicker

  // Function to pick an image from the gallery or camera
  bool imageLoading = false;
  Future<void> _pickImage() async {
    setState(() {
      imageLoading = true;
    });

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      final int sizeInBytes = await file.length();
      final double sizeInMB = sizeInBytes / (1024 * 1024);

      if (sizeInMB > 10) {
        setState(() {
          imageLoading = false;
        });

        SnackbarHelper.showSnackbar("Image must be less than 10 MB",
            color: Colors.red);
        return;
      }

      setState(() {
        _image = file;
        avatarIndex = -1;
        imageLoading = false;
      });
    } else {
      setState(() {
        imageLoading = false;
      });
    }
  }

  bool _didLoad = false;
  int? avatarIndex;
  List<dynamic> avatarsData = [];
  void getAvatars() async {
    final _userToken = Provider.of<SessionProvider>(context, listen: false)
        .userData?['user_token'];
    var getDefaultAvatarsResponse =
        await ApiService.getDefaultProfileAvatars(_userToken!, context);
    if (getDefaultAvatarsResponse['status'] == 200) {
      if (mounted)
        setState(() {
          avatarsData = getDefaultAvatarsResponse['data'];
          for (var avatar in avatarsData) {
            print(avatar['avatarUrl']);
            print(Provider.of<SessionProvider>(context, listen: false)
                .landingPageData?['patientAvatarURL']);

            if (avatar['avatarUrl'] ==
                Provider.of<SessionProvider>(context, listen: false)
                    .landingPageData?['patientAvatarURL']) {
              setState(() {
                avatarIndex = avatarsData.indexOf(avatar);
              });
            }
          }
        });
    }
  }

  void landingPage() async {
    final _userToken = Provider.of<SessionProvider>(context, listen: false)
        .userData?['user_token'];
    final _userId = Provider.of<SessionProvider>(context, listen: false)
        .userData?['userId'];
    final _profileId = Provider.of<SessionProvider>(context, listen: false)
        .userData?['profileId'];
    int? selectedProfileId =
        Provider.of<SessionProvider>(context, listen: false).selectedProfileId;

    var getResponse = await ApiService.landingPage(context, _userToken,
        selectedProfileId == null ? _profileId : selectedProfileId, _userId);
    if (getResponse['code'] == 200) {
      if (mounted) {
        setState(() {
          Provider.of<SessionProvider>(context, listen: false)
              .setLandingPageData(getResponse['data']);
        });
        Navigator.pop(context);
      }
    }
  }

  ///final session = Provider.of<SessionProvider>(context, listen: false);
  //                       final _selectedProfileId = session.selectedProfileId;
  //                       print("_selectedProfileId");
  //                       print(_selectedProfileId);
  //                       print(_selectedProfileId);


  void updateUserProfileAvatarAndName() async {
    final session = Provider.of<SessionProvider>(context, listen: false);
    final _selectedProfileId = session.selectedProfileId;
    int? selectedAvatar = avatarIndex;
    var updateUserProfileAvatarAndNameResponse =
        await ApiService.updateUserProfileAvatarAndName(
            context: context,
            userToken: Provider.of<SessionProvider>(context, listen: false)
                .userData?['user_token']!,
            userId: Provider.of<SessionProvider>(context, listen: false)
                .userData?['userId']!,
            profileId: session.isPatient == true? Provider.of<SessionProvider>(context, listen: false)
                .userData!['profileId']:_selectedProfileId,
            profileName: usernameController.text,
            base64Image: avatarsData[selectedAvatar!]['avatarUrl']);
    if (updateUserProfileAvatarAndNameResponse['status'] == 200) {
      context.read<SessionProvider>().setSelectedProfileName(usernameController.text);
      showComplete();
    }
  }

  void updateUserProfilePhotoAndName() async {
    var updateUserProfilePhotoAndNameResponse =
        await ApiService.updateUserProfilePhotoAndName(
            context: context,
            userToken: Provider.of<SessionProvider>(context, listen: false)
                .userData?['user_token']!,
            userId: Provider.of<SessionProvider>(context, listen: false)
                .userData?['userId']!,
            profileName: usernameController.text,
            profileId: Provider.of<SessionProvider>(context, listen: false)
                .userData?['profileId']!,
            imageFile: _image!);
    if (updateUserProfilePhotoAndNameResponse['status'] == 200) {
      context.read<SessionProvider>().setSelectedProfileName(usernameController.text);
      showComplete();
    }
  }

  Future<String> convertImageToBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64String = base64Encode(imageBytes);
    return base64String;
  }

  Widget displayBase64Image(String base64String) {
    try {
      Uint8List bytes = base64Decode(base64String);
      return Image.memory(
        fit: BoxFit.cover,
        bytes,
        errorBuilder: (context, error, stackTrace) {
          return const Text('Failed to decode image');
        },
      );
    } catch (e) {
      return const Text('Invalid image data');
    }
  }

  TextEditingController usernameController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _didLoad = true;
        getAvatars();
        usernameController.text =
            context.read<SessionProvider>().profileName ?? '';
        print(usernameController.text);
        print("********");
        print(usernameController.text);
      });
    }
  }

  FocusNode usernameFocus = FocusNode();
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int? selectedAvatar = avatarIndex;
    bool uploadPhoto =
        (Provider.of<FirstTimeUserProvider>(context, listen: false).age != "" &&
            int.parse(Provider.of<FirstTimeUserProvider>(context, listen: false)
                    .age) >=
                18);
    return Scaffold(
      backgroundColor: Color(0xfff6f5f3),
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   forceMaterialTransparency: true,
      //   actions: [
      //     Expanded(child: ProfileHeader()),
      //   ],
      // ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Expanded(
                flex: 13,
                child: Column(
                  children: [
                    Text(
                      "Set profile name",
                      style:
                          TextStyle(fontSize: 22, fontFamily: "Alegreya_Sans"),
                    ),
                    Expanded(
                      flex: !uploadPhoto ? 1 : 2,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SvgPicture.asset(
                              TEXTFIELD_CONTAINER_PROFILE,
                              fit: BoxFit.fill,
                            ),
                            Center(
                              child: TextField(
                                controller: usernameController,
                                focusNode: usernameFocus,
                                onTapOutside: (event) {
                                  usernameFocus.unfocus();
                                },
                                style: TextStyle(
                                    fontSize: 26, fontFamily: "Alegreya_Sans"),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      "Select an Avatar",
                      style:
                          TextStyle(fontSize: 22, fontFamily: "Alegreya_Sans"),
                    ),
                    Expanded(
                      flex: !uploadPhoto ? 3 : 8,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: SizedBox()),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    decoration: (selectedAvatar != null &&
                                            selectedAvatar != -1 &&
                                            selectedAvatar == 0)
                                        ? BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(AVATAR_FRAME),
                                                fit: BoxFit.fill))
                                        : null,
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          (selectedAvatar != null &&
                                                  selectedAvatar != -1 &&
                                                  selectedAvatar == 0)
                                              ? 20
                                              : 0),
                                      child: ScaleButton(
                                          onTap: avatarsData.isEmpty
                                              ? null
                                              : () async {
                                                  setState(() {
                                                    avatarIndex = 0;
                                                  });
                                                },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black54,
                                                    blurRadius: 7,
                                                    spreadRadius: 1,
                                                    offset: Offset(-2, 4),
                                                  )
                                                ]),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                              image: AssetImage(
                                                                  AVATAR_CONTAINER_INNER))),
                                                      child: Skeletonizer(
                                                        enabled:
                                                            avatarsData.isEmpty,
                                                        child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50),
                                                            child: avatarsData
                                                                    .isEmpty
                                                                ? AspectRatio(
                                                                    aspectRatio:
                                                                        2 / 2,
                                                                    child: displayBase64Image(
                                                                        defaultBase64))
                                                                : Base64ImageWidget(
                                                                    base64String:
                                                                        avatarsData[0]
                                                                            [
                                                                            'avatarUrl'])),
                                                      )),
                                                ),
                                                Image.asset(
                                                    AVATAR_CONTAINER_OUTER),
                                              ],
                                            ),
                                          )),
                                    ),
                                  ),
                                ),
                                Expanded(flex: 1, child: SizedBox()),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    decoration: (selectedAvatar != null &&
                                            selectedAvatar != -1 &&
                                            selectedAvatar == 1)
                                        ? BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(AVATAR_FRAME),
                                                fit: BoxFit.fill))
                                        : null,
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          (selectedAvatar != null &&
                                                  selectedAvatar != -1 &&
                                                  selectedAvatar == 1)
                                              ? 20
                                              : 0),
                                      child: ScaleButton(
                                          onTap: avatarsData.isEmpty
                                              ? null
                                              : () async {
                                                  setState(() {
                                                    avatarIndex = 1;
                                                  });
                                                },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black54,
                                                    blurRadius: 7,
                                                    spreadRadius: 1,
                                                    offset: Offset(-2, 4),
                                                  )
                                                ]),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                              image: AssetImage(
                                                                  AVATAR_CONTAINER_INNER))),
                                                      child: Skeletonizer(
                                                        enabled:
                                                            avatarsData.isEmpty,
                                                        child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50),
                                                            child: avatarsData
                                                                    .isEmpty
                                                                ? AspectRatio(
                                                                    aspectRatio:
                                                                        2 / 2,
                                                                    child: displayBase64Image(
                                                                        defaultBase64))
                                                                : Base64ImageWidget(
                                                                    base64String:
                                                                        avatarsData[1]
                                                                            [
                                                                            'avatarUrl'])),
                                                      )),
                                                ),
                                                Image.asset(
                                                    AVATAR_CONTAINER_OUTER),
                                              ],
                                            ),
                                          )),
                                    ),
                                  ),
                                ),
                                Expanded(flex: 1, child: SizedBox()),
                              ],
                            ),
                          ),
                          Expanded(flex: 1, child: SizedBox()),
                          Expanded(
                            flex: 5,
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: SizedBox()),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    decoration: (selectedAvatar != null &&
                                            selectedAvatar != -1 &&
                                            selectedAvatar == 2)
                                        ? BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(AVATAR_FRAME),
                                                fit: BoxFit.fill))
                                        : null,
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          (selectedAvatar != null &&
                                                  selectedAvatar != -1 &&
                                                  selectedAvatar == 2)
                                              ? 20
                                              : 0),
                                      child: ScaleButton(
                                          onTap: avatarsData.isEmpty
                                              ? null
                                              : () async {
                                                  setState(() {
                                                    avatarIndex = 2;
                                                  });
                                                },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black54,
                                                    blurRadius: 7,
                                                    spreadRadius: 1,
                                                    offset: Offset(-2, 4),
                                                  )
                                                ]),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                              image: AssetImage(
                                                                  AVATAR_CONTAINER_INNER))),
                                                      child: Skeletonizer(
                                                        enabled:
                                                            avatarsData.isEmpty,
                                                        child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50),
                                                            child: avatarsData
                                                                    .isEmpty
                                                                ? AspectRatio(
                                                                    aspectRatio:
                                                                        2 / 2,
                                                                    child: displayBase64Image(
                                                                        defaultBase64))
                                                                : Base64ImageWidget(
                                                                    base64String:
                                                                        avatarsData[2]
                                                                            [
                                                                            'avatarUrl'])),
                                                      )),
                                                ),
                                                Image.asset(
                                                    AVATAR_CONTAINER_OUTER),
                                              ],
                                            ),
                                          )),
                                    ),
                                  ),
                                ),
                                Expanded(flex: 1, child: SizedBox()),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    decoration: (selectedAvatar != null &&
                                            selectedAvatar != -1 &&
                                            selectedAvatar == 3)
                                        ? BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(AVATAR_FRAME),
                                                fit: BoxFit.fill))
                                        : null,
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          (selectedAvatar != null &&
                                                  selectedAvatar != -1 &&
                                                  selectedAvatar == 3)
                                              ? 20
                                              : 0),
                                      child: ScaleButton(
                                          onTap: avatarsData.isEmpty
                                              ? null
                                              : () async {
                                                  setState(() {
                                                    avatarIndex = 3;
                                                  });
                                                },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black54,
                                                    blurRadius: 7,
                                                    spreadRadius: 1,
                                                    offset: Offset(-2, 4),
                                                  )
                                                ]),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                              image: AssetImage(
                                                                  AVATAR_CONTAINER_INNER))),
                                                      child: Skeletonizer(
                                                        enabled:
                                                            avatarsData.isEmpty,
                                                        child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50),
                                                            child: avatarsData
                                                                    .isEmpty
                                                                ? AspectRatio(
                                                                    aspectRatio:
                                                                        2 / 2,
                                                                    child: displayBase64Image(
                                                                        defaultBase64))
                                                                : Base64ImageWidget(
                                                                    base64String:
                                                                        avatarsData[3]
                                                                            [
                                                                            'avatarUrl'])),
                                                      )),
                                                ),
                                                Image.asset(
                                                    AVATAR_CONTAINER_OUTER),
                                              ],
                                            ),
                                          )),
                                    ),
                                  ),
                                ),
                                Expanded(flex: 1, child: SizedBox()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    uploadPhoto
                        ? Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                Text(
                                  "Upload Photo",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontFamily: "Alegreya_Sans"),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: _image != null &&
                                            (selectedAvatar == null ||
                                                selectedAvatar == -1)
                                        ? BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(AVATAR_FRAME),
                                                fit: BoxFit.fill))
                                        : null,
                                    child: Padding(
                                      padding: EdgeInsets.all(_image != null &&
                                              (selectedAvatar == null ||
                                                  selectedAvatar == -1)
                                          ? 20
                                          : 0),
                                      child: GestureDetector(
                                          onTap:
                                              _pickImage, // Allow the user to upload a photo
                                          child: _image != null
                                              ? AspectRatio(
                                                  aspectRatio: 1 / 1,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color:
                                                                Colors.black54,
                                                            blurRadius: 7,
                                                            spreadRadius: 1,
                                                            offset:
                                                                Offset(-2, 4),
                                                          )
                                                        ]),
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            child: Container(
                                                                decoration: BoxDecoration(
                                                                    image: DecorationImage(
                                                                        image: AssetImage(
                                                                            AVATAR_CONTAINER_INNER),
                                                                        fit: BoxFit
                                                                            .fill)),
                                                                child:
                                                                    ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                50),
                                                                        child: Image
                                                                            .file(
                                                                          _image!,
                                                                          fit: BoxFit
                                                                              .fill,
                                                                        ))),
                                                          ),
                                                        ),
                                                        Image.asset(
                                                            AVATAR_CONTAINER_OUTER),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : AspectRatio(
                                                  aspectRatio: 1 / 1,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color:
                                                                Colors.black54,
                                                            blurRadius: 7,
                                                            spreadRadius: 1,
                                                            offset:
                                                                Offset(-2, 4),
                                                          )
                                                        ]),
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Container(
                                                                decoration: BoxDecoration(
                                                                    image: DecorationImage(
                                                                        image: AssetImage(
                                                                            AVATAR_CONTAINER_INNER),
                                                                        fit: BoxFit
                                                                            .fill)),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              50),
                                                                )),
                                                          ),
                                                        ),
                                                        Image.asset(
                                                            AVATAR_CONTAINER_OUTER),
                                                      ],
                                                    ),
                                                  ),
                                                )),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: ScaleButton(
                    onTap: () {
                      final session = Provider.of<SessionProvider>(context, listen: false);
                      final _selectedProfileId = session.selectedProfileId;
                      print("_selectedProfileId");
                      print(_selectedProfileId);
                      print(_selectedProfileId);
                      if (usernameController.text != "") {
                        if (uploadPhoto) {
                          if (_image != null &&
                              (selectedAvatar == null ||
                                  selectedAvatar == -1)) {
                            updateUserProfilePhotoAndName();
                          } else if (selectedAvatar != null) {
                            updateUserProfileAvatarAndName();
                          } else {
                            SnackbarHelper.showSnackbar(
                                "Please select an avatar or upload an Image",
                                color: Colors.red);
                          }
                        } else {
                          if (selectedAvatar != null) {
                            updateUserProfileAvatarAndName();
                          } else {
                            SnackbarHelper.showSnackbar(
                                "Please select an avatar to continue",
                                color: Colors.red);
                          }
                        }
                      } else {
                        SnackbarHelper.showSnackbar("Please enter a username",
                            color: Colors.red);
                      }
                    },
                    child: Provider.of<SessionProvider>(context, listen: false)
                                .userData?['user_token'] ==
                            null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                            ],
                          )
                        : Padding(
                            padding: EdgeInsets.only(left: screenWidth / 17),
                            child: Image.asset(SAVE_BTN, fit: BoxFit.contain),
                          )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showComplete() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(SUCCESS_CONTAINER),
                          fit: BoxFit.fill)),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Text(
                              "Success",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: "Alegreya_Sans",
                                  fontSize: 28,
                                  color: Colors.black),
                            )),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: Text(
                                  "Profile Updated Successfully",
                                  style: TextStyle(
                                      fontFamily: "Alegreya_Sans",
                                      fontSize: 24,
                                      color: Color(0xff676767)),
                                )),
                              ],
                            )),

                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: ScaleButton(
                              onTap: () {
                                landingPage();
                                Navigator.pop(context);
                                Provider.of<IndexProvider>(context, listen: false)
                                    .setIndex(PatientTab.home.index);
                              },
                              child: Image.asset(
                                EXERCISE_VIEW_OK_BTN,
                                fit: BoxFit.cover,
                              )),
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
