import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../constants/formate_date.dart';
import '../controller/appwrite_controller.dart';
import '../controller/fcm_controllers.dart';
import '../models/chat_data_model.dart';
import '../models/user_data.dart';
import '../provider/chat_provider.dart';
import '../provider/user_data_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String currentUserid = "";


  @override
  void initState() {
    currentUserid =
        Provider.of<UserDataProvider>(context, listen: false).getUserId;
    Provider.of<ChatProvider>(context, listen: false).loadChats(currentUserid);
    PushNotifications.getDeviceToken();
    subscribeToRealtime(userId: currentUserid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    updateOnlineStatus(status: true, userId: currentUserid);
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: kbackgroundColor,
        title: Text(
          "Chats",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          GestureDetector(
              onTap: () => Navigator.pushNamed(context, "/profile"),
              child:
                  Consumer<UserDataProvider>(builder: (context, value, child) {
                return CircleAvatar(
                  backgroundImage: value.getUserProfilePic != null &&
                          value.getUserProfilePic != ""
                      ? CachedNetworkImageProvider(
                          "https://cloud.appwrite.io/v1/storage/buckets/668f94cf001c50b86555/files/${value.getUserProfilePic}/view?project=668e1f750039e24ba6ee&mode=admin")
                      : Image(
                          image: AssetImage("assets/user.png"),
                        ).image,
                );
              }))
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, value, child) {
          if (value.getAllChats.isEmpty) {
            return Center(
              child: Text("No Chats"),
            );
          } else {
            List otherUsers = value.getAllChats.keys.toList();
            return ListView.builder(
                itemCount: otherUsers.length,
                itemBuilder: (context, index) {
                  List<ChatDataModel> chatData =
                      value.getAllChats[otherUsers[index]]!;

                  int totalChats = chatData.length;

                  UserData otherUser =
                      chatData[0].users[0].userId == currentUserid
                          ? chatData[0].users[1]
                          : chatData[0].users[0];

                  int unreadMsg = 0;

                  chatData.fold(
                    unreadMsg,
                    (previousValue, element) {
                      if (element.message.isSeen == false) {
                        unreadMsg++;
                      }
                      return unreadMsg;
                    },
                  );
                  return ListTile(
                    onTap: () => Navigator.pushNamed(context, "/chat",
                        arguments: otherUser),
                    leading: Stack(children: [
                      CircleAvatar(
                        backgroundImage: otherUser.profilePic == "" ||
                                otherUser.profilePic == null
                            ? Image(
                                image: AssetImage("assets/user.png"),
                              ).image
                            : CachedNetworkImageProvider(
                                "https://cloud.appwrite.io/v1/storage/buckets/668f94cf001c50b86555/files/${otherUser.profilePic}/view?project=668e1f750039e24ba6ee&mode=admin"),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 6,
                          backgroundColor: otherUser.isOnline == true
                              ? Colors.green
                              : Colors.grey.shade600,
                        ),
                      )
                    ]),
                    textColor: Colors.white,
                    title: Text(otherUser.name!),
                    subtitle: Text(
                      "${chatData[totalChats - 1].message.sender == currentUserid ? "You : " : ""}${chatData[totalChats - 1].message.isImage == true ? "Sent an image" : chatData[totalChats - 1].message.message}",
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        chatData[totalChats - 1].message.sender != currentUserid
                            ? unreadMsg != 0
                                ? CircleAvatar(
                                    backgroundColor: kprimaryColor,
                                    radius: 10,
                                    child: Text(
                                      unreadMsg.toString(),
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.white),
                                    ),
                                  )
                                : SizedBox()
                            : SizedBox(),
                        SizedBox(
                          height: 8,
                        ),
                        Text(formatDate(
                            chatData[totalChats - 1].message.timestamp))
                      ],
                    ),
                  );
                });
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kprimaryColor,
        onPressed: () {
          Navigator.pushNamed(context, "/search");
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
