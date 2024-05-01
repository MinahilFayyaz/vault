import 'package:flutter/material.dart';
import 'package:vault/screens/gallery.dart';

import 'consts/consts.dart';
import 'screens/homepage.dart';
import 'widgets/custombutton.dart';

class Permission extends StatefulWidget {
  const Permission({Key? key, required this.folderName}) : super(key: key);

  final String? folderName;

  @override
  State<Permission> createState() => _PermissionState();
}

class _PermissionState extends State<Permission> {
  final Color fgcolor = Consts.FG_COLOR;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // First Container: Top half with BG_COLOR
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height / 2,
            child: Container(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white // Color for light theme
                  : Consts.BG_COLOR,
            ),
          ),
          // Second Container: Bottom half with FG_COLOR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height / 2,
            child: Container(
              color: Theme.of(context).brightness == Brightness.light
                  ? Color(0xFFF5F5F5) // Color for light theme
                  : Consts.BG_COLOR,
            ),
          ),
          // Content in the middle
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Image.asset('assets/Frame 37366.png')),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.05,
                  horizontal: size.width * 0.05,
                ),
                child: Center(
                  child: Text(
                    'Allow access to the LOCKER enables\nusers to securely store and manage\ntheir private photos within a\nprotected environment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      //color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.05,
                  horizontal: size.width * 0.05,
                ),
                child: CustomButton(
                  ontap: () {
                    dynamic res = Navigator.push(context, MaterialPageRoute(
                      builder: (context) => GalleryScreen(folderName: widget.folderName),
                    ));
                    if (res == true) {
                      setState(() {});
                    }
                  },
                  buttontext: 'Got it',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
