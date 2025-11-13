import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:peersglobleeventapp/home_page.dart';
import 'package:peersglobleeventapp/otpverification_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:peersglobleeventapp/widgets/autocomplatetextbox.dart';
import 'package:peersglobleeventapp/modelClass/model/auth_User_model.dart';
import 'package:peersglobleeventapp/data_repository/user_auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _countryCodeController =
  TextEditingController(text: '+91');

  final _formKey = GlobalKey<FormState>();
  bool ischeck = false;
  bool _isLoading = false;

  final AuthRepository _repo = AuthRepository();

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      if (!ischeck) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please accept Terms & Privacy Policy")),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        List<AuthUserModel> users = await _repo.fetchUsers();

        final mobile = _mobileController.text.trim();

        final matchUser = users.firstWhere(
              (u) => u.mobile.trim() == mobile,
          orElse: () => AuthUserModel(id: '', name: '', mobile: ''),
        );

        if (matchUser.id.isNotEmpty) {
          print("✅ User found: ${matchUser.mobile}");
          print("userid: ${matchUser.id}");

          final String phoneNumberForFirebase = '+91${matchUser.mobile}';
          print("📞 Sending OTP to: $phoneNumberForFirebase");

          // Send OTP via Firebase
          FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: phoneNumberForFirebase,

            verificationCompleted: (PhoneAuthCredential credential) async {
              print("✅ Auto verification completed");
              await FirebaseAuth.instance.signInWithCredential(credential);
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HomePage(userId: matchUser.id),
                ),
              );
            },
            verificationFailed: (FirebaseAuthException e) {
              print(" Verification failed: ${e.message}");
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.message ?? "Error")));
              setState(() {
                _isLoading = false;
              });
            },
            codeSent: (String verificationId, int? resendToken) {
              print("codeSent triggered with verificationId: $verificationId");
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtpverificationScreen(
                    mobile: matchUser.mobile,
                    verificationId: verificationId,
                    userId: matchUser.id,
                  ),
                ),
              );
            },
            codeAutoRetrievalTimeout: (String verificationId) {
              print("⏳ codeAutoRetrievalTimeout: $verificationId");
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Mobile number not found! please Register First "),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        print(" Error: $e");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 22, color: Colors.grey[700]),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    List<String> countrycode = [
      '+91',
      '+81',
      '+71',
      '+61',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.050,
              vertical: screenHeight * 0.02,
            ),
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
                        style: TextStyle(
                          fontSize: screenWidth * 0.060,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF535D97),
                        ),
                      ),
                      Text(
                        "Please enter your Mobile Number",
                        style: TextStyle(
                            fontSize: screenWidth * 0.030, color: Colors.grey),
                      ),
                      Text(
                        "and meet with your Community",
                        style: TextStyle(
                            fontSize: screenWidth * 0.030, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.040),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Country code + Mobile number
                      Row(
                        children: [
                          IntrinsicWidth(
                            child: SizedBox(
                              height: 55,
                              child: AutocompleteTextbox(
                                options: countrycode,
                                controller: _countryCodeController,
                                validator: (value) =>
                                value == null || value.isEmpty
                                    ? 'Please select code'
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 55,
                              child: TextFormField(
                                controller: _mobileController,
                                keyboardType: TextInputType.phone,
                                decoration: _inputDecoration(
                                    'Mobile Number', Icons.phone),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter mobile number';
                                  } else if (value.length != 10) {
                                    return 'Mobile number must be 10 digits';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01),

                      // Terms Checkbox
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
                                        _launchUrl(
                                            'https://peersglobal.com/terms-conditions/');
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
                                        _launchUrl(
                                            'https://peersglobal.com/code-of-conduct/');
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01),

                      // Login Button
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,   // 90% width of screen
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            double buttonHeight = constraints.maxWidth * 0.13; // auto height
                            double fontSize = constraints.maxWidth * 0.045;    // auto font size

                            return SizedBox(
                              height: buttonHeight.clamp(45, 60), // min 45, max 60
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _loginUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E356A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: fontSize, // Responsive font
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.06),

                      // Register link
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
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      context.go('/registration_screen');
                                    },
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