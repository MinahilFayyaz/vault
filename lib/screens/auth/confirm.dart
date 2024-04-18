import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import 'package:vault/screens/auth/pin_recovery.dart';

import '../../consts/consts.dart';
import '../../provider/authprovider.dart';
import '../../provider/onboardprovider.dart';
import '../../widgets/custombutton.dart';
import '../homepage.dart';

class ConfirmPasswordPage extends StatefulWidget {
  final String password;

  const ConfirmPasswordPage({Key? key, required this.password}) : super(key: key);

  @override
  State<ConfirmPasswordPage> createState() => _ConfirmPasswordPageState();
}

class _ConfirmPasswordPageState extends State<ConfirmPasswordPage> {
  final focus = FocusNode();
  final confirmpasswordController = TextEditingController();
  final GlobalKey<FormState> _registerformKey = GlobalKey<FormState>();
  final passwordMatchValidator = MatchValidator(errorText: 'Passwords do not match');
  String pin = '';

  @override
  void dispose() {
    confirmpasswordController.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Consumer<AuthProvider>(
      builder: (BuildContext context, provider, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title:  Text(
              'STEP 2/4',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
                child: Form(
                  key: _registerformKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      Text(
                        'Confirm Passcode',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        'Ensure your Private Photo remain Confidential \n by establishing a personalized password',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      TextFormField(
                        focusNode: focus,
                        obscureText: true,
                        controller: confirmpasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        validator: (val) => passwordMatchValidator.validateMatch(
                          val!,
                          widget.password,
                        ),
                        decoration: InputDecoration(
                          //labelText: 'Confirm Password',
                          //filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Consts.COLOR)
                          ),
                          hintText: ' ....',
                          hintStyle: TextStyle(
                              color: Colors.white, // Set color of hint dots
                              fontSize: 30, // Increase the font size of the hint text
                              fontWeight: FontWeight.bold, // Make the hint text bold (optional)
                              height: 1.5 ), // Set color of hint dots
                          // Custom style for the actual text (dots)
                          counterText: "",
                          contentPadding: EdgeInsets.symmetric(horizontal: 5.0),
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Consts.COLOR, // Set the text color to deep purple
                            fontSize: 30 // Adjust the font size as needed for the actual text
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      CustomButton(
                        ontap: () {
                          validate();
                        },
                        buttontext: 'Confirm Password',
                      ),
                      SizedBox(height: size.height * 0.02,),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        childAspectRatio: 1.5,
                        padding: EdgeInsets.all(8.0),
                        mainAxisSpacing: 16.0,
                        crossAxisSpacing: 1.0,
                        children: List.generate(
                          11, // Increase by 1 to include the cancel button
                              (index) {
                            if (index == 9) {
                              // Add the 0 button as the 9th element in the grid view
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (pin.length < 4) {
                                        pin += '0'; // Append '0' to the pin
                                        confirmpasswordController.text = pin; // Set password controller text to the pin
                                      }
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                  ),
                                  child: Text(
                                    '0',
                                    style: TextStyle(fontSize: 20, color: Colors.white),
                                  ),
                                ),
                              );
                            } else if (index == 10) {
                              // Add a cancel button as the 10th element in the grid view
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      pin = ''; // Clear the pin
                                      confirmpasswordController.clear(); // Clear password controller text
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                    // Adjust color as needed
                                  ),
                                  child: Icon(Icons.cancel, color: Colors.white),
                                ),
                              );
                            } else {
                              // Add numeric buttons from 1 to 9
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (pin.length < 4) {
                                        pin += '${index + 1}'; // Append the pressed digit to the pin
                                        confirmpasswordController.text = pin; // Set password controller text to the pin
                                      }
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(fontSize: 20, color: Colors.white),
                                  ),
                                ),
                              );
                            }
                          },
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

  void validate() async {
    final FormState form = _registerformKey.currentState!;
    if (form.validate()) {
      context.read<OnBoardingProvider>().isBoardingCompleate = true;
      context
          .read<AuthProvider>()
          .savePassword(password: confirmpasswordController.text.trim());

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PinRecoveryPage(),
        ),
      );
    }
  }
}
