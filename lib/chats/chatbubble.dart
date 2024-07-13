import 'package:bluejobs/styles/textstyle.dart';
import 'package:flutter/material.dart';

class Chatbubble extends StatelessWidget {
  final String message;
  final String? image;
  const Chatbubble({super.key, required this.message, this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12), // fix the ui
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 19, 52, 77), // Fixed color
        borderRadius: BorderRadius.circular(8), // Adjust the border radius to 5
        // border: Border.all(
        //   color: Color.fromARGB(255, 19, 52, 77),
        //   width: 1, // Keep the border width as 1
        // ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image != null) Image.network(image!),
          Text(
            message,
            style: CustomTextStyle.chatRegularText,
          ),
        ],
      ),
    );
  }
}
