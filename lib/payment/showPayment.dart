import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hmz_patient/utils/colors.dart';
import '../home/widgets/bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';
import '../jitsi/jitsi.dart';
import 'addPayment.dart';
import '../auth/providers/auth.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PaymentDetails {
  final String id;
  final String patient_name;
  final String doctor_name;
  final String date;
  final String start_time;
  final String end_time;
  final String status;
  final String remarks;
  final String jitsi_link;

  PaymentDetails({
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

class ShowPayment extends StatefulWidget {
  static const routeName = '/showpayment';
  String id;
  ShowPayment(this.id);

  @override
  ShowPaymentState createState() => ShowPaymentState(this.id);
}

class ShowPaymentState extends State<ShowPayment> {
  String idd;

  ShowPaymentState(this.idd);

  Future<List<PaymentDetails>> _responseFuture() async {
    final patient_id = this.idd;

    var data = await http.get(
        Uri.parse(Auth().linkURL + "api/patientAllInvoices?id=${patient_id}"));

    // final url = Auth().linkURL + "api/patientAllInvoices";
    // var data = await http.post(
    //   Uri.parse(url),
    //   body: {
    //     'id': patient_id,
    //   },
    // );

    var jsondata = json.decode(data.body);
    List<PaymentDetails> _lcdata = [];

    for (var u in jsondata) {
      PaymentDetails subdata = PaymentDetails(
        id: u["id"],
        patient_name: u["patient_name"],
        doctor_name: u["doctor_name"],
        date: u["date"],
        start_time: u["amount"],
        end_time: u["hospital_amount"],
        remarks: u["doctor_amount"],
        status: u["deposit_type"],
        jitsi_link: u["patient_phone"],
      );
      _lcdata.add(subdata);
    }
    return _lcdata;
  }

  AppColor appcolor = new AppColor();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).paymentList,
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
          onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
        ),
        centerTitle: true,
        backgroundColor: appcolor.appbarbackground(),
        elevation: 0.0,
        iconTheme: IconThemeData(color: appcolor.appbaricontheme()),
      ),
      body: new FutureBuilder(
        future: _responseFuture(),
        builder: (BuildContext context, AsyncSnapshot response) {
          if (response.data == null) {
            return Container(
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            return ListView(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddPaymentScreen(this.idd)),
                    );
                  },
                  child: Text(AppLocalizations.of(context).addPayment,
                      style: TextStyle(fontSize: 15)),
                ),
                Divider(),
                Container(
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: response.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: ExpansionTile(
                            title: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Padding(
                                        padding: EdgeInsets.only(right: 20),
                                        child: Text(
                                          "${response.data[index].id}",
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                  ),
                                  Flexible(
                                    child: Padding(
                                        padding: EdgeInsets.only(right: 20),
                                        child: Text(
                                          "${response.data[index].patient_name}",
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                          color: Color.fromRGBO(0, 13, 79, 1),
                                          width: 0.2)),
                                ),
                                child: Column(
                                  children: [
                                    ListTile(
                                      contentPadding: EdgeInsets.only(left: 50),
                                      title: Row(
                                        children: [
                                          Text(AppLocalizations.of(context)
                                              .invoiceId),
                                          Padding(
                                            padding: EdgeInsets.only(right: 20),
                                          ),
                                          Flexible(
                                              child: Text(
                                                  "${response.data[index].id}")),
                                        ],
                                      ),
                                    ),
                                    ListTile(
                                      contentPadding: EdgeInsets.only(left: 50),
                                      title: Row(
                                        children: [
                                          Text(AppLocalizations.of(context)
                                              .patientName),
                                          Padding(
                                            padding: EdgeInsets.only(right: 20),
                                          ),
                                          Flexible(
                                              child: Text(
                                                  "${response.data[index].patient_name}")),
                                        ],
                                      ),
                                    ),
                                    ListTile(
                                      contentPadding: EdgeInsets.only(left: 50),
                                      title: Row(
                                        children: [
                                          Text(AppLocalizations.of(context)
                                              .doctorName),
                                          Padding(
                                            padding: EdgeInsets.only(right: 20),
                                          ),
                                          Flexible(
                                              child: Text(
                                                  "${response.data[index].doctor_name}")),
                                        ],
                                      ),
                                    ),
                                    ListTile(
                                      contentPadding: EdgeInsets.only(left: 50),
                                      title: Row(
                                        children: [
                                          Text(AppLocalizations.of(context)
                                              .date),
                                          Padding(
                                            padding: EdgeInsets.only(right: 20),
                                          ),
                                          Flexible(
                                              child: Text(
                                                  "${response.data[index].date}")),
                                        ],
                                      ),
                                    ),
                                    ListTile(
                                      contentPadding: EdgeInsets.only(left: 50),
                                      title: Row(
                                        children: [
                                          Text(AppLocalizations.of(context)
                                              .amount),
                                          Padding(
                                            padding: EdgeInsets.only(right: 20),
                                          ),
                                          Flexible(
                                              child: Text(
                                                  "${response.data[index].start_time}")),
                                        ],
                                      ),
                                    ),
                                    ListTile(
                                      contentPadding: EdgeInsets.only(left: 50),
                                      title: Row(
                                        children: [
                                          Text(AppLocalizations.of(context)
                                              .depositType),
                                          Padding(
                                            padding: EdgeInsets.only(right: 20),
                                          ),
                                          Flexible(
                                              child: Text(
                                                  "${response.data[index].status}")),
                                        ],
                                      ),
                                    ),
                                    ListTile(
                                      contentPadding: EdgeInsets.only(left: 50),
                                      title: Row(
                                        children: [
                                          Text(AppLocalizations.of(context)
                                              .patientPhone),
                                          Padding(
                                            padding: EdgeInsets.only(right: 20),
                                          ),
                                          Flexible(
                                              child: Text(
                                                  "${response.data[index].jitsi_link}")),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                )
              ],
            );
          }
        },
      ),
      bottomNavigationBar: AppBottomNavigationBar(),
    );
  }
}
