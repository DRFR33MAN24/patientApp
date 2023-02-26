import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:watantib/auth/providers/auth.dart';
import 'package:watantib/home/widgets/app_drawer.dart';
import 'package:watantib/utils/colors.dart';
import '../home/widgets/bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppintmentDetails {
  final String id;
  final String patient_name;
  final String doctor_name;
  final String hospital_name;
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
    this.hospital_name,
    this.date,
    this.start_time,
    this.end_time,
    this.remarks,
    this.status,
    this.jitsi_link,
  });
}

class ShowTodaysAppointmentScreen extends StatefulWidget {
  static const routeName = '/ShowTodaysAppointmentlist';

  String idd;
  ShowTodaysAppointmentScreen(this.idd);

  @override
  ShowTodaysAppointmentScreenState createState() =>
      ShowTodaysAppointmentScreenState(this.idd);
}

class ShowTodaysAppointmentScreenState
    extends State<ShowTodaysAppointmentScreen> {
  String idd;
  ShowTodaysAppointmentScreenState(this.idd);

  List<AppintmentDetails> _tempappointmentlistdata = [];
  List<AppintmentDetails> _appointmentlistdata = [];
  bool erroralllistdata = true;
  Future<List<AppintmentDetails>> _responseFuture() async {
    final doctor_id = this.idd;

    // var data = await http.get(Uri.parse(Auth().linkURL +
    //     "api/getMyTodaysAppoinmentList?group=patient&id=" +
    //     doctor_id));

    final url = Auth().linkURL + "api/getMyTodaysAppoinmentList";

    final data = await http.post(
      Uri.parse(url),
      body: {
        'group': "patient",
        'id': doctor_id,
      },
    );

    var jsondata = json.decode(data.body);
    List<AppintmentDetails> _lcdata = [];

    for (var u in jsondata) {
      AppintmentDetails subdata = AppintmentDetails(
        id: u["id"],
        patient_name: u["patient_name"],
        doctor_name: u["doctor_name"],
        hospital_name: u['hospital_name'],
        date: u["date"],
        start_time: u["start_time"],
        end_time: u["end_time"],
        remarks: u["remarks"],
        status: u["status"],
        jitsi_link: u["jitsi_link"],
      );
      _appointmentlistdata.add(subdata);
    }
    setState(() {
      _tempappointmentlistdata = _appointmentlistdata;
      erroralllistdata = false;
    });

    return _appointmentlistdata;
  }

  @override
  void initState() {
    super.initState();

    _responseFuture();
  }

  TextEditingController _searchappointment = TextEditingController();
  Future<String> searchallappointmentList(var appointmentdata) async {
    setState(() {
      _tempappointmentlistdata = [];

      if (appointmentdata == "") {
        _tempappointmentlistdata = _appointmentlistdata;
      } else {
        for (var item in _appointmentlistdata) {
          if (item.doctor_name
              .toLowerCase()
              .contains(appointmentdata.toString().toLowerCase())) {
            _tempappointmentlistdata.add(item);
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
          AppLocalizations.of(context).todaysAppointment,
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
          onPressed: () => Navigator.of(context).pushNamed('/'),
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                width: double.infinity,
                child: TextFormField(
                  controller: _searchappointment,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: AppLocalizations.of(context).searchbydoctorname,
                    hintText: AppLocalizations.of(context).doctor,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(top: 10, left: 10, bottom: 10),
                      child: Icon(Icons.search),
                    ),
                  ),
                  onChanged: (value) {
                    searchallappointmentList(value);

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
              : (_tempappointmentlistdata.length == 0)
                  ? Container(
                      height: MediaQuery.of(context).size.height * .5,
                      child: Center(
                        child: Text(AppLocalizations.of(context).nodatatoshow),
                      ),
                    )
                  : Container(
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: _tempappointmentlistdata.length,
                          itemBuilder: (BuildContext context, int index) {
                            Color statusColor;
                            if (_tempappointmentlistdata[index].status ==
                                "Confirmed") {
                              statusColor = Colors.green;
                            } else if (_tempappointmentlistdata[index].status ==
                                "Requested") {
                              statusColor = Colors.orange;
                            } else if (_tempappointmentlistdata[index].status ==
                                "Cancelled") {
                              statusColor = Colors.red;
                            } else if (_tempappointmentlistdata[index].status ==
                                "Treated") {
                              statusColor = Colors.indigo;
                            } else if (_tempappointmentlistdata[index].status ==
                                "Pending Confirmation") {
                              statusColor = Colors.orange;
                            }

                            return Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 30, horizontal: 30),
                              padding: EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue[300].withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            height: 100,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .25,
                                            child: CircleAvatar(
                                              backgroundColor: Colors.blue[200],
                                              child: Icon(
                                                Icons.person,
                                                size: 60,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          (_tempappointmentlistdata[index]
                                                      .status ==
                                                  "Confirmed")
                                              ? Container(
                                                  width: 40,
                                                  height: 30,
                                                  child: ElevatedButton(
                                                    style: ButtonStyle(
                                                        padding:
                                                            MaterialStateProperty.all(
                                                                EdgeInsets.only(
                                                                    top: 2,
                                                                    bottom: 2)),
                                                        backgroundColor:
                                                            MaterialStateProperty.all(
                                                                Colors.white),
                                                        shape: MaterialStateProperty.all<
                                                                RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        10),
                                                                side: BorderSide(color: Colors.black12)))),
                                                    onPressed: () {
                                                      // Navigator.push(
                                                      //   context,
                                                      //   MaterialPageRoute(
                                                      //       builder: (context) => Jitsi(
                                                      //           link: _tempappointmentlistdata[
                                                      //                   index]
                                                      //               .jitsi_link,
                                                      //           p_name: _tempappointmentlistdata[
                                                      //                   index]
                                                      //               .patient_name,
                                                      //           d_name:
                                                      //               _tempappointmentlistdata[
                                                      //                       index]
                                                      //                   .doctor_name,
                                                      //           d_date:
                                                      //               _tempappointmentlistdata[
                                                      //                       index]
                                                      //                   .date,
                                                      //           s_time: _tempappointmentlistdata[
                                                      //                   index]
                                                      //               .start_time,
                                                      //           e_time: _tempappointmentlistdata[
                                                      //                   index]
                                                      //               .end_time)),
                                                      // );
                                                    },
                                                    child: Icon(
                                                      Icons.video_call,
                                                      size: 25,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .50,
                                            child: Text(
                                              "${_tempappointmentlistdata[index].doctor_name}",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .50,
                                            child: Text(
                                              "${_tempappointmentlistdata[index].hospital_name}",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                child: Icon(
                                                  Icons.event_note,
                                                  size: 16,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .50,
                                                child: Text(
                                                  "${AppLocalizations.of(context).remarks}: ${_tempappointmentlistdata[index].remarks}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                child: Icon(
                                                  Icons.event,
                                                  size: 16,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .50,
                                                child: Text(
                                                  " ${_tempappointmentlistdata[index].date}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                child: Icon(
                                                  Icons.access_time_sharp,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .50,
                                                child: Text(
                                                  "${_tempappointmentlistdata[index].start_time} - ${_tempappointmentlistdata[index].end_time}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Text(
                                            "${_tempappointmentlistdata[index].status}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: statusColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                    )
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(),
    );
  }
}
