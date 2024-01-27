import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String mag){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mag),
    backgroundColor: Colors.blueAccent,
    behavior: SnackBarBehavior.floating,
    ));
  }

  static void showProgressBar(BuildContext context){
     showDialog(context: context, builder: (_)=>const Center(child: CircularProgressIndicator()));
  }
}