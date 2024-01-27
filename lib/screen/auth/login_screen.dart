
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ss_chat/api/apis.dart';
import 'package:ss_chat/helper/dialogs.dart';
import 'package:ss_chat/main.dart';
import 'package:ss_chat/screen/home_screen.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _isAnimate=false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1),(){
       setState(() {
      _isAnimate=true;
    });
    });
  }


   _handleGoogleBtnClick(){
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
       Navigator.pop(context);

      if(user !=null){
        print('\nUser: ${user.user}');
      print('\nUserAdditionalInfo: ${user.additionalUserInfo}');
       
       if ((await APIs.UserExists())) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeView()));
       } else {
         await APIs.createUser().then((value){
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeView()));
         });
       }
      }
     },
    );
   }

  Future<UserCredential?> _signInWithGoogle() async {
   try {
    await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await APIs.auth.signInWithCredential(credential);
   } catch (e) {
     print('signInWithGoogle $e');
     Dialogs.showSnackbar(context, 'Somethingh whan worng no Internet Connect!');
     return null;
   }
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
            right:_isAnimate? mq.width*.25 :-mq.width*.5,
            width: mq.width*.5,
            duration: Duration(seconds: 1),
          child: Image.asset('images/icon.png'),),
          Positioned(bottom: mq.height*.15,left: mq.width*.05,width: mq.width*.9,height: mq.height*.07,
          child:ElevatedButton.icon(style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent
          ),
            onPressed: (){
              _handleGoogleBtnClick();
            }, icon: Image.asset("images/Google.png"),label: RichText(text: TextSpan(
              style: TextStyle(color: Colors.black,fontSize: 19),
              children: [
                TextSpan(text: 'Singh with '),
                TextSpan(text: 'Google',style: TextStyle(fontWeight: FontWeight.bold))
              ]
            )),),),
          ]), 
    );
  }
}

