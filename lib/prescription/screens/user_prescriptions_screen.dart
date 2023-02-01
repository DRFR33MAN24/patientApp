import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hmz_patient/auth/providers/auth.dart';
import 'package:hmz_patient/dashboard/dashboard.dart';
import 'package:hmz_patient/prescription/screens/prescription_detail_screen.dart';
import 'package:hmz_patient/utils/colors.dart';
import 'package:provider/provider.dart';
import '../../home/widgets/app_drawer.dart';

import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PrescriptionDetails {
  final String id;
  final String patient_name;
  final String doctor_name;
  final String date;
  final String state;
  final String symptom;
  final String advice;
  final String medicine;
  final String note;

  PrescriptionDetails({
    this.id,
    this.patient_name,
    this.doctor_name,
    this.date,
    this.state,
    this.symptom,
    this.advice,
    this.medicine,
    this.note,
  });
}

class UserPrescriptionsScreen extends StatefulWidget {
  static const routeName = '/userPrescriptions';
  String idd;
  String useridd;

  UserPrescriptionsScreen(this.idd, this.useridd);

  @override
  _UserPrescriptionsScreenState createState() =>
      _UserPrescriptionsScreenState(this.idd, this.useridd);
}

class _UserPrescriptionsScreenState extends State<UserPrescriptionsScreen> {
  String idd;
  String useridd;

  _UserPrescriptionsScreenState(this.idd, this.useridd);

