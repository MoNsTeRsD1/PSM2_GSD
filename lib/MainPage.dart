import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:groceriery/Cart.dart';
import 'package:groceriery/PurchaseHistoryPage.dart';
import 'package:groceriery/UpdateProfile.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'Shop.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.userId}) : super(key: key);

  final int userId;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<dynamic> shops = [];
  List<dynamic> filteredShops = [];

  dynamic user;

  get welcomeText {
    String welcomeText = "";
    if (user != null) {
      welcomeText = "Welcome ${user['name']}!";
    }
    return welcomeText;
  }

  List<String> _bannerImages = [
    'assets/images/1.jpg',
    'assets/images/2.jpg',
    'assets/images/3.jpg',
  ];

  int currentPageIndex = 0;
  late Timer timer;
  final pageController = PageController();

  @override
  void initState() {
    super.initState();
    getUserData();
    getShopData();
    startTimer();
  }

  @override
  void dispose() {
    timer.cancel();
    pageController.dispose();
    super.dispose();
  }

  Future<void> getShopData() async {
    try {
      var url = Uri.http('157.245.199.11', 'users/shops');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          shops = json.decode(response.body);
          filteredShops = shops;
        });
      } else {
        throw Exception('Failed to load shops');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void filterShops(String searchInput) {
    setState(() {
      filteredShops = shops
          .where((item) => item['name']
              .toString()
              .toLowerCase()
              .contains(searchInput.toLowerCase()))
          .toList();
    });
  }

  Future<void> getUserData() async {
    try {
      var url = Uri.http('157.245.199.11', 'users/${widget.userId}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          user = json.decode(response.body);
          // print("user: $user");
        });
      } else {
        throw Exception('Failed to load shops');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (currentPageIndex < _bannerImages.length - 1) {
        currentPageIndex++;
      } else {
        currentPageIndex = 0;
      }
      pageController.animateToPage(
        currentPageIndex,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    });
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
            // NetworkImage('https://picsum.photos/id/237/200/200'),
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
              title: Text('Profile'),
              leading: Icon(Icons.person),
              onTap: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileEditPage(userId: widget.userId),
                  ),
                )
                    .then((value) {
                  getUserData();
                });
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
      body: Column(
        children: [
          Container(
            height: 50,
            child: Text(welcomeText),
            alignment: Alignment.center,
          ),
          Container(
            height: 180,
            child: PageView.builder(
              controller: pageController,
              itemCount: _bannerImages.length,
              onPageChanged: (index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              itemBuilder: (BuildContext context, int index) {
                return Image.asset(
                  _bannerImages[index],
                  fit: BoxFit.fill,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageIndicator(),
            ),
          ),
          TextField(
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
              filterShops(value);
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredShops.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.store),
                    ),
                    title: Text('${filteredShops[index]["name"]}'),
                    subtitle: Text(filteredShops[index]["description"]),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShopPage(
                            shopId: filteredShops[index]["id"],
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
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
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => PurchaseHistoryPage(
                      userId: widget.userId,
                    )));
          }
        },
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];

    for (int i = 0; i < _bannerImages.length; i++) {
      indicators.add(
        Container(
          width: 8.0,
          height: 8.0,
          margin: EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentPageIndex == i ? Colors.blue : Colors.grey,
          ),
        ),
      );
    }

    return indicators;
  }
}
