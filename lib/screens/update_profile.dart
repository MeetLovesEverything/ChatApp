import 'dart:ffi';
import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/controller/appwrite_controller.dart';
import 'package:chat_app/provider/user_data_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  TextEditingController _namecontroller = TextEditingController();
  TextEditingController _phonecontroller = TextEditingController();

  FilePickerResult? _filePickerResult;
  late String? imageId = "";
  late String? userId = "";
  final _namekey = GlobalKey<FormState>();

  @override
  void initState() {
    userId = Provider.of<UserDataProvider>(context, listen: false).getUserId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserDataProvider>(context, listen: false)
          .loadUserData(userId!)
          .then((_) {
        imageId = Provider.of<UserDataProvider>(context, listen: false)
            .getUserProfilePic;
      });
    });

    print("starting userid : $userId, imageId : $imageId");

    super.initState();
  }

  //open file picker
  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    setState(() {
      _filePickerResult = result;
    });
  }

  //upload image and save it to database
  Future uploadProfileImage() async {
    try {
      if (_filePickerResult != null && _filePickerResult!.files.isNotEmpty) {
        PlatformFile file = _filePickerResult!.files.first;
        final filebytes = await File(file.path!).readAsBytes();
        final inputfile =
            InputFile.fromBytes(bytes: filebytes, filename: file.name);

        //if image already exist for the user profile or not

        if (imageId != "" && imageId != null) {
          await updateImageOnBucket(imageId: imageId!, image: inputfile)
              .then((value) {
            if (value != null) {
              imageId = value;
            }
          });
        }

        //create new image in database
        else {
          await saveImageToBucket(image: inputfile).then((value) {
            if (value != null) {
              imageId = value;
            }
          });
        }
      } else {
        print("somting went wrong");
      }
    } catch (e) {
      print("some error occured : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> datapassed =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Consumer<UserDataProvider>(builder: (context, value, child) {
      _namecontroller.text = value.getUserName;
      _phonecontroller.text = value.getUserPhone;
      return Scaffold(
        appBar: AppBar(
          backgroundColor: kbackgroundColor,
          title: Text(
            datapassed["title"] == "edit" ? "Update Profile" : "Add Details",
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                ),
                GestureDetector(
                  onTap: () {
                    _openFilePicker();
                  },
                  child: Stack(children: [
                    CircleAvatar(
                      radius: 120,
                      backgroundImage: _filePickerResult != null
                          ? FileImage(
                              File(_filePickerResult!.files.first.path!))
                          : imageId != null && imageId != ""
                              ? CachedNetworkImageProvider(
                                  "https://cloud.appwrite.io/v1/storage/buckets/668f94cf001c50b86555/files/${imageId}/view?project=668e1f750039e24ba6ee&mode=admin")
                              : AssetImage("assets/user.png"),
                    ),
                    Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: kprimaryColor,
                              borderRadius: BorderRadius.circular(30)),
                          child: Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                          ),
                        )),
                  ]),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  margin: EdgeInsets.all(6),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Form(
                    key: _namekey,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return ("Enter the name");
                        } else
                          return null;
                      },
                      controller: _namecontroller,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter your name",
                          hintStyle: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  margin: EdgeInsets.all(6),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: TextFormField(
                    controller: _phonecontroller,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Phone Number",
                        hintStyle: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.all(6),
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_namekey.currentState!.validate()) {
                        //upload image if picked
                        if (_filePickerResult != null) {
                          await uploadProfileImage();
                        }
                        //save data to database
                        print(
                            "pic : $imageId, name : ${_namecontroller.text}, userId: $userId");
                        await updateUserDetails(
                          imageId ?? "",
                          name: _namecontroller.text,
                          userId: userId!,
                        );

                        Navigator.pushNamedAndRemoveUntil(
                            context, '/home', (route) => false);
                      }
                    },
                    child: Text(
                      datapassed["title"] == "edit"
                          ? "Update Profile"
                          : "Continue",
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kprimaryColor,
                        foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
