import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hmz_patient/doctorsearch/doctorappointment.dart';
import 'package:hmz_patient/doctorsearch/doctorlist.dart';
import 'package:hmz_patient/home/widgets/app_drawer.dart';
import 'package:hmz_patient/language/provider/language_provider.dart';
import 'package:hmz_patient/patient/showAppointment.dart';
import 'package:hmz_patient/profile/changePassword.dart';
import 'package:hmz_patient/profile/editProfile.dart';
import 'package:hmz_patient/utils/colors.dart';
import 'package:table_calendar/table_calendar.dart';

import '../home/widgets/bottom_navigation_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:date_field/date_field.dart';
import 'package:html/parser.dart';
import 'package:flutter_html/flutter_html.dart';
// import 'package:flutter_html/flutter_html.dart';
import 'dart:async';
import 'dart:convert';
import '../auth/providers/auth.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DoctorDetailProfile extends StatefulWidget {
  static const routeName = '/doctordetail';

  String idd;
  String useridd;
  String doctorionid;
  String doctoruserid;

  DoctorDetailProfile(this.idd, this.useridd,
      {this.doctorionid, this.doctoruserid});

  @override
  DoctorDetailProfileState createState() => DoctorDetailProfileState(
      this.idd, this.useridd, this.doctorionid, this.doctoruserid);
}

class DoctorDetailProfileState extends State<DoctorDetailProfile> {
  String idd;
  String useridd;
  String doctorionid;
  String doctoruserid;

  DoctorDetailProfileState(
      this.idd, this.useridd, this.doctorionid, this.doctoruserid);

  final _formKey = GlobalKey<FormState>();
  var patientlist = "";

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  List<Doctor> doctorDataList = List();
  List<DropdownMenuItem<Doctor>> dropdownDoctorItems;
  Doctor selectedDoctor;

  List<dynamic> doctorSlotList = [];
  List<DropdownMenuItem> dropdownDoctorSlotItems;
  var selectedDoctorSlot;

  List data2 = List();
  String availableSlot = '';
  TextEditingController appointmentStatus = TextEditingController();
  String _patient;
  DateTime selectedDate;

  String _date = "";
  TextEditingController _remarks = TextEditingController();

  String url;

  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _department = TextEditingController();
  TextEditingController _profile = TextEditingController();
  TextEditingController _doctoruserid = TextEditingController();

  List data = new List();
  String zname;

  bool _isloadingPatient = true;

  Future<String> getDoctorProfileData() async {
    // url = Auth().linkURL + "api/getDoctorProfile?id=";
    // String urrr1 = url + this.doctorionid;
    // var res = await http
    //     .get(Uri.parse(urrr1), headers: {"Accept": "application/json"});
    print('dbg getDoctorProfileData');
    final url = Auth().linkURL + "api/getDoctorProfile";
    var res = await http.post(
      Uri.parse(url),
      body: {
        'id': doctorionid,
      },
    );

    var resBody = json.decode(res.body);

    setState(() {
      _email.text = resBody['email'];
      _name.text = resBody['name'];
      _phone.text = resBody['phone'];
      _department.text = resBody['department_name'];
      _address.text = resBody['address'];

      // _profile.text =
      //     parse(parse(resBody['profile']).body.text).documentElement.text;
      // _profile.text = Html(data: resBody['profile']);
      _profile.text = resBody['profile'];

      _doctoruserid.text = resBody['id'];

      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay);
      this._date = formattedDate;

      String getslot = Auth().linkURL +
          'api/getDoctorTimeSlop?doctor_id=' +
          _doctoruserid.text +
          '&date=' +
          formattedDate;
      getDoctorSlot(getslot);

      _isloadingPatient = false;
    });

