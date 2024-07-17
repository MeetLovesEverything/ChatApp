import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/constants/chat_message.dart';
import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/controller/appwrite_controller.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_data.dart';
import 'package:chat_app/provider/chat_provider.dart';
import 'package:chat_app/provider/user_data_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  TextEditingController editmessageController = TextEditingController();

  late String userId = "";
  late String userName = "";

  FilePickerResult? _filePickerResult;

  @override
  void initState() {
    super.initState();
    userId = Provider.of<UserDataProvider>(context, listen: false).getUserId;
    userName =
        Provider.of<UserDataProvider>(context, listen: false).getUserName;
    print("username : - $userName & userID : - $userId");
  }

  void _openFilePicker(UserData receiver) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);

    setState(() {
      _filePickerResult = result;
      uploadAllImage(receiver);
    });
  }

  void uploadAllImage(UserData receiver) async {
    if (_filePickerResult != null) {
      _filePickerResult!.paths.forEach((path) {
        if (path != null) {
          var file = File(path);
          final fileBytes = file.readAsBytesSync();
          final inputfile = InputFile.fromBytes(
              bytes: fileBytes, filename: file.path.split("/").last);

          // saving image to our storage bucket
          saveImageToBucket(image: inputfile).then((imageId) {
            if (imageId != null) {
              createNewMessage(
                message: imageId,
                senderId: userId,
                receiverId: receiver.userId,
                isImage: true,
              ).then((value) {
                if (value != null) {
                  Provider.of<ChatProvider>(context, listen: false).addMessage(
                      MessageModel(
                        message: imageId,
                        sender: userId,
                        receiver: receiver.userId,
                        timestamp: DateTime.now(),
                        isSeen: false,
                        isImage: true,
                      ),
                      userId,
                      [UserData(phone: "", userId: userId), receiver]);
                  sendNotificationtoOtherUser(
                      notificationTitle: '$userName sent you an image',
                      notificationBody: "check it out.",
                      deviceToken: receiver.deviceToken!);
                }
              });
            }
          });
        }
      });
    } else {
      print("file pick cancelled by user");
    }
  }

  void _sendMessage({required UserData receiver}) {
    if (messageController.text.isNotEmpty) {
      setState(() {
        createNewMessage(
          message: messageController.text,
          senderId: userId,
          receiverId: receiver.userId,
          isImage: false,
        ).then((newMessageId) {
          if (newMessageId != null) {
            Provider.of<ChatProvider>(context, listen: false).addMessage(
              MessageModel(
                message: messageController.text,
                sender: userId,
                receiver: receiver.userId,
                timestamp: DateTime.now(),
                isSeen: false,
                isImage: false,
                messageID: newMessageId, // Assign the new message ID here
              ),
              userId,
              [UserData(userId: userId, phone: ""), receiver],
            );

            sendNotificationtoOtherUser(
                notificationTitle: "${userName} sent you a message",
                notificationBody: messageController.text,
                deviceToken: receiver.deviceToken!);

            messageController.clear();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    UserData receiver = ModalRoute.of(context)!.settings.arguments as UserData;
    return Consumer<ChatProvider>(
      builder: (context, value, child) {
        final userAndOtherChats = value.getAllChats[receiver.userId] ?? [];

        bool? otherUserOnline = userAndOtherChats.isNotEmpty
            ? userAndOtherChats[0].users[0].userId == receiver.userId
                ? userAndOtherChats[0].users[0].isOnline
                : userAndOtherChats[0].users[1].isOnline
            : false;

        List<String> receiverMsgList = [];
        for (var chat in userAndOtherChats) {
          if (chat.message.receiver == userId) {
            if (chat.message.isSeen == false) {
              receiverMsgList.add(chat.message.messageID!);
            }
          }
        }
        updateIsSeen(chatsIds: receiverMsgList);
        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: kbackgroundColor,
            leadingWidth: 40,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundImage: receiver.profilePic != "" &&
                          receiver.profilePic != null
                      ? CachedNetworkImageProvider(
                          "https://cloud.appwrite.io/v1/storage/buckets/668f94cf001c50b86555/files/${receiver.profilePic}/view?project=668e1f750039e24ba6ee&mode=admin")
                      : AssetImage("assets/user.png"),
                  radius: 20,
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receiver.name!,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      otherUserOnline == true ? "Online" : "Offline",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                )
              ],
            ),
            scrolledUnderElevation: 0,
            elevation: 0,
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: ListView.builder(
                      reverse: true,
                      itemCount: userAndOtherChats.length,
                      itemBuilder: (context, index) {
                        final chatData = userAndOtherChats[
                            userAndOtherChats.length - 1 - index];
                        final msg = chatData.message;
                        return GestureDetector(
                          onLongPress: () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: msg.isImage == true
                                          ? Text(
                                              msg.sender == userId
                                                  ? "Choose what you want to do with this image."
                                                  : "This image can't be modified",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )
                                          : Text(
                                              "${msg.message.length > 20 ? msg.message.substring(0, 20) : msg.message} ...",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                      backgroundColor: Colors.grey[800],
                                      content: msg.isImage == true
                                          ? Text(
                                              msg.sender == userId
                                                  ? 'Delete this image'
                                                  : 'This image can\'t be deleted',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )
                                          : Text(
                                              msg.sender == userId
                                                  ? 'Choose what you want to do with this message.'
                                                  : 'This message can\'t be modified',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text("Cancel",
                                                style: TextStyle(
                                                  color: kprimaryColor,
                                                ))),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              editmessageController.text =
                                                  msg.message;
                                              showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                        title: Text("Edit"),
                                                        backgroundColor:
                                                            Colors.grey[800],
                                                        content: TextFormField(
                                                          controller:
                                                              editmessageController,
                                                          decoration:
                                                              InputDecoration(
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                              borderSide:
                                                                  BorderSide(
                                                                      color: Colors
                                                                          .grey),
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                              borderSide:
                                                                  BorderSide(
                                                                      color: Colors
                                                                          .grey),
                                                            ),
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              editChat(
                                                                  chatId: msg
                                                                      .messageID!,
                                                                  message:
                                                                      editmessageController
                                                                          .text);
                                                              Navigator.pop(
                                                                  context);
                                                              editmessageController
                                                                  .text = "";
                                                            },
                                                            child: const Text(
                                                              "Update",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            style: TextButton.styleFrom(
                                                                backgroundColor:
                                                                    kprimaryColor),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                              "Cancel",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            style: TextButton.styleFrom(
                                                                backgroundColor:
                                                                    kprimaryColor),
                                                          ),
                                                        ],
                                                      ));
                                            },
                                            child: Text("Edit",
                                                style: TextStyle(
                                                  color: kprimaryColor,
                                                ))),
                                        msg.sender == userId
                                            ? TextButton(
                                                onPressed: () {
                                                  Provider.of<ChatProvider>(
                                                          context,
                                                          listen: false)
                                                      .deleteMessage(
                                                          msg, userId);
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Delete",
                                                    style: TextStyle(
                                                      color: kprimaryColor,
                                                    )))
                                            : SizedBox(),
                                      ],
                                    ));
                          },
                          child: ChatMessage(
                            isImage: msg.isImage ?? false,
                            msg: msg,
                            currentUser: userId,
                          ),
                        );
                      }),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 6, right: 6, bottom: 6),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      onSubmitted: (value) {
                        _sendMessage(receiver: receiver);
                      },
                      controller: messageController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.grey),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )),
                    IconButton(
                        onPressed: () {
                          _openFilePicker(receiver);
                        },
                        icon: Icon(
                          Icons.image,
                          color: Colors.grey,
                        )),
                    IconButton(
                        onPressed: () {
                          _sendMessage(receiver: receiver);
                        },
                        icon: Icon(
                          Icons.send,
                          color: Colors.grey,
                        )),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
