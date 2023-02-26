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

  Future<List<DepartmentDetails>> _responseFuture() async {
    // var data = await http.get(Uri.parse(
    //     Auth().linkURL + "api/getAllDepartments?ion_id=" + this.useridd));

    final url = Auth().linkURL + "api/getAllDepartments";
    var data = await http.post(
      Uri.parse(url),
      body: {
        'ion_id': this.useridd,
      },
    );

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

    return _departmentdata;
  }

  @override
  void initState() {
    super.initState();
    _responseFuture();
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
                                              DoctorListScreen(idd, useridd, '',
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
