import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hmz_patient/home/widgets/app_drawer.dart';
import 'package:hmz_patient/profile/editProfile.dart';
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

class FullProfile extends StatefulWidget {
  static const routeName = '/fullprofile';

  String idd;
  String useridd;
  FullProfile(this.idd, this.useridd);

  @override
  FullProfileState createState() => FullProfileState(this.idd, this.useridd);
}

class FullProfileState extends State<FullProfile> {
  String idd;
  String useridd;
  FullProfileState(this.idd, this.useridd);

  final _formKey = GlobalKey<FormState>();

  String url;
  String image;
  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _blood = TextEditingController();
  TextEditingController _age = TextEditingController();
  TextEditingController _sex = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _department = TextEditingController();
  String error = '';

  List data = new List();
  String zname;
  bool _isloading = false;

  // Future<String> getSWData() async {
  //   // url = Auth().linkURL + "api/getPatientProfile?id=";
  //   // String urrr1 = url + "${this.useridd}";
  //   // var res = await http
  //   //     .get(Uri.parse(urrr1), headers: {"Accept": "application/json"});

  //   final url = Auth().linkURL + "api/getPatientProfile";
  //   var data = await http.post(Uri.parse(url), body: {
  //     'id': this.useridd,
  //   }, headers: {
  //     "Accept": "application/json"
  //   });

  //   var resBody = json.decode(data.body);

  //   if (resBody == null) {
  //     error = 'error';
  //     setState(() {
  //       _isloading = false;
  //     });
  //     return 'failed';
  //   } else {
  //     setState(() {
  //       _email.text = resBody['email'];
  //       _name.text = resBody['name'];
  //       _phone.text = resBody['phone'];
  //       _department.text = resBody['department'];
  //       _address.text = resBody['address'];
  //       image = resBody['img_url'];

  //       _isloading = false;
  //     });
  //     return "Sucess";
  //   }
  // }

  @override
  void initState() {
    super.initState();
    if (!Auth().profileCreated) {
      String mode = 'new';
      Navigator.of(context).pushNamed(EditProfile.routeName, arguments: mode);
    } else {
      _email.text = Auth().email;
      _name.text = Auth().name;
      _phone.text = Auth().phone;
      _department.text = Auth().department;
      _address.text = Auth().address;
      image = Auth().image;
      _blood.text = Auth().blood;
      _sex.text = Auth().sex;
      _age.text = Auth().age;
    }
    // getSWData().then((value) {
    //   if (value == 'failed') {
    //     String mode = 'new';
    //     Navigator.of(context).pushNamed(EditProfile.routeName, arguments: mode);
    //   }
    // });
  }

  AppColor appcolor = new AppColor();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        actions: [
          if (_isloading == false)
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  elevation: 0.0,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(EditProfile.routeName);
                },
                icon: Icon(
                  Icons.edit,
                  color: appcolor.appbaricontheme(),
                ),
                label: Text(
                  AppLocalizations.of(context).edit,
                  style: TextStyle(color: appcolor.appbaricontheme()),
                )),
        ],
      ),
      body: (_isloading)
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: Center(
                  child: CircleAvatar(
                      radius: 70,
                      backgroundImage: image != null
                          ? NetworkImage(Auth().linkURL + image)
                          : NetworkImage('https://picsum.photos/200')),
                ),
              ),
              Center(
                child: Container(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_name.text,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                    SizedBox(
                      width: 5,
                    ),
                    InkWell(
                      child: CircleAvatar(
                        radius: 15,
                        child: Icon(
                          Icons.edit,
                          color: Colors.black,
                          size: 16,
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(EditProfile.routeName);
                      },
                    ),
                  ],
                )),
              ),
              SizedBox(height: 30),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * .9,
                  child: ListTile(
                    leading: Icon(Icons.email),
                    title: Text(_email.text),
                    trailing: PopupMenuButton<int>(
                      itemBuilder: (context) => [
                        PopupMenuItem<int>(
                            value: 0,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Text(AppLocalizations.of(context).edit)
                              ],
                            )),
                      ],
                      onSelected: (item) {
                        if (item == 0) {
                          Navigator.of(context)
                              .pushNamed(EditProfile.routeName);
                        }
                      },
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * .9,
                  child: ListTile(
                    leading: Icon(Icons.phone),
                    title: Text(_phone.text),
                    trailing: PopupMenuButton<int>(
                      itemBuilder: (context) => [
                        PopupMenuItem<int>(
                            value: 0,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Text(AppLocalizations.of(context).edit)
                              ],
                            )),
                      ],
                      onSelected: (item) {
                        if (item == 0) {
                          Navigator.of(context)
                              .pushNamed(EditProfile.routeName);
                        }
                      },
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * .9,
                  child: ListTile(
                    leading: Icon(Icons.home),
                    title: Text(_address.text),
                    trailing: PopupMenuButton<int>(
                      itemBuilder: (context) => [
                        PopupMenuItem<int>(
                            value: 0,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Text(AppLocalizations.of(context).edit)
                              ],
                            )),
                      ],
                      onSelected: (item) {
                        if (item == 0) {
                          Navigator.of(context)
                              .pushNamed(EditProfile.routeName);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ])),
      bottomNavigationBar: AppBottomNavigationBar(screenNum: 2),
    );
  }
}
