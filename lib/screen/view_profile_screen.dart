
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
import 'package:ss_chat/helper/my_date_util.dart';
import 'package:ss_chat/main.dart';
import 'package:ss_chat/models/chat_user.dart';
import 'package:ss_chat/screen/auth/login_screen.dart';

// Profile view screen -- to view profile of user
class ProfileViewScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileViewScreen({super.key, required this.user});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
        elevation: 10,
          title: Text(widget.user.Name),
          ), 

          floatingActionButton:  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                    Text('Joined On: ', 
                    style: TextStyle(
                      color: Colors.black87,fontWeight: FontWeight.w500,
                      fontSize: 16),),
                     Text(MyDateUtil.getLastMessageTime(
                      context: context, time: widget.user.createdAt,showYear: true),
                     style: TextStyle(
                      color: Colors.black87, fontSize: 17),),
                   ],
                 ),
      
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: mq.width*.05),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: mq.height*.03, width:mq.width),
                  
              ClipRRect(
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
                  // for adding space
                  SizedBox(height: mq.height*.03, width:mq.width),

                 Text(widget.user.email,
                 style: TextStyle(
                  color: Colors.black87, fontSize: 17),),

                // for adding space
                 SizedBox(height: mq.height*.02,),
                
                // user about
                 Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                    Text('About : ', 
                    style: TextStyle(
                      color: Colors.black87,fontWeight: FontWeight.w500,
                      fontSize: 16),),
                     Text(widget.user.about,
                     style: TextStyle(
                      color: Colors.black87, fontSize: 17),),
                   ],
                 ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}