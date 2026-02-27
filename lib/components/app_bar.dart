import 'package:flutter/material.dart';
import 'package:myocircle15screens/components/components_path.dart';
import 'package:scale_button/scale_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {


  const CustomAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return AppBar(forceMaterialTransparency: true,automaticallyImplyLeading: false,
      backgroundColor: Colors.blueGrey.shade900,
      elevation: 4,
      centerTitle: true,
      actions: [
        Expanded(
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             LayoutBuilder(
               builder: (context,constraints) {
                 double size = constraints.maxHeight;
                 return Row(
                   children: [
                     Image.asset(IMAGE_LOGO,height: size,fit: BoxFit.contain,),
                   ],
                 );
               }
             ),
             Expanded(
               child: Column(mainAxisAlignment: MainAxisAlignment.start,
                 children: [
                   RichText(textAlign: TextAlign.center,
                     text: TextSpan(
                       style: TextStyle(letterSpacing: 3,
                         fontFamily: "Alegreya_SC",
                         color: Color(0xFF3E52A8),
                         fontSize: 36,
                       ),
                       children: [
                         TextSpan(text: "M"),
                         TextSpan(
                           text: "YO", // Circle character
                           style: TextStyle(fontSize: 28), // Larger font size for the circle
                         ),
                         TextSpan(text: "C"),
                         TextSpan(
                           text: "IRCLE", // Circle character
                           style: TextStyle(fontSize: 28), // Larger font size for the circle
                         ),
                       ],
                     ),
                   ),
                 ],
               ),
             ),
             Row(
               children: [
                 ScaleButton(child: Image.asset(BELL_ICON,fit: BoxFit.cover,),onTap: (){

                 },),
                 ScaleButton(child: Image.asset(MENU_ICON,fit: BoxFit.cover,),onTap: (){

                 }),
               ],
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
