import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault/screens/settings/app_icons.dart';
import 'package:vault/screens/settings/premium.dart';

import '../../consts/consts.dart';
import '../../provider/themeprovider.dart';
import '../../utils/utils.dart';
import '../../widgets/selectionbuttonwidget.dart';
import '../auth/chagepassword.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Consts.BG_COLOR,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.07),
        child: AppBar(
          backgroundColor: Consts.FG_COLOR,
          centerTitle: true,
          title: const Text('Setting',
            style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w400,
            fontFamily: 'GilroyBold', // Apply Gilroy font family
          ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
            ),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.02,),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.02,
                    vertical: size.height * 0.005
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text('Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'GilroyBold', // Apply Gilroy font family
                      ),),
                  ),
                ),
                _buildListtile(
                  tiletitle: 'Language',
                  iconData: Icons.language,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage(),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: size.height * 0.0001,
                ),
                _buildListtile(
                  tiletitle: 'App Icon',
                  iconData: Icons.settings_applications_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppIcons(),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: size.height * 0.0001,
                ),
                _buildListtile(
                  tiletitle: 'Export all Files',
                  iconData: Icons.save_alt,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage(),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: size.height * 0.0001,
                ),
                _buildListtile(
                  tiletitle: 'Security',
                  iconData: Icons.security_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage(),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: size.height * 0.0001,
                ),
                _buildListtile(
                  tiletitle: 'Theme',
                  iconData: Icons.format_paint,
                  onTap: () {
                    Utils(context).showCustomDialog(
                      child: _themetileWidget(
                        context: context,
                      ),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.02,
                      vertical: size.height * 0.01
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text('Membership',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'GilroyBold', // Apply Gilroy font family
                      ),),
                  ),
                ),
                _buildListtile(
                  tiletitle: 'Restore Purchase',
                  iconData: Icons.restore,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PremiumScreen(),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.02,
                      vertical: size.height * 0.01
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text('Others',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'GilroyBold', // Apply Gilroy font family
                      ),),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.0001,
                ),
                _buildListtile(
                  tiletitle: 'Share this app',
                  iconData: Icons.share,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PremiumScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: size.height * 0.0001,
                ),
                _buildListtile(
                  tiletitle: 'Privacy Policy',
                  iconData: Icons.lock,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PremiumScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: size.height * 0.0001,
                ),
                _buildListtile(
                  tiletitle: 'Rate our app',
                  iconData: Icons.lightbulb,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PremiumScreen(),
                      ),
                    );
                  },
                ),SizedBox(
                  height: size.height * 0.0001,
                ),
                _buildListtile(
                  tiletitle: 'App Version',
                  iconData: Icons.pages,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PremiumScreen(),
                      ),
                    );
                  },
                ),SizedBox(
                  height: size.height * 0.0001,
                ),
                _buildListtile(
                  tiletitle: 'Contact Us',
                  iconData: Icons.mail,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PremiumScreen(),
                      ),
                    );
                  },
                ),
                _buildListtile(
                  tiletitle: 'Change Password',
                  iconData: Icons.password_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage(),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: size.height * 0.0001,
                ),
                _buildListtile(
                  tiletitle: 'Privacy Policy',
                  iconData: Icons.policy_outlined,
                  onTap: () {
                    Utils(context)
                        .showSnackBar(snackText: 'Privacy Policy Coming Soon');
                  },
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                _buildListtile(
                  tiletitle: 'Backup Data',
                  iconData: Icons.backup_outlined,
                  onTap: () {
                    Utils(context).showSnackBar(
                        snackText: 'Backup Data Feature Coming Soon');
                  },
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                _buildListtile(
                  tiletitle: 'Restore Data',
                  iconData: Icons.restore_outlined,
                  onTap: () {
                    Utils(context).showSnackBar(
                        snackText: 'Restore Data Feature Coming Soon');
                  },
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                _buildListtile(
                  tiletitle: 'Theme',
                  iconData:
                      context.watch<ThemeProvider>().themeMode == ThemeMode.system
                          ? Icons.phonelink_setup_outlined
                          : context.watch<ThemeProvider>().themeMode ==
                                  ThemeMode.light
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                  onTap: () => Utils(context).showCustomDialog(
                    child: _themetileWidget(
                      context: context,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildListtile({
    required IconData iconData,
    required String tiletitle,
    required Function onTap,
  }) {
    return Card(
      color: Consts.FG_COLOR,
      child: InkWell(
        borderRadius: BorderRadius.circular(Consts.BORDER_RADIUS),
        onTap: () {
          onTap();
        },
        child: ListTile(
          leading: Icon(iconData),
          title: Text(tiletitle),
        ),
      ),
    );
  }

  _themetileWidget({required BuildContext context}) {
    return Consumer<ThemeProvider>(builder: (context, provider, child) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Theme',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SelectionButtonWidget(
                  buttontitle: 'System Theme',
                  iconCondition: provider.themeMode == ThemeMode.system,
                  ontap: () {
                    provider.themeMode = ThemeMode.system;
                  },
                ),
                const Divider(
                  height: 0,
                ),
                SelectionButtonWidget(
                  iconCondition: provider.themeMode == ThemeMode.light,
                  buttontitle: 'Light Theme',
                  ontap: () {
                    provider.themeMode = ThemeMode.light;
                  },
                ),
                const Divider(
                  height: 0,
                ),
                SelectionButtonWidget(
                  iconCondition: provider.themeMode == ThemeMode.dark,
                  buttontitle: 'Dark Theme',
                  ontap: () {
                    provider.themeMode = ThemeMode.dark;
                  },
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // Widget _buildSettingList({
  //   required String title,
  //   required IconData icon,
  //   required BuildContext context,
  //   required VoidCallback ontap,
  // }) {
  //   return Material(
  //     color: Theme.of(context).highlightColor,
  //     borderRadius: BorderRadius.circular(5),
  //     child: InkWell(
  //       borderRadius: BorderRadius.circular(5),
  //       onTap: ontap,
  //       child: Padding(
  //         padding: const EdgeInsets.all(14.0),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               title,
  //               style: const TextStyle(
  //                 fontWeight: FontWeight.w600,
  //                 fontSize: 16,
  //               ),
  //             ),
  //             Icon(
  //               icon,
  //               color: Theme.of(context).iconTheme.color,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
