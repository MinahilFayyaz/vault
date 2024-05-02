import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../provider/authprovider.dart';
import '../provider/onboardprovider.dart';
import '../provider/themeprovider.dart';
import '../services/databaseservice.dart';
import '../utils/utils.dart';
import '../widgets/custombutton.dart';
import 'auth/login.dart';
import 'onboardingpage.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<OnBoardingProvider>(
      builder: (
          context,
          value,
          child,
          ) {
        return PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) => Utils(context).onWillPop(),
          child: Scaffold(
            //backgroundColor: Consts.BG_COLOR,
            body: SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: size.height * 0.07,
                    ),
                    Image.asset(
                      'assets/Frame 37367.png',
                      height: size.height * 0.5,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.07,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: size.height * 0.05,
                          ),
                          Text(
                            'Gallery Vault',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              //color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          Text(
                            AppLocalizations.of(context)!.safeBoxIsThePhotoVaultAppForProtectingPrivatePhotoAndVideo,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              //color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: size.height * 0.05,
                          ),
                          CustomButton(
                            ontap: () {
                              final onBoardingProvider = Provider.of<OnBoardingProvider>(context, listen: false);
                              onBoardingProvider.checkOnBoardingStatus();
                              final isOnBoardingComplete = onBoardingProvider.isBoardingCompleate;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  isOnBoardingComplete ? const LoginPage() : const OnBoardingSceen(),
                                ),
                              );
                            },
                            buttontext: AppLocalizations.of(context)!.getStarted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

