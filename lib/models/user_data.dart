class UserData {
  final String userId;
  final String phone;
  final String? name;
  final String? profilePic;
  final String? deviceToken;
  final bool? isOnline;

  UserData(
      {required this.userId,
      required this.phone,
      this.name,
      this.profilePic,
      this.deviceToken,
      this.isOnline});
 // convert document data to userdata
  factory UserData.toMap(Map<String, dynamic> map) {
    return UserData(
      userId: map["userId"] ?? "",
      phone: map["phone_no"] ?? "",
      name: map["name"] ?? "",
      profilePic: map["profile_pic"] ?? "",
      deviceToken: map["device_token"] ?? "",
      isOnline: map["isOnline"] ?? false,
    );
  }
}
