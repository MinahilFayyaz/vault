import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vault/consts/consts.dart';
import '../controller/language_change_controller.dart';
import '../models/languages_model.dart';

class languagesScreen extends StatefulWidget {
  languagesScreen(this.isFirstLaunch, {Key? key}) : super(key: key);

  final bool isFirstLaunch;
  @override
  State<languagesScreen> createState() => _languagesScreenState();
}

class _languagesScreenState extends State<languagesScreen> {
  late SharedPreferences _prefs;
  late Language selectedLanguage = languages.isNotEmpty ? languages.first : Language(code: 'en', name: 'English', flagAsset: 'assets/flags/America.svg');

  @override
  void initState() {

    filteredLanguages = languages;
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      _loadSelectedLanguage(); // Load selected language
    });
    super.initState();
  }


  List<Language> filteredLanguages = [];

  void filterLanguages(String query) {
    setState(() {
      filteredLanguages = languages
          .where((language) =>
          language.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  List<Language> languages = [
    Language(code: 'en', name: 'English', flagAsset: 'assets/flags/America.svg'),
    Language(code: 'ar', name: 'Arabic', flagAsset: 'assets/flags/Group 21118.svg'),
    Language(code: 'bn', name: 'Bangali', flagAsset: 'assets/flags/Group 21140.svg'),
    Language(code: 'zh', name: 'Chinese', flagAsset: 'assets/flags/Group 21129.svg'),
    Language(code: 'fr', name: 'French', flagAsset: 'assets/flags/Group 21122.svg'),
    Language(code: 'de', name: 'German', flagAsset: 'assets/flags/Group 21132.svg'),
    Language(code: 'hi', name: 'Hindi', flagAsset: 'assets/flags/Group 21119.svg'),
    Language(code: 'id', name: 'Indonesia', flagAsset: 'assets/flags/Group 21125.svg'),
    Language(code: 'ms', name: 'Malay', flagAsset: 'assets/flags/Group 21124.svg'),
    Language(code: 'nl', name: 'Dutch', flagAsset: 'assets/flags/Group 21137.svg'),
    Language(code: 'ga', name: 'Irish', flagAsset: 'assets/flags/Group 21306.svg'),
    Language(code: 'it', name: 'Italian', flagAsset: 'assets/flags/Group 21305.svg'),
    Language(code: 'ja', name: 'Japanese', flagAsset: 'assets/flags/Group 21304.svg'),
    Language(code: 'ko', name: 'Korean', flagAsset: 'assets/flags/Group 21302.svg'),
    Language(code: 'fa', name: 'Persian', flagAsset: 'assets/flags/Group 21128.svg'),
    Language(code: 'pl', name: 'Polish', flagAsset: 'assets/flags/Group 21126.svg'),
    Language(code: 'pt', name: 'Portuguese', flagAsset: 'assets/flags/Group 21131.svg'),
    Language(code: 'ro', name: 'Romanian', flagAsset: 'assets/flags/Group 21134.svg'),
    Language(code: 'ru', name: 'Russian', flagAsset: 'assets/flags/Group 21127.svg'),
    Language(code: 'th', name: 'Thai', flagAsset: 'assets/flags/Group 21133.svg'),
    Language(code: 'tr', name: 'Turkish', flagAsset: 'assets/flags/Group 21130.svg'),
    Language(code: 'ur', name: 'Urdu', flagAsset: 'assets/flags/Group 21123.svg'),
  ];

  Future<void> _loadSelectedLanguage() async {
    String? selectedLanguageCode = _prefs.getString('selectedLanguageCode');
    if (selectedLanguageCode != null) {
      setState(() {
        selectedLanguage = languages.firstWhere(
              (language) => language.code == selectedLanguageCode,
          orElse: () => languages.first, // Set default language if not found
        );
      });
    } else {
      setState(() {
        selectedLanguage = languages.first; // Set default language if not saved
      });
    }
    // Update isSelected flag for loaded selectedLanguage
    languages.forEach((language) {
      language.isSelected = language == selectedLanguage;
    });
  }

  void _setSelectedLanguage(Language language) async {
    setState(() {
      selectedLanguage = language;
      _prefs.setString('selectedLanguageCode', language.code);
      languages.forEach((lang) {
        lang.isSelected = lang == selectedLanguage;
      });
    });
    final languageChangeController = context.read<LanguageChangeController>();
    await languageChangeController.changeLanguage(Locale(language.code));
    //Get.updateLocale(Locale(language.code));

    if (widget.isFirstLaunch == false) {
      //Get.reset();
    }

    //GetStorage().write('selectedLanguageCode', language.code); // Use GetStorage to write the selected language code

    print('Language set state Changed to: ${language.code}');
  }

  void updateFilteredCountries(String query) {
    print('Query: $query'); // Add this line to see if the method is triggered
    setState(() {
      filteredLanguages = languages.where((language) =>
          language.name.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }




  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.07),
        child: AppBar(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Color(0xFFFFFFFF) // Color for light theme
              : Consts.FG_COLOR,
          centerTitle: true,
          title: const Text('Language',
            style: TextStyle(
              //color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
              fontFamily: 'GilroyBold', // Apply Gilroy font family
            ),
          ),
        ),
      ),
      body:  Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //SearchBox(onTextChanged: updateFilteredCountries),
            SizedBox(height: screenHeight * 0.01),
            Expanded(
              child: ListView.builder(
                itemCount: filteredLanguages.length,
                itemBuilder: (context, index) {
                  Language currentLanguage = filteredLanguages[index];
                  return GestureDetector(
                    onTap: () {
                      _setSelectedLanguage(currentLanguage);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      child: Card(
                        child: ListTile(
                          onTap: () {
                            _setSelectedLanguage(currentLanguage);
                          },
                          title: Text(
                            currentLanguage.name,
                          ),
                          trailing: currentLanguage.isSelected ? Icon(Icons.check, color: Consts.COLOR) : null,
                        ),
                      ),
                    ),
                  );
                },
              ),

            ),
          ],
        ),
      ),
    );
  }

}
