import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groceriery/AdminPage.dart';
import 'package:groceriery/MainPage.dart';
import 'package:groceriery/ShopMainPage.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
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

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _email;
  late String _password;

  Future<UserObject?> login() async {
    Map<String, String> customHeaders = {"content-type": "application/json"};

    var url = Uri.http('157.245.199.11', 'users/login');
    var response = await http.post(url,
        headers: customHeaders,
        body: jsonEncode({'email': '$_email', 'password': '$_password'}));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
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
        title: Text("Grocery Store Login"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 24.0),
                Image.asset(
                  'assets/images/groceriery.png',
                  height: 200.0,
                ),
                SizedBox(height: 24.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    _email = value!;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    _password = value!;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  child: Text('Login'),
                  onPressed: loginPressed,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor:
                          Theme.of(context).colorScheme.primaryContainer),
                ),
                SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  child: Text('Don\'t have an account? Register here.'),
                  style: TextButton.styleFrom(
                    primary: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loginPressed() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // TODO: Handle login logic
      // Navigator.pushReplacementNamed(context, '/main');
      var user = await login();
      print(user);
      if (user != null) {
        if (user.type == 0) {
          //edit this later to pass user object

          // await storage.write(key: 'user', value: jsonEncode(user));
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => MainPage(userId: user.id)));

          // Navigator.of(context).pushReplacementNamed('/main');
          // Navigator.pushReplacementNamed(context, '/main');
        } else if (user.type == 1) {
          //edit this later to pass user object
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => ShopLandingPage(shopId: user.id)));

          // Navigator.pushReplacementNamed(context, '/shopMain');
        } else if (user.type == 2) {
          //edit this later to pass user object
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => AdminLandingPage()));

          // Navigator.pushReplacementNamed(context, '/main');
        }
      } else {
        //show failed login popup
      }
    }
  }
}
