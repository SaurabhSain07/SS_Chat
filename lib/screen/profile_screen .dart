
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ss_chat/api/apis.dart';
import 'package:ss_chat/helper/dialogs.dart';
import 'package:ss_chat/main.dart';
import 'package:ss_chat/models/chat_user.dart';
import 'package:ss_chat/screen/auth/login_screen.dart';
// import 'package:ss_chat/widgets/chat_user_card.dart';
// import 'package:ss_chat/widgets/chat_user_card.dart';

class ProfileView extends StatefulWidget {
  final ChatUser user;
  const ProfileView({super.key, required this.user});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formkey=GlobalKey<FormState>();

  String? _image;
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
        elevation: 10,
          title: Text('Profile View'),
          ),
         floatingActionButton: FloatingActionButton.extended(onPressed: ()async {
        //  for sowing progres dialog
          Dialogs.showProgressBar(context);

         await APIs.updateActiveStatus(false);
          
          // sign out from app
          // await APIs.auth.signOut();
          await GoogleSignIn().signOut().then((value){
            // for hide progress dialog
            Navigator.pop(context);
            
          APIs.auth =FirebaseAuth.instance;

            Navigator.pushReplacement(context, MaterialPageRoute(builder:(_) => LoginView(),));
          });
          },
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          label: Text('Logout'),
         icon:const Icon(Icons.logout),), 
      
      body: Form(
        key: _formkey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width*.05),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: mq.height*.03, width:mq.width),
                    
                Stack(
                  children: [
                    // Profile Image
                    _image!=null?
                    ClipRRect(
                          borderRadius: BorderRadius.circular(mq.width*.2),
                          child: Image.file(
                            File(_image!),
                            width: mq.height*.2,
                            height: mq.height*.2,
                            fit: BoxFit.cover,
                               ),
                        )
                    :ClipRRect(
                          borderRadius: BorderRadius.circular(mq.width*.2),
                          child: CachedNetworkImage(
                            width: mq.height*.2,
                            height: mq.height*.2,
                            fit: BoxFit.cover,
                          imageUrl: widget.user.image,
                          // placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => CircleAvatar(
                              child: Icon(CupertinoIcons.person),
                            ),
                               ),
                        ),
                        
                  // edit button
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                            elevation: 1,
                            shape: CircleBorder(),
                            color: Colors.white,
                            onPressed: (){
                              _showBottomSheet();
                            }, 
                            child: Icon(Icons.edit,color: Colors.blue,),),
                        )
                  ],
                ),
                    
                    SizedBox(height: mq.height*.03, width:mq.width),
                   Text(widget.user.email,style: TextStyle(
                    color: Colors.black54, fontSize: 17
                   ),),
                    
                   SizedBox(height: mq.height*.05, width:mq.width),
                   TextFormField(
                   initialValue:widget.user.Name,
                   onSaved: (val) =>APIs.me.Name=val?? '',
                   validator: (val) => val !=null && val.isNotEmpty?
                    null:'Required Field',
                   decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person, color: Colors.blue,),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    hintText: 'Ex, Saurabh Sain',
                    label: Text('Name'),
                    ),
                   ),
                    
                   SizedBox(height: mq.height*.02, width:mq.width),
                   TextFormField(
                   initialValue:widget.user.about,
                    onSaved: (val) =>APIs.me.about=val?? '',
                   validator: (val) => val !=null && val.isNotEmpty?
                    null:'Required Field',
                   decoration: InputDecoration(
                    prefixIcon: Icon(Icons.info_outline, color: Colors.blue,),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    hintText: 'Ex, Today I am Happy',
                    label: Text('About'),
                    ),
                   ),
                  
                  SizedBox(height: mq.height*.02, width:mq.width),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      minimumSize: Size(mq.width*.5, mq.height*.06)
                    ),
                    onPressed: (){
                      if (_formkey.currentState!.validate()) {
                        _formkey.currentState!.save();
                        APIs.updateUserInfo().then((value) {
                          Dialogs.showSnackbar(context, 'Profile Update Successfully');
                        });
                      }
                    }, 
                    icon: Icon(Icons.login), 
                    label: Text('UPDATE')),
                    
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

// BottomSheet for picking a Profile Picture for user
  _showBottomSheet(){
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),topRight: Radius.circular(20)
        )
      ),
      context: context, 
      builder:(_){
     return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.only(
        top: mq.height*.03, 
        bottom: mq.height*.05),
      children: [
        Text('Pick Profile Picture',textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),
        ),

       SizedBox(height: mq.height*.02,),

        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                fixedSize: Size(mq.width*.3, mq.height*.15)
              ),
              onPressed: ()async{
                final ImagePicker picker = ImagePicker();
                // Pick an image.
                final XFile? image = 
                   await picker.pickImage(source: ImageSource.gallery);
                   if (image != null) {
                     print("Image Path: ${image.path} --mimeType ${image.mimeType}");
                     setState(() {
                       _image=image.path;
                     });

                     APIs.updateProfilePicture(File(_image!));

                    //  For hidling bottom sheet
                     Navigator.pop(context);
                   }
              }, 
              child: Image.asset('images/add-image.png')),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                fixedSize: Size(mq.width*.3, mq.height*.15)
              ),
              onPressed: ()async{
                 final ImagePicker picker = ImagePicker();
                // Pick an image.
                final XFile? image = 
                   await picker.pickImage(source: ImageSource.camera);
                   if (image != null) {
                     print("Image Path: ${image.path}");
                     setState(() {
                       _image=image.path;
                     });

                     APIs.updateProfilePicture(File(_image!));

                     //  For hidling bottom sheet
                     Navigator.pop(context);
                   }
              }, 
              child: Image.asset('images/camera.png'))
          ],
        )
        ],
     );
    });
  }
}