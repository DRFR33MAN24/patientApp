import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hmz_patient/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';

import 'dart:io';
import 'lib.dart';

import 'package:jitsi_meet/feature_flag/feature_flag.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:jitsi_meet/room_name_constraint.dart';
import 'package:jitsi_meet/room_name_constraint_type.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Jitsi extends StatefulWidget {
  static const routeName = '/jitsi';
  String link;
  String p_name;
  String d_name;
  String d_date;
  String s_time;
  String e_time;
  Jitsi(
      {this.p_name,
      this.link,
      this.d_name,
      this.d_date,
      this.s_time,
      this.e_time});
  @override
  JitsiState createState() => JitsiState(this.p_name, this.link, this.d_name,
      this.d_date, this.s_time, this.e_time);
}

class JitsiState extends State<Jitsi> {
  String link;
  String p_name;
  String d_name;
  String d_date;
  String s_time;
  String e_time;

  final serverText = TextEditingController();
  final roomText = TextEditingController(text: "");
  final subjectText = TextEditingController(text: "");
  final doctorName = TextEditingController(text: "");
  final patientname = TextEditingController(text: "");
  final emailText = TextEditingController(text: "fake@email.com");
  var isAudioOnly = false;
  var isAudioMuted = false;
  var isVideoMuted = false;

  JitsiState(this.p_name, this.link, this.d_name, this.d_date, this.s_time,
      this.e_time) {
    patientname.text = p_name;

    roomText.text = link;
    subjectText.text = "" + d_date + " - " + s_time + " to " + e_time;
    doctorName.text = d_name;
  }

  @override
  void initState() {
    super.initState();
    // JitsiMeet.addListener(JitsiMeetingListener(
    //     onConferenceWillJoin: _onConferenceWillJoin,
    //     onConferenceJoined: _onConferenceJoined,
    //     onConferenceTerminated: _onConferenceTerminated,
    //     onPictureInPictureWillEnter: _onPictureInPictureWillEnter,
    //     onPictureInPictureTerminated: _onPictureInPictureTerminated,
    //     onError: _onError));
  }

  @override
  void dispose() {
    super.dispose();
    JitsiMeet.removeAllListeners();
  }

  AppColor appcolor = new AppColor();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).videoAppointment,
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
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 24.0,
              ),
              SizedBox(
                height: 16.0,
              ),
              TextField(
                controller: doctorName,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: AppLocalizations.of(context).doctorName,
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
              TextField(
                controller: subjectText,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: AppLocalizations.of(context).appointmentTime,
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
              TextField(
                controller: patientname,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: AppLocalizations.of(context).patientName,
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
              SizedBox(
                height: 16.0,
              ),
              SizedBox(
                height: 16.0,
              ),
              CheckboxListTile(
                title: Text(AppLocalizations.of(context).audioOnly),
                value: isAudioOnly,
                onChanged: _onAudioOnlyChanged,
              ),
              SizedBox(
                height: 16.0,
              ),
              CheckboxListTile(
                title: Text(AppLocalizations.of(context).audioMuted),
                value: isAudioMuted,
                onChanged: _onAudioMutedChanged,
              ),
              SizedBox(
                height: 16.0,
              ),
              CheckboxListTile(
                title: Text(AppLocalizations.of(context).videoMuted),
                value: isVideoMuted,
                onChanged: _onVideoMutedChanged,
              ),
              Divider(
                height: 48.0,
                thickness: 2.0,
              ),
              SizedBox(
                height: 64.0,
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed: () {
                    _joinMeeting();
                  },
                  child: Text(
                    AppLocalizations.of(context).joinMeeting,
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(

                      // foregroundColor: Colors.blue,
                      ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _onAudioOnlyChanged(bool value) {
    setState(() {
      isAudioOnly = value;
    });
  }

  _onAudioMutedChanged(bool value) {
    setState(() {
      isAudioMuted = value;
    });
  }

  _onVideoMutedChanged(bool value) {
    setState(() {
      isVideoMuted = value;
    });
  }

  _joinMeeting() async {
    String serverUrl =
        serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;

    try {
      // Enable or disable any feature flag here
      // If feature flag are not provided, default values will be used
      // Full list of feature flags (and defaults) available in the README
      FeatureFlag featureFlag = FeatureFlag();
      featureFlag.welcomePageEnabled = false;

      // included by aurnab
      featureFlag.meetingPasswordEnabled = true;
      featureFlag.addPeopleEnabled = false;
      featureFlag.inviteEnabled = false;

      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlag.callIntegrationEnabled = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlag.pipEnabled = false;
      }

      //uncomment to modify video resolution
      //featureFlag.resolution = FeatureFlagVideoResolution.MD_RESOLUTION;

      // Define meetings options here
      var options = JitsiMeetingOptions()
        //..room = roomText.text
        ..serverURL = serverUrl
        ..subject = subjectText.text
        ..userDisplayName = patientname.text
        ..userEmail = emailText.text
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted;
      //..featureFlag = featureFlag;

      debugPrint("JitsiMeetingOptions: $options");
      await JitsiMeet.joinMeeting(
        options,
        listener: null,
        //  JitsiMeetingListener(
        //   onConferenceWillJoin: ({message}) {
        //   debugPrint("${options.room} will join with message: $message");
        // }, onConferenceJoined: ({message}) {
        //   debugPrint("${options.room} joined with message: $message");
        // }, onConferenceTerminated: ({message}) {
        //   debugPrint("${options.room} terminated with message: $message");
        // }, onPictureInPictureWillEnter: ({message}) {
        //   debugPrint("${options.room} entered PIP mode with message: $message");
        // }, onPictureInPictureTerminated: ({message}) {
        //   debugPrint("${options.room} exited PIP mode with message: $message");
        // }),
        // by default, plugin default constraints are used
        //roomNameConstraints: new Map(), // to disable all constraints
        //roomNameConstraints: customContraints, // to use your own constraint(s)
      );
    } catch (error) {
      debugPrint("error: $error");
    }
  }

  static final Map<RoomNameConstraintType, RoomNameConstraint>
      customContraints = {
    RoomNameConstraintType.MAX_LENGTH: new RoomNameConstraint((value) {
      return value.trim().length <= 50;
    }, "Maximum room name length should be 30."),
    RoomNameConstraintType.FORBIDDEN_CHARS: new RoomNameConstraint((value) {
      return RegExp(r"[$€£]+", caseSensitive: false, multiLine: false)
              .hasMatch(value) ==
          false;
    }, "Currencies characters aren't allowed in room names."),
  };

  void _onConferenceWillJoin({message}) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined({message}) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated({message}) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");
  }

  void _onPictureInPictureWillEnter({message}) {
    debugPrint(
        "_onPictureInPictureWillEnter broadcasted with message: $message");
  }

  void _onPictureInPictureTerminated({message}) {
    debugPrint(
        "_onPictureInPictureTerminated broadcasted with message: $message");
  }

  _onError(error) {
    debugPrint("_onError broadcasted: $error");
  }

//  Widget build(BuildContext context) {

//   }
}
