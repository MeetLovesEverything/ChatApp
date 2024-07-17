// import 'package:chat_app/controller/appwrite_controller.dart';
// import 'package:chat_app/models/chat_data_model.dart';
// import 'package:chat_app/models/message_model.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../models/user_data.dart';
//
// class ChatProvider extends ChangeNotifier {
//   Map<String, List<ChatDataModel>> _chats = {};
//
//   Map<String, List<ChatDataModel>> get getAllChats => _chats;
//
//   //load current chats
//   void loadChats(String currentUser) async {
//     Map<String, List<ChatDataModel>>? loadedChats =
//         await currentUserChats(currentUser);
//     if (loadedChats != null) {
//       _chats = loadedChats;
//     }
//
//     _chats.forEach((key, value) {
//       value.sort((a, b) => a.message.timestamp.compareTo(b.message.timestamp));
//     });
//     print("chats updated in provider");
//
//     notifyListeners();
//   }
//
//   //add chat message when user send message to someone
//   void addMessage(
//       MessageModel message, String currentUser, List<UserData> users) {
//     try {
//       if (_chats[message.sender] == null) {
//         _chats[message.sender] = [];
//       }
//       _chats[message.sender]!.add(ChatDataModel(message: message, users: users));
//
//       if (_chats[message.receiver] == null) {
//         _chats[message.receiver] = [];
//       }
//       _chats[message.receiver]!.add(ChatDataModel(message: message, users: users));
//
//       notifyListeners();
//     } catch (e) {
//       print("error in adding message : $e");
//     }
//   }
//
//
//   //delete message from chats data
//   void deleteMessage(MessageModel message, String currentUser) async {
//     try {
//       // user is delete the message
//       print("message sender: ${message.sender}, current :${currentUser}, isImage : ${message.isImage},message reicever: ${message.receiver}, message id: ${message.messageID}");
//       if (message.sender == currentUser) {
//         _chats[message.receiver]!
//             .removeWhere((element) => element.message == message);
//
//         if (message.isImage == true) {
//           deleteImagefromBucket(imageId: message.message);
//           print("image deleted from bucket");
//         }
//
//         deleteCurrentUserChat(chatId: message.messageID!);
//       } else {
//         // current user is receiver
//         _chats[message.sender]!
//             .removeWhere((element) => element.message == message);
//         print("message deleted");
//       }
//       notifyListeners();
//     } catch (e) {
//       print("error on message deletion : $e");
//     }
//   }
//
//   //clear values
//   void clearAllProvider()
//   {
//
//   }
// }
import 'dart:async';

import 'package:flutter/foundation.dart';


import '../controller/appwrite_controller.dart';
import '../models/chat_data_model.dart';
import '../models/message_model.dart';
import '../models/user_data.dart';

class ChatProvider extends ChangeNotifier {
  Map<String, List<ChatDataModel>> _chats = {};

  // get all users chats
  Map<String, List<ChatDataModel>> get getAllChats => _chats;

  Timer? _debounce;

  // to load all current user chats
  void loadChats(String currentUser) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(seconds: 1), () async {
      Map<String, List<ChatDataModel>>? loadedChats =
      await currentUserChats(currentUser);

      if (loadedChats != null) {
        _chats = loadedChats;

        _chats.forEach((key, value) {
          // sorting in descending timestamp
          value.sort(
                  (a, b) => a.message.timestamp.compareTo(b.message.timestamp));
        });
        print("chats updated in provider");

        notifyListeners();
      }
    });
  }

  // add the chat message when user send a new message to someone else
  void addMessage(
      MessageModel message, String currentUser, List<UserData> users) {
    try {
      if (message.sender == currentUser) {
        if (_chats[message.receiver] == null) {
          _chats[message.receiver] = [];
        }

        _chats[message.receiver]!
            .add(ChatDataModel(message: message, users: users));
      } else {
        //  the current user is receiver
        if (_chats[message.sender] == null) {
          _chats[message.sender] = [];
        }

        _chats[message.sender]!
            .add(ChatDataModel(message: message, users: users));
      }

      notifyListeners();
    } catch (e) {
      print("error in chatprovider on message adding");
    }
  }

  // delete message from the chats data
  void deleteMessage(MessageModel message, String currentUser) async {
    try {
      // user is delete the message
      if (message.sender == currentUser) {
        _chats[message.receiver]!
            .removeWhere((element) => element.message == message);

        if (message.isImage == true) {
          deleteImagefromBucket(imageId: message.message);
          print("image deleted from bucket");
        }

        deleteCurrentUserChat(chatId: message.messageID!);
      } else {
        // current user is receiver
        _chats[message.sender]!
            .removeWhere((element) => element.message == message);
        print("message deleted");
      }
      notifyListeners();
    } catch (e) {
      print("error on message deletion");
    }
  }

  // clear all chats
  void clearChats() {
    _chats = {};
    notifyListeners();
  }
}
