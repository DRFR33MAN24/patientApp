import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:watantib/dashboard/dashboard.dart';
import 'package:watantib/doctorsearch/doctorlist.dart';
import 'package:watantib/setting/setting.dart';
import 'package:watantib/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:date_field/date_field.dart';
import 'package:search_choices/search_choices.dart';

import 'dart:async';
import 'dart:convert';

import '../home/widgets/app_drawer.dart';
import '../home/widgets/bottom_navigation_bar.dart';
import '../profile/fullProfile.dart';

import '../patient/appointment.dart';
import '../patient/showAppointment.dart';
import '../patient/todaysappointment.dart';
import '../profile/changePassword.dart';
import '../auth/providers/auth.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DepartmentDetails {
  final String id;
  final String name;
  final String description;

  DepartmentDetails({
    this.id,
    this.name,
    this.description,
  });
}

class DoctorDepartmentScreen extends StatefulWidget {
  static const routeName = '/doctordepartment';

  String idd;
  String useridd;
  DoctorDepartmentScreen(this.idd, this.useridd);

  @override
  DoctorDepartmentScreenState createState() =>
      DoctorDepartmentScreenState(this.idd, this.useridd);
}

class DoctorDepartmentScreenState extends State<DoctorDepartmentScreen> {
  String idd;
  String useridd;
  DoctorDepartmentScreenState(this.idd, this.useridd);
  int len;
  List<DepartmentDetails> _departmentdata = [];
  List<DepartmentDetails> _tempdepartment = [];
  bool erroralllistdata = true;
  String url_hospitals;
  String url_regions;
  List hospitalDataList = [];
  List regionsDataList = [];
  var _hospital;
  var _region;

  Future<String> getHospitalsData(String region) async {
    String urrr1;

    urrr1 = url_hospitals + "?region=${region}";

    print('getHospitalsList');
    var res = await http.get(
      Uri.parse(urrr1),
      headers: {"Accept": "application/json"},
    );
    var resBody = json.decode(res.body);
    print(resBody);

    setState(() {
      hospitalDataList = resBody;
    });

    return "Sucess";
  }

  Future<String> getAllRegions() async {
    String urrr1 = url_regions;
    print('getAllRegions');
    var res = await http.get(
      Uri.parse(urrr1),
      headers: {"Accept": "application/json"},
    );
    var resBody = json.decode(res.body);
    print(resBody);

    setState(() {
      regionsDataList = resBody;
    });

    return "Sucess";
  }

