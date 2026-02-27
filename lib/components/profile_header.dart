import 'package:flutter/material.dart';
import 'package:myocircle15screens/components/components_path.dart';
import 'package:scale_button/scale_button.dart';

class ProfileHeader extends StatelessWidget implements PreferredSizeWidget {
  const ProfileHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    print(screenWidth);
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Row(),
        Image.asset(
          IMAGE_LOGO,
          height: screenWidth / 7.7,
          width: screenWidth / 5.15,
          fit: BoxFit.contain,
        ),
        Positioned(
          right: 0,
          left: 0,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                letterSpacing: 3,
                fontFamily: "Alegreya_SC",
                color: Color(0xFF3E52A8),
                fontSize: screenWidth / 10.5,
              ),
              children: [
                TextSpan(text: "M"),
                TextSpan(
                  text: "YO", // Circle character
                  style: TextStyle(
                      fontSize:
                          screenWidth / 13), // Larger font size for the circle
                ),
                TextSpan(text: "C"),
                TextSpan(
                  text: "IRCLE", // Circle character
                  style: TextStyle(
                      fontSize:
                          screenWidth / 13), // Larger font size for the circle
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 0,
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.home,
              color: Color(0xFF3E52A8),
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
