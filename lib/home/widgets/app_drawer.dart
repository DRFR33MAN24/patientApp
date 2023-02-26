import 'package:flutter/material.dart';
import 'package:watantib/doctorsearch/doctordepartment.dart';
import 'package:watantib/doctorsearch/doctordetail.dart';
import 'package:watantib/doctorsearch/doctorlist.dart';
import 'package:watantib/payment/allInvoices.dart';
import 'package:watantib/payment/deposit.dart';
import 'package:watantib/prescription/screens/prescription_detail_screen.dart';
import 'package:watantib/profile/fullProfile.dart';
import '../../profile/editProfile.dart';
import '../../setting/setting.dart';
import '../../prescription/screens/user_prescriptions_screen.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth.dart';

import '../../patient/appointment.dart';
import '../../patient/showAppointment.dart';
import '../../patient/todaysappointment.dart';

import '../../payment/addPayment.dart';
import '../../payment/showPayment.dart';

import '../../dashboard/dashboard.dart';
import '../../profile/changePassword.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Auth>(builder: (ctx, auth, _) {
      return Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              AppBar(
                backgroundColor: Colors.blue,
                toolbarHeight: 70,
                title: Center(
                    child: Column(
                  children: [
                    Text('وطن طب'),
                    Text('ID: ${auth.patient_id}'),
                  ],
                )),
                automaticallyImplyLeading: false,
                centerTitle: false,
              ),
              ListTile(
                leading: Icon(
                  Icons.dashboard,
                ),
                title: Text(AppLocalizations.of(context).dashboard),
                onTap: () {
                  Navigator.of(context).pushNamed(DashboardScreen.routeName);
                },
              ),
              Divider(
                height: 3,
              ),
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  leading: Icon(
                    Icons.list,
                  ),
                  title: Text(AppLocalizations.of(context).appointment),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: ListTile(
                        leading: Icon(
                          Icons.add_circle_outline,
                        ),
                        title: Text(
                            AppLocalizations.of(context).appointmentRequest),
                        onTap: () {
                          if (auth.profileCreated) {
                            Navigator.of(context).pushNamed(
                                PatientAppointmentDetailsScreen.routeName);
                          } else {
                            String mode = 'new';
                            Navigator.of(context).pushNamed(
                                EditProfile.routeName,
                                arguments: mode);
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: ListTile(
                        leading: Icon(
                          Icons.today,
                        ),
                        title: Text(
                            AppLocalizations.of(context).todaysAppointment),
                        onTap: () {
                          if (auth.profileCreated) {
                            Navigator.of(context).pushNamed(
                                ShowTodaysAppointmentScreen.routeName);
                          } else {
                            String mode = 'new';
                            Navigator.of(context).pushNamed(
                                EditProfile.routeName,
                                arguments: mode);
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: ListTile(
                        leading: Icon(
                          Icons.list,
                        ),
                        title:
                            Text(AppLocalizations.of(context).appointmentList),
                        onTap: () {
                          if (auth.profileCreated) {
                            Navigator.of(context).pushNamed(
                                ShowPatientAppointmentScreen.routeName);
                          } else {
                            String mode = 'new';
                            Navigator.of(context).pushNamed(
                                EditProfile.routeName,
                                arguments: mode);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 3,
              ),
              ListTile(
                leading: Icon(
                  Icons.file_copy,
                ),
                title: Text(AppLocalizations.of(context).prescription),
                onTap: () {
                  if (auth.profileCreated) {
                    Navigator.of(context)
                        .pushNamed(UserPrescriptionsScreen.routeName);
                  } else {
                    String mode = 'new';
                    Navigator.of(context)
                        .pushNamed(EditProfile.routeName, arguments: mode);
                  }
                },
              ),
              Divider(
                height: 2,
              ),
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  leading: Icon(
                    Icons.payment,
                  ),
                  title: Text(AppLocalizations.of(context).payment),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: ListTile(
                        leading: Icon(
                          Icons.payment,
                        ),
                        title: Text(AppLocalizations.of(context).addPayment),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(AddPaymentScreen.routeName);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: ListTile(
                        leading: Icon(
                          Icons.payments_outlined,
                        ),
                        title: Text(AppLocalizations.of(context).allInvoices),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(AllInvoicePayment.routeName);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: ListTile(
                        leading: Icon(Icons.payments_outlined),
                        title: Text(AppLocalizations.of(context).deposit),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(DepositPayment.routeName);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 3,
              ),
              Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: Icon(
                    Icons.search,
                  ),
                  title: Text(AppLocalizations.of(context).doctorsearch),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: ListTile(
                        leading: Icon(Icons.add_business_rounded),
                        title: Text(AppLocalizations.of(context).department),
                        onTap: () {
                          if (auth.profileCreated) {
                            Navigator.of(context)
                                .pushNamed(DoctorDepartmentScreen.routeName);
                          } else {
                            String mode = 'new';
                            Navigator.of(context).pushNamed(
                                EditProfile.routeName,
                                arguments: mode);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 3,
              ),
              ListTile(
                leading: Icon(
                  Icons.person,
                ),
                title: Text(AppLocalizations.of(context).profile),
                onTap: () {
                  if (auth.profileCreated) {
                    Navigator.of(context).pushNamed(FullProfile.routeName);
                  } else {
                    String mode = 'new';
                    Navigator.of(context)
                        .pushNamed(EditProfile.routeName, arguments: mode);
                  }
                },
              ),
              Divider(
                height: 3,
              ),
              ListTile(
                leading: Icon(
                  Icons.settings,
                ),
                title: Text(AppLocalizations.of(context).setting),
                onTap: () {
                  Navigator.of(context).pushNamed(SettingScreen.routeName);
                },
              ),
              Divider(
                height: 3,
              ),
              ListTile(
                leading: Icon(
                  Icons.exit_to_app,
                ),
                title: Text(AppLocalizations.of(context).logout),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/');

                  Provider.of<Auth>(context, listen: false).logout();
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
