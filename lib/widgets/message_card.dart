import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:ss_chat/api/apis.dart';
import 'package:ss_chat/helper/dialogs.dart';
import 'package:ss_chat/helper/my_date_util.dart';
import 'package:ss_chat/main.dart';
import 'package:ss_chat/models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe=APIs.user.uid==widget.message.fromId;

    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe? _greenMessage(): _blueMessage());
    
  }

//  sender or another user message
  Widget _blueMessage(){
    //  update last read message if sender and recever are different
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type==Type? 
            mq.width*.03
            :mq.width*.04),
            margin: EdgeInsets.symmetric(vertical: mq.height*.01, horizontal: mq.width*.04),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 221, 245, 255),
              border: Border.all(color: Colors.lightBlue),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30)
              )
            ),
            child:
            widget.message.type== Type.text ?

            // show text
             Text(
             widget.message.msg, 
              style:const TextStyle(fontSize: 15, color: Colors.black87), ):
            
            // show image
           ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
            imageUrl: widget.message.msg,
            placeholder: (context, url) => 
          const  Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeAlign: 2,),
            ),
            errorWidget: (context, url, error) => CircleAvatar(
                child: Icon(Icons.image, size: 70,),
              ),
                 ),
          ),
         ),
        ),
        Padding(
          padding: EdgeInsets.only(right:mq.width*.04),
          child: Text( 
            MyDateUtil.getFormatedTime(
            context: context, time: widget.message.sent),
            style: TextStyle(fontSize: 13, color: Colors.black54),),),
      ],
    );
  }

  Widget _greenMessage(){
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
       
        Row(
          children: [
            // for adding for some space
            SizedBox(width: mq.width* .04,),

            // double tik blue icon for message read
            if(widget.message.read.isNotEmpty)
           const Icon(
              Icons.done_all_rounded, color: Colors.blue, size: 20,
            ),

            // for adding some space
            SizedBox(width: 2,),

            // read Text
            Text(
              MyDateUtil.getFormatedTime(
              context: context, time: widget.message.sent),
            style: TextStyle(fontSize: 13, color: Colors.black54),),
          ],
        ),

         Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type==Type? 
            mq.width*.03
            :mq.width*.04),
            margin: EdgeInsets.symmetric(vertical: mq.height*.01, horizontal: mq.width*.04),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 218, 255, 176),
              border: Border.all(color: Colors.lightGreen),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30)
              )
            ),
            child:  widget.message.type== Type.text ?
             Text(
             widget.message.msg, 
              style:const TextStyle(fontSize: 15, color: Colors.black87), ):
               ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
            imageUrl: widget.message.msg,
            errorWidget: (context, url, error) => CircleAvatar(
                child: Icon(Icons.image, size: 70,),
              ),
                 ),
          ),
          ),
        ),
      ],
    );
  }

  // BottomSheet for modifying message details
  _showBottomSheet(isMe){
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
      children: [
        Container(
          height: 4,
          margin: EdgeInsets.symmetric(
            vertical: mq.height*.015, 
            horizontal: mq.width*.4
            ),
            decoration: BoxDecoration(
              color: Colors.grey, borderRadius: BorderRadius.circular(8)
            ),
        ),
        
       widget.message.type==Type.text
       ? // copy option
        _OptionItem(
            icon:const Icon(Icons.copy_all_rounded,
            color: Colors.blue, size: 26,),
            name: 'Copy Text',
            onTap: ()async {
              await Clipboard.setData(
                ClipboardData(text: widget.message.msg)
              ).then((value) {
                // for hiding bottem Sheet
                Navigator.pop(context);

                Dialogs.showSnackbar(context,'Text Copy');
              });
            },)
            : // save option
        _OptionItem(
            icon:const Icon(Icons.download_rounded,
            color: Colors.blue, size: 26,),
            name: 'Save Image',
            onTap: ()async {
             try {
                print('Image Url: ${widget.message.msg}');
             GallerySaver.saveImage(widget.message.msg, 
             albumName: 'SS_Chat').then((success) {
              // for hiding bottem Sheet
                Navigator.pop(context);
                if (success !=null && success) {
                  Dialogs.showSnackbar(context, "Image Successfull Saved!");
                }
            });
             } catch (e) {
               print('ErrorwhileSavingImage ${e}');
             }
         },),
         
        Divider(
          color: Colors.black54,
          endIndent: mq.width*.04,
          indent: mq.width*.04,
        ),

         // edit option
         if(widget.message.type==Type.text && isMe)
         _OptionItem(
            icon:const Icon(Icons.edit,
            color: Colors.blue, size: 26,),
            name: 'Edit Message',
            onTap: () {
              // for hiding bottem Sheet
                Navigator.pop(context);
                 _showMessageUpdateDialog();
            },),
        
        // delete option
         if(isMe)
        _OptionItem(
            icon:const Icon(Icons.delete_forever,
            color: Colors.red, size: 26,),
            name: 'Deleta Message',
            onTap: ()async {
              await APIs.deleteMessage(widget.message).then((value) {
                // for hiding bottem Sheet
                Navigator.pop(context);
              });
            },),
        if(isMe)
        Divider(
          color: Colors.black54,
          endIndent: mq.width*.04,
          indent: mq.width*.04,
        ),

        // sent Time
        _OptionItem(
            icon:const Icon(Icons.remove_red_eye,
            color: Colors.blue, size: 26,),
            name: 
            'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
            onTap: () {},),
         
        //  read Time
         _OptionItem(
            icon:const Icon(Icons.remove_red_eye,
            color: Colors.green, size: 26,),
            name: widget.message.read.isEmpty?
            'Read At: Not seen yet'
            :'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
            onTap: () {},),
    

        ],
     );
    });
  }

  // Dialog for updating message contant
  void _showMessageUpdateDialog(){
    String updateMsg=widget.message.msg;
    showDialog(context: context, 
    builder: (_)=>AlertDialog(
      contentPadding:const EdgeInsets.only(
        left: 24,right: 24,top: 10,bottom: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)),
        // title
      title: Row(
        children: [
          Icon(Icons.message,color: Colors.blue,size: 28,),
          Text(' Update Messsag')
        ],
     ),

      // content 
      content: TextFormField(
        initialValue: updateMsg,
        maxLines: null,
        onChanged: (value) => updateMsg=value,
        decoration: InputDecoration(
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
            
            // update button
            MaterialButton(
            onPressed: (){
              // for hiding bottem Sheet
                Navigator.pop(context);
                APIs.updateMessage(widget.message, updateMsg);
            }, 
            child:const Text(
              'Update', 
            style: TextStyle(color: Colors.blue, fontSize: 16),),)
        ],
    ));
  }
}

// custom option card (for copy, edit, delete, etc)
class _OptionItem extends StatelessWidget{
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem({required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
          top: mq.height*.015,
          left: mq.width*.05,
          bottom: mq.height*.015,
        ),
        child: Row(
          children: [
            icon, Flexible(child: Text('  $name',
            style: TextStyle(fontSize: 15,color: Colors.black54),))
            ],
        ),
      ),
    );
  }  
}