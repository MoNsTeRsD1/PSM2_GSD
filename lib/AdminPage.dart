import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminLandingPage extends StatefulWidget {
  @override
  _AdminLandingPageState createState() => _AdminLandingPageState();
}

class _AdminLandingPageState extends State<AdminLandingPage> {
  List<dynamic> acceptedShops = [];
  List<dynamic> pendingShops = [];
  dynamic _revenue;
  double get revenue => (_revenue != null) ? _revenue.toDouble() : 0.0;
  set revenue(val) {
    _revenue = val;
  }

  @override
  void initState() {
    super.initState();
    getShops();
    getRevenue();
  }

  Future<void> getShops() async {
    try {
      final response =
          await http.get(Uri.http('157.245.199.11', 'users/shopsAdmin'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          acceptedShops = List<dynamic>.from(
              data.where((i) => i["shopStatus"] == 'active').toList());
          pendingShops = List<dynamic>.from(
              data.where((i) => i["shopStatus"] == 'pending').toList());
        });
      } else {
        throw Exception('Failed to fetch shop data');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> getRevenue() async {
    try {
      final response =
          await http.get(Uri.http('157.245.199.11', 'orders/adminRevenue'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          revenue = data['revenue'];
        });
      } else {
        throw Exception('Failed to get admin revenue');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> deleteShop(
    int index,
  ) async {
    final shopId = acceptedShops[index]["id"];
    try {
      final response =
          await http.delete(Uri.http('157.245.199.11', 'users/$shopId'));
      if (response.statusCode == 200) {
        setState(() {
          acceptedShops.removeAt(index);
        });
        print('Shop deleted successfully');
      } else {
        throw Exception('Failed to delete shop');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> acceptShop(int index) async {
    final shopId = pendingShops[index]["id"];
    final updateContent = {"newStatus": "active"};

    try {
      final response = await http.put(
        Uri.http('157.245.199.11', 'users/shops/$shopId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updateContent),
      );
      if (response.statusCode == 200) {
        setState(() {
          acceptedShops.add(pendingShops[index]);
          pendingShops.removeAt(index);
        });
        print('Shop accepted successfully');
      } else {
        throw Exception('Failed to accept shop');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> rejectShop(int index) async {
    final shopId = pendingShops[index]["id"];
    final updateContent = {"newStatus": "inactive"};
    try {
      final response = await http.put(
        Uri.http('157.245.199.11', 'users/shops/$shopId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updateContent),
      );
      if (response.statusCode == 200) {
        setState(() {
          pendingShops.removeAt(index);
        });
        print('Shop rejected successfully');
      } else {
        throw Exception('Failed to reject shop');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void _showNotificationsPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Shop Requests'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(pendingShops.length, (index) {
              final shopName = pendingShops[index]["name"];
              return ListTile(
                leading: Icon(Icons.shop),
                title: Text(shopName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        acceptShop(index);
                        Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        rejectShop(index);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: _showNotificationsPopup,
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Admin Menu'),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              ListTile(
                title: Text('Logout'),
                leading: Icon(Icons.logout),
                onTap: () {
                  // Perform logout
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
        body: Column(children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey),
              ),
            ),
            height: 50,
            child: Text(
              'Total Revenue: \$${revenue.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            alignment: Alignment.center,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: acceptedShops.length,
              itemBuilder: (BuildContext context, int index) {
                final shopName = acceptedShops[index]["name"];
                return ListTile(
                  leading: Icon(Icons.shop),
                  title: Text(shopName),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteShop(index);
                    },
                  ),
                );
              },
            ),
          )
        ]));
  }
}
