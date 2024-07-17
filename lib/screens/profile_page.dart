import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/controller/appwrite_controller.dart';
import 'package:chat_app/controller/local_saved_data.dart';
import 'package:chat_app/provider/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/user_data_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(builder: (context, value, child) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: kbackgroundColor,
            iconTheme: IconThemeData(color: Colors.white),
            title: Text(
              "Profile",
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: ListView(
            children: [
              ListTile(
                onTap: () {
                  Navigator.pushNamed(context, '/update_profile',
                      arguments: {"title": "edit"});
                },
                leading: CircleAvatar(
                  backgroundImage: value.getUserProfilePic != ""
                      ? CachedNetworkImageProvider(
                          "https://cloud.appwrite.io/v1/storage/buckets/668f94cf001c50b86555/files/${value.getUserProfilePic}/view?project=668e1f750039e24ba6ee&mode=admin")
                      : AssetImage("assets/user.png"),
                ),
                textColor: Colors.white,
                title: Text(value.getUserName),
                subtitle: Text(
                  value.getUserPhone,
                ),
                trailing: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.mode_edit_outline_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Colors.grey,
                ),
                textColor: Colors.white,
                title: Text("Logout"),
                onTap: () async {
                  await LocalSavedData.clearALlData();
                  updateOnlineStatus(status: false, userId: value.getUserId);

                  Provider.of<UserDataProvider>(context, listen: false)
                      .clearAllProvider();
                  Provider.of<ChatProvider>(context, listen: false)
                      .clearChats();
                  await logout();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.info,
                  color: Colors.grey,
                ),
                textColor: Colors.white,
                title: Text("About"),
              )
            ],
          ));
    });
  }
}