  Future<void> _responseFuture() async {
    // var data = await http.get(Uri.parse(
    //     Auth().linkURL + "api/getAllDepartments?ion_id=" + this.useridd));

    print('dbg getDepartments ${_hospital}');
    if (_hospital != null) {
      final url = Auth().linkURL + "api/getAllDepartments";
      var data = await http.post(
        Uri.parse(url),
        body: {
          'hospital_id': this._hospital['id'],
        },
      );
      print('dbg departmets ${data.body}');
      var jsondata = json.decode(data.body);

      for (var u in jsondata) {
        DepartmentDetails subdata = DepartmentDetails(
          id: u["id"],
          name: u["name"],
          description: u["description"],
        );
        _departmentdata.add(subdata);
      }

      this.len = _departmentdata.length;
      setState(() {
        _tempdepartment = _departmentdata;
        erroralllistdata = false;
      });
    } else {
      setState(() {
        erroralllistdata = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    url_regions = Auth().linkURL + "api/getAllRegions";
    url_hospitals = Auth().linkURL + "api/getHospitalsList";
    _responseFuture();
    this.getHospitalsData('');
    this.getAllRegions();

    //set user and doctor ids from auth provider
    Auth auth = Provider.of<Auth>(context, listen: false);
    this.idd = auth.userId;
  }

  TextEditingController _searchdepartment = TextEditingController();
  Future<String> searchDepartment(var department) async {
    setState(() {
      _tempdepartment = [];

      if (department == "") {
        _tempdepartment = _departmentdata;
      } else {
        for (var item in _departmentdata) {
          if (item.name
              .toLowerCase()
              .contains(department.toString().toLowerCase())) {
            _tempdepartment.add(item);
          }
        }
      }
    });
    return "as";
  }

  AppColor appcolor = new AppColor();

  Widget build(BuildContext context) {
    print('dbg ${erroralllistdata}');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).department,
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
          onPressed: () =>
              Navigator.of(context).pushNamed(DashboardScreen.routeName),
        ),
        centerTitle: true,
        backgroundColor: appcolor.appbarbackground(),
        elevation: 0.0,
        iconTheme: IconThemeData(color: appcolor.appbaricontheme()),
      ),
      drawer: AppDrawer(),
      body: Container(
          child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 10,
              left: 25,
              right: 25,
            ),
            child: Center(
              child: Container(
                  child: SearchChoices.single(
                displayClearIcon: false,
                items: regionsDataList.map((item) {
                  return new DropdownMenuItem(
                    child: Container(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            child: Image.asset("assets/icon/points.png"),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(item["area"]),
                        ],
                      ),
                    ),
                    value: item,
                  );
                }).toList(),
                value: _region,
                hint: Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    AppLocalizations.of(context).choosearegion,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                searchHint: AppLocalizations.of(context).choosearegion,
                onChanged: (value) {
                  print('dbg region onCanged ${value['area']}');
                  setState(() {
                    // errordoctorselect = false;
                    _region = value;
                  });
                  getHospitalsData(_region['area']);
                },
                isExpanded: true,
              )),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              top: 10,
              left: 25,
              right: 25,
            ),
            child: Center(
              child: Container(
                  child: SearchChoices.single(
                displayClearIcon: false,
                items: hospitalDataList.map((item) {
                  return new DropdownMenuItem(
                    child: Container(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            child: Image.asset("assets/icon/points.png"),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(item["name"]),
                        ],
                      ),
                    ),
                    value: item,
                  );
                }).toList(),
                value: _hospital,
                hint: Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    AppLocalizations.of(context).chooseahospital,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                searchHint: AppLocalizations.of(context).chooseahospital,
                onChanged: (value) {
                  print('dbg current hospital ${_hospital}');
                  setState(() {
                    // errordoctorselect = false;

                    _hospital = value;
                    // url = Auth().linkURL +
                    //     "api/getDoctorList?id=${this.useridd}&hospitalId=${_hospital['id']}";
                    // getSWData();
                  });
                  _responseFuture();
                },
                isExpanded: true,
              )),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              top: 10,
              left: 25,
              right: 25,
            ),
            child: Center(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                child: TextFormField(
                  controller: _searchdepartment,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: AppLocalizations.of(context).searchdepartment,
                    hintText: AppLocalizations.of(context).department,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(top: 10, left: 10, bottom: 10),
                      child: Icon(Icons.search),
                    ),
                  ),
                  onChanged: (value) {
                    searchDepartment(value);

                    return null;
                  },
                ),
              ),
            ),
          ),
          (erroralllistdata)
              ? Container(
                  height: MediaQuery.of(context).size.height * .5,
                  child: Center(child: CircularProgressIndicator()))
              : (_tempdepartment.length == 0)
                  ? Container(
                      height: MediaQuery.of(context).size.height * .5,
                      child: Center(
                        child: Text(AppLocalizations.of(context).nodatatoshow),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 10),
                      child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            childAspectRatio: (50 / 45),
                          ),
                          shrinkWrap: true,
                          primary: false,
                          physics: ClampingScrollPhysics(),
                          itemCount: _tempdepartment.length,
                          itemBuilder: (BuildContext context, int index) {
                            Color statusColor;

                            return Container(
                              padding: EdgeInsets.all(10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                  onPrimary: Colors.black,
                                  shadowColor: Color.fromRGBO(0, 0, 0, .5),
                                  elevation: 5,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.local_hospital,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      Padding(padding: EdgeInsets.all(5)),
                                      Text(
                                        "${_tempdepartment[index].name}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: "Proxima Nova",
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DoctorListScreen(
                                                  idd, useridd, _hospital['id'],
                                                  departmentname:
                                                      _tempdepartment[index]
                                                          .id)));
                                },
                              ),
                            );
                          }),
                    )
        ],
      )),
    );
  }
}
