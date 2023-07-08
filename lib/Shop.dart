import 'package:flutter/material.dart';
import 'package:groceriery/Cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key, required this.shopId, required this.userId})
      : super(key: key);

  final int shopId;
  final int userId;

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  List<dynamic> shopItems = [];
  List<dynamic> filteredItems = [];

  @override
  void initState() {
    super.initState();
    getShopItems();
  }

  Future<void> getShopItems() async {
    try {
      final response = await http
          .get(Uri.http('157.245.199.11', 'products/shop/${widget.shopId}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> items = [];
        for (var item in data) {
          items.add(item);
        }
        setState(() {
          shopItems = items;
          filteredItems = items;
        });
      } else {
        throw Exception('Failed to fetch shop items');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void filterItems(String searchInput) {
    setState(() {
      filteredItems = shopItems
          .where((item) => item['name']
              .toString()
              .toLowerCase()
              .contains(searchInput.toLowerCase()))
          .toList();
    });
  }

  String dropdownValue =
      'Price Ascending'; // Selected value in the drop-down menu

  void reorderItems(String newValue) {
    setState(() {
      dropdownValue = newValue;
      if (dropdownValue == 'Price Ascending') {
        filteredItems.sort((a, b) => a['price'].compareTo(b['price']));
      } else if (dropdownValue == 'Name') {
        filteredItems.sort((a, b) => a['name'].compareTo(b['name']));
      } else if (dropdownValue == 'Price Descending') {
        filteredItems.sort((a, b) => b['price'].compareTo(a['price']));
      }
    });
  }

  Future<void> addCartItem(productId, amount) async {
    try {
      Map<String, String> customHeaders = {"content-type": "application/json"};
      var url = Uri.http('157.245.199.11', 'cart');

      var response = await http.post(url,
          headers: customHeaders,
          body: jsonEncode({
            'productId': productId,
            'amount': amount,
            'userId': widget.userId
          }));

      if (response.statusCode == 201) {
        // show success pop up
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CartPage(
                  userId: widget.userId,
                )));
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: AssetImage('assets/images/icon.png'),
              radius: 18,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                filterItems(value);
              },
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: DropdownButton<String>(
                  value: 'Price Ascending',
                  icon: Icon(Icons.keyboard_arrow_down),
                  iconSize: 24,
                  elevation: 16,
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurple,
                  ),
                  onChanged: (String? newValue) {
                    reorderItems(newValue!);
                  },
                  items: <String>['Price Ascending', 'Price Descending', 'Name']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              // IconButton(
              //   icon: Icon(Icons.filter_list),
              //   onPressed: () {},
              // ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (BuildContext context, int index) {
                final item = filteredItems[index];

                return Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey),
                      bottom: BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                    leading: SizedBox(
                      child: Image.memory(
                        base64Decode(item["image"]),
                      ),
                      width: 75,
                    ),
                    title: Text(item["name"]),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item["description"]),
                        TextButton(
                          onPressed: () {
                            addCartItem(item["id"], 1);
                          },
                          child: Text('Add to cart'),
                        ),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 50.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.favorite,
                            // color: Colors.red,
                          ),
                          SizedBox(height: 8.0),
                          Text('\$${item["price"].toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'History',
          ),
        ],
        currentIndex: 0,
        onTap: (int index) {
          if (index == 0) {
          } else if (index == 1) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CartPage(
                      userId: widget.userId,
                    )));
          } else if (index == 2) {}
        },
      ),
    );
  }
}
