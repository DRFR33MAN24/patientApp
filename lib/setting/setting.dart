import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hmz_patient/utils/colors.dart';
import '../profile/changePassword.dart';
import '../l10n/l10n.dart';
import '../language/provider/language_provider.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum ChangingLanguages { English, French }

class SettingScreen extends StatefulWidget {
  static const routeName = '/setting';
  String idd;
  String useridd;
  SettingScreen(this.idd, this.useridd);
  @override
  SettingScreenState createState() =>
      SettingScreenState(this.idd, this.useridd);
}

class SettingScreenState extends State<SettingScreen> {
  String idd;
  String useridd;
  SettingScreenState(this.idd, this.useridd);

  ChangingLanguages _character = ChangingLanguages.English;

  AppColor appcolor = new AppColor();

  Widget build(BuildContext context) {
    final provider = Provider.of<LanguageProvider>(context);
    final locale = provider.locale ?? Locale('en');

    return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).setting,
            style: TextStyle(
                color: appcolor.appbartext(),
                fontWeight: appcolor.appbarfontweight()),
          ),
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              size: 45,
              color: Colors.blue,
            ),
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
          centerTitle: true,
          backgroundColor: appcolor.appbarbackground(),
          elevation: 0.0,
          iconTheme: IconThemeData(color: appcolor.appbaricontheme()),
        ),
        body: new Container(
          padding: EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                        child: Text(
                          AppLocalizations.of(context).language,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                          value: locale,
                          items: L10n.all.map((locale) {
                            final flag = L10n.getLang(locale.languageCode);
                            return DropdownMenuItem(
                              child: Center(
                                child: Text(
                                  flag,
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              value: locale,
                              onTap: () {
                                final provider = Provider.of<LanguageProvider>(
                                    context,
                                    listen: false);

                                provider.setLocale(locale);
                              },
                            );
                          }).toList(),
                          onChanged: (_) {},
                        )),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: ListTile(
                      title: Text(AppLocalizations.of(context).changePassword),
                      trailing: InkWell(
                        child: Icon(Icons.send),
                        onTap: () {
                          Navigator.of(context)
                              .pushReplacementNamed(Profile.routeName);
                        },
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
