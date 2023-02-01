import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hmz_patient/home/widgets/app_drawer.dart';
import 'package:hmz_patient/setting/setting.dart';
import 'package:hmz_patient/utils/colors.dart';
import '../home/widgets/bottom_navigation_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:date_field/date_field.dart';

import 'dart:async';
import 'dart:convert';
import '../auth/providers/auth.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Profile extends StatefulWidget {
  static const routeName = '/profile';

  String idd;
  String useridd;
  Profile(this.idd, this.useridd);

  @override
  ProfileState createState() => ProfileState(this.idd, this.useridd);
}

class ProfileState extends State<Profile> {
  String idd;
  String useridd;
  ProfileState(this.idd, this.useridd);

  final _formKey = GlobalKey<FormState>();

  String url;

  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

  List data = new List();
  String zname;
  bool _isloading = true;

  Future<String> getSWData() async {
    String urrr1 = url + "${this.useridd}";
    var res = await http
        .get(Uri.parse(urrr1), headers: {"Accept": "application/json"});
    var resBody = json.decode(res.body);

    setState(() {
      data = resBody;

      var email;
      var pass;
      var name;
      for (var i = 0; i < data.length; i++) {
        email = data[i]['email'];
        pass = data[i]['password'];
        name = data[i]['username'];
        zname = name;
        break;
      }

      _email = new TextEditingController(text: email);
      _name = new TextEditingController(text: name);

      _isloading = false;
    });

    return "Sucess";
  }

  @override
  void initState() {
    super.initState();
    url = Auth().linkURL + "api/getProfile?id=";
    getSWData();
  }

  Future<String> changePassword(context) async {
    if (_name != zname || _password != "") {
      String posturl = Auth().linkURL + "api/updateProfile";

      final res = await http.post(
        Uri.parse(posturl),
        body: {
          'email': this._email.text,
          'password': this._password.text,
          'id': this.useridd,
          'name': this._name.text,
        },
      );

      if (res.statusCode == 200) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  AppLocalizations.of(context).success,
                ),
                content: Text(
                    AppLocalizations.of(context).changesUpdatedSuccessfuly),
                actions: [
                  TextButton(
                    child: Text(AppLocalizations.of(context).ok),
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(Profile.routeName);
                    },
                  )
                ],
              );
            });

        return 'success';
      } else {
        return "error";
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context).invalid),
              content: Text(AppLocalizations.of(context).invalidInput),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context).ok),
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(Profile.routeName);
                  },
                )
              ],
            );
          });
    }
  }

  AppColor appcolor = new AppColor();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).changePassword,
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
          onPressed: () => Navigator.of(context)
              .pushReplacementNamed(SettingScreen.routeName),
        ),
        centerTitle: true,
        backgroundColor: appcolor.appbarbackground(),
        elevation: 0.0,
        iconTheme: IconThemeData(color: appcolor.appbaricontheme()),
      ),
      body: (_isloading)
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _email,
                              readOnly: true,
                              decoration: InputDecoration(
                                  labelText:
                                      '${AppLocalizations.of(context).email} (${AppLocalizations.of(context).notChangable})',
                                  hintText: AppLocalizations.of(context).email),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return AppLocalizations.of(context)
                                      .invalidEmail;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _password,
                              obscureText: true,
                              decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(context).password,
                                  hintText:
                                      AppLocalizations.of(context).password),
                              validator: (value) {
                                if (value.isEmpty || value.length < 5) {
                                  return AppLocalizations.of(context)
                                      .invalidPassword;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * .9,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              changePassword(context);
                            }
                          },
                          child: Text(AppLocalizations.of(context).update),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )),
    );
  }
}
