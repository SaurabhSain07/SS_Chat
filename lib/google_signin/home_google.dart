
// import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:sign_in_button/sign_in_button.dart';

// class GoogleHome extends StatefulWidget {
//   const GoogleHome({super.key});

//   @override
//   State<GoogleHome> createState() => _GoogleHomeState();
// }

// class _GoogleHomeState extends State<GoogleHome> {

//   final FirebaseAuth _auth=FirebaseAuth.instance;

//   User? _user;

//   @override
//   void initState() {
//     super.initState();
//     _auth.authStateChanges().listen((event){
//       setState(() {
//         _user=event;
//       });
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Google SignIn'),
//       centerTitle: true,
//       ),
//       body: _user != null ? _userinfo(): _googleSingInButton(),
//     );
//   }
//   Widget _googleSingInButton(){
//     return Center(
//       child: SizedBox(
//       height: 50,
//       child: SignInButton(Buttons.google,text: 'Sinh Up with Google',onPressed: (){_handleGoogleSignIn();},
//       ),
//       ),
//     );
//   }


//   Widget _userinfo(){
//     return SizedBox();
//   }

// void _handleGoogleSignIn(){
//   try{
//     GoogleAuthProvider _googleAuthProvider=GoogleAuthProvider();
//     _auth.signInWithProvider(_googleAuthProvider);
//   }catch(error){
//    print('error');
//   }
// }  
// }