    return "Sucess";
  }

  // get doctor slot data
  List<dynamic> buildDoctorSlotItems(List doctorslot) {
    List<String> itemss = List();
    doctorSlotList = new List();
    for (var zdoctor in doctorslot) {
      doctorSlotList
          .add([zdoctor['s_time'] + " To " + zdoctor['e_time'], false]);

      itemss.add(
        zdoctor['s_time'] + " To " + zdoctor['e_time'],
      );
    }

    return itemss;
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

  // make appointment

  bool errordoctorslotselect = false;
  Future<String> makeAppointment(context) async {
    setState(() {
      _isloadingPatient = true;
    });

    String posturl = Auth().linkURL + "api/addAppointment";

    final res = await http.post(
      Uri.parse(posturl),
      body: {
        'patient': this._patient,
        'doctor': this.doctoruserid,
        'date': this._date,
        'status': this.appointmentStatus.text,
        'time_slot': this.availableSlot,
        'user_type': 'patient',
        'remarks': this._remarks.text,
      },
    );

    if (res.statusCode == 200 && _patient != "") {
      setState(() {
        _isloadingPatient = false;
      });
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
                    Navigator.of(context).pushReplacementNamed(
                        ShowPatientAppointmentScreen.routeName);
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

  @override
  void initState() {
    super.initState();

    getDoctorProfileData();
    setState(() {});

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
          AppLocalizations.of(context).doctordetail,
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
        elevation: 0,
        iconTheme: IconThemeData(color: appcolor.appbaricontheme()),
      ),
      body: (_isloadingPatient)
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
              color: Colors.white,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 20),
                      child: Row(
                        children: [
                          Container(
                              color: Colors.black45,
                              width: MediaQuery.of(context).size.width * .4,
                              child: Image.network(
                                  "https://img.freepik.com/free-vector/doctor-character-background_1270-84.jpg?size=338&ext=jpg")),
                          Container(
                            padding: EdgeInsets.only(left: 20),
                            width: MediaQuery.of(context).size.width * .5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(
                                    _name.text,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    _department.text,
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    _phone.text,
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                // Container(
                                //   child: Text(
                                //     "${AppLocalizations.of(context).profile}:",
                                //     style: TextStyle(
                                //       fontSize: 16,
                                //       fontFamily: "Proxima Nova",
                                //     ),
                                //   ),
                                // ),
                                Container(
                                  child: Html(data: _profile.text),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: 10),
                    Divider(color: Colors.black12),

                    //  appointment

                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: TableCalendar(
                                firstDay: DateTime.now(),
                                lastDay: DateTime.utc(2030, 3, 14),
                                focusedDay: _focusedDay,
                                headerStyle: HeaderStyle(
                                    formatButtonVisible: false,
                                    titleCentered: true),
                                selectedDayPredicate: (day) {
                                  return isSameDay(_selectedDay, day);
                                },
                                onDaySelected: (selectedDay, focusedDay) {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;

                                    availableSlot = "";

                                    String formattedDate =
                                        DateFormat('yyyy-MM-dd')
                                            .format(_selectedDay);
                                    this._date = formattedDate;

                                    String getslot = Auth().linkURL +
                                        'api/getDoctorTimeSlop?doctor_id=' +
                                        _doctoruserid.text +
                                        '&date=' +
                                        formattedDate;
                                    getDoctorSlot(getslot);
                                  });
                                },
                                calendarFormat: CalendarFormat.twoWeeks,
                                calendarStyle: CalendarStyle(
                                  defaultTextStyle: TextStyle(
                                    fontSize: 12,
                                  ),
                                  isTodayHighlighted: false,
                                  cellMargin: EdgeInsets.all(10),
                                  selectedDecoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  selectedTextStyle: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Proxima Nova',
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
                            SizedBox(height: 0),
                            // Padding(
                            //   padding: const EdgeInsets.all(10),
                            //   child: Container(
                            //     child: Center(child: Text("Available slots")),
                            //   ),
                            // ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 0),
                              child: Center(
                                child: Container(
                                  width: double.infinity,
                                  height:
                                      (doctorSlotList.length > 0) ? 160 : 50,
                                  decoration: BoxDecoration(
                                      border: Border(
                                    top: BorderSide(
                                        width: 1, color: Colors.black12),
                                    bottom: BorderSide(
                                        width: 1, color: Colors.black12),
                                  )),
                                  child: Scrollbar(
                                    child: (doctorSlotList.length >= 1)
                                        ? GridView.builder(
                                            scrollDirection: Axis.vertical,
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 1,
                                              mainAxisSpacing: 1,
                                              childAspectRatio: 5,
                                            ),
                                            shrinkWrap: true,
                                            primary: false,
                                            padding: const EdgeInsets.all(10),
                                            physics: ClampingScrollPhysics(),
                                            itemCount: doctorSlotList.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(0),
                                                child: TextButton(
                                                  style: (doctorSlotList[index]
                                                              [1] ==
                                                          true)
                                                      ? ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(Theme.of(
                                                                          context)
                                                                      .primaryColor),
                                                        )
                                                      : ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(Colors
                                                                      .amberAccent),
                                                        ),
                                                  onPressed: () {
                                                    setState(() {
                                                      for (var listdatas = 0;
                                                          listdatas <
                                                              doctorSlotList
                                                                  .length;
                                                          listdatas++) {
                                                        if (doctorSlotList[
                                                                listdatas][0] !=
                                                            doctorSlotList[
                                                                index][0]) {
                                                          doctorSlotList[
                                                                  listdatas]
                                                              [1] = false;
                                                        }
                                                      }
                                                      doctorSlotList[index][1] =
                                                          true;
                                                      availableSlot =
                                                          doctorSlotList[index]
                                                              [0];

                                                      errordoctorslotselect =
                                                          false;
                                                    });
                                                  },
                                                  child: Container(
                                                    child: Center(
                                                        child: Text(
                                                      "${doctorSlotList[index][0]}",
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              (!doctorSlotList[
                                                                      index][1])
                                                                  ? Colors.black
                                                                  : Colors
                                                                      .white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                                  ),
                                                ),
                                              );
                                            })
                                        : Container(
                                            padding: EdgeInsets.only(
                                                top: 10, left: 10),
                                            child: Text(
                                                AppLocalizations.of(context)
                                                    .noslots),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            (errordoctorslotselect)
                                ? Container(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Text(
                                      " No Slot selected",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : Container(),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Center(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(),
                                  child: Theme(
                                    data: theme.copyWith(
                                      primaryColor: Colors.black,
                                      backgroundColor: Colors.black,
                                    ),
                                    child: TextFormField(
                                      controller: _remarks,
                                      decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)
                                            .remarks,
                                        labelStyle: TextStyle(
                                          color: Colors.black,
                                        ),
                                        hintText: AppLocalizations.of(context)
                                            .giveYourRemarks,
                                        border: UnderlineInputBorder(),
                                      ),
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Theme.of(context).primaryColor)),
                                  onPressed: () {
                                    if (_formKey.currentState.validate()) {
                                      if (_formKey.currentState.validate()) {
                                        if (availableSlot == "" ||
                                            availableSlot == null) {
                                          setState(() {
                                            errordoctorslotselect = true;
                                          });
                                        } else {
                                          makeAppointment(context);
                                        }
                                      }
                                    }
                                  },
                                  child: Text(AppLocalizations.of(context)
                                      .appointmentRequest),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
            )),
    );
  }
}
