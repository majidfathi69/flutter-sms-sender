import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MainApp());
}

// class MainApp extends StatelessWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: Text('Hello World!'),
//         ),
//       ),
//     );
//   }
// }

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  static const platform = MethodChannel('sendSms');

  Future<Null> sendSms() async {
    if (kDebugMode) {
      print("SendSMS");
    }
    try {
      final String result = await platform.invokeMethod(
          'send', <String, dynamic>{
        "phone": "09199795867",
        "msg": "Hello! I'm sent programatically."
      }); //Replace a 'X' with 10 digit phone number
      if (kDebugMode) {
        print(result);
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          alignment: Alignment.center,
          // child: Text('sdf'),
          child: ElevatedButton(
              onPressed: () => sendSms(), child: const Text("Send SMS")),
        ),
      ),
    );
  }
}
