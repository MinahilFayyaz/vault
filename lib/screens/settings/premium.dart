import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../consts/consts.dart';
import '../../permission.dart';
import '../../widgets/custombutton.dart';
import '../../widgets/custombuttontransparent.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Consts.BG_COLOR,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 333, // Set the desired height
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/cyber-security-security-password-login-online-concept-hands-typing-entering-username_620652-63 1.png'),
                        fit: BoxFit.cover, // Cover the entire container with the image
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: SvgPicture.asset('assets/cancel 1.svg'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 200.0),
                    child: Align(
                      alignment: Alignment.bottomCenter, // Align to the bottom center of the image
                      child: Container(
                        width: double.infinity, // Stretch to the full width
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Optional padding for aesthetics
                        color: Colors.transparent, // Transparent background
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'UPGRADE TO PREMIUM',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white, // Set text color
                              ),
                              textAlign: TextAlign.center, // Center the text
                            ),
                            SizedBox(height: 8), // Optional spacing between title and subtitle
                            Text(
                              'Unlock All the Premium Features',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white, // Set text color
                              ),
                              textAlign: TextAlign.center, // Center the text
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: size.height * 0.02
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset('assets/success 2.svg'),
                      SizedBox(width: size.width * 0.03,),
                      Text('upload unlimited Photo and Videos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700
                      ),)
                    ],
                  ),
                  SizedBox(height: size.height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset('assets/success 2.svg'),
                      SizedBox(width: size.width * 0.03,),
                      Text('Support High Qiality',
                        style: TextStyle(
                          color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700
                        ),)
                    ],
                  ),
                  SizedBox(height: size.height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset('assets/success 2.svg'),
                      SizedBox(width: size.width * 0.03,),
                      Text('Download Stored Assets in anytime',
                        style: TextStyle(
                          color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700
                        ),)
                    ],
                  ),
                  SizedBox(height: size.height * 0.02),
                ],
              ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05
                ),
                child: CustomButton1(ontap: (){

                }, buttontext: 'PKR 238/Month', buttontext1: 'Billed Yearly',),
              ),
              SizedBox(height: size.height * 0.02,),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05
                ),
                child: CustomButton1(ontap: (){

                }, buttontext: 'PKR 4,900/One-Time', buttontext1: 'Lifetime Access',),
              ),
              SizedBox(height: size.height * 0.027,),
              Padding(
                  padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05
              ),
                child: CustomButton(
                  ontap: (){

                  },
                  buttontext: 'Continue',
                )
              ),
              SizedBox(height: size.height * 0.02,),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Permission()));
                },
                child: Padding(padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05
                ),
                  child: Center(
                    child: Text(
                      'Continue with Ads',
                      style: TextStyle(
                        color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
