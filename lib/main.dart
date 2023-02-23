import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hmz_patient/doctorsearch/doctorappointment.dart';
import 'package:hmz_patient/doctorsearch/doctordepartment.dart';
import 'package:hmz_patient/doctorsearch/doctordetail.dart';
import 'package:hmz_patient/doctorsearch/doctorlist.dart';
import 'package:hmz_patient/language/provider/language_provider.dart';
import 'package:hmz_patient/payment/allInvoices.dart';
import 'package:hmz_patient/payment/deposit.dart';

import 'profile/editProfile.dart';
import 'profile/fullProfile.dart';
import 'setting/setting.dart';

import 'prescription/screens/user_prescriptions_screen.dart';
import 'auth/providers/auth.dart';
import 'auth/screens/auth_screen.dart';
import 'prescription/screens/prescription_detail_screen.dart';
import 'package:provider/provider.dart';
import 'prescription/screens/user_prescriptions_screen.dart';
import 'home/screens/splash-screen.dart';
import 'lab/screens/user_labs_screen.dart';
import 'lab/screens/lab_detail_screen.dart';

import 'patient/appointment.dart';
import 'patient/showAppointment.dart';
import 'patient/todaysappointment.dart';

import 'payment/addPayment.dart';
import 'payment/showPayment.dart';

import 'dashboard/dashboard.dart';
import 'profile/changePassword.dart';

import 'package:hmz_patient/l10n/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  String appointmentid;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => LanguageProvider(),
        ),
      ],
      child: Consumer<Auth>(builder: (ctx, auth, _) {
        final langProvider = Provider.of<LanguageProvider>(ctx);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Patient Express',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Color(0xffbfafafa),
            //  scaffoldBackgroundColor: Colors.black,
            accentColor: Colors.blue,
            fontFamily: 'Proxima Nova',
          ),
          locale: langProvider.locale,
          supportedLocales: L10n.all,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: auth.isAuth
              ? DashboardScreen(auth.particularId, auth.userId)
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            DashboardScreen.routeName: (ctx) =>
                DashboardScreen(auth.particularId, auth.userId),
            Profile.routeName: (ctx) => Profile(auth.particularId, auth.userId),
            FullProfile.routeName: (ctx) =>
                FullProfile(auth.particularId, auth.userId),
            EditProfile.routeName: (ctx) =>
                EditProfile('edit', auth.particularId, auth.userId),
            PrescriptionDetailScreen.routeName: (ctx) =>
                PrescriptionDetailScreen(auth.particularId, auth.userId),
            AddPaymentScreen.routeName: (ctx) =>
                AddPaymentScreen(auth.particularId),
            ShowPayment.routeName: (ctx) => ShowPayment(auth.particularId),
            AllInvoicePayment.routeName: (ctx) =>
                AllInvoicePayment(auth.particularId, auth.userId),
            DepositPayment.routeName: (ctx) =>
                DepositPayment(auth.particularId, auth.userId),
            PatientAppointmentDetailsScreen.routeName: (ctx) =>
                PatientAppointmentDetailsScreen(auth.particularId, auth.userId),
            ShowPatientAppointmentScreen.routeName: (ctx) =>
                ShowPatientAppointmentScreen(auth.particularId, auth.userId),
            ShowTodaysAppointmentScreen.routeName: (ctx) =>
                ShowTodaysAppointmentScreen(auth.particularId),
            UserPrescriptionsScreen.routeName: (ctx) =>
                UserPrescriptionsScreen(auth.particularId, auth.userId),
            AuthScreen.routeName: (ctx) => AuthScreen(),
            SettingScreen.routeName: (ctx) =>
                SettingScreen(auth.particularId, auth.userId),
            DoctorDepartmentScreen.routeName: (ctx) =>
                DoctorDepartmentScreen(auth.particularId, auth.userId),
            DoctorDetailProfile.routeName: (ctx) =>
                DoctorDetailProfile(auth.particularId, auth.userId),
            DoctorListScreen.routeName: (ctx) =>
                DoctorListScreen(auth.particularId, auth.userId, ''),
            AppointmentFromDoctorScreen.routeName: (ctx) =>
                AppointmentFromDoctorScreen(auth.particularId, auth.userId),
            LabDetailScreen.routeName: (ctx) =>
                LabDetailScreen(auth.particularId, auth.userId),
            LabListScreen.routeName: (ctx) =>
                LabListScreen(auth.particularId, auth.userId),
          },
        );
      }),
    );
  }
}
