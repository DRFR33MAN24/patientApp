// ignore_for_file: unused_local_variable

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:watantib/auth/providers/auth.dart';
import 'package:watantib/dashboard/dashboard.dart';
import 'package:watantib/prescription/screens/prescription_detail_screen.dart';
import 'package:watantib/utils/colors.dart';
import 'package:provider/provider.dart';
import '../../home/widgets/app_drawer.dart';
import 'package:watantib/lab/screens/lab_detail_screen.dart';

import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LabDetails {
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
  final Color reportStatusColor;

  LabDetails({
    this.id,
    this.patient_name,
    this.patient_id,
    this.doctor_name,
    this.date,
    this.report,
    this.test_name,
    this.test_status,
    this.status,
    this.gender,
    this.age,
    this.hospital_title,
    this.hospital_address,
    this.hospital_phone,
    this.reportStatusColor,
  });
}

class LabListScreen extends StatefulWidget {
  static const routeName = '/userLabs';
  String idd;
  String useridd;

  LabListScreen(this.idd, this.useridd);

  @override
  _LabListScreenState createState() =>
      _LabListScreenState(this.idd, this.useridd);
}

class _LabListScreenState extends State<LabListScreen> {
  String idd;
  String useridd;

  _LabListScreenState(this.idd, this.useridd);

  Future<List<LabDetails>> _responseFuture() async {
    String patient_id = this.useridd;

    // var data = await http.get(Uri.parse(Auth().linkURL +
    //     "api/getPatientLab?group=patient&id=" +
    //     patient_id));

    final url = Auth().linkURL + "api/getLabReports";
    var data = await http.post(
      Uri.parse(url),
      body: {
        'user_ion_id': patient_id,
      },
    );

    var jsondata = json.decode(data.body);

    List<LabDetails> _lcdata = [];

    for (var u in jsondata) {
      var timestamp = int.parse(u["date"]);
      var datess = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      var datesss = "${datess.day}-${datess.month}-${datess.year}";

      LabDetails subdata = LabDetails(
        id: u["id"],
        patient_name: u["patient_name"],
        patient_id: u["patient"],
        doctor_name: u["doctor_name"],
        date: datesss,
        report: u["report"],
        test_name: u["test_name"],
        test_status: u["test_status"],
        status: u['status'],
      );
      _lcdata.add(subdata);
    }
    return _lcdata;
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
          AppLocalizations.of(context).labReports,
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
          onPressed: () =>
              Navigator.of(context).pushNamed(DashboardScreen.routeName),
        ),
      ),
      drawer: AppDrawer(),
      body: Container(
        padding: EdgeInsets.only(top: 10),
        child: new FutureBuilder(
          future: _responseFuture(),
          builder: (BuildContext context, AsyncSnapshot response) {
            if (response.data == null) {
              return Container(
                child: Center(child: CircularProgressIndicator()),
              );
            } else {
              return ListView(children: [
                Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: response.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          Color statusColor;
                          Color iconColor;
                          var reportStatus;
                          if (response.data[index].status == 'completed') {
                            statusColor = Colors.green;
                            reportStatus = 'Completed';
                            iconColor = Colors.grey;
                          } else {
                            statusColor = Colors.orange;
                            reportStatus = 'Pending';
                            iconColor = Colors.grey;
                          }

                          Widget rightArrow = Container(
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => LabDetailScreen(
                                      idd, useridd,
                                      labid: response.data[index].id),
                                ));
                              },
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.blue,
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.blueGrey,
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );

                          if (response.data[index].status != 'completed') {
                            rightArrow = Container(
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => LabDetailScreen(
                                        idd, useridd,
                                        labid: response.data[index].id),
                                  ));
                                },
                                child: CircleAvatar(
                                  radius: 0,
                                  backgroundColor: Colors.blue,
                                  child: CircleAvatar(
                                    radius: 0,
                                    backgroundColor: Colors.blue,
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                              bottom: 10,
                            ),
                            child: Card(
                              child: Column(
                                // mainAxisAlignment: MainAxisAlignment.start,
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(
                                      Icons.file_copy,
                                      size: 40,
                                      color: iconColor,
                                    ),
                                    title: Text(
                                      "${response.data[index].test_name}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Proxima Nova',
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 0,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(height: 5),
                                      SizedBox(width: 70),
                                      Container(
                                        child: Icon(
                                          Icons.event_note,
                                          size: 16,
                                          color: Colors.black12,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .45,
                                        child: Text(
                                          "${AppLocalizations.of(context).date}: ${response.data[index].date}",
                                          overflow: TextOverflow.visible,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                      rightArrow,
                                    ],
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 70),
                                      Container(
                                        child: Icon(
                                          Icons.medical_services_rounded,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .20,
                                        child: Text(
                                          "${AppLocalizations.of(context).labId}:  ${response.data[index].id}",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(children: [
                                    SizedBox(width: 71),
                                    Text(
                                      reportStatus,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: statusColor,
                                      ),
                                    )
                                  ]),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      // TextButton(
                                      //   child: Text(
                                      //       AppLocalizations.of(context).view),
                                      //   onPressed: () {
                                      //     Navigator.push(
                                      //       context,
                                      //       MaterialPageRoute(
                                      //           builder: (context) =>
                                      //               LabDetailScreen(
                                      //                   idd, useridd,
                                      //                   labid: response
                                      //                       .data[index].id)),
                                      //     );
                                      //   },
                                      // ),
                                      const SizedBox(width: 8),
                                      // Text(
                                      //   reportStatus,
                                      //   style: TextStyle(
                                      //     fontWeight: FontWeight.bold,
                                      //     fontSize: 12,
                                      //     color: statusColor,
                                      //   ),
                                      // ),
                                      Divider(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }))
              ]);
            }
          },
        ),
      ),
    );
  }
}
