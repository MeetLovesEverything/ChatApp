import 'package:chat_app/controller/appwrite_controller.dart';
import 'package:chat_app/controller/local_saved_data.dart';
import 'package:chat_app/models/user_data.dart';
import 'package:flutter/cupertino.dart';

class UserDataProvider extends ChangeNotifier{
  String _userId = "";
  String _userName = "";
  String _userProfilePic = "";
  String _userPhoneNumber = "";
  String _userDeviceToken = "";

  String get getUserId => _userId;
  String get getUserName => _userName;
  String get getUserProfilePic => _userProfilePic;
  String get getUserPhone => _userPhoneNumber;
  String get getUserToken => _userDeviceToken;



  Future<void> loadDatafromLocale() async {
    _userId = await LocalSavedData.getUserId() as String;
    _userName = await LocalSavedData.getUserName() as String;
    _userProfilePic = await LocalSavedData.getUserProfile() as String;
    _userPhoneNumber = await LocalSavedData.getUserPhone() as String;
    print("userId: $_userId, usrPhone : $_userPhoneNumber, profile pic : $_userProfilePic, name : $_userName");
    notifyListeners();
  }


  Future<void> loadUserData(String userId) async{
    UserData? userData = await getUserDetails(userId: userId);
    if(userData != null)
      {
        _userName = userData.name ?? "";
        _userProfilePic = userData.profilePic ?? "";
        print("userId: $_userId, usrPhone : $_userPhoneNumber, profile pic : $_userProfilePic, name : $_userName");
        notifyListeners();
      }
  }

  void setUserId(String id){
    _userId = id;
    LocalSavedData.saveUserId(id);
    notifyListeners();
  }
  void setUserName(String name){
    _userName = name;
    LocalSavedData.saveUserName(name);
    notifyListeners();
  }
  void setUserProfile(String profile){
    _userProfilePic = profile;
    LocalSavedData.saveUserProfile(profile);
    notifyListeners();
  }
  void setUserPhone(String phone){
    _userPhoneNumber = phone;
    LocalSavedData.saveUserPhone(phone);
    notifyListeners();
  }
  void setDeviceToken(String token){
    _userDeviceToken = token;
    notifyListeners();
  }

  void clearAllProvider(){
    _userId = "";
    _userName = "";
    _userProfilePic = "";
    _userPhoneNumber = "";
    _userDeviceToken = "";
    notifyListeners();
  }


}