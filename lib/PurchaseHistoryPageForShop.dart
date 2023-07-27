import 'package:flutter/material.dart';
import 'package:groceriery/ShopMainPage.dart';
import 'package:groceriery/UpdateProfileShop.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PurchaseHistoryForShopPage extends StatefulWidget {
  const PurchaseHistoryForShopPage({Key? key, required this.shopId})
      : super(key: key);

  final int shopId;

  @override
  _PurchaseHistoryForShopPageState createState() =>
      _PurchaseHistoryForShopPageState();
}

class _PurchaseHistoryForShopPageState
    extends State<PurchaseHistoryForShopPage> {
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  Future<void> getOrders() async {
    try {
      final response = await http
          .get(Uri.http('157.245.199.11', 'orders/all/shop/${widget.shopId}'));
      if (response.statusCode == 200) {
        setState(() {
          orders = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        // Handle failure scenario here
        setState(() {
          orders = [];
        });
      }
    } catch (error) {
      setState(() {
        orders = [];
      });
      print('Error: $error');
    }
  }

  Future<void> setPurchaseStatus(orderId, newStatus) async {
    try {
      var url = Uri.http('157.245.199.11', 'orders/$orderId');

      var orderDetails = jsonEncode({
        'newStatus': newStatus,
      });

      var response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: orderDetails,
      );

      if (response.statusCode == 200) {
        getOrders();
        Navigator.of(context).pop();
      } else {}
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> getOrderDetails(int orderId) async {
    try {
      final response =
          await http.get(Uri.http('157.245.199.11', 'orders/$orderId'));
      if (response.statusCode == 200) {
        final orderDetails = json.decode(response.body);
        // Navigate to the order details page and pass the order details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsPage(orderItems: orderDetails),
          ),
        );
      } else {
        // Handle failure scenario here
      }
    } catch (error) {
      print('Error: $error');
    }
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
          CircleAvatar(
            backgroundImage: AssetImage('assets/images/icon.png'),
            radius: 18,
          ),
          SizedBox(width: 16),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(''),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            ListTile(
              title: Text('Update Profile'),
              leading: Icon(Icons.person),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfileEditPageShop(
                          userId: widget.shopId,
                        )));
              },
            ),
            // ListTile(
            //   title: Text('Option 2'),
            //   onTap: () {
            //     // Navigate to Option 2
            //   },
            // ),
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
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey),
              ),
            ),
            child: ListTile(
              title: Text('Order Id: ${order['orderId']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payment Type: ${order['paymentMethod']}'),
                  Text('Final Price: \$${order['price'].toStringAsFixed(2)}'),
                  Text('Discount: ${order['discount']}%'),
                  Text('Commission: ${order['commission']}%'),
                  Text(
                      'Original Price: \$${order['originalPrice'].toStringAsFixed(2)}'),
                  Text('Status: ${order['status']}'),
                  Text('Customer Name: ${order['customerName']}'),
                  Text('Customer Number: ${order['customerNumber']}'),
                ],
              ),
              onTap: () {
                // getOrderDetails(order['orderId']);
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                child: Text('Delivered'),
                                onPressed: () async {
                                  setPurchaseStatus(
                                      order['orderId'], 'delivered');
                                },
                              ),
                              ElevatedButton(
                                child: Text('  Cancel  '),
                                onPressed: () async {
                                  setPurchaseStatus(
                                      order['orderId'], 'cancelled');
                                },
                              ),
                            ],
                          ),
                        ));
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: 'Product Sales',
          ),
        ],
        currentIndex: 1,
        onTap: (int index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => ShopLandingPage(
                      shopId: widget.shopId,
                    )));
          } else if (index == 1) {}
        },
      ),
    );
  }
}

class OrderDetailsPage extends StatelessWidget {
  final List<dynamic> orderItems;

  OrderDetailsPage({required this.orderItems});

  double getTotalPrice() {
    double total = 0.0;
    for (int i = 0; i < orderItems.length; i++) {
      total += orderItems[i]['price'] * orderItems[i]['amount'];
    }
    return total;
  }

  double get combinedPrice => getTotalPrice();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: orderItems.length,
        itemBuilder: (context, index) {
          final item = orderItems[index];
          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey),
              ),
            ),
            child: ListTile(
              leading: Image.memory(base64Decode(item["image"])),
              title: Text('Product Name: ${item['name']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price: \$${item['price'].toStringAsFixed(2)}'),
                  Text('Quantity: ${item['amount']}'),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 56,
          child: Center(
            child: Text(
              'Total Price: \$${combinedPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
