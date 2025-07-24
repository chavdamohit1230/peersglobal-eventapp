import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OtpverificationScreen extends StatefulWidget {
  final String mobile;

  const OtpverificationScreen({super.key, required this.mobile});

  @override
  State<OtpverificationScreen> createState() => _OtpverificationScreenState();
}

class _OtpverificationScreenState extends State<OtpverificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:Color(0xFFF0F4FD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal:screenHeight*0.030, vertical:screenHeight*0.090),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.05),
                Center(
                  child: Lottie.asset(
                    'assets/Otpverification.json',
                    width: screenWidth * 0.7,
                    height: screenHeight * 0.3,
                    fit: BoxFit.contain,
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Verify Mobile Number",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.05,
                            color:Color(0xFF535D97)
                        ),
                      ),
                      Text(
                        "Otp Sent To",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "+${widget.mobile}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.03,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Form(
                  key: _formKey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width:screenWidth*0.1,
                        height:screenHeight*0.07,
                        child: TextFormField(
                          controller: _otpControllers[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          decoration: const InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Opt';
                            }
                            return null;
                          },
                        ),
                      );
                    }),
                  ),
                ),
                 SizedBox(height:screenWidth*0.11),
                ElevatedButton(
                  onPressed: () {
                    // Custom validation: Check if all 6 fields are filled
                    bool allFilled = _otpControllers.every((controller) => controller.text.isNotEmpty);

                    if (!allFilled) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter complete 6-digit OTP")),
                      );
                      return;
                    }
                    String otp = _otpControllers.map((c) => c.text).join();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Verifying OTP: $otp")),
                    );
                  },
                  child: const Text("Verify OTP",style:TextStyle(color:Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:Color(0xFF2E356A),
                    minimumSize: Size(screenWidth*1,screenHeight*0.060),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
