import 'package:bluejobs/styles/textstyle.dart';
import 'package:flutter/material.dart';

class Chatbubble extends StatelessWidget {
  final String message;
  const Chatbubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 19, 52, 77), // Fixed color
        borderRadius: BorderRadius.circular(8), // Adjust the border radius to 5
        // border: Border.all(
        //   color: Color.fromARGB(255, 19, 52, 77),
        //   width: 1, // Keep the border width as 1
        // ),
      ),
      child: Text(
        message,
        style: CustomTextStyle.chatRegularText,
      ),
    );
  }
}
