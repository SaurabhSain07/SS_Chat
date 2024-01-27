import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ss_chat/models/chat_user.dart';
import 'package:ss_chat/models/message.dart';

class APIs{
  // For Authentication
  static FirebaseAuth auth=FirebaseAuth.instance;
  
  // For accessing cloud firestore database
  static FirebaseFirestore firestore=FirebaseFirestore.instance;
  
  // For accesssing firebase storage
  static FirebaseStorage storage=FirebaseStorage.instance;

  static late ChatUser me;

  static User get user=>auth.currentUser!;

  // for accessing firebase messaging (push Notification)
 static FirebaseMessaging fMessaging = FirebaseMessaging.instance; 

  // for getting  firebase messaging Token
  static Future<void> getFirebaseMessegingToken()async{
     await fMessaging.requestPermission();
    
    await fMessaging.getToken().then((t){
      if (t !=null) {
        me.pushToken=t;
        print('Push Token: $t');
      }
    });

   // for handling forground message  
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print('Got a message whilst in the foreground!');
  //     print('Message data: ${message.data}');

  //     if (message.notification != null) {
  //       print('Message also contained a notification: ${message.notification}');
  //     }
  //  });
  }

  // For sending push Notification
 static Future<void> sendPushNotification(ChatUser chatUser, String msg)async{
  try {
      final body={
    "to": chatUser.pushToken,
    "notification":{
      "title": chatUser.Name,
      "body":msg,
      "android_channel_id": "chats"
    },
    "data": {
    "some_data" : "User ID: ${me.id}",
  }

  };
  var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'), 
      headers: {
        HttpHeaders.contentTypeHeader:"application/json",
        HttpHeaders.authorizationHeader:
        "key=AAAAdzVVIrA:APA91bH9pdtTfoPC7S70vAvTfF1sBEQB_zcnPl59tQQXPTEh502SJ3tk52t3z7a9F3SpY_EF_E-0gXivd_3F8uaiC8xmxEpF80SWdi7CKGKs9tj8haBjlrarz0e1Z39TPP4hNug63URx"
      }, 
      body: jsonEncode(body));
      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');
  } catch (e) {
    print('\nsendPushNotificationE: $e');
  }
 }
  
  // for checking if user exists or not?
  static Future<bool> UserExists()async{
    return (await firestore
    .collection('users')
    .doc(user.uid)
    .get()).exists;
  }

   // for adding an chat user for our conversation
  static Future<bool> addChatUser(String email)async{
    final data = await firestore
    .collection('users')
    .where('email', isEqualTo: email)
    .get();

    print('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id!=user.uid) {
      // user exists
      
      print('user exists: ${data.docs.first.data()}');
     
     firestore
     .collection('users')
     .doc(user.uid)
     .collection('my_users')
     .doc(data.docs.first.id)
     .set({});

      return true;
    }else{
      // user doesn't exists
      return false;
    }
  }
  
  // For getting current user info
  static Future<void> getSelfInfo()async{
    await firestore
    .collection('users')
    .doc(user.uid)
    .get().then((user)async {
      if (user.exists) {
        me=ChatUser.fromJson(user.data()!);
       await getFirebaseMessegingToken();

       // for setting user status to active
        APIs.updateActiveStatus(true);

        print('My Data: ${user.data()}');
      } else {
        await createUser().then((value) =>getSelfInfo());
      }
    });
  }


  static Future<void> createUser()async{
    final time=DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser=ChatUser(  
     image: user.photoURL.toString(),
     about: 'Hay I am Saurabh Sain',
     createdAt: time,
     id: user.uid,
     lastActive: time,
     isOnline: false,
     email: user.email.toString(),
     pushToken: '', 
     Name: user.displayName.toString()
     );


    return await firestore
    .collection('users')
    .doc(user.uid)
    .set(chatUser.toJson());
  }

  // For getting id's of known users from firestoree datebase
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId(){
    return firestore
    .collection('users')
    .doc(user.uid)
    .collection("my_users")
    .snapshots();
  }
  
  // For getting all users from firestoree datebase
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(List<String>userIds){
    print('\nUserIds: $userIds');
    return firestore
    .collection('users')
    // .where('id', whereIn: userIds)
    .where('id', isNotEqualTo: user.uid)
    .snapshots();
  }

   // For adding an user to my user when frist message is send
  static Future<void> sendFristMessage(ChatUser chatUser, String msg, Type type)async{
    await firestore
    .collection('users')
    .doc(chatUser.id)
    .collection('my_users')
    .doc(user.uid)
    .set({}).then((value) => sendMessage(chatUser, msg, type));
    
  }
  
  // For updating user information
  static Future<void> updateUserInfo()async{
    await firestore
    .collection('users')
    .doc(user.uid)
    .update({
      'Name': me.Name,
      'about':me.about,
    });
  }

  // update profile picture of user
   static Future<void> updateProfilePicture(File file)async {
    final ext=file.path.split('.').last;
    print('Extension: $ext');

    // storage file ref with path
    final ref = storage.ref().child('profile_pictiures/${user.uid}.$ext');

    // uploading image
   await ref
   .putFile(file, SettableMetadata(contentType: 'image/$ext'))
   .then((p0) {
    print('Data Transferred: ${p0.bytesTransferred/1000}Kb');
   });

  //  uploading image in firebase database
   me.image=await ref.getDownloadURL();
    await firestore
    .collection('users')
    .doc(user.uid)
    .update({
      'image': me.image,
    });
   }

  // for getting specific user info
   static Stream<QuerySnapshot<Map<String, dynamic>>> getUserinfo(
    ChatUser chatUser){
   return firestore
    .collection('users')
    .where('id', isEqualTo: chatUser.id)
    .snapshots();
   }

  //  update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline)async{
    firestore
    .collection('users').doc(user.uid).update({
      'is_online':isOnline,
      'last_active':DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token':me.pushToken,
    });
  }

  ///**************** Chat Screen Related APIs ****************
  
  //usefil for getting conversation id
  static String getConversationID(String id)=>user.uid.hashCode<=id.hashCode
  ? '${user.uid}_$id'
  : '${id}_${user.uid}';
  
  // For getting all users from firestoree datebase
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user){
    return firestore.collection('Chats/${getConversationID(user.id)}/messages')
    .orderBy('sent',descending: true)
    .snapshots();
  }
 
  // for sending message
  static Future<void> sendMessage(ChatUser chatUser, String msg, Type type)async{
    
    // Message sending time (also used as id)
    final time=DateTime.now().microsecondsSinceEpoch.toString();

    // Message to send
    final Message message=Message(
      toId: chatUser.id, 
      msg: msg, read: '', 
      type: type, 
      sent: time, 
      fromId: user.uid);

    final ref =firestore.collection('Chats/${getConversationID(chatUser.id)}/messages');
    await ref.doc(time).set(message.toJson())
    .then((value) => sendPushNotification(chatUser,type==Type.text? msg:'image'));
  }

   // update read status of message
  static Future<void> updateMessageReadStatus(Message message)async{
     firestore
     .collection('Chats/${getConversationID(message.fromId)}/messages')
     .doc(message.sent)
     .update({'read':DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
    ChatUser user
  ){
   return firestore
   .collection('Chats/${getConversationID(user.id)}/messages')
   .orderBy('sent',descending: true)
   .limit(1)
   .snapshots();
  }

  // send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file,)async{
     final ext=file.path.split('.').last;

    // storage file ref with path
    final ref = storage.ref().child('images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    // uploading image
   await ref
   .putFile(file, SettableMetadata(contentType: 'image/$ext'))
   .then((p0) {
    print('Data Transferred: ${p0.bytesTransferred/1000}Kb');
   });

  //  uploading image in firebase database
   final imageUrl=await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  // delete message
  static Future<void> deleteMessage(Message message)async{
    await  firestore
     .collection('Chats/${getConversationID(message.toId)}/messages')
     .doc(message.sent)
     .delete();

     if (message.type==Type.image) {
       await storage.refFromURL(message.msg).delete();
     }
  }

  // update message
   static Future<void> updateMessage(Message message, String updateMsg)async{
    await  firestore
     .collection('Chats/${getConversationID(message.toId)}/messages')
     .doc(message.sent)
     .update({'msg':updateMsg});
  }
}