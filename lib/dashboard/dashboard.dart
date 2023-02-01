import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hmz_patient/doctorsearch/doctordepartment.dart';
import 'package:hmz_patient/prescription/screens/prescription_detail_screen.dart';
import 'package:hmz_patient/prescription/screens/user_prescriptions_screen.dart';
import 'package:hmz_patient/lab/screens/user_labs_screen.dart';
import 'package:hmz_patient/lab/screens/lab_detail_screen.dart';
import 'package:hmz_patient/setting/setting.dart';
import 'package:hmz_patient/utils/colors.dart';
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

class AppintmentDetails {
  final String id;
  final String patient_name;
  final String doctor_name;
  final String date;
  final String start_time;
  final String end_time;
  final String status;
  final String remarks;
  final String jitsi_link;

  AppintmentDetails({
    this.id,
    this.patient_name,
    this.doctor_name,
    this.date,
    this.start_time,
    this.end_time,
    this.remarks,
    this.status,
    this.jitsi_link,
  });
}

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dsh';

  String idd;
  String useridd;
  DashboardScreen(this.idd, this.useridd);

  @override
  DashboardScreenState createState() =>
      DashboardScreenState(this.idd, this.useridd);
}

class DashboardScreenState extends State<DashboardScreen> {
  String idd;
  String useridd;
  DashboardScreenState(this.idd, this.useridd);
  int len;

  Future<List<AppintmentDetails>> _responseFuture() async {
    // var data = await http.get(Uri.parse(Auth().linkURL +
    //     "api/getMyAllAppoinmentList?group=patient&id=" +
    //     this.idd));

    final url = Auth().linkURL + "api/getMyAllAppoinmentList";
    try {
      final data = await http.post(
        Uri.parse(url),
        body: {
          'group': "patient",
          'id': idd,
        },
      );

      var jsondata = json.decode(data.body);

      List<AppintmentDetails> _lcdata = [];

      for (var u in jsondata) {
        AppintmentDetails subdata = AppintmentDetails(
          id: u["id"],
          patient_name: u["patient_name"],
          doctor_name: u["doctor_name"],
          date: u["date"],
          start_time: u["start_time"],
          end_time: u["end_time"],
          remarks: u["remarks"],
          status: u["status"],
          jitsi_link: u["jitsi_link"],
        );
        _lcdata.add(subdata);
      }

      this.len = _lcdata.length;

      return _lcdata;
    } catch (error) {
      throw error;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  AppColor appcolor = new AppColor();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).dashboard,
          style: TextStyle(
            color: appcolor.appbartext(),
            fontWeight: appcolor.appbarfontweight(),
          ),
        ),
        centerTitle: false,
        backgroundColor: appcolor.appbarbackground(),
        elevation: 0.0,
        iconTheme: IconThemeData(color: appcolor.appbaricontheme()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: GestureDetector(
              child: CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(
                        "https://image.flaticon.com/icons/png/512/147/147144.png") ??
                    Icon(Icons.person),
                backgroundColor: Colors.transparent,
              ),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(FullProfile.routeName);
              },
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        // height: MediaQuery.of(context).size.height,
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          GridView.count(
            shrinkWrap: true,
            primary: false,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            crossAxisCount: 2,
            childAspectRatio: (100 / 100),
            children: <Widget>[
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 10, right: 5, bottom: 5, left: 5),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      shadowColor: Color.fromRGBO(0, 0, 0, .5),
                      elevation: 5,
                      alignment: Alignment.bottomLeft,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.medical_services,
                          color: Theme.of(context).primaryColor,
                          size: 50,
                        ),
                        Padding(padding: EdgeInsets.all(15)),
                        Text(
                          AppLocalizations.of(context).bookADoctor,
                          style: TextStyle(fontSize: 14, color: Colors.black),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(
                          DoctorDepartmentScreen.routeName);
                    },
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 10, right: 5, bottom: 5, left: 5),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      shadowColor: Color.fromRGBO(0, 0, 0, .5),
                      elevation: 5,
                      alignment: Alignment.bottomLeft,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).primaryColor,
                          size: 50,
                        ),
                        Padding(padding: EdgeInsets.all(15)),
                        Text(
                          AppLocalizations.of(context).appointments,
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(
                          ShowPatientAppointmentScreen.routeName);
                    },
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.black, // foreground
                      shadowColor: Color.fromRGBO(0, 0, 0, .5),
                      elevation: 5,
                      alignment: Alignment.bottomLeft,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.file_copy,
                          color: Theme.of(context).primaryColor,
                          size: 50,
                        ),
                        Padding(padding: EdgeInsets.all(15)),
                        Text(
                          AppLocalizations.of(context).prescription,
                          style: TextStyle(fontSize: 15, color: Colors.black),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(
                          UserPrescriptionsScreen.routeName);
                    },
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.black, // foreground
                      shadowColor: Color.fromRGBO(0, 0, 0, .5),
                      elevation: 5,
                      alignment: Alignment.bottomLeft,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.file_copy,
                          color: Theme.of(context).primaryColor,
                          size: 50,
                        ),
                        Padding(padding: EdgeInsets.all(15)),
                        Text(
                          AppLocalizations.of(context).labReports,
                          style: TextStyle(fontSize: 15, color: Colors.black),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(LabListScreen.routeName);
                    },
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.black, // foreground
                      shadowColor: Color.fromRGBO(0, 0, 0, .5),
                      elevation: 5,
                      alignment: Alignment.bottomLeft,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.person,
                          color: Theme.of(context).primaryColor,
                          size: 50,
                        ),
                        Padding(padding: EdgeInsets.all(15)),
                        Text(
                          AppLocalizations.of(context).profile,
                          style: TextStyle(fontSize: 15, color: Colors.black),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(FullProfile.routeName);
                    },
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.black, // foreground
                      shadowColor: Color.fromRGBO(0, 0, 0, .5),
                      elevation: 5,
                      alignment: Alignment.bottomLeft,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.settings,
                          color: Theme.of(context).primaryColor,
                          size: 50,
                        ),
                        Padding(padding: EdgeInsets.all(15)),
                        Text(
                          AppLocalizations.of(context).setting,
                          style: TextStyle(fontSize: 15, color: Colors.black),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(SettingScreen.routeName);
                    },
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
      bottomNavigationBar: AppBottomNavigationBar(screenNum: 0),
    );
  }
}
