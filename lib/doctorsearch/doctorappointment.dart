import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hmz_patient/doctorsearch/doctordetail.dart';
import 'package:hmz_patient/doctorsearch/doctorlist.dart';
import 'package:hmz_patient/language/provider/language_provider.dart';
import 'package:hmz_patient/utils/colors.dart';

import '../home/widgets/bottom_navigation_bar.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:date_field/date_field.dart';

import 'dart:async';
import 'dart:convert';

import '../auth/providers/auth.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';

class Doctor {
  final String id;
  final String image;
  final String name;

  Doctor({
    this.id,
    this.image,
    this.name,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class AppointmentFromDoctorScreen extends StatefulWidget {
  static const routeName = '/doctorappointment';

  String idd;
  String useridd;
  AppointmentFromDoctorScreen(this.idd, this.useridd);

  @override
  AppointmentFromDoctorScreenScreenState createState() =>
      AppointmentFromDoctorScreenScreenState(this.idd, this.useridd);
}

class AppointmentFromDoctorScreenScreenState
    extends State<AppointmentFromDoctorScreen> {
  String idd;
  String useridd;

  AppointmentFromDoctorScreenScreenState(this.idd, this.useridd);

  final _formKey = GlobalKey<FormState>();
  String _ddoctor;
  String _ddoctorId;
  var patientlist = "";

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  String url;

  List<Doctor> doctorDataList = List();
  List<DropdownMenuItem<Doctor>> dropdownDoctorItems;
  Doctor selectedDoctor;

  List<String> doctorSlotList = [];
  List<DropdownMenuItem> dropdownDoctorSlotItems;
  var selectedDoctorSlot;

  List data2 = List();
  List data3 = ['Confirmed', 'Pending', 'Requested'];
  String availableSlot = '';
  TextEditingController appointmentStatus = TextEditingController();
  String _patient;
  DateTime selectedDate;

  bool _isloading = true;

  String _date = "";
  TextEditingController _remarks = TextEditingController();

  List<String> buildDoctorSlotItems(List doctorslot) {
    List<String> itemss = List();
    doctorSlotList = new List();
    for (var zdoctor in doctorslot) {
      doctorSlotList.add(
        zdoctor['s_time'] + " To " + zdoctor['e_time'],
      );

      itemss.add(
        zdoctor['s_time'] + " To " + zdoctor['e_time'],
      );
    }

    return itemss;
  }

  List<DropdownMenuItem> buildDoctorSlotMenuItems(List doctorslot) {
    List<DropdownMenuItem> itemss = List();
    for (var zdoctor in doctorslot) {
      itemss.add(DropdownMenuItem(
          value: zdoctor['s_time'] + " To " + zdoctor['e_time'],
          child: Text(zdoctor['s_time'] + " To " + zdoctor['e_time'])));
    }

    return itemss;
  }

  onchangedDropdownDoctorSlotItem(var selectedDoctorSlot1) {
    setState(() {
      selectedDoctorSlot = selectedDoctorSlot1;
      availableSlot = selectedDoctorSlot.toString();
    });
  }

  Future<String> getDoctorSlot(getslot) async {
    var res = await http
        .get(Uri.parse(getslot), headers: {"Accept": "application/json"});
    var resBody = json.decode(res.body);

    setState(() {
      data2 = resBody;

      buildDoctorSlotItems(resBody);
    });

    return "success";
  }

  List<DropdownMenuItem<Doctor>> buildDoctorMenuItems(List doctors) {
    List<DropdownMenuItem<Doctor>> itemss = List();
    for (Doctor zdoctor in doctors) {
      itemss.add(DropdownMenuItem(value: zdoctor, child: Text(zdoctor.name)));
    }
    return itemss;
  }

  onchangedDropdownDoctorItem(Doctor selectedDoctor1) {
    setState(() {
      selectedDoctor = selectedDoctor1;
      _ddoctor = selectedDoctor.id;

      if (_date != "") {
        String getslot = Auth().linkURL +
            'api/getDoctorTimeSlop?doctor_id=' +
            _ddoctor +
            '&date=' +
            this._date;
        getDoctorSlot(getslot);
      }
    });
  }

  Future<String> getSWData() async {
    String urrr1 = url;

    var res = await http.get(
      Uri.parse(urrr1),
      headers: {"Accept": "application/json"},
    );
    var resBody = json.decode(res.body);
    for (var zx = 0; zx < resBody.length; zx++) {
      doctorDataList.add(Doctor.fromJson(resBody[zx]));
    }

    setState(() {
      dropdownDoctorItems = buildDoctorMenuItems(doctorDataList);
      _isloading = false;
    });

    return "Sucess";
  }

  Future<String> makeAppointment(context) async {
    String posturl = Auth().linkURL + "api/addAppointment";

    final res = await http.post(
      Uri.parse(posturl),
      body: {
        'patient': this._patient,
        'doctor': this._ddoctor,
        'date': this._date,
        'status': this.appointmentStatus.text,
        'time_slot': this.selectedDoctorSlot,
        'user_type': 'patient',
        'remarks': this._remarks.text,
      },
    );

    if (res.statusCode == 200 && _patient != "") {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context).success),
              content:
                  Text(AppLocalizations.of(context).appointmentCreatedMessage),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context).ok),
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(DoctorListScreen.routeName);
                  },
                )
              ],
            );
          });

      return 'success';
    } else {
      return "error";
    }
  }

  bool _firstclick = true;

  @override
  void initState() {
    super.initState();

    url = Auth().linkURL + "api/getDoctorList?id=${this.useridd}";

    this.getSWData();

    _patient = this.idd;
    appointmentStatus = new TextEditingController(text: 'Requested');
  }

  AppColor appcolor = new AppColor();

  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Doctor Appointment",
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        backgroundColor: appcolor.appbarbackground(),
        elevation: 0.0,
        iconTheme: IconThemeData(color: appcolor.appbaricontheme()),
      ),
      body: (_isloading)
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: ListView(
              padding: EdgeInsets.only(left: 20, right: 20),
              children: [
                SizedBox(height: 10),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            border: Border(
                          bottom:
                              BorderSide(width: 1.5, color: Colors.blue[100]),
                        )),
                        child: new DropdownButtonFormField(
                          decoration: InputDecoration(
                              labelText: AppLocalizations.of(context).doctor,
                              border: InputBorder.none),
                          value: selectedDoctor,
                          items: dropdownDoctorItems,
                          onChanged: (zval) {
                            onchangedDropdownDoctorItem(zval);
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(20),
                        child: TableCalendar(
                          firstDay: DateTime.now(),
                          lastDay: DateTime.utc(2030, 3, 14),
                          focusedDay: _focusedDay,
                          headerStyle: HeaderStyle(
                              formatButtonVisible: false, titleCentered: true),
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;

                              String formattedDate =
                                  DateFormat('yyyy-MM-dd').format(_selectedDay);
                              this._date = formattedDate;

                              String getslot = Auth().linkURL +
                                  'api/getDoctorTimeSlop?doctor_id=' +
                                  _ddoctor +
                                  '&date=' +
                                  formattedDate;
                              getDoctorSlot(getslot);
                            });
                          },
                          calendarFormat: CalendarFormat.twoWeeks,
                          calendarStyle: CalendarStyle(
                            defaultTextStyle: TextStyle(
                              fontSize: 15,
                            ),
                            isTodayHighlighted: false,
                            cellMargin: EdgeInsets.all(5),
                            selectedDecoration: BoxDecoration(
                              color: Colors.orange[800].withOpacity(.7),
                              shape: BoxShape.circle,
                            ),
                            selectedTextStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                          },
                          locale: langProvider.locale.languageCode,
                          pageJumpingEnabled: true,
                          pageAnimationEnabled: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          child: Center(child: Text("Available slots")),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            height: (true) ? 180 : 0,
                            decoration: BoxDecoration(
                                border: Border(
                              top: BorderSide(
                                  width: 1, color: Colors.amber[200]),
                              bottom: BorderSide(
                                  width: 1, color: Colors.amber[200]),
                            )),
                            child: Scrollbar(
                              child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 5,
                                    mainAxisSpacing: 5,
                                    childAspectRatio: (50 / 23),
                                  ),
                                  shrinkWrap: true,
                                  primary: false,
                                  padding: const EdgeInsets.all(5),
                                  physics: ClampingScrollPhysics(),
                                  itemCount: doctorSlotList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: TextButton(
                                        style: (false)
                                            ? ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.amber[800]),
                                              )
                                            : ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.white),
                                              ),
                                        onPressed: () {},
                                        child: Container(
                                          child: Center(
                                              child: Text(
                                            "${doctorSlotList[index]}",
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: (true)
                                                    ? Colors.black
                                                    : Colors.white,
                                                fontWeight: FontWeight.bold),
                                          )),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                border: Border(
                              bottom: BorderSide(
                                  width: 1.5, color: Colors.blue[100]),
                            )),
                            child: Theme(
                              data: theme.copyWith(primaryColor: Colors.blue),
                              child: TextFormField(
                                controller: _remarks,
                                decoration: InputDecoration(
                                    labelText:
                                        AppLocalizations.of(context).remarks,
                                    hintText: AppLocalizations.of(context)
                                        .giveYourRemarks,
                                    border: InputBorder.none),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return AppLocalizations.of(context)
                                        .invalidInput;
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * .9,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                if (_firstclick) {
                                  _firstclick = false;
                                  makeAppointment(context);
                                }
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(AppLocalizations.of(context)
                                            .invalid),
                                        content: Text(
                                            AppLocalizations.of(context)
                                                .pleaseEnterValidInput),
                                        actions: [
                                          TextButton(
                                            child: Text(
                                                AppLocalizations.of(context)
                                                    .ok),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          )
                                        ],
                                      );
                                    });
                              }
                            },
                            child: Text(AppLocalizations.of(context).save),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
    );
  }
}
