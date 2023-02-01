import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hmz_patient/home/widgets/app_drawer.dart';
import 'package:hmz_patient/utils/colors.dart';
import 'fullProfile.dart';
import 'changePassword.dart';
import '../home/widgets/bottom_navigation_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:date_field/date_field.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:convert';
import '../auth/providers/auth.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditProfile extends StatefulWidget {
  static const routeName = '/editprofile';
  final String mode;
  String idd;
  String useridd;
  EditProfile(this.mode, this.idd, this.useridd);

  @override
  EditProfileState createState() =>
      EditProfileState(this.mode, this.idd, this.useridd);
}

class EditProfileState extends State<EditProfile> {
  String idd;
  String useridd;
  String mode;
  EditProfileState(this.mode, this.idd, this.useridd);

  final _formKey = GlobalKey<FormState>();

  String url;
  String _image;
  File selectedImage;
  var resJson;
  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _department = TextEditingController();

  List data = new List();
  String zname;
  bool _isloading = true;

  updateProfile(context) async {
    if (_name != zname || _password != "") {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(Auth().linkURL + "api/updatePatientProfile"),
      );

      Map<String, String> headers = {"Content-type": "multipart/form-data"};

      request.files.add(
        http.MultipartFile(
          'image',
          selectedImage.readAsBytes().asStream(),
          selectedImage.lengthSync(),
          filename: selectedImage.path.split('/').last,
        ),
      );

      request.headers.addAll(headers);
      print("request: " + request.toString());
      request.fields.addAll({
        'email': this._email.text,
        'id': this.useridd,
        'name': this._name.text,
        'address': this._address.text,
        'phone': this._phone.text,
        'department': this._department.text,
      });

      var res = await request.send();
      http.Response response = await http.Response.fromStream(res);
      if (response.body == '"successful"') {
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
                          .pushReplacementNamed(FullProfile.routeName);
                    },
                  )
                ],
              );
            });

        return 'success';
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  AppLocalizations.of(context).failed,
                ),
                content: Text(
                    AppLocalizations.of(context).changesUpdatedNotSuccessfull),
                actions: [
                  TextButton(
                    child: Text(AppLocalizations.of(context).ok),
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(FullProfile.routeName);
                    },
                  )
                ],
              );
            });
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
                        .pushReplacementNamed(FullProfile.routeName);
                  },
                )
              ],
            );
          });
    }
  }

  Future getImage() async {
    print('getting the image');
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      selectedImage = File(image.path);
    });
  }

  Future<String> getSWData() async {
    url = Auth().linkURL + "api/getPatientProfile";
    // String urrr1 = url + "${this.useridd}";
    // var res = await http
    //     .get(Uri.parse(urrr1), headers: {"Accept": "application/json"});

    var res = await http.post(Uri.parse(url), body: {
      'id': useridd,
    }, headers: {
      "Accept": "application/json"
    });

    var resBody = json.decode(res.body);
    if (resBody == null) {
      setState(() {
        _isloading = false;
      });
      return 'failed';
    }
    setState(() {
      _email.text = resBody['email'];
      _name.text = resBody['name'];
      _phone.text = resBody['phone'];
      _department.text = resBody['department'];
      _address.text = resBody['address'];
      _image = resBody['image'];

      zname = _name.text;

      _isloading = false;
    });
    print('edit get data');
    return "Sucess";
  }

  @override
  void initState() {
    super.initState();
    url = Auth().linkURL + "api/getProfile?id=";
    getSWData();
  }

  // Future<String> updateProfile(context) async {
  //   if (_name != zname || _password != "") {
  //     String posturl = Auth().linkURL + "api/updatePatientProfile";

  //     final res = await http.post(
  //       Uri.parse(posturl),
  //       body: {
  //         'email': this._email.text,
  //         'id': this.useridd,
  //         'name': this._name.text,
  //         'address': this._address.text,
  //         'phone': this._phone.text,
  //         'department': this._department.text,
  //       },
  //     );

  //     if (res.body == '"successful"') {
  //       showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return AlertDialog(
  //               title: Text(
  //                 AppLocalizations.of(context).success,
  //               ),
  //               content: Text(
  //                   AppLocalizations.of(context).changesUpdatedSuccessfuly),
  //               actions: [
  //                 TextButton(
  //                   child: Text(AppLocalizations.of(context).ok),
  //                   onPressed: () {
  //                     Navigator.of(context)
  //                         .pushReplacementNamed(FullProfile.routeName);
  //                   },
  //                 )
  //               ],
  //             );
  //           });

  //       return 'success';
  //     } else {
  //       showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return AlertDialog(
  //               title: Text(
  //                 AppLocalizations.of(context).failed,
  //               ),
  //               content: Text(
  //                   AppLocalizations.of(context).changesUpdatedNotSuccessfull),
  //               actions: [
  //                 TextButton(
  //                   child: Text(AppLocalizations.of(context).ok),
  //                   onPressed: () {
  //                     Navigator.of(context)
  //                         .pushReplacementNamed(FullProfile.routeName);
  //                   },
  //                 )
  //               ],
  //             );
  //           });
  //       return "error";
  //     }
  //   } else {
  //     showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: Text(AppLocalizations.of(context).invalid),
  //             content: Text(AppLocalizations.of(context).invalidInput),
  //             actions: [
  //               TextButton(
  //                 child: Text(AppLocalizations.of(context).ok),
  //                 onPressed: () {
  //                   Navigator.of(context)
  //                       .pushReplacementNamed(FullProfile.routeName);
  //                 },
  //               )
  //             ],
  //           );
  //         });
  //   }
  // }

  AppColor appcolor = new AppColor();

  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments;
    print(args);
    if (args == 'new') {
      return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context).editProfile,
              style: TextStyle(
                  color: appcolor.appbartext(),
                  fontWeight: appcolor.appbarfontweight()),
            ),
            centerTitle: true,
            backgroundColor: appcolor.appbarbackground(),
            elevation: 0.0,
            iconTheme: IconThemeData(color: appcolor.appbaricontheme()),
          ),
          body: (_isloading)
              ? Center(child: CircularProgressIndicator())
              : Container(
                  height: 700,
                  child: ListView(
                    padding: EdgeInsets.all(20),
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  getImage();
                                },
                                child: CircleAvatar(
                                    radius: 70,
                                    backgroundImage: NetworkImage(
                                        'https://picsum.photos/200')),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Center(
                                child: Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: _name,
                                    decoration: InputDecoration(
                                        labelText:
                                            AppLocalizations.of(context).name,
                                        hintText: AppLocalizations.of(context)
                                            .enterName),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return AppLocalizations.of(context)
                                            .invalidName;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Center(
                                child: Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: _email,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                        labelText:
                                            '${AppLocalizations.of(context).email} (${AppLocalizations.of(context).notChangable})',
                                        hintText:
                                            AppLocalizations.of(context).email),
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
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Center(
                                child: Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: _address,
                                    decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)
                                            .address,
                                        hintText: AppLocalizations.of(context)
                                            .address),
                                    validator: (value) {
                                      if (value.isEmpty || value.length < 5) {
                                        return AppLocalizations.of(context)
                                            .invalidAddress;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Center(
                                child: Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: _phone,
                                    decoration: InputDecoration(
                                        labelText:
                                            AppLocalizations.of(context).phone,
                                        hintText:
                                            AppLocalizations.of(context).phone),
                                    validator: (value) {
                                      if (value.isEmpty || value.length < 5) {
                                        return AppLocalizations.of(context)
                                            .phone;
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
                                    updateProfile(context);
                                  }
                                },
                                child:
                                    Text(AppLocalizations.of(context).update),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )));
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).editProfile,
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
                .pushReplacementNamed(FullProfile.routeName),
          ),
          centerTitle: true,
          backgroundColor: appcolor.appbarbackground(),
          elevation: 0.0,
          iconTheme: IconThemeData(color: appcolor.appbaricontheme()),
        ),
        body: (_isloading)
            ? Center(child: CircularProgressIndicator())
            : Container(
                height: 700,
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
                                  controller: _name,
                                  decoration: InputDecoration(
                                      labelText:
                                          AppLocalizations.of(context).name,
                                      hintText: AppLocalizations.of(context)
                                          .enterName),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return AppLocalizations.of(context)
                                          .invalidName;
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
                                  controller: _email,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                      labelText:
                                          '${AppLocalizations.of(context).email} (${AppLocalizations.of(context).notChangable})',
                                      hintText:
                                          AppLocalizations.of(context).email),
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
                                  controller: _address,
                                  decoration: InputDecoration(
                                      labelText:
                                          AppLocalizations.of(context).address,
                                      hintText:
                                          AppLocalizations.of(context).address),
                                  validator: (value) {
                                    if (value.isEmpty || value.length < 5) {
                                      return AppLocalizations.of(context)
                                          .invalidAddress;
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
                                  controller: _phone,
                                  decoration: InputDecoration(
                                      labelText:
                                          AppLocalizations.of(context).phone,
                                      hintText:
                                          AppLocalizations.of(context).phone),
                                  validator: (value) {
                                    if (value.isEmpty || value.length < 5) {
                                      return AppLocalizations.of(context).phone;
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
                                  updateProfile(context);
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
}
