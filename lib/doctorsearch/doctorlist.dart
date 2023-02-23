import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hmz_patient/doctorsearch/doctorappointment.dart';
import 'package:hmz_patient/doctorsearch/doctordepartment.dart';
import 'package:hmz_patient/doctorsearch/doctordetail.dart';
import 'package:hmz_patient/utils/colors.dart';
import '../home/widgets/bottom_navigation_bar.dart';

import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';
import '../auth/providers/auth.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DoctorDetails {
  final String id;
  final String img_url;
  final String name;
  final String email;
  final String address;
  final String phone;
  final String department;
  final String profile;
  final String ion_user_id;

  DoctorDetails({
    this.id,
    this.img_url,
    this.name,
    this.email,
    this.address,
    this.phone,
    this.department,
    this.profile,
    this.ion_user_id,
  });
}

class DoctorListScreen extends StatefulWidget {
  static const routeName = '/doctorlist';
  String idd;
  String useridd;
  String hospitalId;
  String departmentname;

  DoctorListScreen(this.idd, this.useridd, this.hospitalId,
      {this.departmentname});
  @override
  DoctorListScreenState createState() => DoctorListScreenState(
      this.idd, this.useridd, this.hospitalId, this.departmentname);
}

class DoctorListScreenState extends State<DoctorListScreen> {
  String idd;
  String useridd;
  String hospitalId;
  String departmentname;

  DoctorListScreenState(
      this.idd, this.useridd, this.hospitalId, this.departmentname);

  List<DoctorDetails> _tempdoctorlistdata = [];
  List<DoctorDetails> _doctorlistdata = [];
  bool erroralllistdata = true;

  Future<List<DoctorDetails>> _responseFuture() async {
    String patient_id = this.idd;

    // var data = await http.get(Uri.parse(Auth().linkURL +
    //     "api/getDoctorsByDepartmentname?ion_id=${useridd}&department=" +
    //     departmentname));
    print('dbg getDoctorsByDepartmentname ${hospitalId}');
    final url = Auth().linkURL + "api/getDoctorsByDepartmentname";
    var data = await http.post(
      Uri.parse(url),
      body: {
        'ion_id': useridd,
        'department': departmentname,
        'hospital_id': hospitalId,
      },
    );

// var data = await http.get(Auth().linkURL +
//         "api/getDoctorsByDepartmentname?ion_id=${useridd}&department=");
// var data = await http.get(Auth().linkURL +
//         "api/getDoctorsByDepartmentname?ion_id=1001&department=4");

    // var data = await http.get(Auth().linkURL +
    //     "api/getDoctorsByDepartmentname?ion_id="+useridd+"&department=" +
    //     departmentname);

    var jsondata = json.decode(data.body);

    for (var u in jsondata) {
      DoctorDetails subdata = DoctorDetails(
        id: u["id"],
        img_url: u["img_url"],
        name: u["name"],
        email: u["email"],
        phone: u["phone"],
        profile: u["profile"],
        address: u["address"],
        department: u["department_name"],
        ion_user_id: u["ion_user_id"],
      );
      _doctorlistdata.add(subdata);
    }
    _tempdoctorlistdata = _doctorlistdata;
    setState(() {
      erroralllistdata = false;
    });
    return _doctorlistdata;
  }

  @override
  void initState() {
    super.initState();

    _responseFuture();
  }

