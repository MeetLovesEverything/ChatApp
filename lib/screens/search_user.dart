import 'package:appwrite/models.dart';
import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/controller/appwrite_controller.dart';
import 'package:chat_app/provider/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_data.dart';

class SearchUser extends StatefulWidget {
  const SearchUser({super.key});

  @override
  State<SearchUser> createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  TextEditingController _searchController = TextEditingController();
  DocumentList searchedUsers = DocumentList(total: -1, documents: []);

  void _handleSearch() {
    searchUsers(
        searchItem: _searchController.text,
        userId:
        Provider.of<UserDataProvider>(context, listen: false).getUserId)
        .then((value) {
      setState(() {
        if (value != null) {
          searchedUsers = value;
        } else {
          searchedUsers = DocumentList(total: 0, documents: []);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kbackgroundColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Search User",
          style: TextStyle(color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.grey,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (value) => _handleSearch(),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Phone Number",
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      _handleSearch();
                    },
                    icon: Icon(
                      Icons.search,
                      size: 35,
                    )),
              ],
            ),
          ),
        ),
      ),
      body: searchedUsers.total == -1
          ? Center(
        child: Text("Use the search box to search users."),
      )
          : searchedUsers.total == 0
          ? Center(
        child: Text("No users found"),
      )
          : ListView.builder(
        itemCount: searchedUsers.documents.length,
        itemBuilder: (context, index) {
          return ListTile(
            textColor: Colors.white,
            onTap: () {
              Navigator.pushNamed(context, "/chat",
                  arguments: UserData.toMap(
                      searchedUsers.documents[index].data));
            },
            leading: CircleAvatar(
              backgroundImage: searchedUsers.documents[index].data["profile_pic"] != null &&
                  searchedUsers.documents[index].data["profile_pic"] != ""
                  ? NetworkImage(
                  "https://cloud.appwrite.io/v1/storage/buckets/668f94cf001c50b86555/files/${searchedUsers.documents[index].data["profile_pic"]}/view?project=668e1f750039e24ba6ee&mode=admin")
                  : Image(image: AssetImage("assets/user.png")).image,
            ),
            title: Text(searchedUsers.documents[index].data["name"]),
            subtitle: Text(searchedUsers.documents[index].data["phone_no"]),
          );
        },
      ),
    );
  }
}
