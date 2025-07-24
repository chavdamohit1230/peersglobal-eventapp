import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:peersglobleeventapp/otpverification_screen.dart';
import 'package:peersglobleeventapp/registration_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool ischeck = false;

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.050, vertical: screenHeight * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.05),
                Center(
                  child: Lottie.asset(
                    'assets/loading.json',
                    width: screenWidth * 0.6,
                    height: screenHeight * 0.3,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Welcome Back!",
                        style: TextStyle(fontSize: screenWidth * 0.060, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Please enter your Mobile Number",
                        style: TextStyle(fontSize: screenWidth * 0.030, color: Colors.grey),
                      ),
                      Text(
                        "and meet with your Community",
                        style: TextStyle(fontSize: screenWidth * 0.030, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.040),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.010),
                          prefixIcon: Icon(Icons.person, size: screenWidth * 0.060),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter username';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.020),
                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.010),
                          labelText: 'Mobile Number',
                          prefixIcon: Icon(Icons.phone, size: screenWidth * 0.060),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter mobile number';
                          } else if (value.length != 10) {
                            return 'Mobile number must be 10 digits';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Row(
                        children: [
                          Checkbox(
                            value: ischeck,
                            onChanged: (bool? value) {
                              setState(() {
                                ischeck = value!;
                              });
                            },
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  color: Colors.black,
                                ),
                                children: [
                                  const TextSpan(text: 'I accept the '),
                                  TextSpan(
                                    text: 'Terms & Conditions',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        _launchUrl('https://policies.google.com/terms');
                                      },
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        _launchUrl('https://policies.google.com/privacy');
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (!ischeck) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please accept Terms & Privacy Policy")),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OtpverificationScreen(
                                  mobile: _mobileController.text,
                                ),
                              ),
                            );
                          }
                        },
                        child: Text('Login', style: TextStyle(fontSize: screenWidth * 0.050)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, screenHeight * 0.050),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height:screenHeight*0.06,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          RichText(
                            text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Don't have an account?  ",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenWidth * 0.04,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Register here",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                      fontSize: screenWidth * 0.04,
                                    ),
                                      recognizer:TapGestureRecognizer()
                                        ..onTap=(){
                                          Navigator.push(context,MaterialPageRoute(builder:(context) => RegistrationScreen(),));
                                        }
                                  ),
                                ],
                            ),
                          )

                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
