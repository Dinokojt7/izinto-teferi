import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/order_model.dart';

class ConfirmOrder extends StatefulWidget {
  final OrderModel orderModel;
  ConfirmOrder({required this.orderModel});

  @override
  State<ConfirmOrder> createState() => _ConfirmOrderState();
}

class _ConfirmOrderState extends State<ConfirmOrder> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  CollectionReference _referenceUserInfo =
      FirebaseFirestore.instance.collection('addresses');
  late Stream<QuerySnapshot> _streamUserInfo;
  String _street = '';
  String _area = '';
  String _address = '';
  String? totalOrderAmount;
  int? orderId;
  int? _previousTotalItem;
  String? _previousTotalOrderAmount;
  String? _previousTimeStamp;
  String? _previousOrderId;

  @override
  void initState() {
    super.initState();
    _streamUserInfo = _referenceUserInfo.snapshots();
    _prefferedAddress();
    _getData();
  }

  void _prefferedAddress() async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Addresses")
        .doc('preffered address')
        .snapshots()
        .listen((userData) {
      setState(() {
        _address = userData['address'];
        _area = userData['area'];
        _street = userData['street'];
      });
    });
  }

  void _getData() async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Orders")
        .doc('current order')
        .snapshots()
        .listen((userData) {
      setState(() {
        orderId = userData['unique Id'];
        _previousTotalItem = userData['total item count'];
        _previousTotalOrderAmount = userData['total order amount'];
        _previousTimeStamp = userData['createdAt'].toString();
        _previousOrderId = userData['Order Id'];
      });
    });
  }

  SendOrderToDatabase(String? totalOrderAmount, int totalItem) async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Orders")
        .doc('current order')
        .set({
      'total order amount': totalOrderAmount,
      'total item count': totalItem,
      'Order Id': DateTime.now().toIso8601String(),
      'createdAt': Timestamp.now(),
      'unique Id': UniqueKey().hashCode,
    });
  }

  SendPreviousOrderToDatabaseOrderHistory() async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Orders")
        .doc('${orderId}')
        .set({
      'total order amount': _previousTotalOrderAmount,
      'total item count': _previousTotalItem,
      'Order Id': _previousOrderId,
      'createdAt': _previousTimeStamp,
      'unique Id': orderId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
