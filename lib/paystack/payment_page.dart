import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:izinto/paystack/paystack_autoresponse.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../transaction/trasnaction_model.dart';
import '../utils/app_constants.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({
    Key? key,
    required this.amount,
    required this.reference,
    required this.type,
    required this.switchValues,
    required this.index,
  }) : super(key: key);
  final String amount;
  final int index;
  final ValueNotifier<String> reference;
  final String type;
  final ValueNotifier<List<bool>> switchValues;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String publicKeyTest = AppConstants.THE_HILL;
  String reference = '';
  bool _isShowLoader = false;
  String email = '';
  String _getReference() {
    var platform = (Platform.isIOS) ? 'iOS' : 'Android';
    final thisDate = DateTime.now().millisecondsSinceEpoch;
    return 'ChargedFrom${platform}_$thisDate-';
  }

  String orderNumber = UniqueKey().hashCode.toString();
  final _random = Random();
  final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  @override
  void initState() {
    _getData();
    final randomLetters = letters[_random.nextInt(letters.length)] +
        letters[_random.nextInt(letters.length)];
    String referenceFormatted =
        randomLetters + orderNumber.substring(orderNumber.length - 2);
    reference = _getReference() + referenceFormatted;

    Future.delayed(const Duration(seconds: 10), () {
      passReference();
    });

    super.initState();
  }

  // Here we create the transaction
  Future<PayStackAuthResponse> createTransaction(Transact transaction) async {
    const String url = 'https://api.paystack.co/transaction/initialize';
    final data = transaction.toJson();

    try {
      final response = await http.post(Uri.parse(url),
          headers: {
            'Authorization': 'Bearer ${publicKeyTest}',
            'Content-type': 'application/json'
          },
          body: jsonEncode(data));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        return PayStackAuthResponse.fromJson(responseData['data']);
      } else {
        throw 'Payment not initiated';
      }
    } on Exception {
      throw 'Payment unsuccessful';
    }
  }

  _getData() async {
    User? user = await _firebaseAuth.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots()
        .listen((userData) {
      if (mounted)
        setState(() {
          email = userData['email'];
          //_subStatus = userData['subStatus'];
        });
    });
    return;
  }

  Future<String> initializeTransaction() async {
    try {
      final price = double.parse('${widget.amount}') * 100;
      final transaction = Transact(
          amount: price.toString(),
          reference: reference,
          currency: 'ZAR',
          email: email);

      final authResponse = await createTransaction(transaction);
      setState(() {
        widget.reference.value = reference;
      });
      return authResponse.authorization_url;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> _verifyOnServer(String reference) async {
    const String url = 'https://api.paystack.co/transaction/verify/';
    while (true) {
      try {
        Map<String, String> headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${publicKeyTest}'
        };
        http.Response response =
            await http.get(Uri.parse(url + reference), headers: headers);

        final Map body = json.decode(response.body);
        // print('Check response: ${response.statusCode} of ${response.body}');
        final String status = body['data']['status'];
        if (response.statusCode == 200) {
          return status;
          break;
        }
      } catch (e) {
        // print('This is the problem: $e');
        // return '$e';

        return 'awaiting payment';
      }
      // Pause for a short duration before making the next request
      await Future.delayed(Duration(seconds: 5));
    }
  }

  updateConfirmation(status) async {
    Map<String, dynamic> updateInitialized = {
      '${widget.type} initialized': status,
    };
    User? user = await _firebaseAuth.currentUser;
    // Convert the list to a map

    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .update(updateInitialized);
  }

  passReference() async {
    Map<String, dynamic> updateReference = {
      '${widget.type} reference': reference,
    };
    User? user = await _firebaseAuth.currentUser;
    // Convert the list to a map

    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .update(updateReference);
  }

  sendSubscription() async {
    DateTime orderTime = DateTime.now();
    //final int amount = widget.amount;
    final String type = widget.type;
    Map<String, dynamic> newSubscription = {
      type: type == 'Laundry' ? 60 : 18,
      'Date of $type subscription': orderTime
    };
    User? user = await _firebaseAuth.currentUser;
    // Convert the list to a map

    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .update(newSubscription);
  }

  showExitConfirmationDialog(
    BuildContext,
    reference,
  ) async {
    setState(() {
      _isShowLoader = true;
    });
    final String verify = await _verifyOnServer(reference);
    if (verify == 'success') {
      sendSubscription();
      updateConfirmation(2);
      //  Provider.of<CartViewController>(context, listen: false).showDialog();
    } else {
      updateConfirmation(0);
      //  Provider.of<CartViewController>(context, listen: false).showDialog();
      setState(() {
        widget.switchValues.value[widget.index] = false;
      });
    }
  }

  // late WebViewPlusController controller;

  Future<String> pollForResult() async {
    const server2Endpoint = 'https://your-server2-endpoint/result';

    while (true) {
      try {
        // Make a request to server2 to get the result
        final response = await http.get(Uri.parse(server2Endpoint));

        if (response.statusCode == 200) {
          // Parse and update the result only if the reference matches
          final result = response.body;
          final reference = jsonDecode(result)['reference'];

          if (reference == this.reference) {
            return reference;

            // Stop polling if the result is available
            break;
          }
        }
      } catch (e) {
        return 'awaiting payment';
      }

      // Pause for a short duration before making the next request
      await Future.delayed(Duration(seconds: 5));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await showExitConfirmationDialog(context, reference);
        bool shouldPop = true;

        return shouldPop;
      },
      child: Scaffold(
        body: SafeArea(
            child: FutureBuilder(
                future: initializeTransaction(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final url = snapshot.data;
                    return Stack(
                      children: [
                        // WebViewPlus(
                        //   initialUrl: url.toString(),
                        //   javascriptMode: JavascriptMode.unrestricted,
                        //   onWebViewCreated: (controller) {
                        //     this.controller = controller;
                        //   },
                        //   // onPageFinished: (String url) {
                        //   // Inject JavaScript code to interact with the page
                        //   // controller.evaluateJavascript(
                        //   // Find the "Cancel Payment" button and add a click event listener
                        //   // var cancelButton = document.querySelector('[name="cancel payment"]');
                        //   // if (cancelButton) {
                        //   //   cancelButton.addEventListener('click', function() {
                        //   //     // Handle the click event
                        //   //     // You can communicate with Flutter here or perform other actions
                        //   //     // For example, pop the current screen
                        //   //     window.flutter_inappwebview.callHandler('cancelPayment', null);
                        //   //   });
                        //   // }
                        // ),
                        _isShowLoader
                            ? Dialog(
                                elevation: 0,
                                insetPadding: EdgeInsets.all(0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      child: Center(
                                          child: CircularProgressIndicator(
                                        color: const Color(0xffB09B71),
                                      )),
                                    )
                                  ],
                                ),
                              )
                            : Container()
                      ],
                    );
                  } else {
                    return Dialog(
                      elevation: 0,
                      insetPadding: EdgeInsets.all(0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Center(
                                child: CircularProgressIndicator(
                              color: const Color(0xffB09B71),
                            )),
                          )
                        ],
                      ),
                    );
                  }
                })),
      ),
    );
  }
}
