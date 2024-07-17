import 'package:chat_app/controller/appwrite_controller.dart';
import 'package:chat_app/provider/user_data_provider.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';

class PhoneLogin extends StatefulWidget {
  const PhoneLogin({Key? key}) : super(key: key);

  @override
  _PhoneLoginState createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String countryCode = "+91";

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Spacer(),
          CircleAvatar(
            radius: height * 0.115,
            backgroundImage: AssetImage("assets/chat.gif"),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome to Chat App 👋",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
                ),
                SizedBox(height: 8),
                Text(
                  "Enter your phone number to continue",
                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 18),
                ),
                SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      } else if (value.length != 10) {
                        return 'Please enter a valid 10-digit phone number';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: CountryCodePicker(
                        dialogBackgroundColor: Colors.black,
                        initialSelection: 'in',
                        dialogTextStyle: TextStyle(locale: Locale('en', 'in')),
                        onChanged: (value) {
                          countryCode = value.code!;
                          print(value.code);
                        },
                      ),
                      labelText: "Enter your Phone Number",
                      labelStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        createPhoneSession(
                                phone: countryCode + _phoneController.text)
                            .then((value) {
                          if (value != "login_error") {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      backgroundColor: Colors.grey[800],
                                      title: Text("OTP Verification"),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Enter the 6-digit OTP "),
                                            Form(
                                              key: _formKey1,
                                              child: TextFormField(
                                                controller: _otpController,
                                                validator: (value) {
                                                  if (value!.length != 6)
                                                    return "Invalid OTP";
                                                  else
                                                    return null;
                                                },
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              alignment: Alignment.bottomRight,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  String userId = value;
                                                  if (_formKey1.currentState!
                                                      .validate()) {
                                                    loginWithOtp(
                                                            otp: _otpController
                                                                .text,
                                                            userId: userId)
                                                        .then((value) {
                                                      if (value) {
                                                        Provider.of<UserDataProvider>(
                                                                context,
                                                                listen: false)
                                                            .setUserId(userId);
                                                        Provider.of<UserDataProvider>(
                                                                context,
                                                                listen: false)
                                                            .setUserPhone(
                                                                countryCode +
                                                                    _phoneController
                                                                        .text);
                                                        Provider.of<UserDataProvider>(
                                                                context,
                                                                listen: false)
                                                            .loadUserData(
                                                                userId);
                                                        String name = Provider.of<
                                                                    UserDataProvider>(
                                                                context,
                                                                listen: false)
                                                            .getUserName;
                                                        Navigator.pushNamedAndRemoveUntil(
                                                            context,
                                                            name != "" &&
                                                                    name != null
                                                                ? '/home'
                                                                : '/update_profile',
                                                            (route) => false,
                                                            arguments: {
                                                              "title": "add"
                                                            });
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(SnackBar(
                                                                content: Text(
                                                                    "Login Failed")));
                                                      }
                                                    });
                                                  }
                                                },
                                                child: Text("Submit"),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ));
                          } else {}
                        });
                      }
                    },
                    child: Text("Send OTP"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kprimaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
