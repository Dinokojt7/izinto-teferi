import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:izinto/controllers/auth/auth_provider.dart';
import 'package:izinto/controllers/cart_controller.dart';
import 'package:izinto/live/wrapper.dart';
import 'package:izinto/pages/options/location_settings.dart';
import 'package:izinto/pages/options/view_tokens.dart';
import 'package:izinto/utils/colors.dart';
import 'package:izinto/widgets/texts/integers_and_doubles.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';
import '../../models/user.dart';
import '../../services/firebase_auth_methods.dart';
import '../../services/map_function.dart';
import '../../services/phone_auth_methods.dart';
import '../../utils/dimensions.dart';
import '../../widgets/dialogs/token_display/token_status_dialog.dart';
import '../../widgets/display_tokens.dart';
import '../../widgets/dialogs/main_dialog.dart';
import '../../widgets/miscellaneous/app_icon.dart';
import '../../widgets/texts/big_text.dart';
import '../../widgets/texts/small_text.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({Key? key, this.isPhoneAuth}) : super(key: key);

  final bool? isPhoneAuth;

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  String? location = 'Null, Press Button';
  String? _address = '';
  bool isLoading = false;
  String _name = 'Enter name';
  String _email = 'Enter email';
  String _surname = 'Enter surname';
  String _phone = 'Enter number';
  String? _admin;
  String? _country;
  String? _zipCode;
  String? _street = '';
  String? _area = '';
  String street = '17 Autumn Rd';
  String area = 'Rivonia';
  String address = 'Edenburg';
  String subStatus = '';
  double iTokens = 0.0;
  late String _updateName;
  String? _updateLastName;
  String? _updatePhone;
  String? _updateEmail;
  String error = '';
  String imageUrl = '';
  CollectionReference _referenceUserInfo =
      FirebaseFirestore.instance.collection('users');
  late Stream<QuerySnapshot> _streamUserInfo;
  //bool _showDialog = false;
  final _showDialog = ValueNotifier<bool>(false);
  bool fromRegistration = false;

  var emailController = TextEditingController();
  var nameController = TextEditingController();
  var phoneController = TextEditingController();
  var surnameController = TextEditingController();
  var areaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (_name == '') {
      setState(() {
        fromRegistration = true;
      });
    }

    _streamUserInfo = _referenceUserInfo.snapshots();
    _getData();
    _prefferedAddress();
    widget.isPhoneAuth! ? storeData() : null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _alertUserOfOutstandingDependencies() {
    if (_name == '' ||
        _name == 'Guest user' ||
        _surname == '' ||
        _phone == '' ||
        _email == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 4),
          elevation: 0,
          backgroundColor: Color(0xff9A9484).withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          content: Text('Please fill all the required fields'),
        ),
      );
    } else if (_street == '17 Autumn Rd') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 4),
          elevation: 0,
          backgroundColor: Color(0xff9A9484).withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          content: Text('Please set your address'),
          action: SnackBarAction(
            label: 'EDIT',
            disabledTextColor: Colors.white,
            textColor: Colors.white,
            onPressed: () {
              Get.to(() => const LocationSettings(),
                  transition: Transition.fade, duration: Duration(seconds: 1));
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 4),
          elevation: 0,
          backgroundColor: Color(0xff9A9484).withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          content: Text('Email address is not valid'),
        ),
      );
    }
  }

  bool isEmail(String input) {
    // Regular expression for validating an email address
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(input);
  }

  void _getData() async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots()
        .listen((userData) {
      if (mounted)
        setState(() {
          _name = userData['name'];
          _phone = userData['phone'];
          _surname = userData['surname'];
          _email = userData['email'];
          iTokens = userData['loyalty'];
        });
    });
  }

  void _getEmail() async {
    User? user = await _firebaseAuth.currentUser;
    //_email = user?.email!;
  }

  void _getCurrentAddressMan() async {
    User? user = await _firebaseAuth.currentUser;
    if (user != null) {
      Position position = await determinePosition();
      print(position.latitude);

      _address = await GetAddressFromLatLong(position);
      print(_address);

      List<Placemark> placemark =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemark[0];

      _street = '${place.street}';
      _address = '${place.subLocality}';
      _area = '${place.locality}';
      _admin = '${place.administrativeArea}';
      _country = '${place.country}';
      _zipCode = '${place.postalCode}';
      if (mounted) setState(() {});
    }
  }

  GetAddressFromLatLong(Position position) async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemark);
    Placemark place = placemark[0];
    _street = '${place.street}';
    _address = '${place.subLocality}';
    _area = '${place.locality}';
    _admin = '${place.administrativeArea}';
    _country = '${place.country}';
    _zipCode = '${place.postalCode}';
    if (mounted) setState(() {});
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Addresses")
        .doc('current address')
        .set({
      'street': _street,
      'area': _area,
      'address': _address,
      'province': _admin,
      'country': _country,
      'postal Code': _zipCode,
      'createdAt': Timestamp.now(),
    });
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
      if (mounted)
        setState(() {
          address = userData['address'];
          area = userData['area'];
          street = userData['street'];
        });
    });
  }

  _deleteUserOnCancelWithoutUserData() async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance.collection('users').doc(user?.uid).delete();
  }

  //create user upon phone auth
  void storeData() async {
    //final ap = Provider.of<AuthProvider>(context, listen: false);
    var ap = Get.find<PhoneAuthMethods>();
    // UserModel userModel = UserModel(
    //   uid: '',
    //   name: nameController.text.trim(),
    //   phone: phoneController.text.trim(),
    //   email: emailController.text.trim(),
    // );
    ap.saveUserDataToFirebase(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    late String _updateName;
    var tokens = iTokens.toString();
    final displayTokens = tokens.substring(0, 3);

    // return either profile or authenticate widget
    if (user == null) {
      return Wrapper();
    } else {
      return Stack(
        children: [
          StreamBuilder<Object>(
            stream: _streamUserInfo,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                print(
                  snapshot.error.toString(),
                );
                Center(
                  child: Text(
                    (snapshot.error.toString()),
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.active) {
                QuerySnapshot querySnapshot = snapshot.data;
                return ValueListenableBuilder(
                  valueListenable: _showDialog,
                  builder: (context, value, _) {
                    return Stack(
                      children: [
                        Scaffold(
                          backgroundColor: Colors.white,
                          resizeToAvoidBottomInset: true,
                          body: SafeArea(
                            child: Stack(
                              children: [
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _getCurrentAddressMan();
                                        Get.to(() => const AddressSettings(),
                                            transition: Transition.fade,
                                            duration: Duration(seconds: 1));
                                      },
                                      child: Container(
                                        width: Dimensions.screenWidth / 1.08,
                                        margin: EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.screenWidth / 70,
                                          vertical: Dimensions.screenWidth / 70,
                                        ),
                                        padding: EdgeInsets.only(
                                            top: Dimensions.height10,
                                            bottom: Dimensions.height10,
                                            left: Dimensions.screenWidth / 50,
                                            right: Dimensions.screenWidth / 40),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 2.5,
                                              offset: Offset(1, 2),
                                            ),
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 2.5,
                                              offset: Offset(0, -1),
                                            ),
                                          ],
                                          border: Border.all(
                                            width: 2,
                                            color: Colors.white,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: Wrap(
                                          children: [
                                            GestureDetector(
                                                onTap: () {
                                                  _getCurrentAddressMan();
                                                  Get.to(
                                                      () =>
                                                          const AddressSettings(),
                                                      transition:
                                                          Transition.fade,
                                                      duration:
                                                          Duration(seconds: 1));
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            Dimensions
                                                                    .height10 *
                                                                5),
                                                    border: Border.all(
                                                      width: 1,
                                                      color: Colors.black12,
                                                    ),
                                                  ),
                                                  child: AppIcon(
                                                      icon: (MdiIcons
                                                          .tuneVariant),
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      iconSize:
                                                          Dimensions.height20,
                                                      size: Dimensions
                                                                  .height10 /
                                                              2 +
                                                          Dimensions.height30,
                                                      iconColor:
                                                          Colors.black87),
                                                )),
                                            SizedBox(
                                              width:
                                                  Dimensions.screenWidth / 50,
                                            ),
                                            Wrap(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    _getCurrentAddressMan();
                                                    Get.to(
                                                        () =>
                                                            const AddressSettings(),
                                                        transition:
                                                            Transition.fade,
                                                        duration: Duration(
                                                            seconds: 1));
                                                  },
                                                  child: ProfileAddressInfo(
                                                      street: street,
                                                      address: address,
                                                      area: area),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Container(
                                          // width: double.maxFinite,
                                          padding: EdgeInsets.only(
                                              left: 20, top: 20, right: 20),
                                          child: Form(
                                            key: _formKey,
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: Dimensions.height10,
                                                ),

                                                //top icon
                                                Row(
                                                  children: [
                                                    GestureDetector(
                                                        onTap: () {
                                                          _showDialog.value =
                                                              !_showDialog
                                                                  .value;
                                                        },
                                                        child: TokenView(
                                                            displayTokens:
                                                                displayTokens)),
                                                  ],
                                                ),

                                                SizedBox(
                                                    height:
                                                        Dimensions.height45 *
                                                            1.5),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                Dimensions
                                                                    .radius15)),
                                                  ),
                                                  child: TextFormField(
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .sentences,
                                                    validator: (val) => val!
                                                                .isEmpty ||
                                                            val.toString() ==
                                                                'Name'
                                                        ? "Required"
                                                        : null,
                                                    onChanged: (val) {
                                                      setState(() {
                                                        _name = val;
                                                      });
                                                    },
                                                    keyboardType:
                                                        TextInputType.text,
                                                    obscureText: false,
                                                    cursorColor:
                                                        Color(0xff9A9483),
                                                    decoration: InputDecoration(
                                                      labelText: 'Name',

                                                      floatingLabelStyle:
                                                          TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              bottom: 2,
                                                              left: 20),

                                                      floatingLabelBehavior:
                                                          FloatingLabelBehavior
                                                              .always,
                                                      hintText: _name,
                                                      hintStyle: TextStyle(
                                                        fontSize:
                                                            Dimensions.font16,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: AppColors
                                                            .titleColor,
                                                      ),

                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(
                                                                Radius.circular(
                                                                    Dimensions
                                                                        .radius15),
                                                              ),
                                                              borderSide:
                                                                  const BorderSide(
                                                                width: 1.0,
                                                                color: Color(
                                                                    0xff9A9483),
                                                              )),
                                                      //enabled border
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(
                                                              Dimensions
                                                                  .radius15),
                                                        ),
                                                        borderSide: BorderSide(
                                                          width: 1.5,
                                                          color: Colors.grey
                                                              .withOpacity(0.2),
                                                        ),
                                                      ),
                                                      //border
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(
                                                              Dimensions
                                                                  .radius15),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height:
                                                      Dimensions.height10 / 0.3,
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                Dimensions
                                                                    .radius15)),
                                                  ),
                                                  child: TextFormField(
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .sentences,
                                                    validator: (val) => val!
                                                                .isEmpty ||
                                                            val.toString() ==
                                                                'Surname'
                                                        ? "Required"
                                                        : null,
                                                    onChanged: (val) {
                                                      setState(() {
                                                        _surname = val;
                                                      });
                                                    },
                                                    keyboardType:
                                                        TextInputType.text,
                                                    obscureText: false,
                                                    cursorColor:
                                                        Color(0xff9A9483),
                                                    decoration: InputDecoration(
                                                      labelText: 'Surname',

                                                      floatingLabelStyle:
                                                          TextStyle(
                                                        color:
                                                            Color(0xff9A9483),
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              bottom: 2,
                                                              left: 20),

                                                      floatingLabelBehavior:
                                                          FloatingLabelBehavior
                                                              .always,
                                                      hintText: _surname,
                                                      hintStyle: TextStyle(
                                                        fontSize:
                                                            Dimensions.font16,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: AppColors
                                                            .titleColor,
                                                      ),

                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(
                                                                Radius.circular(
                                                                    Dimensions
                                                                        .radius15),
                                                              ),
                                                              borderSide:
                                                                  const BorderSide(
                                                                width: 1.0,
                                                                color: Color(
                                                                    0xff9A9483),
                                                              )),
                                                      //enabled border
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(
                                                              Dimensions
                                                                  .radius15),
                                                        ),
                                                        borderSide: BorderSide(
                                                          width: 1.5,
                                                          color: Colors.grey
                                                              .withOpacity(0.2),
                                                        ),
                                                      ),
                                                      //border
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(
                                                              Dimensions
                                                                  .radius15),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height:
                                                      Dimensions.height10 / 0.3,
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                Dimensions
                                                                    .radius15)),
                                                  ),
                                                  child: TextFormField(
                                                    validator: (val) => val!
                                                                .isEmpty ||
                                                            val.toString() ==
                                                                'Phone'
                                                        ? "Required"
                                                        : null,
                                                    onChanged: (val) {
                                                      setState(() {
                                                        _phone = val;
                                                      });
                                                    },
                                                    keyboardType:
                                                        TextInputType.phone,
                                                    obscureText: false,
                                                    cursorColor:
                                                        Color(0xff9A9483),
                                                    decoration: InputDecoration(
                                                      labelText: 'Phone',

                                                      floatingLabelStyle:
                                                          TextStyle(
                                                        color:
                                                            Color(0xff9A9483),
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              bottom: 2,
                                                              left: 20),

                                                      floatingLabelBehavior:
                                                          FloatingLabelBehavior
                                                              .always,
                                                      hintText: _phone,
                                                      hintStyle: TextStyle(
                                                        fontSize:
                                                            Dimensions.font16,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: AppColors
                                                            .titleColor,
                                                      ),

                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(
                                                                Radius.circular(
                                                                    Dimensions
                                                                        .radius15),
                                                              ),
                                                              borderSide:
                                                                  const BorderSide(
                                                                width: 1.0,
                                                                color: Color(
                                                                    0xff9A9483),
                                                              )),
                                                      //enabled border
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(
                                                              Dimensions
                                                                  .radius15),
                                                        ),
                                                        borderSide: BorderSide(
                                                          width: 1.5,
                                                          color: Colors.grey
                                                              .withOpacity(0.2),
                                                        ),
                                                      ),
                                                      //border
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(
                                                              Dimensions
                                                                  .radius15),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height:
                                                      Dimensions.height10 / 0.3,
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius
                                                          .all(Radius.circular(
                                                              Dimensions
                                                                  .radius15)),
                                                      color: Colors.white),
                                                  child: TextFormField(
                                                    validator: (val) =>
                                                        _email.isEmpty
                                                            ? "Required"
                                                            : null,
                                                    onChanged: (val) {
                                                      setState(() {
                                                        _email = val;
                                                      });
                                                    },
                                                    keyboardType:
                                                        TextInputType.text,
                                                    obscureText: false,
                                                    cursorColor:
                                                        Color(0xff9A9483),
                                                    decoration: InputDecoration(
                                                      labelText: 'Email',

                                                      floatingLabelStyle:
                                                          TextStyle(
                                                        color:
                                                            Color(0xff9A9483),
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              bottom: 2,
                                                              left: 20),

                                                      floatingLabelBehavior:
                                                          FloatingLabelBehavior
                                                              .always,
                                                      hintText: _email,
                                                      hintStyle: TextStyle(
                                                        fontSize:
                                                            Dimensions.font16,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: AppColors
                                                            .titleColor,
                                                      ),

                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(
                                                                Radius.circular(
                                                                    Dimensions
                                                                        .radius15),
                                                              ),
                                                              borderSide:
                                                                  const BorderSide(
                                                                width: 1.0,
                                                                color: Color(
                                                                    0xff9A9483),
                                                              )),
                                                      //enabled border
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(
                                                              Dimensions
                                                                  .radius15),
                                                        ),
                                                        borderSide: BorderSide(
                                                          width: 1.5,
                                                          color: Colors.grey
                                                              .withOpacity(0.2),
                                                        ),
                                                      ),
                                                      //border
                                                      border:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          width: 1.5,
                                                          color: Colors.grey
                                                              .withOpacity(0.2),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(
                                                              Dimensions
                                                                  .radius15),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                SizedBox(
                                                    height:
                                                        Dimensions.height20),
                                                Text(
                                                  error,
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize:
                                                          Dimensions.font16),
                                                ),
                                                SizedBox(
                                                    height: Dimensions
                                                            .screenHeight *
                                                        0.01),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          bottomNavigationBar: Container(
                            height: Dimensions.bottomHeightBar * 1.35,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: Dimensions.height20 / 1.1,
                                      left: Dimensions.height20 / 1.1),
                                  child: DisplayTokens(tokens: iTokens),
                                ),
                                Container(
                                  height: Dimensions.bottomHeightBar / 1.1,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1.5,
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                                    //color: Colors.grey[50],
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(
                                          Dimensions.radius20 * 2),
                                      topRight: Radius.circular(
                                          Dimensions.radius20 * 2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            if (fromRegistration) {
                                              try {
                                                await _firebaseAuth.currentUser
                                                    ?.delete();
                                                Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const Wrapper()),
                                                    (route) => false);
                                              } catch (e) {
                                                print('Error: $e');
                                              }
                                            } else {
                                              Navigator.of(context).pop();
                                              print(
                                                  'we popping name is not empty');
                                            }
                                          },
                                          child: Container(
                                            height: Dimensions.bottomHeightBar /
                                                1.1,
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  BigText(
                                                    size: Dimensions.font20,
                                                    color: Color(0xFF474745),
                                                    weight: FontWeight.w600,
                                                    text: 'Cancel',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      VerticalDivider(
                                        width: 2.5,
                                        color: Colors.grey.withOpacity(0.6),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            final bool hasValidEmail =
                                                await isEmail(_email);
                                            if (_name != '' &&
                                                _surname != '' &&
                                                _phone != '' &&
                                                _email != '' &&
                                                hasValidEmail) {
                                              setState(() {
                                                isLoading = true;
                                                error = '';
                                              });

                                              User? user = await _firebaseAuth
                                                  .currentUser;
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(user?.uid)
                                                  .update({
                                                'name': _name,
                                                'phone': _phone,
                                                'surname': _surname,
                                                'email': _email
                                              });
                                              fromRegistration
                                                  ? Navigator.pushAndRemoveUntil(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const Wrapper()),
                                                      (route) => false)
                                                  : Navigator.of(context).pop();

                                              setState(() {
                                                isLoading = false;
                                              });
                                            } else {
                                              setState(() {
                                                _alertUserOfOutstandingDependencies();
                                              });
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.radius20),
                                            ),
                                            height: Dimensions.bottomHeightBar /
                                                1.1,
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  BigText(
                                                    size: Dimensions.font20,
                                                    color: Color(0xFF474745),
                                                    weight: FontWeight.w600,
                                                    text: 'Save',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _showDialog.value
                            ? MainDialog(
                                contents: TokenStatus(
                                  tokens: '201',
                                  tokenStage: 0,
                                  showDialog: _showDialog,
                                ),
                                height: Dimensions.screenHeight / 2.6,
                                width: Dimensions.screenWidth / 1.2,
                              )
                            : Container()
                      ],
                    );
                  },
                );
              }
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xffB09B71),
                  ),
                ),
              );
            },
          ),
          isLoading
              ? Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(
                      color: const Color(0xffB09B71),
                    ),
                  ),
                )
              : Container()
        ],
      );
    }
  }

  Widget buildTextField(
    String labelText,
    String placeholder,
    String validatorText,
    String detail,
    TextInputType inputType,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: TextFormField(
        validator: (val) => val!.isEmpty ? validatorText : null,
        onChanged: (val) {
          setState(() {
            detail = val;
          });
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 2),
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: placeholder,
          hintStyle: TextStyle(
            fontSize: Dimensions.font16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _showDialog.dispose();
    super.dispose();
  }
}

class TokenView extends StatelessWidget {
  TokenView({
    super.key,
    this.displayTokens,
    this.icon,
    this.width,
    this.iconSize,
    this.height,
  });

  final String? displayTokens;
  IconData? icon = Icons.blur_circular_sharp;
  double? width = Dimensions.screenWidth / 3.8;
  double? iconSize = Dimensions.iconSize24 * 2.5;
  double? height = 90;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.only(
        top: Dimensions.height10,
      ),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2.5,
            offset: Offset(-2, -1), // Top-left shadow
          ),
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2.5,
            offset: Offset(1, 2), // Bottom-right shadow
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Color(0xff9A9483),
            size: iconSize,
          ),
          displayTokens == null
              ? Container()
              : IntegerText(
                  text: displayTokens == '0.0'
                      ? '0 Tokens'
                      : '${displayTokens} Tokens',
                  color: Color(0xFF474745),
                  fontWeight: FontWeight.w600,
                  size: Dimensions.font16,
                  height: 1.4,
                ),
        ],
      ),
    );
  }
}

