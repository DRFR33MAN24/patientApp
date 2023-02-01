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

class DepositedAmount {
  final String id;
  final String patient_id;
  final String deposited_amount;
  final String date;
  final String payment_id;

  DepositedAmount({
    this.id,
    this.patient_id,
    this.deposited_amount,
    this.date,
    this.payment_id,
  });
}

class AllInvoicePayment extends StatefulWidget {
  static const routeName = '/allinvoicepayment';
  String id;
  String userid;
  AllInvoicePayment(this.id, this.userid);

  @override
  AllInvoicePaymentState createState() =>
      AllInvoicePaymentState(this.id, this.userid);
}

class AllInvoicePaymentState extends State<AllInvoicePayment> {
  String idd;
  String userid;
  String total;
  String deposit;
  String due;

  AllInvoicePaymentState(this.idd, this.userid);

  Future<List<PaymentDetails>> _responseFuture() async {
    final patient_id = this.idd;
    final patient_userid = this.userid;

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
        date: u["date_string"],
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

  Future gettotalamount() async {
    String posturl = Auth().linkURL + "api/totalAmountPatient";

    final res = await http.post(
      Uri.parse(posturl),
      body: {
        'id': this.idd,
        'ion_id': this.userid,
      },
    );

    var jsondata = json.decode(res.body);

    setState(() {
      var ss = jsondata["total"];
      var ss2 = jsondata["deposit"];
      var ss3 = jsondata["due"];
      this.total = "$ss";
      this.deposit = "$ss2";
      this.due = "$ss3";
    });
  }

  @override
  void initState() {
    super.initState();
    gettotalamount();
  }

  AppColor appcolor = new AppColor();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).allInvoices,
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
        actions: <Widget>[
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              primary: Colors.transparent,
              elevation: 0.0,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddPaymentScreen(this.idd)));
            },
            icon: Icon(
              Icons.add_rounded,
            ),
            label: Text(""),
          ),
        ],
      ),
      body: Container(
        child: new FutureBuilder(
          future: _responseFuture(),
          builder: (BuildContext context, AsyncSnapshot response) {
            if (response.data == null) {
              return Container(
                child: Center(child: CircularProgressIndicator()),
              );
            } else {
              return ListView(
                children: [
                  GridView.count(
                      shrinkWrap: true,
                      primary: false,
                      padding: const EdgeInsets.all(10),
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 20,
                      crossAxisCount: 3,
                      childAspectRatio: (50 / 50),
                      children: <Widget>[
                        Container(
                          color: Colors.orange,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.blue.withOpacity(.5)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context).totalAmount,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.white),
                                ),
                                Padding(padding: EdgeInsets.all(2)),
                                Text(
                                  "${this.total}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            onPressed: () {},
                          ),
                        ),
                        Container(
                          color: Colors.orange,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.blue.withOpacity(.5)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context).totalDeposit,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.white),
                                ),
                                Padding(padding: EdgeInsets.all(2)),
                                Text(
                                  "${this.deposit}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            onPressed: () {},
                          ),
                        ),
                        Container(
                          color: Colors.orange,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.blue.withOpacity(.5)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context).totalDue,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.white),
                                ),
                                Padding(padding: EdgeInsets.all(2)),
                                Text(
                                  "${this.due}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ]),
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
                                            "${response.data[index].date}",
                                            style: TextStyle(fontSize: 14),
                                          )),
                                    ),
                                    Flexible(
                                      child: Padding(
                                          padding: EdgeInsets.only(right: 20),
                                          child: Text(
                                            "${response.data[index].id}",
                                            style: TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                    ),
                                    Flexible(
                                      child: Padding(
                                          padding: EdgeInsets.only(right: 20),
                                          child: Text(
                                            "${response.data[index].patient_name}",
                                            style: TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
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
                                        contentPadding:
                                            EdgeInsets.only(left: 50),
                                        title: Row(
                                          children: [
                                            Text(AppLocalizations.of(context)
                                                .invoiceId),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 20),
                                            ),
                                            Flexible(
                                                child: Text(
                                                    "${response.data[index].id}")),
                                          ],
                                        ),
                                      ),
                                      ListTile(
                                        contentPadding:
                                            EdgeInsets.only(left: 50),
                                        title: Row(
                                          children: [
                                            Text(AppLocalizations.of(context)
                                                .patientName),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 20),
                                            ),
                                            Flexible(
                                                child: Text(
                                                    "${response.data[index].patient_name}")),
                                          ],
                                        ),
                                      ),
                                      ListTile(
                                        contentPadding:
                                            EdgeInsets.only(left: 50),
                                        title: Row(
                                          children: [
                                            Text(AppLocalizations.of(context)
                                                .doctorName),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 20),
                                            ),
                                            Flexible(
                                                child: Text(
                                                    "${response.data[index].doctor_name}")),
                                          ],
                                        ),
                                      ),
                                      ListTile(
                                        contentPadding:
                                            EdgeInsets.only(left: 50),
                                        title: Row(
                                          children: [
                                            Text(AppLocalizations.of(context)
                                                .date),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 20),
                                            ),
                                            Flexible(
                                                child: Text(
                                                    "${response.data[index].date}")),
                                          ],
                                        ),
                                      ),
                                      ListTile(
                                        contentPadding:
                                            EdgeInsets.only(left: 50),
                                        title: Row(
                                          children: [
                                            Text(AppLocalizations.of(context)
                                                .amount),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 20),
                                            ),
                                            Flexible(
                                                child: Text(
                                                    "${response.data[index].start_time}")),
                                          ],
                                        ),
                                      ),
                                      ListTile(
                                        contentPadding:
                                            EdgeInsets.only(left: 50),
                                        title: Row(
                                          children: [
                                            Text(AppLocalizations.of(context)
                                                .depositType),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 20),
                                            ),
                                            Flexible(
                                                child: Text(
                                                    "${response.data[index].status}")),
                                          ],
                                        ),
                                      ),
                                      ListTile(
                                        contentPadding:
                                            EdgeInsets.only(left: 50),
                                        title: Row(
                                          children: [
                                            Text(AppLocalizations.of(context)
                                                .patientPhone),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 20),
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
      ),
      bottomNavigationBar: AppBottomNavigationBar(),
    );
  }
}
