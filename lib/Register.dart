import 'package:flutter/material.dart';
import 'package:groceriery/MainPage.dart';
import 'package:groceriery/ShopMainPage.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class UserObject {
  int id;
  String name;
  int type;

  UserObject({
    required this.id,
    required this.name,
    required this.type,
  });

  factory UserObject.fromJson(dynamic json) {
    return UserObject(
        id: json['id'] as int,
        name: json['name'] as String,
        type: json['type'] as int);
  }

  @override
  String toString() {
    return '{ ${this.id}, ${this.name}, ${this.type} }';
  }
}

class _RegistrationPageState extends State<RegistrationPage> {
  String _userType = 'Customer'; // default user type
  late String _email;
  late String _password;
  late String _name;

  List<String> _userTypes = ['Customer', 'Shop'];

  Future<UserObject?> register() async {
    Map<String, String> customHeaders = {"content-type": "application/json"};

    int _type = _userTypes.indexOf(_userType);
    var url = Uri.http('157.245.199.11', 'users');
    var response = await http.post(url,
        headers: customHeaders,
        body: jsonEncode({
          'email': '$_email',
          'password': '$_password',
          'name': '$_name',
          'type': _type
        }));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 201) {
      print(response.body);
      UserObject userObject = UserObject.fromJson(json.decode(response.body));
      return userObject;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Full Name'),
              onChanged: (value) {
                setState(() {
                  _name = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: (value) {
                setState(() {
                  _email = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
              onChanged: (value) {
                setState(() {
                  _password = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'User Type:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: _userType,
                    onChanged: (String? newValue) {
                      setState(() {
                        _userType = newValue!;
                      });
                    },
                    items: _userTypes
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // TODO: Submit registration
                var user = await register();

                if (user != null) {
                  if (user.type == 0) {
                    //edit this later to pass user object

                    // await storage.write(key: 'user', value: jsonEncode(user));
                    // Navigator.pushReplacementNamed(context, '/main');
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => MainPage(
                              userId: user.id,
                            )));
                  } else if (user.type == 1) {
                    //edit this later to pass user object
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) =>
                            ShopLandingPage(shopId: user.id)));
                    // Navigator.pushReplacementNamed(context, '/shopMain');
                  } else if (user.type == 2) {
                    //edit this later to pass user object
                    // Navigator.pushReplacementNamed(context, '/main');
                  }
                } else {
                  //show failed login popup
                }
              },
              child: Text('Register'),
            ),
            SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Already have an account? Login here.'),
            ),
          ],
        ),
      ),
    );
  }
}