  TextEditingController _searchdoctor = TextEditingController();
  Future<String> searchDoctorList(var doctordataz) async {
    setState(() {
      _tempdoctorlistdata = [];

      if (doctordataz == "") {
        _tempdoctorlistdata = _doctorlistdata;
      } else {
        for (var item in _doctorlistdata) {
          if (item.name
              .toLowerCase()
              .contains(doctordataz.toString().toLowerCase())) {
            _tempdoctorlistdata.add(item);
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
            AppLocalizations.of(context).doctorlist,
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
                .pushReplacementNamed(DoctorDepartmentScreen.routeName),
          ),
          centerTitle: true,
          backgroundColor: appcolor.appbarbackground(),
          elevation: 0.0,
          iconTheme: IconThemeData(color: appcolor.appbaricontheme()),
        ),
        body: ListView(
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
                    controller: _searchdoctor,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: AppLocalizations.of(context).searchdoctor,
                      hintText: AppLocalizations.of(context).doctor,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(top: 10, left: 10, bottom: 10),
                        child: Icon(Icons.search),
                      ),
                    ),
                    onChanged: (value) {
                      searchDoctorList(value);

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
                : (_tempdoctorlistdata.length == 0)
                    ? Container(
                        height: MediaQuery.of(context).size.height * .5,
                        child: Center(
                          child:
                              Text(AppLocalizations.of(context).nodatatoshow),
                        ),
                      )
                    : Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 30,
                              mainAxisSpacing: 30,
                              childAspectRatio: (100 / 145),
                            ),
                            shrinkWrap: true,
                            primary: false,
                            padding: const EdgeInsets.all(5),
                            physics: ClampingScrollPhysics(),
                            itemCount: _tempdoctorlistdata.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                Theme.of(context).primaryColor,
                                            offset: Offset(0, 3),
                                            blurRadius: 5,
                                            spreadRadius: 2)
                                      ]),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DoctorDetailProfile(
                                                      idd, useridd,
                                                      doctorionid:
                                                          _doctorlistdata[index]
                                                              .ion_user_id,
                                                      doctoruserid:
                                                          _doctorlistdata[index]
                                                              .id)));
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(),
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(0),
                                                    bottomRight:
                                                        Radius.circular(0),
                                                  ),
                                                  child: Image.network(
                                                      "https://img.freepik.com/free-vector/doctor-character-background_1270-84.jpg?size=338&ext=jpg")),
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: PopupMenuButton<int>(
                                                color: Colors.white,
                                                icon: Icon(
                                                  Icons.more_vert,
                                                  color: Colors.black,
                                                  size: 40,
                                                ),
                                                itemBuilder: (context) => [
                                                  PopupMenuItem<int>(
                                                      value: 0,
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .dashboard_customize,
                                                            color: Colors.black,
                                                          ),
                                                          const SizedBox(
                                                            width: 7,
                                                          ),
                                                          Text(AppLocalizations
                                                                  .of(context)
                                                              .takeappointment)
                                                        ],
                                                      )),
                                                  PopupMenuItem<int>(
                                                      value: 1,
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.person,
                                                            color: Colors.black,
                                                          ),
                                                          const SizedBox(
                                                            width: 7,
                                                          ),
                                                          Text(AppLocalizations
                                                                  .of(context)
                                                              .profile)
                                                        ],
                                                      )),
                                                ],
                                                onSelected: (item) {
                                                  if (item == 0) {
                                                    Navigator.of(context)
                                                        .pushReplacementNamed(
                                                            AppointmentFromDoctorScreen
                                                                .routeName);
                                                  } else if (item == 1) {
                                                    // Navigator.of(context)
                                                    //     .pushReplacementNamed(
                                                    //         DoctorDetailProfile
                                                    //             .routeName);
                                                    Navigator.of(context).push(MaterialPageRoute(
                                                        builder: (context) =>
                                                            DoctorDetailProfile(
                                                                idd, useridd,
                                                                doctorionid:
                                                                    _doctorlistdata[
                                                                            index]
                                                                        .ion_user_id,
                                                                doctoruserid:
                                                                    _doctorlistdata[
                                                                            index]
                                                                        .id)));
                                                  }
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Container(
                                              child: Text(
                                                "${_tempdoctorlistdata[index].name} ",
                                                style: TextStyle(fontSize: 18),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 2, bottom: 10),
                                          child: Container(
                                            child: Text(
                                              "${_tempdoctorlistdata[index].department}",
                                              style: TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ));
                            }),
                      )
          ],
        ));
  }
}
