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

  void _removeLastDigit() {
    String currentPassword = confirmpasswordController.text;
    if (currentPassword.isNotEmpty) {
      String newPassword = currentPassword.substring(0, currentPassword.length - 1);
      confirmpasswordController.text = newPassword;
      pin = newPassword; // Update the pin variable
    }
  }



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
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Color(0xFFFFFFFF) // Color for light theme
                : Consts.FG_COLOR,
            title:  Text(
              'STEP 2/3',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  //color: Colors.white
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
                          //color: Colors.white,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        'Ensure your Private Photo remain Confidential \n by establishing a personalized password',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          //color: Colors.white,
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      TextFormField(
                        //focusNode: focus,
                        obscureText: true,
                        controller: confirmpasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        validator: (val) => passwordMatchValidator.validateMatch(
                          val!,
                          widget.password,
                        ),
                        decoration: InputDecoration(
                          //labelText: 'Password',
                          //filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Consts.COLOR,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Consts.COLOR,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Consts.COLOR,
                            ),
                          ),
                          hintText: ' ....',
                          hintStyle: TextStyle(
                            color: Theme.of(context).brightness == Brightness.light
                                ? Colors.black
                                : Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                          // Custom style for the actual text (dots)
                          counterText: "",
                          contentPadding: EdgeInsets.symmetric(horizontal: 5.0),
                          alignLabelWithHint: true, // Align label with the hint text
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Consts.COLOR,
                          fontSize: 30,
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
                          12, // Increase by 1 to include the cancel button
                              (index) {
                                if (index == 9) {
                                  // Leave the 9th index empty
                                  return Container();
                                }

                                if (index == 10) {
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
                                    style: TextStyle(fontSize: 20, color: Theme.of(context).brightness == Brightness.light
                                        ? Colors.black// Color for light theme
                                        : Colors.white,),
                                  ),
                                ),
                              );
                            } else if (index == 11) {
                              // Add a cancel button as the 10th element in the grid view
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child : CancelButton(
                                  onPressed: () {
                                    _removeLastDigit();
                                  },
                                ),
                                // child: ElevatedButton(
                                //   onPressed: () {
                                //     setState(() {
                                //       pin = ''; // Clear the pin
                                //       confirmpasswordController.clear(); // Clear password controller text
                                //     });
                                //   },
                                //   style: ElevatedButton.styleFrom(
                                //     shape: CircleBorder(),
                                //     // Adjust color as needed
                                //   ),
                                //   child: Theme.of(context).brightness == Brightness.light
                                //       ? ColorFiltered(
                                //     colorFilter: ColorFilter.mode(
                                //       Colors.black,
                                //       BlendMode.srcIn,
                                //     ),
                                //     child: SvgPicture.asset('assets/Vector.svg'), // Color for light theme
                                //   )
                                //       : SvgPicture.asset('assets/Vector.svg'),
                                // ),
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
                                    style: TextStyle(fontSize: 20, color:
                                    Theme.of(context).brightness == Brightness.light
                                        ? Colors.black// Color for light theme
                                        : Colors.white,),
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

class CancelButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CancelButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Theme.of(context).brightness == Brightness.light
          ? ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.black,
          BlendMode.srcIn,
        ),
        child: SvgPicture.asset('assets/Vector.svg'), // Color for light theme
      )
          : SvgPicture.asset('assets/Vector.svg'),
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
      ),
    );
  }
}