import "package:flutter/material.dart";
import 'package:watantib/profile/fullProfile.dart';
import '../../profile/changePassword.dart';
import '../../patient/showAppointment.dart';
import '../../dashboard/dashboard.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppBottomNavigationBar extends StatefulWidget {
  var screenNum;
  AppBottomNavigationBar({this.screenNum});

  @override
  _AppBottomNavigationBarState createState() =>
      _AppBottomNavigationBarState(screenNum: this.screenNum);
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  var screenNum;
  int _selectedIndex;
  Color selectedcolor;

  int _selectedIndexValue;
  TextStyle optionStyle = TextStyle(fontSize: 15);

  _AppBottomNavigationBarState({this.screenNum}) {
    this._selectedIndex = screenNum;
    if (_selectedIndex == null) {
      _selectedIndex = 0;
      _selectedIndexValue = null;
      selectedcolor = Colors.blue;
      this.optionStyle = TextStyle(fontSize: 15);
    } else {
      _selectedIndexValue = screenNum;
      selectedcolor = Colors.blue;
      this.optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == 0) {
        Navigator.of(context).pushNamed(DashboardScreen.routeName);
      }
      if (index == 1) {
        Navigator.of(context).pushNamed(ShowPatientAppointmentScreen.routeName);
      }

      if (index == 2) {
        Navigator.of(context).pushNamed(FullProfile.routeName);
      }

      _selectedIndex = index;
      _selectedIndexValue = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    String dashboard = "${AppLocalizations.of(context).dashboard}";

    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: (_selectedIndexValue == 0)
              ? AppLocalizations.of(context).dashboard
              : "",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: (_selectedIndexValue == 1)
              ? AppLocalizations.of(context).appointments
              : "",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: (_selectedIndexValue == 2)
              ? AppLocalizations.of(context).profile
              : "",
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: selectedcolor,
      onTap: _onItemTapped,
    );
  }
}
