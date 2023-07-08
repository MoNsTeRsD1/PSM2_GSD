import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileEditPageShop extends StatefulWidget {
  const ProfileEditPageShop({Key? key, required this.userId}) : super(key: key);

  final int userId;

  @override
  _ProfileEditPageShopState createState() => _ProfileEditPageShopState();
}

class _ProfileEditPageShopState extends State<ProfileEditPageShop> {
  late String _name;
  late String _phoneNumber;
  late String _password;
  late String _description;

  Future<void> updateUserProfile() async {
    try {
      final response = await http.put(
        Uri.http('157.245.199.11', 'users/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _name,
          'phoneNumber': _phoneNumber,
          'password': _password,
          'description': _description,
          'type': 1,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.of(context).pop();
      } else {
        // Handle other status codes here
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _name = '';
    _phoneNumber = '';
    _password = '';
    _description = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              onChanged: (value) {
                setState(() {
                  _name = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  _password = value;
                });
              },
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  _phoneNumber = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Phone Number',
              ),
            ),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  _description = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'description',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                updateUserProfile();
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