  Future<List<PrescriptionDetails>> _responseFuture() async {
    String patient_id = this.useridd;

    // var data = await http.get(Uri.parse(Auth().linkURL +
    //     "api/getPatientPrescription?group=patient&id=" +
    //     patient_id));

    final url = Auth().linkURL + "api/getPatientPrescription";
    var data = await http.post(
      Uri.parse(url),
      body: {
        'group': "patient",
        'id': patient_id,
      },
    );

    var jsondata = json.decode(data.body);

    List<PrescriptionDetails> _lcdata = [];

    for (var u in jsondata) {
      var timestamp = int.parse(u["date"]);
      var datess = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      var datesss = "${datess.day}-${datess.month}-${datess.year}";

      PrescriptionDetails subdata = PrescriptionDetails(
        id: u["id"],
        patient_name: u["patientname"],
        doctor_name: u["doctorname"],
        date: datesss,
        state: u["state"],
        symptom: u["symptom"],
        advice: u["advice"],
        medicine: u["medicine"],
        note: u["note"],
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
          AppLocalizations.of(context).yourPresciptions,
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
              .pushReplacementNamed(DashboardScreen.routeName),
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
                          Widget rightArrow = Container(
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      PrescriptionDetailScreen(idd, useridd,
                                          prescriptionid:
                                              response.data[index].id),
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
                                      color: Colors.blueGrey,
                                    ),
                                    title: Text(
                                      "${response.data[index].doctor_name}",
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
                                    height: 0,
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
                                                .40,
                                        child: Text(
                                          "${AppLocalizations.of(context).prescriptionId}:  ${response.data[index].id}",
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
                                  // Row(children: [
                                  //   SizedBox(width: 71),
                                  //   Text(
                                  //     'reportStatus',
                                  //     style: TextStyle(
                                  //       fontWeight: FontWeight.bold,
                                  //       fontSize: 12,
                                  //       color: Colors.blueGrey,
                                  //     ),
                                  //   )
                                  // ]),
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



// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:hmz_patient/auth/providers/auth.dart';
// import 'package:hmz_patient/dashboard/dashboard.dart';
// import 'package:hmz_patient/prescription/screens/prescription_detail_screen.dart';
// import 'package:hmz_patient/utils/colors.dart';
// import 'package:provider/provider.dart';
// import '../../home/widgets/app_drawer.dart';

// import 'package:http/http.dart' as http;

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// class PrescriptionDetails {
//   final String id;
//   final String patient_name;
//   final String doctor_name;
//   final String date;
//   final String state;
//   final String symptom;
//   final String advice;
//   final String medicine;
//   final String note;

//   PrescriptionDetails({
//     this.id,
//     this.patient_name,
//     this.doctor_name,
//     this.date,
//     this.state,
//     this.symptom,
//     this.advice,
//     this.medicine,
//     this.note,
//   });
// }

// class UserPrescriptionsScreen extends StatefulWidget {
//   static const routeName = '/userPrescriptions';
//   String idd;
//   String useridd;

//   UserPrescriptionsScreen(this.idd, this.useridd);

//   @override
//   _UserPrescriptionsScreenState createState() =>
//       _UserPrescriptionsScreenState(this.idd, this.useridd);
// }

// class _UserPrescriptionsScreenState extends State<UserPrescriptionsScreen> {
//   String idd;
//   String useridd;

//   _UserPrescriptionsScreenState(this.idd, this.useridd);

//   Future<List<PrescriptionDetails>> _responseFuture() async {
//     String patient_id = this.useridd;

//     // var data = await http.get(Uri.parse(Auth().linkURL +
//     //     "api/getPatientPrescription?group=patient&id=" +
//     //     patient_id));

//     final url = Auth().linkURL + "api/getPatientPrescription";
//     var data = await http.post(
//       Uri.parse(url),
//       body: {
//         'group': "patient",
//         'id': patient_id,
//       },
//     );

//     var jsondata = json.decode(data.body);

//     List<PrescriptionDetails> _lcdata = [];

//     for (var u in jsondata) {
//       var timestamp = int.parse(u["date"]);
//       var datess = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
//       var datesss = "${datess.day}-${datess.month}-${datess.year}";

//       PrescriptionDetails subdata = PrescriptionDetails(
//         id: u["id"],
//         patient_name: u["patientname"],
//         doctor_name: u["doctorname"],
//         date: datesss,
//         state: u["state"],
//         symptom: u["symptom"],
//         advice: u["advice"],
//         medicine: u["medicine"],
//         note: u["note"],
//       );
//       _lcdata.add(subdata);
//     }
//     return _lcdata;
//   }

//   @override
//   void initState() {
//     super.initState();
//   }

//   AppColor appcolor = new AppColor();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           AppLocalizations.of(context).yourPresciptions,
//           style: TextStyle(
//               color: appcolor.appbartext(),
//               fontWeight: appcolor.appbarfontweight()),
//         ),
//         centerTitle: true,
//         backgroundColor: appcolor.appbarbackground(),
//         elevation: 0.0,
//         iconTheme: IconThemeData(color: appcolor.appbaricontheme()),
//         automaticallyImplyLeading: true,
//         leading: IconButton(
//           icon: Icon(
//             Icons.chevron_left,
//             size: 45,
//             color: Colors.blue,
//           ),
//           onPressed: () => Navigator.of(context)
//               .pushReplacementNamed(DashboardScreen.routeName),
//         ),
//       ),
//       drawer: AppDrawer(),
//       body: Container(
//         padding: EdgeInsets.only(top: 10),
//         child: new FutureBuilder(
//           future: _responseFuture(),
//           builder: (BuildContext context, AsyncSnapshot response) {
//             if (response.data == null) {
//               return Container(
//                 child: Center(child: CircularProgressIndicator()),
//               );
//             } else {
//               return ListView(children: [
//                 Container(
//                     margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//                     child: ListView.builder(
//                         shrinkWrap: true,
//                         physics: ClampingScrollPhysics(),
//                         itemCount: response.data.length,
//                         itemBuilder: (BuildContext context, int index) {
//                           return Padding(
//                             padding: const EdgeInsets.only(left: 10, right: 10),
//                             child: Card(
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: <Widget>[
//                                   ListTile(
//                                     leading: CircleAvatar(
//                                       backgroundImage: NetworkImage(
//                                           "http://heymedikal.com/uploads/hey_medikal_logo.png"),
//                                       radius: 30,
//                                     ),
//                                     title: Text(
//                                       "${response.data[index].doctor_name}",
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         fontFamily: 'Proxima Nova',
//                                       ),
//                                     ),
//                                     subtitle:
//                                         Text('${response.data[index].date}'),
//                                   ),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: <Widget>[
//                                       TextButton(
//                                         child: Text(
//                                             AppLocalizations.of(context).view),
//                                         onPressed: () {
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     PrescriptionDetailScreen(
//                                                         idd, useridd,
//                                                         prescriptionid: response
//                                                             .data[index].id)),
//                                           );
//                                         },
//                                       ),
//                                       const SizedBox(width: 8),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         }))
//               ]);
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
