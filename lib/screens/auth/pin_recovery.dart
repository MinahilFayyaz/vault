import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';

import '../../consts/consts.dart';
import '../../provider/authprovider.dart';
import '../../provider/onboardprovider.dart';
import '../../utils/utils.dart';
import '../../widgets/custombutton.dart';
import '../homepage.dart';

class PinRecoveryPage extends StatefulWidget {
  const PinRecoveryPage({Key? key}) : super(key: key);

  @override
  State<PinRecoveryPage> createState() => _PinRecoveryPageState();
}

class _PinRecoveryPageState extends State<PinRecoveryPage> {
  final emailController = TextEditingController();
  final focus = FocusNode();
  final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Consumer<AuthProvider>(
      builder: (BuildContext context, provider, Widget? child) {
        return PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) => Utils(context).onWillPop(),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? Color(0xFFFFFFFF) // Color for light theme
                  : Consts.FG_COLOR,
              title: Text(
                'STEP 3/3',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  //color: Colors.white,
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.07,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      Text(
                        'Pin Recovery',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          //color: Colors.white,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Center(
                        child: Text(
                          'Simply enter your email address, and we’ll guide'
                              'you through the process of resetting Pin Securely',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            //color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      TextFormField(
                        focusNode: focus,
                        obscureText: provider.isObsecured,
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!emailRegex.hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Enter Your Email',
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.deepPurple),
                          ),
                          suffix: InkWell(
                            child: Icon(
                              provider.isObsecured
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onTap: () {
                              provider.isObsecured = !provider.isObsecured;
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      CustomButton(
                        ontap: () {
                          // Check if email controller is empty
                          if (emailController.text.isEmpty) {
                            // Show snackbar or dialog to prompt user to enter email first
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter your email first'),
                              ),
                            );
                          } else {
                            // If email is entered, store it in shared preferences
                            // You can implement the shared preferences logic here
                            // For demonstration purposes, I'm just printing the email
                            print('Email entered: ${emailController.text}');

                            // Navigate to the home screen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );
                          }
                        },
                        buttontext: 'Setup',
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ),
                          );
                        },
                        child: Text(
                          'Skip',
                          style: TextStyle(color: Theme.of(context).brightness == Brightness.light
                              ? Color(0xFF666666)// Color for light theme
                              : Color(0xFF999999),),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
