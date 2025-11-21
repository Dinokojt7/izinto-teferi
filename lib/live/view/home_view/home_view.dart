import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:izinto/live/view/home_view/view_widgets/main_scaffold.dart';
import 'package:provider/provider.dart';
import '../profile_view/controller/profile_view_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    _loadUserDataImmediately();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadUserDataImmediately() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists) {
          final controller =
              Provider.of<ProfileViewController>(context, listen: false);
          controller.updateNewUser(
              userData['name'] ?? '',
              userData['surname'] ?? '',
              userData['email'] ?? '',
              userData['phone'] ?? '',
              userData['telephoneSurveyConsent'] ?? false,
              userData['emailMarketingConsent'] ?? false,
              userData['wallet'] ?? 0);
        }
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold();
  }
}
