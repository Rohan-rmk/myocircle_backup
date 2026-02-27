import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({Key? key, required this.value, required this.onChanged})
      : super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  late bool isOn;

  @override
  void initState() {
    super.initState();
    isOn = widget.value;
  }

  void toggleSwitch() {
    setState(() {
      isOn = !isOn;
    });
    widget.onChanged(isOn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleSwitch,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(height: 25,width: 52,),
          // The Track
          Container(
            width: 52,
            height: 20,
            decoration: BoxDecoration(
              color: isOn ? Color.fromRGBO(61, 126, 128, 1) : Color(0xFFBDBDBD),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          // The Thumb
          AnimatedPositioned(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            left: isOn ? null : 3,
            right: isOn ? 3 : null,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}