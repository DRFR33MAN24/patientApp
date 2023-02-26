import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../../home/models/http_exception.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum AuthMode { Signup, Login }

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
                      child: Image.asset("assets/icon/loginicon.png"),
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
  AuthMode _authMode = AuthMode.Signup;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).anErrorHasOccurred),
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
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).login(
          _authData['email'],
          _authData['password'],
        );
        Navigator.of(context).pushReplacementNamed('/');
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signup(
          _authData['email'],
          _authData['password'],
        );
        _showErrorDialog("Signup successfull please confirm Email");
      }
    } on HttpException catch (error) {
      print('error message' + error.toString());
      var errorMessage = AppLocalizations.of(context).authenticationFailed;
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = AppLocalizations.of(context).theEmailIsAlreadyInUse;
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = AppLocalizations.of(context).thisIsNotAValidEmailAddress;
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = AppLocalizations.of(context).passwordIsTooWeak;
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = AppLocalizations.of(context).couldNotFindTheEmailAddress;
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = AppLocalizations.of(context).invalidPassword;
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      var errorMessage =
          AppLocalizations.of(context).couldNotAuthenticateYouPleasetryagain;

      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
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
                      _authData['email'] = value;
                    },
                  ),
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                      child: Text(
                          _authMode == AuthMode.Login
                              ? AppLocalizations.of(context).login
                              : AppLocalizations.of(context).signup,
                          style: TextStyle(fontSize: 20)),
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
