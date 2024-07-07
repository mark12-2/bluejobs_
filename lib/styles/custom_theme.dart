// custom_input_decoration.dart
import 'package:flutter/material.dart';
import 'package:bluejobs/styles/textstyle.dart'; // Assuming this is where CustomTextStyle is defined

InputDecoration customInputDecoration(String labelText,  {IconButton? suffixIcon})  {
 return InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: const BorderSide(color: Colors.black),
    ),
    labelText: labelText, // Now labelText is defined
    labelStyle: CustomTextStyle.regularText,
     suffixIcon: suffixIcon,
 );
}
