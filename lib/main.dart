import 'package:flutter/material.dart';
// import 'package:groceriery/ShopMainPage.dart';

import 'Login.dart';
import 'Register.dart';
// import 'MainPage.dart';

import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      "pk_test_51NND6OKVIPYspFS5bxGDaTiFDeG7V3AoZQwOOmtyUFbinmWDheWWlrPQt4fOi6tflnifrCASL0dNMnMoTV7ifeTj00SEF75XaW";
  Stripe.merchantIdentifier = 'shop';
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        // useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegistrationPage(),
        // '/main': (context) => MainPage(),
        // '/shopMain': (context) => ShopLandingPage(),
      },
    );
  }
}

























// import 'package:flutter/material.dart';
// import 'router.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Groceriery',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       initialRoute: "/main",
//       onGenerateRoute: CustomRouter.generateRoute,
//     );
//   }
// }