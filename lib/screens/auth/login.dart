import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../consts/consts.dart';
import '../../provider/authprovider.dart';
import '../../utils/utils.dart';
import '../../widgets/custombutton.dart';
import '../homepage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _loginformKey = GlobalKey<FormState>();
  final List<TextEditingController> _pinControllers =
  List.generate(4, (_) => TextEditingController());
  final passwordMatchValidator =
  MatchValidator(errorText: 'Passwords do not match');

  @override
  void initState() {
    super.initState();
    // Add listeners to the pin controllers
    for (var controller in _pinControllers) {
      controller.addListener(_onPinChanged);
    }
  }

  void _onPinChanged() {
    // Combine pin inputs from all controllers
    final pin =
    _pinControllers.map((controller) => controller.text.trim()).join();

    // Validate the entered pin when all 4 digits have been entered
    if (pin.length == 4) {
      _validatePin(pin);
    }
  }

  void _validatePin(String pin) async {
    // Retrieve the master password
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String masterPassword = prefs.getString('password') ?? '';

    // Compare the entered pin with the master password
    if (pin == masterPassword) {
      FirebaseAnalytics.instance.logEvent(
        name: 'login_passcode',
        parameters: <String, dynamic>{
          'activity': 'Navigating to HomeScreen',
          'action': 'correct passcode',
        },
      );
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } else {
      FirebaseAnalytics.instance.logEvent(
        name: 'login_passcode',
        parameters: <String, dynamic>{
          'activity': 'Navigating to Homescreen',
          'action': 'wrong login passcode',
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incorrect pin code. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );

      // Clear the pin input fields
      for (var controller in _pinControllers) {
        controller.clear();
      }
    }
  }

  void _removeLastDigit() {
    for (int i = _pinControllers.length - 1; i >= 0; i--) {
      if (_pinControllers[i].text.isNotEmpty) {
        _pinControllers[i].clear();
        break;
      }
    }
  }

  @override
  void dispose() {
    _pinControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'Login Screen');
    final size = MediaQuery.of(context).size;
    return Consumer<AuthProvider>(
      builder: (BuildContext context, provider, Widget? child) {
        return PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) => Utils(context).onWillPop(),
          child: Scaffold(
            body: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
                  child: Form(
                    key: _loginformKey,
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.07),
                        Theme.of(context).brightness == Brightness.light
                         ? SvgPicture.asset(
                          'assets/padlock 3.svg',
                          height: size.height * 0.1,
                        )
                        : SvgPicture.asset("assets/padlock 2.svg"),
                        SizedBox(height: size.height * 0.03),
                        Text(
                          AppLocalizations.of(context)!.enterYourPasscode,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            //color: Colors.white,
                          ),
                        ),
                        SizedBox(height: size.height * 0.04),
                        Container(
                          width: 270,
                          height: 60,
                          decoration: BoxDecoration(
                            color:
                            Theme.of(context).brightness == Brightness.light
                                ? Color(0xFFF5F5F5) // Color for light theme
                                : Color(0xFF171823),
                            border: Border.all(
                                color: Colors
                                    .deepPurple), // Change border color to purple
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: List.generate(
                              4,
                                  (index) {
                                return Expanded(
                                  child: PinInputField(
                                      controller: _pinControllers[index]),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.05),
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
                              } else if (index == 10) {
                                // Display "0" at the 10th index
                                return Padding(
                                  padding:
                                  EdgeInsets.symmetric(horizontal: 8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final pinIndex = _pinControllers
                                          .indexWhere((controller) =>
                                      controller.text.isEmpty);
                                      if (pinIndex != -1) {
                                        _pinControllers[pinIndex].text = '0';
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: CircleBorder(),
                                    ),
                                    child: Text(
                                      '0',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Theme.of(context).brightness ==
                                            Brightness.light
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              } else if (index == 11) {
                                // Add a cancel button as the 11th element in the grid view
                                return Padding(
                                  padding:
                                  EdgeInsets.symmetric(horizontal: 8.0),
                                  child: CancelButton(
                                    onPressed: () {
                                      _removeLastDigit();
                                    },
                                  ),
                                );
                              } else {
                                // Add numeric buttons from 1 to 9
                                return Padding(
                                  padding:
                                  EdgeInsets.symmetric(horizontal: 8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final pinIndex = _pinControllers
                                          .indexWhere((controller) =>
                                      controller.text.isEmpty);
                                      if (pinIndex != -1) {
                                        _pinControllers[pinIndex].text =
                                        '${index + 1}'; // Increment index by 1 to start counting from 1
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: CircleBorder(),
                                    ),
                                    child: Text(
                                      '${index + 1}', // Increment index by 1 to start counting from 1
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Theme.of(context).brightness ==
                                            Brightness.light
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),

                        //SizedBox(height: size.height * 0.05),
                        // CustomButton(
                        //   ontap: () {
                        //     FocusScope.of(context).unfocus();
                        //     final pin = _pinControllers.map((controller) => controller.text.trim()).join();
                        //     validate(pin);
                        //   },
                        //   buttontext: 'Login',
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void validate(String pin) async {
    final FormState form = _loginformKey.currentState!;

    // Retrieve the master password
    final masterPassword = context.read<AuthProvider>().getMasterPassword();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var masterpassword = prefs.getString('password') ?? '';
    // Compare the entered pin with the master password
    if (pin == masterpassword) {
      if (form.validate()) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
    } else {
      // Show an error message or handle incorrect pin
      // For example:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incorrect pin code. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

class PinInputField extends StatelessWidget {
  final TextEditingController controller;

  const PinInputField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60, // Set the height of the SizedBox
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.deepPurple,
          fontSize: 60,
        ),
        keyboardType: TextInputType.number,
        maxLength: 1,
        obscureText: true, // Hide the entered text
        decoration: InputDecoration(
          hintText: '*',
          hintStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
          counterText: '',
          border: InputBorder.none,
          contentPadding:
          EdgeInsets.only(bottom: 11), // Remove vertical padding
        ),
        onChanged: (_) {
          // No need to handle onChanged when using obscureText
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required';
          }
          return null;
        },
      ),
    );
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
        child: SvgPicture.asset(
            'assets/Vector.svg'), // Color for light theme
      )
          : SvgPicture.asset('assets/Vector.svg'),
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
      ),
    );
  }
}
