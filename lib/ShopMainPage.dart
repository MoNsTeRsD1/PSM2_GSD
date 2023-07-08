import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:groceriery/PurchaseHistoryPageForShop.dart';
import 'package:groceriery/UpdateProfileShop.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/widgets.dart';

class ShopLandingPage extends StatefulWidget {
  const ShopLandingPage({Key? key, required this.shopId}) : super(key: key);
  final int shopId;

  @override
  State<ShopLandingPage> createState() => _ShopLandingPageState();
}

class _ShopLandingPageState extends State<ShopLandingPage> {
  List<dynamic> products = [];
  XFile? _imageFile;
  String? _encodedImage;
  dynamic user;

  @override
  void initState() {
    super.initState();
    getShopData();
    getShops();
  }

  Future _selectImage() async {
    final permissionStatus = await Permission.storage.status;
    if (permissionStatus.isDenied) {
      await Permission.storage.request();

      if (permissionStatus.isDenied) {
        await openAppSettings();
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      final picker = ImagePicker();
      final pickedImage =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 5);
      if (pickedImage == null) return;
      final bytes = await pickedImage.readAsBytes();
      final encodedImage = base64Encode(bytes);
      setState(() {
        _imageFile = pickedImage;
        _encodedImage = encodedImage;
      });
    }
  }

  Future<void> getShops() async {
    // print('${widget.shopId}');
    try {
      var url = Uri.http('157.245.199.11', 'products/shop/${widget.shopId}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load shops');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  ////////////////////
  ///
  ///
  ///////////////////

  void deleteProduct(int index, int productId) async {
    // Remove the product from the list and update the UI
    setState(() {
      products.removeAt(index);
      _imageFile = null;
      _encodedImage = null;
      setState(() {});
    });

    final url = Uri.http('157.245.199.11', 'products/$productId');
    final response = await http.delete(url);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product deleted successfully.'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      // Add the deleted product back to the list
      setState(() {
        products.insert(index, products);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete product.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void addProduct(dynamic nameController, dynamic priceController) async {
    final newProduct = {
      'name': nameController.text,
      'image': _encodedImage != null ? _encodedImage : '',
      'price': double.parse(priceController.text),
      'shopId': widget.shopId,
    };
    // setState(() {
    //   products.add(newProduct);
    // });

    Navigator.pop(context);
    final url = Uri.http('157.245.199.11', 'products');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newProduct));
    if (response.statusCode != 201) {
      setState(() {
        products.removeLast();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to add product.'),
          duration: Duration(seconds: 3)));
    } else {
      getShops();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Product added successfully.'),
          duration: Duration(seconds: 3)));
    }
  }

  void editProduct(dynamic product, dynamic nameController,
      dynamic priceController, index) async {
    final updatedProduct = {
      'id': product['id'],
      'name': nameController.text,
      'image': _encodedImage != null ? _encodedImage : product['image'],
      'price': double.parse(priceController.text),
      'shopId': widget.shopId,
    };
    setState(() {
      products[index] = updatedProduct;
    });
    Navigator.pop(context);
    final url = Uri.http('157.245.199.11', 'products/${product['id']}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedProduct),
    );
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update product.'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product updated successfully.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> getShopData() async {
    try {
      var url = Uri.http('157.245.199.11', 'users/shops/${widget.shopId}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          user = json.decode(response.body);
          print("user: $user");
        });
      } else {
        throw Exception('Failed to load shop data');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  get welcomeText {
    String welcomeText = "";
    if (user != null) {
      welcomeText = "Shop ${user['name']}'s Listed Items'";
    }
    return welcomeText;
  }

  void showAddProductDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _selectImage();
                  setState(() {});
                },
                child: Text('Select Image'),
              ),
              SizedBox(height: 16),
              if (_imageFile != null)
                SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.file(
                      File(
                        _imageFile!.path,
                      ),
                      fit: BoxFit.cover,
                    )),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                _imageFile = null;
                _encodedImage = null;
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () async {
                addProduct(nameController, priceController);
                _imageFile = null;
                _encodedImage = null;
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  //

  void showEditProductDialog(int index, Map<String, dynamic> product) {
    final TextEditingController nameController =
        TextEditingController(text: product['name']);
    final TextEditingController priceController =
        TextEditingController(text: product['price'].toString());
    _encodedImage = product['image'];
    setState(() {});

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _selectImage();
                  setState(() {});
                },
                child: Text('Select Image'),
              ),
              SizedBox(height: 16),
              if (_encodedImage != null)
                SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.memory(base64Decode(_encodedImage!))
                    // Image.file(
                    //   File(
                    //     _imageFile!.path,
                    //   ),
                    //   fit: BoxFit.cover,
                    // ),
                    ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                _imageFile = null;
                _encodedImage = null;
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                editProduct(product, nameController, priceController, index);
                _imageFile = null;
                _encodedImage = null;
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  //

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
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => ProfileEditPageShop(
                              userId: widget.shopId,
                            )))
                    .then((value) {
                  getShopData();
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
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey),
              ),
            ),
            height: 50,
            child: Text(
              welcomeText,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            alignment: Alignment.center,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                final product = products[index];
                return Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: ListTile(
                    leading: SizedBox(
                      child: Image.memory(base64Decode(product["image"])),
                    ),
                    title: Text(product["name"]),
                    subtitle: Text(product["price"].toString()),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(product["name"]),
                            content: Text(product["price"].toString()),
                            actions: [
                              TextButton(
                                child: Text('Edit'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  // Navigate to edit product page
                                  showEditProductDialog(index, product);
                                },
                              ),
                              TextButton(
                                child: Text('Delete'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  // Delete product from list and update UI
                                  deleteProduct(index, product['id']);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showAddProductDialog();
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
        currentIndex: 0,
        onTap: (int index) {
          if (index == 0) {
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => PurchaseHistoryForShopPage(
                      shopId: widget.shopId,
                    )));
          }
        },
      ),
    );
  }
}
