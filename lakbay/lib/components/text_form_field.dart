import 'package:flutter/material.dart';

// setting up the form field  as a component to reuse it and edit it easier.

class TextformField extends StatelessWidget{

  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final Icon? icon;
  const TextformField ({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.icon,


    });

  @override
  Widget build(BuildContext context){
    return SizedBox(

      width: 282.8,
      height: 65.82,
      child: TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Color(0xFF79BAAA),
        prefixIcon: icon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        
      ),
    ),
    );
  }
}