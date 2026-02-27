import 'package:flutter/material.dart';
import 'package:myocircle15screens/components/components_path.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController textFieldController;
  final double size;
  final bool readOnly;
  final String label;
  final int maxLines;
  final TextAlign textAlign;
  const CustomTextField({Key? key, required this.textFieldController, required this.size, required this.readOnly, required this.label, required this.maxLines, required this.textAlign,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),border: Border.all(width: 1,color: Color(0xffAFB7AC)),boxShadow: [
      BoxShadow(offset: Offset(0, 4),blurRadius: size/231.25,color: Colors.black.withOpacity(0.25)),
    ]),
      child: ClipRRect(borderRadius: BorderRadius.circular(10),
        child: TextField(textAlign: textAlign,maxLines: maxLines,readOnly: readOnly,controller: textFieldController,style: TextStyle(
          fontSize: size/51.5,fontFamily: "Alegreya",color: Colors.black
        ),
        decoration: InputDecoration(contentPadding:EdgeInsets.fromLTRB(5, 10, 0,10),filled: true,fillColor: Colors.white,label: Text(label,style: TextStyle(shadows: !readOnly?null:[
          Shadow(color: Colors.black.withOpacity(0.25),blurRadius: 7,offset: Offset(0, 4)),
        ],
          fontSize: size/51.5,color: Colors.black,fontWeight: FontWeight.w600,fontFamily: "Alegreya_Sans_SC"
        ),),floatingLabelAlignment: FloatingLabelAlignment.start,
          border: InputBorder.none,floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        ),
      ),
    );
  }
}