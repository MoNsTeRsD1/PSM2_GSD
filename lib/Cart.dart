import 'package:flutter/material.dart';
import 'package:groceriery/PurchaseHistoryPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:stripe_payment/stripe_payment.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key, required this.userId}) : super(key: key);

  final int userId;

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> cartItems = [];

  String couponCode = '';

  // List<dynamic> cartItems = [
  //   {
  //     "name": "item 1",
  //     "amount": 3,
  //     "price": 25,
  //     "image": "https://picsum.photos/id/237/200/300"
  //   },
  //   {
  //     "name": "item 2",
  //     "amount": 2,
  //     "price": 35,
  //     "image": "https://picsum.photos/id/237/200/300"
  //   },
  //   {
  //     "name": "item 3",
  //     "amount": 1,
  //     "price": 41,
  //     "image": "https://picsum.photos/id/237/200/300"
  //   },
  //   {
  //     "name": "item 4",
  //     "amount": 1,
  //     "price": 12,
  //     "image": "https://picsum.photos/id/237/200/300"
  //   },
  // ];

  // code is the code used to activate the discount
  // rate is how much percent is discounted
  List<dynamic> discountCodes = [
    {
      "code": "50less",
      "rate": 50,
    },
    {
      "code": "20less",
      "rate": 20,
    },
    {
      "code": "10less",
      "rate": 10,
    },
  ];

  void initializeStripe() async {
    Stripe.publishableKey =
        "pk_test_51NND6OKVIPYspFS5bxGDaTiFDeG7V3AoZQwOOmtyUFbinmWDheWWlrPQt4fOi6tflnifrCASL0dNMnMoTV7ifeTj00SEF75XaW";
    Stripe.merchantIdentifier = 'any string works';
    await Stripe.instance.applySettings();
  }

  // Future<void> initiatePayment() async {
  //   try {
  //     PaymentMethod paymentMethod =
  //         await StripePayment.paymentRequestWithCardForm(
  //       CardFormPaymentRequest(),
  //     );

  //     bool success = await processPayment(paymentMethod.id!);

  //     if (success) {
  //       // Payment was successful, send a POST request to the backend
  //       await sendPaymentDetailsToBackend(paymentMethod.id!);

  //       showSuccessDialog();
  //     } else {
  //       // Payment failed, show an error message to the user
  //       showErrorDialog('An error occurred during the transaction process.');
  //     }
  //   } catch (error) {
  //     print('Error: $error');
  //     // Show an error message to the user
  //     showErrorDialog('An error occurred during the transaction process.');
  //   }
  // }
  @override
  void initState() {
    super.initState();
    getCartItems();
    getUserData();
    // initializeStripe();
  }

  Future<void> getCartItems() async {
    try {
      final response = await http
          .get(Uri.http('157.245.199.11', 'cart/user/${widget.userId}'));

      if (response.statusCode == 200) {
        setState(() {
          cartItems = json.decode(response.body);
        });
      } else {
        // Handle failure scenario here
        setState(() {
          cartItems = [];
        });
      }
    } catch (error) {
      setState(() {
        cartItems = [];
      });
      print('Error: $error');
    }
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

  Future<void> updateCartItem(cartItemId, amount) async {
    try {
      Map<String, String> customHeaders = {"content-type": "application/json"};
      var url = Uri.http('157.245.199.11', 'cart/${cartItemId}');

      var response = await http.put(url,
          headers: customHeaders,
          body: jsonEncode({'amount': amount, 'userId': widget.userId}));

      if (response.statusCode == 200) {
        getCartItems();
      } else {
        // Handle failure scenario here
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> deleteCartItem(cartItemId) async {
    try {
      var url = Uri.http('157.245.199.11', 'cart/${cartItemId}');
      var response = await http.delete(url);

      if (response.statusCode == 200) {
        getCartItems();
      } else {
        // Handle failure scenario here
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  double getTotalPrice() {
    double total = 0.0;
    for (int i = 0; i < cartItems.length; i++) {
      total += cartItems[i]['price'] * cartItems[i]['amount'];
    }
    return total;
  }

  double get combinedPrice => getTotalPrice();

  int discountAmount = 0;

  double getDiscountPrice() {
    double discountMultiplier = 1;
    bool discountAmountSet = false;
    for (int i = 0; i < discountCodes.length; i++) {
      if (couponCode == discountCodes[i]["code"]) {
        discountMultiplier = (1 - (discountCodes[i]["rate"] / 100)) as double;
        discountAmountSet = true;
      }
      if (discountAmountSet) {
        setState(() {
          discountAmount = discountCodes[i]["rate"];
        });
      } else {
        setState(() {
          discountAmount = 0;
        });
      }
    }
    print("discount: ${discountAmount}");
    return combinedPrice * discountMultiplier;
  }

  double get discountPrice => getDiscountPrice();

  var paymentIntent;

  Future<void> makePayment() async {
    try {
      //STEP 1: Create Payment Intent
      paymentIntent =
          await createPaymentIntent('${discountPrice.toInt() * 100}', 'USD');

      print("// payment intent created");

      //STEP 2: Initialize Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent!['client_secret'],
            customerId: null,
            customFlow: true,
            style: ThemeMode.dark,
            merchantDisplayName: 'Shop Name',
          ))
          .then((value) {});

      print("// inastance created ");

      //STEP 3: Display Payment sheet
      displayPaymentSheet();
    } catch (err) {
      throw Exception(err);
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer sk_test_51NND6OKVIPYspFS5ho5Ra6PZ3P9cwkwbTUJ76pNfSMUnTwbMUm3CZxQQ7Fj13r4YfMLfjZPoy9YtxyMhKvO0LsSh00Xv4s270d',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        sendPaymentDetailsToBackend();
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 100.0,
                      ),
                      SizedBox(height: 10.0),
                      Text("Payment Successful!"),
                    ],
                  ),
                ));
        paymentIntent = null;
      }).onError((error, stackTrace) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.cancel,
                        color: Colors.red,
                        size: 100.0,
                      ),
                      SizedBox(height: 10.0),
                      Text("Payment Failed"),
                    ],
                  ),
                ));
        throw Exception(error);
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                Text("Payment Failed"),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      print('$e');
    }

    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => PurchaseHistoryPage(userId: widget.userId)));
    });
  }

  dynamic user;

  get cartText {
    String cartText = "";
    if (user != null) {
      cartText = "${user['name']}'s cart";
    }
    return cartText;
  }

  Future<bool> processPayment(String paymentMethodId) async {
    // For demonstration purposes, we'll simulate a successful payment
    return true;
  }

  Future<void> sendPaymentDetailsToBackend() async {
    try {
      var url = Uri.http('157.245.199.11', 'orders');

      var orderDetails = jsonEncode({
        'userId': widget.userId,
        'discount': discountAmount,
      });

      // print("Order Details: $orderDetails");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: orderDetails,
      );

      if (response.statusCode == 201) {
        getCartItems();
      } else {}
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
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Perform notification action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey),
                bottom: BorderSide(color: Colors.grey),
              ),
            ),
            width: double.infinity,
            height: 70,
            child: Text(
              cartText,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            alignment: Alignment.center,
          ),
          Flexible(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (BuildContext context, int index) {
                final item = cartItems[index];
                final totalPrice = item['amount'] * item['price'];

                return Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: Image.memory(base64Decode(item["image"])),
                      title: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('\$${item['price'].toStringAsFixed(2)}'),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  bool delete = false;
                                  setState(() {
                                    if (item['amount'] > 1) {
                                      item['amount']--;
                                    } else {
                                      delete = true;
                                    }
                                  });

                                  // Send PUT request to update the item quantity in the backend
                                  if (delete) {
                                    deleteCartItem(item['cartItemId']);
                                  } else {
                                    updateCartItem(
                                        item['cartItemId'], item['amount']);
                                  }
                                },
                              ),
                              Text(item['amount'].toString()),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    item['amount']++;
                                  });
                                  // Send PUT request to update the item quantity in the backend
                                  updateCartItem(
                                      item['cartItemId'], item['amount']);
                                },
                              ),
                            ],
                          ),
                          SizedBox(width: 64),
                          Text('\$${totalPrice.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Coupon Bar
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Coupon Code',
                    ),
                    onChanged: (value) {
                      setState(() {
                        couponCode = value;
                      });
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  child: Text('Apply'),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Total Price: \$${discountPrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  // Perform purchase action
                  makePayment();
                },
                child: Text('Purchase'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
