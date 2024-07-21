import 'package:flutter/material.dart';
import 'package:bluejobs/styles/textstyle.dart';

InputDecoration customInputDecoration(String labelText,
    {IconButton? suffixIcon}) {
  return InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: const BorderSide(color: Colors.black),
    ),
    labelText: labelText, 
    labelStyle: CustomTextStyle.regularText,
    suffixIcon: suffixIcon,
  );
}
