import 'package:bluejobs/styles/textstyle.dart';
import 'package:flutter/material.dart';

class CustomInkwellForHomeButtonllButton extends StatelessWidget {
 final Widget child;
 final VoidCallback onTap;

 const CustomInkwellForHomeButtonllButton({Key? key, required this.child, required this.onTap}) : super(key: key);

 @override
 Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50, // Set the height to 50
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 19, 52, 77), // Fixed color
          borderRadius: BorderRadius.circular(5), // Adjust the border radius to 5
          border: Border.all(
            color: Color.fromARGB(255, 19, 52, 77),
            width: 1, // Keep the border width as 1
          ),
        ),
        child: Center(
        child: DefaultTextStyle(
          style: CustomTextStyle.regularText.copyWith(color: Colors.white), // Make the font white
          child: child,
        ),
        ),
      ),
    );
 }
}