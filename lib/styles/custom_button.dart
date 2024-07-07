import 'package:bluejobs/styles/textstyle.dart';
import 'package:flutter/material.dart';
//import 'package:bluejobs_user/styles/custom_button.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final Color buttonColor;
  final Color textColor;
  final double width;
  final double height;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;

   const CustomButton({
    Key? key,
    required this.onPressed,
    required this.buttonText,
    this.buttonColor = const Color.fromARGB(255, 243, 107, 4),
    this.textColor = Colors.white,
    this.width = double.infinity,
    this.height = 50,
    this.borderRadius = 5,
    this.borderWidth = 1,
    this.borderColor = const Color.fromARGB(255, 243, 107, 4),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
        ),
        child: Center(
          child: Text(
            buttonText,
            style: CustomTextStyle.regularText.copyWith(
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
