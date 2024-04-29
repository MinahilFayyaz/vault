import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'consts/consts.dart';
import 'consts/style.dart';
import 'controller/language_change_controller.dart';
import 'provider/addpasswordprovider.dart';
import 'provider/authprovider.dart';
import 'provider/generatedpassswordprovideer.dart';
import 'provider/onboardprovider.dart';
import 'provider/themeprovider.dart';
import 'screens/splash_screen.dart';
import 'services/databaseservice.dart';

void main() async{
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await GetStorage.init(); // Initialize GetStorage
  final String languageCode = GetStorage().read('selectedLanguageCode') ?? 'en';
  await Hive.initFlutter();
  runApp(MyApp(locale : languageCode));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.locale});

  final String locale;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LanguageChangeController languageChangeController = LanguageChangeController();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: languageChangeController),
          ChangeNotifierProvider(create: (_) {
            return ThemeProvider(context);
          }),
          ChangeNotifierProvider(create: (_) {
            return OnBoardingProvider();
          }),
          ChangeNotifierProvider(
            create: (context) => AuthProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => DatabaseService(),
          ),
          ChangeNotifierProvider(
            create: (context) => AddPasswordProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => GeneratedPasswordProvider(),
          ),
        ],
        builder: (context, child) {
          removesplash();
          return Consumer<ThemeProvider>(
              builder: (context, value, child) {
            return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: Consts.APP_NAME,
                theme: Styles.themeData(
                  context: context,
                  isDarkTheme: false,
                ),
                darkTheme: Styles.themeData(
                  context: context,
                  isDarkTheme: true,
                ),
                themeMode: context.watch<ThemeProvider>().themeMode,
                home: SplashScreen()
            );
          });
        });
  }

  void removesplash() async {
    return await Future.delayed(const Duration(seconds: 3), () {
      FlutterNativeSplash.remove();
    });
  }
}
