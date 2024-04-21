import 'package:flutter/material.dart';
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';
import '../../consts/consts.dart';
import '../../widgets/custombutton.dart';

class AppIcons extends StatefulWidget {
  const AppIcons({Key? key}) : super(key: key);

  @override
  _AppIconsState createState() => _AppIconsState();
}

class _AppIconsState extends State<AppIcons> {
  int selectedIconIndex = 0;
  List<String> iconNames = ['icon1', 'icon2', 'icon3'];
  List<String> imageFiles = [
    'assets/icon1.png',
    'assets/icon2.png',
    'assets/icon3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Color(0xFFFFFFFF)
            : Consts.FG_COLOR,
        title: Text(
          'App Icon',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            fontFamily: 'GilroyBold',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16),
        child: Column(
          children: [
            Center(
              child: Text(
                'Try a new look for the app to reflect the types\nof Photos you are storing',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Gilroy',
                ),
              ),
            ),
            // Row of app icons
            Padding(
              padding: const EdgeInsets.only(top: 28.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(iconNames.length, (index) {
                  return buildIconTile(index);
                }),
              ),
            ),
            // Spacer to push the button to the bottom
            Expanded(child: SizedBox()),
            // Apply button at the bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 47.0),
              child: CustomButton(
                ontap: () => changeAppIcon(),
                buttontext: 'Apply',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIconTile(int index) {
    return GestureDetector(
      onTap: () => setState(() => selectedIconIndex = index),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Image.asset(
          imageFiles[index],
          width: 60,
          height: 60,
        ),
        decoration: BoxDecoration(
          border: selectedIconIndex == index
              ? Border.all(color: Consts.COLOR, width: 2)
              : Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> changeAppIcon() async {
    try {
      if (await FlutterDynamicIcon.supportsAlternateIcons) {
        await FlutterDynamicIcon.setAlternateIconName(iconNames[selectedIconIndex]);
        debugPrint("App icon change successful");
      }
    } catch (e) {
      debugPrint("Exception: ${e.toString()}");
    }
  }
}
