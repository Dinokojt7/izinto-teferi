import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pages/options/location_settings.dart';
import '../services/firebase_storage_service.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import 'texts/big_text.dart';

class SettingsPopUp extends StatefulWidget {
  const SettingsPopUp({Key? key}) : super(key: key);

  @override
  State<SettingsPopUp> createState() => _SettingsPopUpState();
}

class _SettingsPopUpState extends State<SettingsPopUp> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  late String _updateName;
  late String _updateLastName;
  late String _updatePhone;
  late String _updateEmail;
  String? address;
  int? orderHistory;
  String? subStatus;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100]!,
              borderRadius:
                  BorderRadius.all(Radius.circular(Dimensions.radius15)),
            ),
            child: TextFormField(
              validator: (val) =>
                  val!.isEmpty ? "Please enter your name" : null,
              onChanged: (val) {
                setState(() {
                  _updateName = val;
                });
              },
              keyboardType: TextInputType.text,
              obscureText: false,
              decoration: InputDecoration(
                hintText: 'Enter name',

                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                    borderSide: const BorderSide(
                      width: 1.0,
                      color: Colors.white,
                    )),
                //enabled border
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(Dimensions.radius15)),
                  borderSide: const BorderSide(
                    width: 1.0,
                    color: Colors.white,
                  ),
                ),
                //border
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
