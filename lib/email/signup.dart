import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ss_chat/email/uihelper.dart';
import 'package:ss_chat/screen/home_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController=TextEditingController();
  TextEditingController passwordcontroller=TextEditingController();

  signUp(String email, String password)async{
    if (email=="" && password=="") {
      UiHelper.CustomAlertBox(context, 'Enter Requird text filde');
    }
    else{
      UserCredential? usercredential;
      try {
        usercredential= await FirebaseAuth.instance.createUserWithEmailAndPassword(email:email, password:password);
        Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeView()));
      } on FirebaseAuthException catch(ex){
        return UiHelper.CustomAlertBox(context, ex.code.toString());
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up'),
      centerTitle: true,
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
        UiHelper.CustomTextFilde(emailController, 'Email', Icons.email, false),
        UiHelper.CustomTextFilde(passwordcontroller, 'Password', Icons.password, true,),
        UiHelper.CustomButton(() { 
          signUp(emailController.text.toString(), passwordcontroller.text.toString());
        }, "Sign Up")
      ]),
    );
  }
}