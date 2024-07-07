
import 'package:flutter/material.dart';
import 'package:bluejobs/styles/textstyle.dart'; // Adjust the import path as necessary

class CustomInkWellButton extends StatelessWidget {
 final String buttonText;
 final VoidCallback onPressed;
 final Color fillColor;
 final double width;
 final double height;

 const CustomInkWellButton({
    Key? key,
    required this.buttonText,
    required this.onPressed,
    this.fillColor = const Color.fromARGB(255, 7, 30, 47), // Default color
    this.width = 300, // Default width, adjust as necessary
    this.height = 55, // Adjusted height to match the example
 }) : super(key: key);

 @override
 Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.only(left: 10),
        width: MediaQuery.of(context).size.width - 50, // Adjust the width to match the input fields
        height: height,
        child: InputDecorator(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5), // Set border radius to 5
            ),
            fillColor: fillColor, // Set background color
            filled: true, // Use filled property to apply the background color
          ),
          child: Center(
            child: Text(buttonText,
                style: CustomTextStyle.regularText.copyWith(
                 color: Colors.white,
                )),
          ),
        ),
      ),
    );
 }
}