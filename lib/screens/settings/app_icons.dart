import 'package:flutter/material.dart';
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';
import 'package:vault/widgets/custombutton.dart';

class AppIcons extends StatefulWidget {
  const AppIcons({Key? key}) : super(key: key);

  @override
  State<AppIcons> createState() => _AppIconsState();
}

class _AppIconsState extends State<AppIcons> {
  int iconIndex = 0;
  List iconName = <String>['icon1', 'icon2', 'icon3'];
  List imagefiles = [
    'assets/icon1.png',
    'assets/icon2.png',
    'assets/icon3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildIconTile(0, 'red'),
                buildIconTile(1, 'dark'),
                buildIconTile(2, 'blue'),
                HeightSpacer(myHeight: 16),
                CustomButton(
                    ontap: () => changeAppIcon(), buttontext: 'Set as app icon',),
              ],
            )),
    );
  }

  Widget buildIconTile(int index, String themeTxt) =>
      Padding(
        padding: EdgeInsets.all(16 / 2),
        child: GestureDetector(
          onTap: () => setState(() => iconIndex = index),
          child: ListTile(
              contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
              leading: Image.asset(
                imagefiles[index],
                width: 45,
                height: 45,
              ),
              title: Text(themeTxt, style: const TextStyle(fontSize: 25)),
              trailing: iconIndex == index
                  ? const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 30,
              )
                  : Icon(
                Icons.circle_outlined,
                color: Colors.grey.withOpacity(0.5),
                size: 30,
              )),
        ),
      );

  changeAppIcon() async {
    try {
      if (await FlutterDynamicIcon.supportsAlternateIcons) {
        await FlutterDynamicIcon.setAlternateIconName(iconName[iconIndex]);
        debugPrint("App icon change successful");
        return;
      }
    } catch (e) {
      debugPrint("Exception: ${e.toString()}");
    }
    debugPrint("Failed to change app icon ");
  }
}

class HeightSpacer extends StatelessWidget {
  final double myHeight;
  const HeightSpacer({Key? key, required this.myHeight}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: myHeight,
    );
  }
}
class WidthSpacer extends StatelessWidget {
  final double myWidth;
  const WidthSpacer({Key? key, required this.myWidth}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: myWidth,
    );
  }
}