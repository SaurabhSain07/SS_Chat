import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ss_chat/email/signup.dart';
import 'package:ss_chat/email/uihelper.dart';
import 'package:ss_chat/screen/home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  Login(String email, String Password)async{
    if (email=='' && Password=="") {
      return UiHelper.CustomAlertBox(context, 'Enter Required Filds');
    }else{
      UserCredential? usercredential;
      try {
        usercredential=await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: Password);
        Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeView()));
      }on FirebaseAuthException catch (ex) {
        return UiHelper.CustomAlertBox(context, ex.code.toString());
      }
    }
  }
  @override
  TextEditingController emailcontroller=TextEditingController();
  TextEditingController passwordcontroller=TextEditingController();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login Page'),
      centerTitle: true,
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
        UiHelper.CustomTextFilde(emailcontroller, 'Email', Icons.email, false),
        UiHelper.CustomTextFilde(passwordcontroller, 'Password', Icons.password, true),
        SizedBox(height: 30,),
        UiHelper.CustomButton(() {
          Login(emailcontroller.text.toString(), passwordcontroller.text.toString());
         }, 'Login'),
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Already Have an Account??',style: TextStyle(fontSize: 20),),
          TextButton(onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignUpPage()),);
          }, child: Text('Sing Up',style: TextStyle(fontSize: 20,fontWeight: FontWeight.normal),))
          ],
        )
        ]),
      ),
    );
  }
}