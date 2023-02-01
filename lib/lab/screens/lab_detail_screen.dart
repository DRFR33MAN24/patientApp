import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hmz_patient/auth/providers/auth.dart';
import 'package:hmz_patient/dashboard/dashboard.dart';
import 'package:hmz_patient/lab/screens/user_labs_screen.dart';
import 'package:hmz_patient/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';

import 'dart:io';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LabDetailsSingle {
  final String id;
  final String patient_name;
  final String patient_id;
  final String doctor_name;
  final String date;
  final String report;
  final String test_name;
  final String test_status;
  final String status;
  final String age;
  final String gender;
  final String hospital_title;
  final String hospital_address;
  final String hospital_phone;

  LabDetailsSingle({
    this.id,
    this.patient_name,
    this.patient_id,
    this.doctor_name,
    this.date,
    this.report,
    this.test_name,
    this.test_status,
    this.status,
    this.age,
    this.gender,
    this.hospital_title,
    this.hospital_address,
    this.hospital_phone,
  });
}

class LabDetailScreen extends StatefulWidget {
  static const routeName = '/lab-detail';
  var labid;
  String idd;
  String useridd;

  LabDetailScreen(this.idd, this.useridd, {this.labid});

  @override
  _LabDetailScreenState createState() =>
      _LabDetailScreenState(this.idd, this.useridd, this.labid);
}

class _LabDetailScreenState extends State<LabDetailScreen> {
  var labid;
  String idd;
  String useridd;

  Future<LabDetails> labDetails;

  _LabDetailScreenState(this.idd, this.useridd, this.labid);

  Future<LabDetails> _responseFuture() async {
    // var data = await http.get(Uri.parse(Auth().linkURL +
    //     "api/viewLab?id=${labid}&user_ion_id=" +
    //     useridd));

    final url = Auth().linkURL + "api/getLabReportDetails";

    try {
      final data = await http.post(
        Uri.parse(url),
        body: {
          'id': labid,
          'user_ion_id': useridd,
        },
      );

      var jsondata = json.decode(data.body);
      print(jsondata);
      var ini_lab = jsondata["labreport"];
      var ini_setting = jsondata["settings"];
      var ini_user = jsondata["user"];

      var timestamp = int.parse(ini_lab["date"]);
      var datess = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      var datesss = "${datess.day}-${datess.month}-${datess.year}";

      var currenttime = DateTime.now();
      var parsaage = ini_user["birthdate"];
      var agearray = parsaage.split("-");

      var borntime = DateTime(int.parse(agearray[2]), int.parse(agearray[1]),
          int.parse(agearray[0]));
      var currentage = currenttime.difference(borntime).inDays / 365;
      var currentage_F = currentage.floor();

      LabDetails subdata = LabDetails(
        id: ini_lab["id"],
        patient_name: ini_lab["patient_name"],
        patient_id: ini_lab["patient"],
        doctor_name: ini_lab["doctor_name"],
        date: datesss,
        report: ini_lab["report"],
        test_name: ini_lab["test_name"],
        test_status: ini_lab["test_status"],
        status: ini_lab["status"],
        age: currentage_F.toString(),
        gender: ini_user["sex"],
        hospital_title: ini_setting["title"],
        hospital_address: ini_setting["address"],
        hospital_phone: ini_setting["phone"],
      );

      return subdata;
    } catch (error) {
      throw error;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  AppColor appcolor = new AppColor();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).labReport,
          style: TextStyle(
              color: appcolor.appbartext(),
              fontWeight: appcolor.appbarfontweight()),
        ),
        centerTitle: true,
        backgroundColor: appcolor.appbarbackground(),
        elevation: 0.0,
        iconTheme: IconThemeData(color: appcolor.appbaricontheme()),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 45,
            color: Colors.blue,
          ),
          onPressed: () => Navigator.of(context)
              .pushReplacementNamed(LabListScreen.routeName),
        ),
        actions: <Widget>[],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 10),
          child: new FutureBuilder(
            future: _responseFuture(),
            builder: (BuildContext context, AsyncSnapshot response) {
              if (response.data == null) {
                return Container(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        "${response.data.test_name}",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Text(
                                "${AppLocalizations.of(context).date}: ${response.data.date}"),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            child: Text(
                                "${AppLocalizations.of(context).labId}: ${response.data.id}"),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Text(
                                "${AppLocalizations.of(context).patient}: ${response.data.patient_name}"),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            child: Text(
                                "${AppLocalizations.of(context).patientId}: ${response.data.patient_id}"),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Text(
                                "${AppLocalizations.of(context).age}: ${response.data.age} "),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            child: Text(
                                "${AppLocalizations.of(context).gender}: ${response.data.gender}"),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Html(
                        data: "${response.data.report}",
                        // style: TextStyle(
                        //   fontSize: 15,
                        // ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Column(
                              children: [
                                Text(
                                  "__________",
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(AppLocalizations.of(context).signature),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * .5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                    child: Text(
                                  "${response.data.hospital_title}",
                                  style: TextStyle(fontSize: 20),
                                )),
                                Container(
                                  child: Text(
                                    " ${response.data.hospital_address}",
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ),
                                Container(
                                    child: Text(
                                  "${response.data.hospital_phone}",
                                  style: TextStyle(fontSize: 12),
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
