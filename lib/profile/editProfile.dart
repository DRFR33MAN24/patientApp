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
import 'package:http_parser/http_parser.dart';

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
  String image;

  File selectedImage;
  var resJson;
  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _age = TextEditingController();
  TextEditingController _day = TextEditingController();
  TextEditingController _month = TextEditingController();
  TextEditingController _year = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _department = TextEditingController();

  String selectedSex = 'Male';
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("Male"), value: "Male"),
      DropdownMenuItem(child: Text("Female"), value: "Female"),
    ];
    return menuItems;
  }

  String selectedBlood = 'A+';
  List<DropdownMenuItem<String>> get dropdownItemsBlood {
    List<DropdownMenuItem<String>> menuItemsBlood = [
      DropdownMenuItem(child: Text("A+"), value: "A+"),
    ];
    return menuItemsBlood;
  }

  List data = new List();
  String zname;
  bool _isloading = false;

  updateProfile(context) async {
    createNewProfile(context, true);
  }

  createNewProfile(context, edit) async {
    print(selectedImage);
    if (selectedImage == null && edit == false) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context).action,
              ),
              content: Text("Please choose image"),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context).ok),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
      return 'error';
    }
    if (_name != "") {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(Auth().linkURL + "api/createPatientProfile"),
      );

      Map<String, String> headers = {"Content-type": "multipart/form-data"};

      request.files.add(
        http.MultipartFile(
          'image',
          selectedImage.readAsBytes().asStream(),
          selectedImage.lengthSync(),
          filename: 'image.' + selectedImage.path.split('/').last,
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
        'sex': this.selectedSex,
        'bloodgroup': this.selectedBlood,
        'age': this._age.text,
        'birthdate':
            this._day.text + "-" + this._month.text + "-" + this._year.text,
        'edit': edit ? 'edit' : 'new'
      });

      var res = await request.send();
      http.Response response = await http.Response.fromStream(res);
      print('createPatientProfile' + response.body);
      if (response.body == '"success"') {
        Auth auth = Provider.of<Auth>(context, listen: false);
        await auth.getProfileData();
        //Auth().getProfileData();
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
                      // Navigator.of(context)
                      //     .pushReplacementNamed(FullProfile.routeName);
                      Navigator.of(context).pop();
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
    var image = await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      selectedImage = File(image.path);
    });
  }

  // Future<String> getSWData() async {
  //   url = Auth().linkURL + "api/getPatientProfile";
  //   // String urrr1 = url + "${this.useridd}";
  //   // var res = await http
  //   //     .get(Uri.parse(urrr1), headers: {"Accept": "application/json"});

  //   var res = await http.post(Uri.parse(url), body: {
  //     'id': useridd,
  //   }, headers: {
  //     "Accept": "application/json"
  //   });

  //   var resBody = json.decode(res.body);
  //   if (resBody == null) {
  //     setState(() {
  //       _isloading = false;
  //     });
  //     return 'failed';
  //   }
  //   setState(() {
  //     _email.text = resBody['email'];
  //     _name.text = resBody['name'];
  //     _phone.text = resBody['phone'];
  //     _department.text = resBody['department'];
  //     _address.text = resBody['address'];
  //     _image = resBody['image'];

  //     zname = _name.text;

  //     _isloading = false;
  //   });
  //   print('edit get data');
  //   return "Sucess";
  // }

  @override
  void initState() {
    super.initState();
    Auth auth = Provider.of<Auth>(context, listen: false);
    print(auth.email);
    _email.text = auth.email;
    _name.text = auth.name;
    _phone.text = auth.phone;
    _department.text = auth.department;
    _address.text = auth.address;
    image = auth.image;
    selectedBlood = auth.blood;
    selectedSex = auth.sex;
    _age.text = auth.age;

    if (auth.birthday != null) {
      var birthday = auth.birthday.split('-');

      if (birthday.length == 3) {
        _day.text = birthday[0];
        _month.text = birthday[1];
        _year.text = birthday[2];
      }
    } else {
      _day.text = '';
      _month.text = '';
      _year.text = '';
    }
  }

  AppColor appcolor = new AppColor();

  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments;
    print(args);
    if (args == 'new') {
      return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context).newProfile,
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
                                    backgroundImage: selectedImage != null
                                        ? Image.file(selectedImage).image
                                        : NetworkImage(Auth().linkURL +
                                            'uploads/sidebar_image.png')),
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
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Center(
                                child: Container(
                                    width: double.infinity,
                                    child: DropdownButton(
                                      hint: Text('Sex'),
                                      value: selectedSex,
                                      items: dropdownItems,
                                      onChanged: (String value) {
                                        setState(() {
                                          selectedSex = value;
                                        });
                                      },
                                    )),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Center(
                                child: Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: _age,
                                    decoration: InputDecoration(
                                        labelText:
                                            AppLocalizations.of(context).age,
                                        hintText:
                                            AppLocalizations.of(context).age),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return AppLocalizations.of(context).age;
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
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _day,
                                            decoration: InputDecoration(
                                                labelText:
                                                    AppLocalizations.of(context)
                                                        .day,
                                                hintText:
                                                    AppLocalizations.of(context)
                                                        .day),
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return AppLocalizations.of(
                                                        context)
                                                    .day;
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _month,
                                            decoration: InputDecoration(
                                                labelText:
                                                    AppLocalizations.of(context)
                                                        .month,
                                                hintText:
                                                    AppLocalizations.of(context)
                                                        .month),
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return AppLocalizations.of(
                                                        context)
                                                    .month;
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _year,
                                            decoration: InputDecoration(
                                                labelText:
                                                    AppLocalizations.of(context)
                                                        .year,
                                                hintText:
                                                    AppLocalizations.of(context)
                                                        .year),
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return AppLocalizations.of(
                                                        context)
                                                    .year;
                                              }
                                              return null;
                                            },
                                          ),
                                        )
                                      ],
                                    )),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Center(
                                child: Container(
                                    width: double.infinity,
                                    child: DropdownButton(
                                      hint: Text('Blood group'),
                                      value: selectedBlood,
                                      items: dropdownItemsBlood,
                                      onChanged: (String value) {
                                        setState(() {
                                          selectedBlood = value;
                                        });
                                      },
                                    )),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * .9,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    createNewProfile(context, false);
                                  }
                                },
                                child:
                                    Text(AppLocalizations.of(context).create),
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
                                    backgroundImage: selectedImage != null
                                        ? Image.file(selectedImage).image
                                        : NetworkImage(Auth().linkURL + image)),
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
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Center(
                                child: Container(
                                    width: double.infinity,
                                    child: DropdownButton(
                                      hint: Text('Sex'),
                                      value: selectedSex,
                                      items: dropdownItems,
                                      onChanged: (String value) {
                                        setState(() {
                                          selectedSex = value;
                                        });
                                      },
                                    )),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Center(
                                child: Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: _age,
                                    decoration: InputDecoration(
                                        labelText:
                                            AppLocalizations.of(context).age,
                                        hintText:
                                            AppLocalizations.of(context).age),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return AppLocalizations.of(context).age;
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
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _day,
                                            decoration: InputDecoration(
                                                labelText:
                                                    AppLocalizations.of(context)
                                                        .day,
                                                hintText:
                                                    AppLocalizations.of(context)
                                                        .day),
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return AppLocalizations.of(
                                                        context)
                                                    .day;
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _month,
                                            decoration: InputDecoration(
                                                labelText:
                                                    AppLocalizations.of(context)
                                                        .month,
                                                hintText:
                                                    AppLocalizations.of(context)
                                                        .month),
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return AppLocalizations.of(
                                                        context)
                                                    .month;
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _year,
                                            decoration: InputDecoration(
                                                labelText:
                                                    AppLocalizations.of(context)
                                                        .year,
                                                hintText:
                                                    AppLocalizations.of(context)
                                                        .year),
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return AppLocalizations.of(
                                                        context)
                                                    .year;
                                              }
                                              return null;
                                            },
                                          ),
                                        )
                                      ],
                                    )),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Center(
                                child: Container(
                                    width: double.infinity,
                                    child: DropdownButton(
                                      hint: Text('Blood group'),
                                      value: selectedBlood,
                                      items: dropdownItemsBlood,
                                      onChanged: (String value) {
                                        setState(() {
                                          selectedBlood = value;
                                        });
                                      },
                                    )),
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
                                child: Text(AppLocalizations.of(context).edit),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )));
    }
  }
}
