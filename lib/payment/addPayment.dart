import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hmz_patient/payment/deposit.dart';
import 'package:hmz_patient/utils/colors.dart';
import '../home/widgets/bottom_navigation_bar.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:date_field/date_field.dart';

import '../auth/providers/auth.dart';

import 'dart:async';
import 'dart:convert';
import 'showPayment.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Patient {
  final String id;
  final String image;
  final String name;

  Patient({
    this.id,
    this.image,
    this.name,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      name: json['img_url'] as String,
      image: json['name'] as String,
    );
  }
}

class AddPaymentScreen extends StatefulWidget {
  static const routeName = '/addpayment';
  String id;
  AddPaymentScreen(this.id);
  @override
  AddPaymentScreenState createState() => AddPaymentScreenState(this.id);
}

class AddPaymentScreenState extends State<AddPaymentScreen> {
  String idd;
  String patientId;

  AddPaymentScreenState(this.idd) {
    this.patientId = this.idd;
  }

  final _formKey = GlobalKey<FormState>();
  String invoiceId;
  var patientlist = "";
  Future<List<Patient>> users;

  String _mySelection;
  String _mySelection2;
  String _mySelection3;

  String url2;
  String url;

  List data = List();
  List data2 = List();
  String _cardType;

  TextEditingController _depositAmount = TextEditingController();
  TextEditingController _depositType = TextEditingController(text: "Card");
  final _name = TextEditingController();
  final _cardNumber = TextEditingController();
  final _expiryDate = TextEditingController();
  final _cvv = TextEditingController();
  bool _isloading = true;

  List<String> data3 = ['Mastercard', 'Visa', 'American Express'];

  Future<String> getSWData() async {
    var res =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    var resBody = json.decode(res.body);

    setState(() {
      data = resBody;
      _isloading = false;
    });

    return "Sucess";
  }

  @override
  void initState() {
    super.initState();

    url2 = Auth().linkURL + "api/paymentGateway?id=${patientId}";
    url = Auth().linkURL + "api/patientAllInvoices?id=${patientId}";

    this.getSWData();
    this.patientId = this.idd;
  }

  bool _firstclick = true;
  bool _donemakingpayment = false;

