
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ss_chat/api/apis.dart';
import 'package:ss_chat/helper/dialogs.dart';
import 'package:ss_chat/models/chat_user.dart';
import 'package:ss_chat/screen/profile_screen%20.dart';
import 'package:ss_chat/widgets/chat_user_card.dart';
// import 'package:ss_chat/widgets/chat_user_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
 List<ChatUser> _list=[];

final List<ChatUser>_searchList=[];
// for storing search status
bool _isSearching=false;

 @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    // for updating user active status according to lifecycle event
    // resume -- active or online
    // pause -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      // print('Message : $message');
      if (APIs.auth.currentUser !=null) {
        if(message.toString().contains('resume')){
          APIs.updateActiveStatus(true);
        }       
        if(message.toString().contains('pause')){
          APIs.updateActiveStatus(false);
        }
      }

     return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching=!_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading:const Icon(CupertinoIcons.home),
            // centerTitle: true,
          elevation: 10,
            title:_isSearching ? TextField(
              decoration:const InputDecoration(
                border: InputBorder.none,
                hintText: 'Name, Email, ...',
              ),
              autofocus: true,
              style: TextStyle(fontSize: 17,letterSpacing: 0.5),
        
              onChanged:(val){
                  _searchList.clear();
        
                 for (var i in _list) {
                   if (i.Name.toLowerCase().contains(val.toLowerCase()) ||
                   i.email.toLowerCase().contains(val.toLowerCase())){
                     _searchList.add(i);
                   }
                   setState(() {
                     _searchList;
                   });
                 } 
              },
            ) :Text('SS Chat'),
            actions: [
            IconButton(onPressed: (){
              setState(() {
                _isSearching= !_isSearching;
              });
            }, 
            icon: Icon(_isSearching 
              ? CupertinoIcons.clear_circled_solid
              : Icons.search)),
            IconButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (_)=>ProfileView(user: APIs.me)));
            }, icon: const Icon(Icons.more_vert)),
            ],
            ),
           floatingActionButton: FloatingActionButton(
            onPressed: (){
             _addChatUserDialog();
            },
           child:const Icon(Icons.add_comment_rounded),), 
        // body
        body: StreamBuilder(
          stream: APIs.getMyUsersId(),

          // get id of only Known users
          builder: (context, snapshot) {
          switch (snapshot.connectionState) {

              // if data is loading
              case ConnectionState.waiting:
              case ConnectionState.none:
              return const Center(child: CircularProgressIndicator(),);

             // if some or all data is loading then show it
              case ConnectionState.active:
              case ConnectionState.done:

           return StreamBuilder(
            stream:APIs.getAllUsers(
            snapshot.data?.docs.map((e) => e.id).toList()??[]),

          // get only those user, who's ids are provide
          builder: (context,snapshot){
            switch (snapshot.connectionState) {

              // if some or all data is loading then show it
              case ConnectionState.waiting:
              case ConnectionState.none:
              return const Center(child: CircularProgressIndicator(),);
                
              case ConnectionState.active:
              case ConnectionState.done:  
             
              final data=snapshot.data!.docs;
              _list=data?.map((e) => ChatUser.fromJson(e.data())).toList()??[];
                
                if(_list.isNotEmpty){
                  return ListView.builder(
                itemCount:_isSearching? _searchList.length :_list.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context,index){
                return ChatUserCard(user:
                _isSearching? _searchList[index] : _list[index],);
                // return Text('Name: ${list[index]}');
                 },);
              }else{
               return Center(
                 child: Text('No Connection found!',
                 style: TextStyle(fontSize: 20),
                 ),
               );
              }
        
            }       
          },
        );
          }
        },)
        ),
      ),
    );
  }
   
  //  for Adding new chat user
   void _addChatUserDialog(){
    String email='';
    showDialog(context: context, 
    builder: (_)=>AlertDialog(
      contentPadding:const EdgeInsets.only(
        left: 24,right: 24,top: 10,bottom: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)),
        // title
      title: Row(
        children: [
          Icon(Icons.person_add,color: Colors.blue,size: 28,),
          Text(' Add User')
        ],
     ),

      // content 
      content: TextFormField(
        maxLines: null,
        onChanged: (value) => email=value,
        decoration: InputDecoration(
          hintText: 'Email Id',
          prefixIcon: Icon(Icons.email, color: Colors.blue,),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20)
          )
        ),),
        
        // actions
        actions: [
          // cancel button
          MaterialButton(
            onPressed: (){
              // for hiding bottem Sheet
                Navigator.pop(context);
            }, 
            child:const Text(
              'Cancel', 
            style: TextStyle(color: Colors.blue, fontSize: 16),),),
            
            // Add button
            MaterialButton(
            onPressed: ()async{
              // for hiding bottem Sheet
                Navigator.pop(context);
                if(email.isNotEmpty){
                  await APIs.addChatUser(email).then((value){
                    if(!value){
                      Dialogs.showSnackbar(
                        context, 'User Dose Not Exists!');
                    }
                  });
                }
            }, 
            child:const Text(
              'Add', 
            style: TextStyle(color: Colors.blue, fontSize: 16),),)
        ],
    ));
  }
}