class ProfileAddressInfo extends StatelessWidget {
  const ProfileAddressInfo({
    super.key,
    required this.street,
    required this.address,
    required this.area,
  });

  final String street;
  final String address;
  final String area;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 3.0),
                  child: SmallText(
                    text: 'Edit address',
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    size: Dimensions.font16,
                    height: 1.4,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 3.0),
                  child: Wrap(
                    children: [
                      IntegerText(
                        text: street,
                        overFlow: TextOverflow.fade,
                        color: AppColors.titleColor,
                        height: 1.5,
                        size: Dimensions.font16 / 1.2,
                      ),
                      SizedBox(
                        width: Dimensions.width10 / 2,
                      ),
                      IntegerText(
                        text: '.',
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        height: 0.9,
                      ),
                      SizedBox(
                        width: Dimensions.width10 / 2,
                      ),
                      IntegerText(
                        text: address,
                        maxLines: 1,
                        color: AppColors.titleColor,
                        height: 1.5,
                        size: Dimensions.font16 / 1.2,
                        overFlow: TextOverflow.fade,
                      ),
                      SizedBox(
                        width: Dimensions.width10 / 2,
                      ),
                      IntegerText(
                        text: '.',
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        height: 0.9,
                      ),
                      SizedBox(
                        width: Dimensions.width10 / 2,
                      ),
                      IntegerText(
                        text: area,
                        color: AppColors.titleColor,
                        height: 1.5,
                        size: Dimensions.font16 / 1.2,
                        overFlow: TextOverflow.fade,
                      ),
                      SizedBox(
                        width: Dimensions.width10 / 2,
                      )
                    ],
                  ),
                )
              ],
            ),
          ],
        )
      ],
    );
  }
}
