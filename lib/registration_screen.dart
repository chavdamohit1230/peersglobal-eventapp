import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:peersglobleeventapp/home_page.dart';
import 'package:peersglobleeventapp/widgets/autocomplatetextbox.dart';
import 'package:peersglobleeventapp/widgets/dropdown.dart';
import 'package:peersglobleeventapp/widgets/multiline_textarea.dart';
import 'package:dio/dio.dart';
import 'package:peersglobleeventapp/widgets/formtextfiled.dart';
import 'package:peersglobleeventapp/modelClass/model/userregister_model.dart';
import 'package:peersglobleeventapp/Api/api_userRegister.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? Selectedvalue;
  String? Selectedpurpose;
  String? Hearaboutus;

  List<String> country = ['India', 'Pakistan', 'Australia', 'England'];
  List<String> State = ['Gujarat', 'Up', 'Bihar','Kerala','Patna','Raipur'];
  List<String> City = ['Botad', 'Ahmedabad', 'Surat','Bhavnagar','Navasari','Jumagadh','Amreli'];
  List<String> PurposeofAttending=['Networking','Business Opportunities','Exhibiting','Visitor','General Curiosity'];
  List<String> HearaboutFrom=['Linkdin','Instagram','facebook','twitter','whatsapp'];
  List<String> countrycode=['+91','+81','+71','+61','+51','+41','+31','+21','+11'];

  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController  statecontroller = TextEditingController();
  final TextEditingController  citycontroller = TextEditingController();
  final TextEditingController  multilineTextarea = TextEditingController();
  final TextEditingController  orgenationNameControler = TextEditingController();
  final TextEditingController  DesignationControler= TextEditingController();
  final TextEditingController  businessLocationControler=TextEditingController();
  final TextEditingController  CompanyWebsiteurlControler = TextEditingController();
  final TextEditingController  IndustryControler =TextEditingController();
  final TextEditingController   PurposeofAttendee =TextEditingController();
  final TextEditingController hearAboutus=TextEditingController();
  final TextEditingController  Otherinfomultiline =TextEditingController();
  final TextEditingController countrycode1= TextEditingController();

  void _nextPage() {
    if (_formKeys[_currentPage].currentState!.validate()) {
      if (_currentPage < 2) {
        setState(() {
          _currentPage++;
        });
        _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn);
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut);
    }
  }

  void _submitForm() async {
    if (_formKeys[_currentPage].currentState!.validate()) {
      try {
        // Pehle snackbar show karega
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submitting registration...')),
        );

        // User model banayenge
        final user = UserRegister(
          name: _nameController.text,
          email: _emailController.text,
          mobile: _mobileController.text,
          countrycode: countrycode1.text,
          country: countryController.text,
          state: statecontroller.text,
          city: citycontroller.text,
          aboutme: multilineTextarea.text,
          organization: orgenationNameControler.text,
          designation: DesignationControler.text,
          businessLocation: businessLocationControler.text,
          companywebsite: CompanyWebsiteurlControler.text,
          industry: IndustryControler.text,
          purposeOfAttending: Selectedpurpose ?? '',
          hearAboutUs: Hearaboutus ?? '',
          otherInfo: Otherinfomultiline.text,
        );

        // Dio + ApiClient instance
        final dio = Dio();
        final apiClient = ApiClient(dio);

        final response = await apiClient.registerUser(user.toJson());
        if (response.response.statusCode == 200) {
          final userId = response.response.data["id"]?.toString() ?? "";

          // yahi bhejo: pura user + userId
          context.go(
            "/home_page",
            extra: {
              'user': user,      // UserRegister object
              'userId': userId,  // backend id
            },
          );
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('⚠️ Failed: ${response.response.statusMessage ?? "Unknown error"}')),
          );
        }

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.04;
    final verticalPadding = screenHeight * 0.015;
    final headingFontSize = screenWidth * 0.05;
    final spacing = screenHeight * 0.02;

    double progress = (_currentPage + 1) / 3;

    return Scaffold(
      backgroundColor:Color(0xFFF0F4FD),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Registration",style:TextStyle(fontWeight: FontWeight.bold,color:Color(0xFF535D97),),),
        centerTitle: true,
        backgroundColor:Color(0xFFC3CCDA),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            color: Colors.blue,
            minHeight: 5,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Step 1
                Form(
                  key: _formKeys[0],
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenHeight * 0.030),

                        /// Step Title
                        Text(
                          "Step 1: Personal Information",
                          style: TextStyle(
                            fontSize: headingFontSize,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF535D97),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.030),

                        /// Name
                        SizedBox(
                          height: 55,
                          child: Formtextfiled(
                            controller: _nameController,
                            labelText: 'Enter Name',
                            prefixIcon: Icons.person,
                            keybordType: TextInputType.text,
                            validator: (value) =>
                            value == null || value.isEmpty ? 'Please Enter Name' : null,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.020),

                        /// Mobile + Country Code (Perfect Alignment)
                        Row(
                          children: [
                            SizedBox(
                              width: 84,
                              height: 55,
                              child: TextFormField(
                                controller: countrycode1,
                                decoration: InputDecoration(
                                  hintText: '+91',
                                  prefixIcon: Icon(Icons.flag, size: 22, color: Colors.grey[700]),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) =>
                                value == null || value.isEmpty ? 'Code' : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 55,
                                child: Formtextfiled(
                                  controller: _mobileController,
                                  labelText: 'Enter Mobile',
                                  prefixIcon: Icons.call,
                                  keybordType: TextInputType.phone,
                                  validator: (value) => value == null || value.isEmpty
                                      ? 'Enter Mobile Number'
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.020),

                        /// Email
                        SizedBox(
                          height: 55,
                          child: Formtextfiled(
                            controller: _emailController,
                            labelText: 'Enter Email',
                            prefixIcon: Icons.attach_email,
                            keybordType: TextInputType.emailAddress,
                            validator: (value) =>
                            value == null || value.isEmpty ? 'Enter Email' : null,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.020),

                        /// Country
                        SizedBox(
                          height: 55,
                          child: AutocompleteTextbox(
                            options: country,
                            label: 'Select Country',
                            icon: Icons.flag,
                            controller: countryController,
                            validator: (value) =>
                            value == null || value.isEmpty ? 'Please select a country' : null,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.020),

                        /// State
                        SizedBox(
                          height: 55,
                          child: AutocompleteTextbox(
                            options: State,
                            label: 'Select State',
                            icon: Icons.map,
                            controller: statecontroller,
                            validator: (value) =>
                            value == null || value.isEmpty ? 'Please select State' : null,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.020),

                        /// City
                        SizedBox(
                          height: 55,
                          child: AutocompleteTextbox(
                            options: City,
                            label: 'Select City',
                            icon: Icons.home,
                            controller: citycontroller,
                            validator: (value) =>
                            value == null || value.isEmpty ? 'Please select City' : null,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.020),

                        /// About Me (Multi-line but uniform style)
                        SizedBox(
                          height: 110, // bigger but consistent padding
                          child: MultilineTextarea(
                            label: 'About Me',
                            icon: Icons.description,
                            controller: multilineTextarea,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),


            // Step 2
                Form(
                  key: _formKeys[1],
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenHeight*0.030),
                        Text(
                          "Step 2: Business Information",
                          style: TextStyle(
                              fontSize: headingFontSize,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height:screenHeight*0.030),

                          Formtextfiled(
                              controller:orgenationNameControler,
                              labelText:'Enter Organization',
                              prefixIcon:Icons.reduce_capacity_outlined,
                            validator:(value)=> value==null || value.isEmpty? 'Please Enter Organization':null,
                          ),

                        SizedBox(height:screenHeight*0.020),
                        Formtextfiled(controller: DesignationControler,
                            labelText:'Enter Designation',
                            prefixIcon:Icons.policy_rounded,
                            keybordType:TextInputType.text,
                          validator:(value)=> value==null || value.isEmpty? 'Please Enter Designation':null,
                        ),
                        SizedBox(height:screenHeight*0.020),

                        Formtextfiled(controller:businessLocationControler,
                            labelText:'Enter Business Location (Optional)',
                            prefixIcon:Icons.location_history),
                        SizedBox(height:screenHeight*0.020),
                        Formtextfiled(controller:CompanyWebsiteurlControler,
                            labelText:'Company Website Url (Optional)',
                            prefixIcon:Icons.public),
                        SizedBox(height:screenHeight*0.020),

                        Formtextfiled(controller: IndustryControler,
                            labelText:'Enter Industry (Optional)',
                            prefixIcon: Icons.location_city_rounded)
                      ],
                    ),
                  ),
                ),

                // Step 3
                Form(
                  key: _formKeys[2],
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenHeight*0.030),
                        Text(
                          "Step 3: Confirm Info",
                          style: TextStyle(
                              fontSize: headingFontSize,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: screenHeight*0.030),
                            FormDropdownField(labelText:'Purpose Of Attending',
                                value:Selectedpurpose,
                                items:PurposeofAttending,
                                onChanged:(val){
                                  setState(() {
                                    Selectedpurpose = val;
                                  });
                                },
                                validator:(val) => val == null || val.isEmpty? 'Please Select Purpose of Attending': null ,
                                ),
                            SizedBox(height: screenHeight*0.020),

                        FormDropdownField(
                                labelText:''
                                    'How did you hear about us',
                                items:HearaboutFrom,
                                value:Hearaboutus,
                                onChanged:(val){
                                  setState(() {
                                    Hearaboutus=val;
                                  });
                                }),
                          SizedBox(height: screenHeight*0.020),
                        MultilineTextarea(
                                  label:'Anything else we should know?',
                                  icon:Icons.description,
                                  controller:Otherinfomultiline)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: verticalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_currentPage > 0)
                  Padding(
                    padding:  EdgeInsets.only(right:screenWidth*0.012,bottom:screenHeight*0.025),
                    child: SizedBox(width:screenWidth*0.40,
                      height:screenHeight*0.05,
                      child: ElevatedButton(
                        onPressed: _previousPage,
                        style:ElevatedButton.styleFrom(
                            backgroundColor:Color(0xFF2E356A),
                            foregroundColor:Colors.white,
                            textStyle:TextStyle(fontSize:screenWidth*0.040)
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  ),
                SizedBox(width:screenWidth*0.1,),
                if (_currentPage < 2)
                  Padding(
                    padding:  EdgeInsets.only(right:screenWidth*0.012,bottom:screenHeight*0.025),
                    child: SizedBox(
                      width:screenWidth*0.37,
                      height:screenHeight*0.05,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style:ElevatedButton.styleFrom(
                            backgroundColor:Color(0xFF2E356A),
                          foregroundColor:Colors.white,
                          textStyle:TextStyle(fontSize:screenWidth*0.040)
                        ),
                        child: const Text('Next',),
                      ),
                    ),
                  ),

                if (_currentPage == 2)
                  Padding(
                    padding:  EdgeInsets.only(right:screenWidth*0.012,bottom:screenHeight*0.025),
                    child: SizedBox(
                      width:screenWidth*0.37,
                      height:screenHeight*0.05,
                      child: ElevatedButton(
                        onPressed:(){
                          _submitForm();
                        },
                        style:ElevatedButton.styleFrom(
                            backgroundColor:Color(0xFF2E356A),
                            foregroundColor:Colors.white,
                            textStyle:TextStyle(fontSize:screenWidth*0.040)
                        ),
                        child: const Text('Submit'),

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
