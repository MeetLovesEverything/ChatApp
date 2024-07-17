

import 'package:chat_app/models/user_data.dart';

import 'message_model.dart';

class ChatDataModel {
  final MessageModel message;
  final List<UserData> users;

  ChatDataModel({required this.message, required this.users});
}