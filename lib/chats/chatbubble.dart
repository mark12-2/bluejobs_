import 'package:bluejobs/styles/textstyle.dart';
import 'package:flutter/material.dart';

class Chatbubble extends StatelessWidget {
  final String message;
  final String? image;
  final bool isSender; // Add this parameter

  const Chatbubble(
      {super.key, required this.message, this.image, required this.isSender});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSender
            ? Color.fromARGB(255, 19, 52, 77)
            : const Color.fromARGB(255, 243, 107, 4),
        borderRadius: BorderRadius.circular(8),
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
