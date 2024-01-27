import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ss_chat/api/apis.dart';
import 'package:ss_chat/helper/my_date_util.dart';
import 'package:ss_chat/main.dart';
import 'package:ss_chat/models/chat_user.dart';
import 'package:ss_chat/models/message.dart';
import 'package:ss_chat/screen/chat_screeen.dart';
import 'package:ss_chat/widgets/dialogs/profile_dialog.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {

  // last message info (if null --> no message)
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          // For navigating to chat screen
          Navigator.push(context, MaterialPageRoute(builder: (_)=>ChatScreen(user: widget.user,)));
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {

            final data=snapshot.data?.docs;

              final list=
                data?.map((e) => Message.fromJson(e.data())).toList()??[];
            if (list.isNotEmpty) _message=list[0];
              
          return ListTile(
          // leading: CircleAvatar(
          //   child: Icon(CupertinoIcons.person),
          // ),
        leading: InkWell(
          onTap: () {
            showDialog(context: context, builder:(_)=>ProfileDialog(user: widget.user,));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(mq.width*.3),
            child: CachedNetworkImage(
              width: mq.height*.055,
              height: mq.height*.055,
            imageUrl: widget.user.image,
            // placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => CircleAvatar(
                child: Icon(CupertinoIcons.person),
              ),
                 ),
          ),
        ),

        // user Name
          title: Text(widget.user.Name),
          
       // last message
          subtitle: Text(
            _message !=null
            ? _message!.type==Type.image
            ?'image'
             :_message!.msg :widget.user.about,
            maxLines: 1,),
          // last message time
          trailing: _message==null
          // show nothin when no message is sent
          ?null 
            :_message!.read.isEmpty &&
             _message!.fromId !=APIs.user.uid
             ?
            // show for unread message
           Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(color: Colors.greenAccent,
            borderRadius: BorderRadius.circular(5)),)
            // message sent message
            :Text(
             MyDateUtil.getLastMessageTime(context: context, time: _message!.sent)
            ,style: TextStyle(color: Colors.black54),)
        );
        },)
      ),
    );
  }
}