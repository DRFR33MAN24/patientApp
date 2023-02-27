import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../../home/models/http_exception.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResetPassword extends StatelessWidget {
  static const routeName = '/reset_password';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: deviceSize.height,
            width: deviceSize.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          ListView(
            children: [
              Container(
                alignment: Alignment.center,
                height: 600,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 200,
                      margin: EdgeInsets.only(bottom: 5, left: 30, right: 30),
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Image.asset("assets/icon/loginicon1.png"),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      child: ResetCard(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ResetCard extends StatefulWidget {
  const ResetCard({
    Key key,
  }) : super(key: key);

  @override
  _ResetCardState createState() => _ResetCardState();
}

class _ResetCardState extends State<ResetCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  var _isLoading = false;

  String email = '';

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).success),
        content: Text(message),
        actions: <Widget>[
          TextButton(
              child: Text(AppLocalizations.of(context).ok),
              onPressed: () {
                Navigator.of(ctx).pop();
              }),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<Auth>(context, listen: false).forgotPassword(
        this.email,
      );
      Navigator.of(context).pushNamed('/');

      _showErrorDialog(AppLocalizations.of(context)
          .yourPasswordResetLinkHasBeenSentToYourEmailAddress);
    } on HttpException catch (error) {
      print('error message' + error.toString());
      // var errorMessage = AppLocalizations.of(context).authenticationFailed;
      // if (error.toString().contains('EMAIL_EXISTS')) {
      //   errorMessage = AppLocalizations.of(context).theEmailIsAlreadyInUse;
      // } else if (error.toString().contains('INVALID_EMAIL')) {
      //   errorMessage = AppLocalizations.of(context).thisIsNotAValidEmailAddress;
      // } else if (error.toString().contains('WEAK_PASSWORD')) {
      //   errorMessage = AppLocalizations.of(context).passwordIsTooWeak;
      // } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
      //   errorMessage = AppLocalizations.of(context).couldNotFindTheEmailAddress;
      // } else if (error.toString().contains('INVALID_PASSWORD')) {
      //   errorMessage = AppLocalizations.of(context).invalidPassword;
      // }
      // _showErrorDialog(error);
    } catch (error) {
      var errorMessage = AppLocalizations.of(context).anErrorHasOccurred;

      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Container(
      child: Container(
        width: deviceSize.width * 0.85,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).email,
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value.isEmpty || !value.contains('@')) {
                        return AppLocalizations.of(context).invalidEmail;
                      }
                      return null;
                    },
                    onSaved: (value) {
                      this.email = value;
                    },
                  ),
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ElevatedButton(
                        child: Text(AppLocalizations.of(context).resetPassword,
                            style: TextStyle(fontSize: 20)),
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50))),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
