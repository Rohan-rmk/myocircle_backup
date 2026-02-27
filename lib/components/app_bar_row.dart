import 'package:flutter/material.dart';
import 'package:myocircle15screens/components/components_path.dart';
import 'package:scale_button/scale_button.dart';

class CustomAppBarRow extends StatelessWidget implements PreferredSizeWidget {
  final Function menuButton;
  const CustomAppBarRow({
    Key? key,
    required this.menuButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            flex: 3,
            child: Padding(
                padding: EdgeInsets.all(3), child: Image.asset(IMAGE_LOGO))),
        Expanded(
            flex: 7,
            child: Text("MYOCIRCLE",
                textAlign: TextAlign.center,
                style: TextStyle(
                  letterSpacing: 3,
                  fontFamily: "Alegreya_SC",
                  color: Color(0xFF3E52A8),
                  fontSize: screenWidth / 15,
                ))),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: ScaleButton(
                  child: Image.asset(
                    BELL_ICON,
                    fit: BoxFit.cover,
                  ),
                  onTap: () {},
                ),
              ),
              Expanded(
                flex: 2,
                child: ScaleButton(
                    child: Image.asset(
                      MENU_ICON,
                      fit: BoxFit.cover,
                    ),
                    onTap: () {
                      menuButton();
                    }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
