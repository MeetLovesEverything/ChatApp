import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/constants/formate_date.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatefulWidget {
  final MessageModel msg;
  final String currentUser;
  final bool isImage;

  const ChatMessage(
      {super.key,
      required this.msg,
      required this.currentUser,
      required this.isImage});

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: widget.msg.sender == widget.currentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: widget.msg.sender == widget.currentUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              widget.isImage
                  ? Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                        imageUrl:
    "https://cloud.appwrite.io/v1/storage/buckets/668f94cf001c50b86555/files/${widget.msg.message}/view?project=668e1f750039e24ba6ee&mode=admin",
                      )),
                      padding: EdgeInsets.all(7),
                      margin: EdgeInsets.only(left: 5, right: 5),
                      decoration: BoxDecoration(
                          color: widget.msg.sender == widget.currentUser
                              ? kprimaryColor
                              : Colors.grey[700],
                          borderRadius: widget.msg.sender == widget.currentUser
                              ? BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20))
                              : BorderRadius.only(
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20))),
                    )
                  : Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75),
                      child: Text(
                        widget.msg.message,
                        style: TextStyle(fontSize: 16),
                      ),
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(left: 5, right: 5),
                      decoration: BoxDecoration(
                          color: widget.msg.sender == widget.currentUser
                              ? kprimaryColor
                              : Colors.grey[700],
                          borderRadius: widget.msg.sender == widget.currentUser
                              ? BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20))
                              : BorderRadius.only(
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20))),
                    ),
              Row(
                children: [
                  Text(formatDate(widget.msg.timestamp),style: TextStyle(fontSize: 12),),
                  widget.msg.sender == widget.currentUser
                      ? widget.msg.isSeen
                          ? Icon(
                              Icons.check_circle,
                              color: kprimaryColor,
                              size: 18,
                            )
                          : Icon(
                              Icons.check_circle_outline,
                              color: Colors.grey,
                              size: 18,
                            )
                      : SizedBox(),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
