import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';

import '../../consts/consts.dart';
import '../../provider/authprovider.dart';
import '../../widgets/custombutton.dart';
import '../homepage.dart';
import 'confirm.dart';// Import the ConfirmPasswordPage

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final passwordController = TextEditingController();
  final GlobalKey<FormState> _registerformKey = GlobalKey<FormState>();
  final passwordValidator = MultiValidator([
    RequiredValidator(errorText: 'Password is required'),
    MinLengthValidator(4, errorText: 'Password must be at least 4 digits long'),
    //PatternValidator(r'(?=.*?[#?!@$%^&*-])', errorText: 'Passwords must have at least one special character'),
  ]);

  String pin = ''; // Variable to store the entered pin

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<AuthProvider>(
      builder: (BuildContext context, provider, Widget? child) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(screenHeight * 0.07),
            child: AppBar(
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? Color(0xFFFFFFFF) // Color for light theme
                  : Consts.FG_COLOR,
             title:  Text(
                'STEP 1/4',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    //color: Colors.white
                ),
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
                      SizedBox(height: size.height * 0.02),
                      Text(
                        'Set a Passcode',
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
                        obscureText: true,
                        controller: passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (passwordValidator.call(value) != null) {
                            return passwordValidator.call(value)!;
                          }
                          return null;
                        },

                        decoration: InputDecoration(
                          //labelText: 'Password',
                          //filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: Consts.COLOR)
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Consts.COLOR, // Set the focused border color to Consts.COLOR
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Consts.COLOR, // Set the enabled border color to Consts.COLOR
                            ),
                          ),
                          hintText: ' ....',
                          hintStyle: TextStyle(
                              color:  Theme.of(context).brightness == Brightness.light
                                  ? Colors.black// Color for light theme
                                  : Colors.white,// Set color of hint dots
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
                      SizedBox(height: size.height * 0.01),
                      CustomButton(
                        ontap: () {
                          validate();
                        },
                        buttontext: 'Set Password',
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
                                        passwordController.text = pin; // Set password controller text to the pin
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
                                      passwordController.clear(); // Clear password controller text
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                    // Adjust color as needed
                                  ),
                                  child: Theme.of(context).brightness == Brightness.light
                                      ? ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                      Colors.black,
                                      BlendMode.srcIn,
                                    ),
                                    child: SvgPicture.asset('assets/Vector.svg'), // Color for light theme
                                  )
                                      : SvgPicture.asset('assets/Vector.svg'),
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
                                        passwordController.text = pin; // Set password controller text to the pin
                                      }
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                    ),
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(fontSize: 20,
                                        color: Theme.of(context).brightness == Brightness.light
                                            ? Colors.black// Color for light theme
                                            : Colors.white,),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),
                      // Text(
                      //   'Entered Pin: $pin',
                      //   style: TextStyle(fontSize: 18),
                      // ),
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
      // Set the password to the entered pin
      String password = pin;

      // Navigate to the ConfirmPasswordPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ConfirmPasswordPage(password: password)),
      );
    }
  }
}
