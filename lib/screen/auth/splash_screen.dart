import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ss_chat/api/apis.dart';
import 'package:ss_chat/main.dart';
import 'package:ss_chat/screen/auth/login_screen.dart';
import 'package:ss_chat/screen/home_screen.dart';
// import 'package:ss_chat/screen/home_screen.dart';
// import 'package:ss_chat/screen/home_screen.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {


  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1),(){
      if (APIs.auth.currentUser !=null) {
        print('\nUser: ${APIs.auth.currentUser}');
     Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeView()));
   } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LoginView()));
   }
    });
   
  }
  @override
  Widget build(BuildContext context) {
  mq =MediaQuery.of(context).size;  
    return Scaffold(
       appBar: AppBar(
        // leading: Icon(CupertinoIcons.home),
        centerTitle: true,
        elevation: 10,
        title: Text('Welcome to SS Chat'),
        ),
        body: Stack(children: [
          AnimatedPositioned(
            top: mq.height*.15,
            right: mq.width*.25,
            width: mq.width*.5,
            duration: Duration(seconds: 1),
          child: Image.asset('images/icon.png'),),
          Positioned(
          bottom: mq.height*.15,
          width: mq.width,
          child:const Text('Made in India with ❤️',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            letterSpacing: sqrt1_2,
          ),),
          
          ),
          ]), 
    );
  }
}