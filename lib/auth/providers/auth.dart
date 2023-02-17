import 'dart:convert';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../home/models/http_exception.dart';

class Auth extends ChangeNotifier {
  String _token;
  bool _profileCreated = false;
  DateTime _expiryDate;
  String _userId;
  String _particularId;
  Timer _authTimer;

  // Profile data
  String error;
  String email;
  String phone;
  String name;
  String age;
  String blood;
  String sex;
  String department;
  String image;
  String address;
  bool isloading;

  String _url_link = "http://192.168.1.5/";
  //String _url_link = "https://watan-tib.com/";

  bool get isAuth {
    return _token != null;
  }

  bool get profileCreated {
    return _profileCreated;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  DateTime get expiryDate {
    return _expiryDate;
  }

  String get particularId {
    return _particularId;
  }

  String get linkURL {
    return _url_link;
  }

  Future<String> getProfileData() async {
    final url = linkURL + "api/getPatientProfile";
    var data = await http.post(Uri.parse(url), body: {
      'id': userId,
    }, headers: {
      "Accept": "application/json"
    });

    print('dbg getProfileData' + data.body);
    var resBody = json.decode(data.body);
    print('dbg resBody ' + resBody.toString());
    if (resBody == null) {
      error = 'error';

      isloading = false;
      _profileCreated = false;

      return 'failed';
    } else {
      email = resBody['email'];
      name = resBody['name'];
      phone = resBody['phone'];
      sex = resBody['sex'];
      age = resBody['age'];
      blood = resBody['bloodgroup'];
      department = resBody['department'];
      address = resBody['address'];
      image = resBody['img_url'];

      isloading = false;
      _profileCreated = true;
      print('dbg profile retrived');

      return "Sucess";
    }
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    String gtype = "Patient";
    final url = this._url_link + 'api/authenticate';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'email': email,
          'password': password,
          'mode': urlSegment,
          'group': gtype,
        },
      );

      final responseData = json.decode(response.body);
      print('dbg response data' + response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['message']);
      }

      if (urlSegment == 'login') {
        _token = responseData['idToken'].toString();
        _userId = responseData['ion_id'].toString();
        _particularId = responseData['user_id'].toString();

        _expiryDate = DateTime.now().add(
          Duration(
            seconds: int.parse(
              responseData['expiresIn'].toString(),
            ),
          ),
        );

        _autoLogout();
        notifyListeners();
        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode(
          {
            'token': _token,
            'userId': _userId,
            'particularId': _particularId,
            'expiryDate': _expiryDate.toIso8601String(),
          },
        );
        prefs.setString('userData', userData);
        if (_userId != null) {
          print('dbg ' + _userId);
          getProfileData();
          notifyListeners();
        }
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signup');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'login');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    this._token = extractedUserData['token'];
    this._userId = extractedUserData['userId'];

    this._particularId = extractedUserData['particularId'];

    this._expiryDate = expiryDate;

    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    print('dbg logout');
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