  Future<String> makePayment(context) async {
    String posturl = Auth().linkURL + "api/deposit";

    final res = await http.post(
      Uri.parse(posturl),
      body: {
        'patient_id': this.patientId,
        'payment_id': this.invoiceId,
        'deposited_amount': this._depositAmount.text,
        'deposit_type': this._depositType.text,
        'card_type': this._cardType,
        'card_number': this._cardNumber.text,
        'expire_date': this._expiryDate.text,
        'cvv_number': this._cvv.text,
        'group': 'patient',
        'cardholder': this._name.text,
      },
    );

    if (res.statusCode == 200 && res.body == '"successful"') {
      setState(() {
        _donemakingpayment = false;
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context).success),
              content:
                  Text(AppLocalizations.of(context).paymentSuccessfullMessage),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context).ok),
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(DepositPayment.routeName);
                  },
                )
              ],
            );
          });

      return 'success';
    } else {
      setState(() {});

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context).failed),
              content: Text(AppLocalizations.of(context).paymentUnsuccessfull),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context).ok),
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(DepositPayment.routeName);
                  },
                )
              ],
            );
          });

      return "error";
    }
  }

  AppColor appcolor = new AppColor();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).payment,
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
                setState(() {
                  _donemakingpayment = true;
                });

                if (_formKey.currentState.validate()) {
                  if (_firstclick) {
                    _firstclick = false;
                    makePayment(context);
                  }
                }
              },
              icon: Icon(
                Icons.save,
                color: appcolor.appbaricontheme(),
              ),
              label: Text(
                AppLocalizations.of(context).save,
                style: TextStyle(color: appcolor.appbaricontheme()),
              )),
        ],
      ),
      body: (_isloading)
          ? Center(child: CircularProgressIndicator())
          : (_donemakingpayment)
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(children: [
                  Container(
                      padding: EdgeInsets.only(top: 10),
                      height: 700,
                      child: ListView(
                        padding: EdgeInsets.all(20),
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: Center(
                                    child: Center(
                                      child: new DropdownButtonFormField(
                                        decoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(context)
                                                    .invoice),
                                        items: data.map((item) {
                                          return new DropdownMenuItem(
                                            child: new Text(item['id']),
                                            value: item['id'],
                                          );
                                        }).toList(),
                                        onChanged: (newVal) {
                                          setState(() {
                                            this._mySelection = newVal;
                                            this.invoiceId = newVal;
                                          });
                                        },
                                        value: this._mySelection,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: Center(
                                    child: Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        controller: _depositAmount,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(context)
                                                    .depositAmount,
                                            hintText:
                                                AppLocalizations.of(context)
                                                    .depositAmount),
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return AppLocalizations.of(context)
                                                .depositAmountValidMessage;
                                          }
                                          return null;
                                        },
                                        onSaved: (valuez) {
                                          _depositAmount.text = valuez;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: Center(
                                    child: Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        controller: _depositType,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(context)
                                                    .depositType,
                                            hintText:
                                                AppLocalizations.of(context)
                                                    .depositType),
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return AppLocalizations.of(context)
                                                .depositTypeValidMessage;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: Center(
                                    child: new DropdownButtonFormField(
                                      decoration: InputDecoration(
                                          labelText:
                                              AppLocalizations.of(context)
                                                  .cardType),
                                      items: data3.map((item3) {
                                        return new DropdownMenuItem(
                                          child: new Text(item3),
                                          value: item3,
                                        );
                                      }).toList(),
                                      onChanged: (newVal3) {
                                        setState(() {
                                          this._mySelection3 = newVal3;
                                          this._cardType = newVal3;
                                        });
                                      },
                                      value: this._mySelection3,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Image.asset(
                                    'assets/images/creditcardlogos.png',
                                    width: double.infinity,
                                    height: 80,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: Center(
                                    child: Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(context)
                                                    .name,
                                            hintText:
                                                AppLocalizations.of(context)
                                                    .enterName),
                                        validator: (value1) {
                                          if (value1.isEmpty) {
                                            return AppLocalizations.of(context)
                                                .enterCardHolderName;
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          _name.text = value;
                                        },
                                        controller: _name,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: Center(
                                    child: Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        controller: _cardNumber,
                                        decoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(context)
                                                    .cardNumber,
                                            hintText:
                                                AppLocalizations.of(context)
                                                    .enterCardnumber),
                                        validator: (value2) {
                                          if (value2.isEmpty) {
                                            return AppLocalizations.of(context)
                                                .invalidCardNumber;
                                          }
                                          _cardNumber.text = value2;
                                          return null;
                                        },
                                        onSaved: (valuez) {
                                          _cardNumber.text = valuez;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: Center(
                                    child: Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        controller: _expiryDate,
                                        decoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(context)
                                                    .exipryDate,
                                            hintText:
                                                AppLocalizations.of(context)
                                                    .enterExipryDate),
                                        validator: (value3) {
                                          if (value3.isEmpty) {
                                            return AppLocalizations.of(context)
                                                .invalid;
                                          }
                                          return null;
                                        },
                                        onSaved: (valuez) {
                                          _expiryDate.text = valuez;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: Center(
                                    child: Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        controller: _cvv,
                                        decoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(context)
                                                    .cvv,
                                            hintText:
                                                AppLocalizations.of(context)
                                                    .enterCvv),
                                        validator: (value4) {
                                          if (value4.isEmpty) {
                                            return AppLocalizations.of(context)
                                                .invalidCvv;
                                          }
                                          return null;
                                        },
                                        onSaved: (valuez) {
                                          _cvv.text = valuez;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                  SizedBox(height: 10),
                ])),
    );
  }
}
