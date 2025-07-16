import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:izinto/pages/options/location_settings.dart';
import 'package:izinto/widgets/keep_page_alive.dart';
import 'package:izinto/widgets/texts/integers_and_doubles.dart';
import 'package:izinto/widgets/texts/small_text.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../services/map_function.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../miscellaneous/app_icon.dart';
import '../texts/big_text.dart';

class CarVenueSettings extends StatefulWidget {
  const CarVenueSettings({Key? key}) : super(key: key);

  @override
  State<CarVenueSettings> createState() => _CarVenueSettingsState();
}

class _CarVenueSettingsState extends State<CarVenueSettings>
    with TickerProviderStateMixin {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String autocompletePlace = '';
  Prediction? initialValue;
  late String _houseNumber;
  late String _estateName;
  late String _buildingName;
  late String _suitFloorNumber;
  late String _unitNumber;
  late String _label;
  late String _accessNote;
  late String _selectedAddress;
  String area = '';
  String street = '';
  String _email = '';
  String? address;
  bool isLoading = false;
  late String selectedUrl;
  final _controller = TextEditingController();
  double value = 0.0;
  var _houseNumberController = TextEditingController();
  var _estateNameController = TextEditingController();
  var _buildingNameController = TextEditingController();
  var _labelController = TextEditingController();
  var _accessNoteController = TextEditingController();
  var _complexAccessNoteController = TextEditingController();
  var _businessAccessNoteController = TextEditingController();
  var _complexLabelController = TextEditingController();
  var _businessLabelController = TextEditingController();

  String instructions = '';
  bool _isLoading = true;
  String _currentStreet = '';
  String _currentAddress = '';
  String _currentArea = '';
  String _currentAdmin = '';
  String _currentZip = '';
  String _currentCountry = '';
  CollectionReference _referenceUserInfo =
      FirebaseFirestore.instance.collection('addresses');
  late Stream<QuerySnapshot> _streamUserInfo;
  String _address = '';
  String? totalOrderAmount;
  int? orderId;
  String _street = 'Cnr New & Lever Rd';
  String _area = 'Midrand';
  String? _admin;
  String? _country;
  String? _zipCode;
  String? venueType = '';
  late TabController _tabController;

  List<Widget> _tabs = [
    Tab(text: 'House', icon: Icon(Icons.house_sharp)),
    Tab(text: 'Estate/Complex', icon: Icon(Icons.apartment_rounded)),
    Tab(
        text: 'Business/Office',
        icon: Icon(Icons.store_mall_directory_outlined)),
  ];

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    _currentAddressSelected();
    _streamUserInfo = _referenceUserInfo.snapshots();
  }

  @override
  void dispose() {
    _tabController;
    super.dispose();
  }

  void _updateAddress() async {
    _houseNumber = _houseNumberController.text.toString();
    _estateName = _estateNameController.text.toString();
    _buildingName = _buildingNameController.text.toString();
    _label = _labelController.length != 0
        ? _labelController.text.toString()
        : _complexLabelController.length != 0
            ? _complexLabelController.text.toString()
            : _businessLabelController.text.toString();
    _accessNote = _accessNoteController.length != 0
        ? _accessNoteController.text.toString()
        : _complexAccessNoteController.length != 0
            ? _complexAccessNoteController.text.toString()
            : _businessAccessNoteController.text.toString();
    venueType = _houseNumberController.length != 0
        ? 'House'
        : _buildingNameController.length != 0
            ? 'Business/Office'
            : _estateNameController.length != 0
                ? 'Estate/Complex'
                : '';
    if (mounted) setState(() {});
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Addresses")
        .doc('preffered address')
        .set({
      'venueType': venueType,
      'street': _currentStreet,
      'area': _currentArea,
      'address': _currentAddress,
      'province': _currentAdmin,
      'country': _currentCountry,
      'postal code': _currentZip,
      'house number': _houseNumber,
      'estate/complex name': _estateName,
      'building name': _buildingName,
      'address label': _label,
      'access note': _accessNote,
      'createdAt': Timestamp.now(),
    });
  }

  void _currentAddressSelected() async {
    User? user = await _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection("Addresses")
        .doc('selected address')
        .snapshots()
        .listen((userData) {
      if (mounted)
        setState(() {
          _currentAddress = userData['address'];
          _currentArea = userData['area'];
          _currentStreet = userData['street'];
          _currentAdmin = userData['province'];
          _currentZip = userData['postal Code'];
          _currentCountry = userData['country'];
        });
    });
  }

  //delete this address from db after it's contents are transferred to another document

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    return StreamBuilder<Object>(
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
          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_sharp),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              iconTheme: IconThemeData(
                  weight: 900,
                  color: AppColors.fontColor,
                  size: Dimensions.font20 * 1.5),
              titleTextStyle: TextStyle(
                  fontSize: Dimensions.font20 * 1.5,
                  color: AppColors.fontColor,
                  fontWeight: FontWeight.w700),
              title: Text('Address details'),
              centerTitle: false,
              backgroundColor: Colors.white,
            ),
            body: Column(
              children: [
                Container(
                  width: Dimensions.screenWidth / 1.08,
                  margin: EdgeInsets.symmetric(
                    horizontal: Dimensions.screenWidth / 100,
                    vertical: Dimensions.screenWidth / 40,
                  ),
                  padding: EdgeInsets.only(
                      top: Dimensions.height10,
                      bottom: Dimensions.height10,
                      left: Dimensions.screenWidth / 50,
                      right: Dimensions.screenWidth / 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      width: 1,
                      color: Color(0xff9A9484).withOpacity(0.4),
                    ),
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                  ),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AppIcon(
                        icon: (Icons.location_on),
                        backgroundColor: Colors.white,
                        iconSize: Dimensions.height20 + Dimensions.height10,
                        size: Dimensions.height10 + Dimensions.height30,
                        iconColor: Color(0xff9A9483),
                      ),
                      Wrap(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 3.0),
                                child: IntegerText(
                                  text: _currentStreet,
                                  color: Color(0xff9A9483),
                                  fontWeight: FontWeight.w600,
                                  size: Dimensions.font16,
                                  height: 1.4,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 3.0),
                                child: Wrap(
                                  children: [
                                    IntegerText(
                                      text: _currentAddress,
                                      overFlow: TextOverflow.fade,
                                      color: AppColors.titleColor,
                                      height: 1.5,
                                      size: Dimensions.font16 / 1.1,
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
                                      text: _currentArea,
                                      maxLines: 1,
                                      color: AppColors.titleColor,
                                      height: 1.5,
                                      size: Dimensions.font16 / 1.1,
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
                                      text: _currentAdmin,
                                      color: AppColors.titleColor,
                                      height: 1.5,
                                      size: Dimensions.font16 / 1.1,
                                      overFlow: TextOverflow.fade,
                                    ),
                                    SizedBox(
                                      width: Dimensions.width10 / 2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(right: 8, left: 20, bottom: 0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: Dimensions.height20,
                          ),
                          Row(
                            children: [
                              BigText(
                                text: 'Property Details',
                                color: AppColors.mainColor,
                                size: Dimensions.font20,
                                weight: FontWeight.w600,
                              ),
                            ],
                          ),
                          Container(
                            height: Dimensions.screenHeight / 1.9,
                            width: double.maxFinite,
                            margin: EdgeInsets.only(top: 10, right: 10),
                            padding:
                                EdgeInsets.only(left: 10, right: 10, top: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 3,
                                  offset: Offset(5, 5),
                                  color: AppColors.iconColor1.withOpacity(0.1),
                                ),
                                BoxShadow(
                                  blurRadius: 3,
                                  offset: Offset(-5, -5),
                                  color: AppColors.iconColor1.withOpacity(0.1),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  child: TabBar(
                                    indicatorColor: Color(0xffB09B71),
                                    controller: _tabController,
                                    tabs: _tabs,
                                    labelColor: AppColors.fontColor,
                                    unselectedLabelColor: Colors.grey,
                                  ),
                                ),
                                SizedBox(
                                  height: Dimensions.height45,
                                ),
                                Container(
                                  height: Dimensions.screenHeight / 3,
                                  width: double.maxFinite,
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      // Content for tab 1
                                      KeepPageAlive(
                                        child: Column(
                                          children: [
                                            Flexible(
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                  left: Dimensions.screenWidth /
                                                      30,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 2.5,
                                                      offset: Offset(1, 2),
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions.radius15),
                                                ),
                                                child: TextField(
                                                  cursorColor:
                                                      AppColors.iconColor1,
                                                  controller:
                                                      _houseNumberController,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  decoration: InputDecoration(
                                                    suffixIcon: IconButton(
                                                      color:
                                                          _houseNumberController
                                                                  .text.isEmpty
                                                              ? Colors
                                                                  .transparent
                                                              : AppColors
                                                                  .iconColor1,
                                                      iconSize:
                                                          Dimensions.iconSize16,
                                                      onPressed:
                                                          _houseNumberController
                                                              .clear,
                                                      icon: Icon(Icons.close),
                                                    ),
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                    hintStyle: TextStyle(
                                                        color: Colors.black45,
                                                        fontSize:
                                                            Dimensions.font16),
                                                    hintText: 'House number',
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: Dimensions.width20,
                                            ),
                                            Flexible(
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                  left: Dimensions.screenWidth /
                                                      30,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 2.5,
                                                      offset: Offset(1, 2),
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions.radius15),
                                                ),
                                                child: TextField(
                                                  cursorColor:
                                                      AppColors.iconColor1,
                                                  controller: _labelController,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  decoration: InputDecoration(
                                                    suffixIcon: IconButton(
                                                      color: _labelController
                                                              .text.isEmpty
                                                          ? Colors.transparent
                                                          : AppColors
                                                              .iconColor1,
                                                      iconSize:
                                                          Dimensions.iconSize16,
                                                      onPressed:
                                                          _labelController
                                                              .clear,
                                                      icon: Icon(Icons.close),
                                                    ),
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                    hintStyle: TextStyle(
                                                        color: Colors.black45,
                                                        fontSize:
                                                            Dimensions.font16),
                                                    hintText:
                                                        'Label e.g. House / (optional) ',
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: Dimensions.width20,
                                            ),
                                            Flexible(
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                  left: Dimensions.screenWidth /
                                                      30,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 2.5,
                                                      offset: Offset(1, 2),
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions.radius15),
                                                ),
                                                child: TextField(
                                                  cursorColor:
                                                      AppColors.iconColor1,
                                                  controller:
                                                      _accessNoteController,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  decoration: InputDecoration(
                                                    suffixIcon: IconButton(
                                                      color:
                                                          _accessNoteController
                                                                  .text.isEmpty
                                                              ? Colors
                                                                  .transparent
                                                              : AppColors
                                                                  .iconColor1,
                                                      iconSize:
                                                          Dimensions.iconSize16,
                                                      onPressed:
                                                          _accessNoteController
                                                              .clear,
                                                      icon: Icon(Icons.close),
                                                    ),
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                    hintStyle: TextStyle(
                                                        color: Colors.black45,
                                                        fontSize:
                                                            Dimensions.font16),
                                                    hintText:
                                                        'Access note / (optional)',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Content for tab 2
                                      KeepPageAlive(
                                        child: Column(
                                          children: [
                                            Flexible(
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                  left: Dimensions.screenWidth /
                                                      30,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 2.5,
                                                      offset: Offset(1, 2),
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions.radius15),
                                                ),
                                                child: TextField(
                                                  cursorColor:
                                                      AppColors.iconColor1,
                                                  controller:
                                                      _estateNameController,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  decoration: InputDecoration(
                                                    suffixIcon: IconButton(
                                                      color:
                                                          _estateNameController
                                                                  .text.isEmpty
                                                              ? Colors
                                                                  .transparent
                                                              : AppColors
                                                                  .iconColor1,
                                                      iconSize:
                                                          Dimensions.iconSize16,
                                                      onPressed:
                                                          _estateNameController
                                                              .clear,
                                                      icon: Icon(Icons.close),
                                                    ),
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                    hintStyle: TextStyle(
                                                        color: Colors.black45,
                                                        fontSize:
                                                            Dimensions.font16),
                                                    hintText:
                                                        'Estate name and unit number',
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: Dimensions.width20,
                                            ),
                                            Flexible(
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                  left: Dimensions.screenWidth /
                                                      30,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 2.5,
                                                      offset: Offset(1, 2),
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions.radius15),
                                                ),
                                                child: TextField(
                                                  cursorColor:
                                                      AppColors.iconColor1,
                                                  controller:
                                                      _complexLabelController,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  decoration: InputDecoration(
                                                    suffixIcon: IconButton(
                                                      color: _labelController
                                                              .text.isEmpty
                                                          ? Colors.transparent
                                                          : AppColors
                                                              .iconColor1,
                                                      iconSize:
                                                          Dimensions.iconSize16,
                                                      onPressed:
                                                          _labelController
                                                              .clear,
                                                      icon: Icon(Icons.close),
                                                    ),
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                    hintStyle: TextStyle(
                                                        color: Colors.black45,
                                                        fontSize:
                                                            Dimensions.font16),
                                                    hintText:
                                                        'Label e.g. Apartments / (optional) ',
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: Dimensions.width20,
                                            ),
                                            Flexible(
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                  left: Dimensions.screenWidth /
                                                      30,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 2.5,
                                                      offset: Offset(1, 2),
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions.radius15),
                                                ),
                                                child: TextField(
                                                  cursorColor:
                                                      AppColors.iconColor1,
                                                  controller:
                                                      _complexAccessNoteController,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  decoration: InputDecoration(
                                                    suffixIcon: IconButton(
                                                      color:
                                                          _accessNoteController
                                                                  .text.isEmpty
                                                              ? Colors
                                                                  .transparent
                                                              : AppColors
                                                                  .iconColor1,
                                                      iconSize:
                                                          Dimensions.iconSize16,
                                                      onPressed:
                                                          _accessNoteController
                                                              .clear,
                                                      icon: Icon(Icons.close),
                                                    ),
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                    hintStyle: TextStyle(
                                                        color: Colors.black45,
                                                        fontSize:
                                                            Dimensions.font16),
                                                    hintText:
                                                        'Access note  / (optional)',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Content for tab 3
                                      KeepPageAlive(
                                        child: Column(
                                          children: [
                                            Flexible(
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                  left: Dimensions.screenWidth /
                                                      30,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 2.5,
                                                      offset: Offset(1, 2),
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions.radius15),
                                                ),
                                                child: TextField(
                                                  cursorColor:
                                                      AppColors.iconColor1,
                                                  controller:
                                                      _buildingNameController,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  decoration: InputDecoration(
                                                    suffixIcon: IconButton(
                                                      color:
                                                          _buildingNameController
                                                                  .text.isEmpty
                                                              ? Colors
                                                                  .transparent
                                                              : AppColors
                                                                  .iconColor1,
                                                      iconSize:
                                                          Dimensions.iconSize16,
                                                      onPressed:
                                                          _buildingNameController
                                                              .clear,
                                                      icon: Icon(Icons.close),
                                                    ),
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                    hintStyle: TextStyle(
                                                        color: Colors.black45,
                                                        fontSize:
                                                            Dimensions.font16),
                                                    hintText:
                                                        'Building name and suit floor',
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: Dimensions.width20,
                                            ),
                                            Flexible(
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                  left: Dimensions.screenWidth /
                                                      30,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 2.5,
                                                      offset: Offset(1, 2),
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions.radius15),
                                                ),
                                                child: TextField(
                                                  cursorColor:
                                                      AppColors.iconColor1,
                                                  controller:
                                                      _businessLabelController,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  decoration: InputDecoration(
                                                    suffixIcon: IconButton(
                                                      color: _labelController
                                                              .text.isEmpty
                                                          ? Colors.transparent
                                                          : AppColors
                                                              .iconColor1,
                                                      iconSize:
                                                          Dimensions.iconSize16,
                                                      onPressed:
                                                          _labelController
                                                              .clear,
                                                      icon: Icon(Icons.close),
                                                    ),
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                    hintStyle: TextStyle(
                                                        color: Colors.black45,
                                                        fontSize:
                                                            Dimensions.font16),
                                                    hintText:
                                                        'Label e.g. Office building / (optional) ',
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: Dimensions.width20,
                                            ),
                                            Flexible(
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                  left: Dimensions.screenWidth /
                                                      30,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 2.5,
                                                      offset: Offset(1, 2),
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions.radius15),
                                                ),
                                                child: TextField(
                                                  cursorColor:
                                                      AppColors.iconColor1,
                                                  controller:
                                                      _businessAccessNoteController,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  decoration: InputDecoration(
                                                    suffixIcon: IconButton(
                                                      color:
                                                          _accessNoteController
                                                                  .text.isEmpty
                                                              ? Colors
                                                                  .transparent
                                                              : AppColors
                                                                  .iconColor1,
                                                      iconSize:
                                                          Dimensions.iconSize16,
                                                      onPressed:
                                                          _accessNoteController
                                                              .clear,
                                                      icon: Icon(Icons.close),
                                                    ),
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                    hintStyle: TextStyle(
                                                        color: Colors.black45,
                                                        fontSize:
                                                            Dimensions.font16),
                                                    hintText:
                                                        'Access note / (optional)',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: GestureDetector(
              onTap: () async {
                if (_buildingNameController.length != 0 ||
                    _estateNameController.length != 0 ||
                    _houseNumberController.length != 0) {
                  // Navigator.pushReplacement(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (BuildContext context) =>
                  //             AddressSettings()));
                  _updateAddress();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: Duration(seconds: 4),
                      elevation: 8,
                      backgroundColor: Color(0xff9A9484).withOpacity(0.9),
                      behavior: SnackBarBehavior.floating,
                      content:
                          const Text('Please provide the required details.'),
                    ),
                  );
                }
              },
              child: Container(
                height: Dimensions.bottomHeightBar / 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xff9A9483),
                      Color(0xffCFC5A5),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Dimensions.radius20 * 2),
                    topRight: Radius.circular(Dimensions.radius20 * 2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (_buildingNameController.length != 0 ||
                            _estateNameController.length != 0 ||
                            _houseNumberController.length != 0) {
                          // Navigator.pushReplacement(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (BuildContext context) =>
                          //             AddressSettings()));

                          _updateAddress();
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: Duration(seconds: 4),
                              elevation: 8,
                              backgroundColor:
                                  Color(0xff9A9484).withOpacity(0.9),
                              behavior: SnackBarBehavior.floating,
                              content: const Text(
                                  'Please provide the required details.'),
                            ),
                          );
                        }
                      },
                      child: BigText(
                        size: Dimensions.font26 / 1.1,
                        text: 'Save',
                        color: Colors.white,
                        weight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
        return Center(
          child: CircularProgressIndicator(
            color: const Color(0xffB09B71),
          ),
        );
      },
    );
  }
}
