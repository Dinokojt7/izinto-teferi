import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:izinto/controllers/recommended_specialty_controller.dart';
import 'package:izinto/pages/home/specialty_page_body.dart';
import 'package:izinto/pages/specialty/recommended_specialty_grid_view.dart';
import 'package:izinto/widgets/location/address_details_view.dart';
import 'package:izinto/widgets/wash_details_panel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/car_specialty_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/user.dart';
import '../../routes/route_helper.dart';
import '../../services/map_function.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/miscellaneous/app_icon.dart';
import '../../widgets/skeletons.dart';
import '../../widgets/texts/small_text.dart';
import '../../live/wrapper.dart';

class CarSpecialtyDetail extends StatefulWidget {
  const CarSpecialtyDetail({Key? key}) : super(key: key);

  @override
  State<CarSpecialtyDetail> createState() => _CarSpecialtyDetailState();
}

class _CarSpecialtyDetailState extends State<CarSpecialtyDetail>
    with TickerProviderStateMixin {
  late String selectedUrl;
  String autocompletePlace = '';
  Prediction? initialValue;
  final _controller = TextEditingController();
  double value = 0.0;
  var instructionsController = TextEditingController();
  String instructions = '';
  bool _isLoading = true;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  CollectionReference _referenceUserInfo =
      FirebaseFirestore.instance.collection('addresses');
  late Stream<QuerySnapshot> _streamUserInfo;
  bool isLoading = false;
  String _address = '';
  String? totalOrderAmount;
  int? orderId;
  String? address;
  String? street;
  String? area;
  String _street = 'Cnr New & Lever Rd';
  String _area = 'Midrand';
  String? _admin;
  String? _country;
  String? _zipCode;
  Color stateColor = Color(0xff9A9483);
  Map<String, dynamic> info = {};
  bool typeSelected = false;
  String washPrice = '';
  String dropdownValue = 'Comprehensive';
  String timeValue = '08:00 - 10:00';
  late TabController _tabController;

  final _newStreet = '';
  final List<dynamic> selectWash = [
    {"wash": 'Exterior', "washType": false},
    {"wash": 'Tyre Polish', "washType": false},
    {"wash": 'Interior', "washType": false},
    {"wash": 'Body Polish', "washType": false},
  ];

  final List<dynamic> vehicleTypes = [
    {"title": "SUV", "img": "assets/image/suv.png", "vehicleType": "suv"},
    {
      "title": "Hatch back",
      "img": "assets/image/hatch.png",
      "vehicleType": "hatch"
    },
    {"title": "Sedan", "img": "assets/image/sedan.png", "vehicleType": "sedan"},
    {
      "title": "Minibus",
      "img": "assets/image/minibus.png",
      "vehicleType": "minibus"
    }
  ];

  String? _currentWash;
  int _basePrice = 120;
  List vehicleType = [];

  _initData() {
    DefaultAssetBundle.of(context)
        .loadString('assets/DM/specialties/vehicle_types.json')
        .then((value) {
      info = json.decode(value);
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController;
    super.dispose();
  }

  _checkPrice() {
    if (vehicleType == vehicleTypes[0] || vehicleType == vehicleTypes[1]) {
      setState(() {
        _basePrice = _basePrice + 30;
      });
    } else {
      setState(() {
        _basePrice = _basePrice + 20;
      });
    }
  }

  DateTime dateTime = DateTime.now();

  //DateTime dateTime = (DateFormat('d MMMM y').format(DateTime.now()));

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(2023, dateTime.month, dateTime.day),
      lastDate: DateTime(2024),
    ).then((value) {
      setState(() {
        dateTime = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    void _showSelectedWashPanel() {
      showModalBottomSheet(
          useSafeArea: false,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20), topLeft: Radius.circular(20))),
          context: context,
          builder: (context) {
            return WashDetailsPanel();
          });
    }

    return GetBuilder<CarSpecialtyController>(builder: (carSpecialties) {
      return carSpecialties.isLoaded
          ? Column(
              children: [
                // Container(
                //   color: Colors.red,
                //   height: Dimensions.screenWidth / 4.5,
                //   width: Dimensions.screenWidth / 1.10,
                //   child: ListView.builder(
                //     scrollDirection: Axis.horizontal,
                //     itemCount: selectWash.length,
                //     itemBuilder: (_, i) {
                //       return Padding(
                //         padding: const EdgeInsets.symmetric(
                //             horizontal: 5.0, vertical: 24),
                //         child: ElevatedButton(
                //           style: ButtonStyle(
                //             foregroundColor: MaterialStateProperty.all(
                //                 AppColors.fontColor),
                //             backgroundColor: !selectWash[i]['washType']
                //                 ? MaterialStateProperty.all(
                //                     Colors.white)
                //                 : MaterialStateProperty.all(
                //                     const Color(0xFFB09B71)
                //                         .withOpacity(0.9)),
                //           ),
                //           child: Text(
                //             selectWash[i]['wash'],
                //             style: TextStyle(
                //                 color: !selectWash[i]['washType']
                //                     ? const Color(0xFFB09B71)
                //                     : Colors.white),
                //           ),
                //           onPressed: () async {
                //             setState(() {
                //               selectWash[i]['washType'] =
                //                   !selectWash[i]['washType'];
                //               typeSelected = true;
                //
                //               stateColor = Color(0xffCFC5A5);
                //
                //               if (selectWash[i]['washType']) {
                //                 _basePrice = _basePrice + 20;
                //               } else if (!selectWash[i]['washType']) {
                //                 _basePrice = _basePrice - 20;
                //               }
                //             });
                //             info[selectWash[i]['wash']] =
                //                 selectWash[i]['washType'];
                //           },
                //         ),
                //       );
                //     },
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 3.2,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              topRight: Radius.circular(80),
                            ),
                            gradient: LinearGradient(
                                colors: [
                                  const Color(0xff9A9483),
                                  const Color(0xff9A9483),
                                  const Color(0xff9A9483).withOpacity(0.9),
                                  const Color(0xff9A9483).withOpacity(0.8),
                                  const Color(0xff9A9483)
                                ],
                                begin: Alignment.bottomLeft,
                                end: Alignment.centerRight),
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(5, 10),
                                  blurRadius: 10,
                                  color: AppColors.iconColor1.withOpacity(0.2))
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    left: 8,
                                    right: Dimensions.width30 * 1.8,
                                    top: 6),
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          offset: Offset(5, 10),
                                          blurRadius: 10,
                                          color: AppColors.iconColor1
                                              .withOpacity(0.2))
                                    ]),
                                child: Row(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          color: AppColors.fontColor,
                                          size: 22,
                                        ),
                                        MaterialButton(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          onPressed: () {
                                            _showDatePicker();
                                          },
                                          child: Text(
                                            ('${dateTime.day} - ${dateTime.month} - ${dateTime.year}'),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: Dimensions.font16 / 1.1,
                                              color: AppColors.fontColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '|',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: Dimensions.font16,
                                        color: AppColors.fontColor
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                    SizedBox(
                                      width: Dimensions.width10,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.watch_later_outlined,
                                          color: AppColors.fontColor,
                                          size: 22,
                                        ),
                                        SizedBox(
                                          width: Dimensions.width10,
                                        ),
                                        DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            focusColor: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            dropdownColor: Colors.white,
                                            value: timeValue ?? '08:00 - 10:00',
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                timeValue = newValue!;
                                              });
                                            },
                                            items: <String>[
                                              '08:00 - 10:00',
                                              '10:00 - 12:00',
                                              '12:00 - 14:00',
                                              '14:00 - 16:00',
                                              '16:00 - 18:00',
                                            ].map<DropdownMenuItem<String>>(
                                                (String value) {
                                              return DropdownMenuItem<String>(
                                                onTap: () {
                                                  setState(() {
                                                    timeValue = value;
                                                  });
                                                },
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize:
                                                        Dimensions.font16 / 1.1,
                                                    color: AppColors.fontColor,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: Dimensions.height10,
                                  ),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              AppColors.fontColor),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.white),
                                    ),
                                    child:
                                        Text('R $_basePrice .00 | Add to cart'),
                                    onPressed: () {
                                      setState(
                                        () {
                                          if (vehicleType == '') {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                duration: Duration(seconds: 4),
                                                elevation: 8,
                                                backgroundColor:
                                                    Color(0xff9A9484)
                                                        .withOpacity(0.9),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                content: const Text(
                                                    'Please select vehicle type'),
                                              ),
                                            );
                                          } else if (_basePrice == 120) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                duration: Duration(seconds: 4),
                                                elevation: 8,
                                                backgroundColor:
                                                    Color(0xff9A9484)
                                                        .withOpacity(0.9),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                content: const Text(
                                                    'Please select wash, you haven\'t selected any wash.'),
                                              ),
                                            );
                                          } else {
                                            _checkPrice();
                                            info['time'] = timeValue;
                                            info['Total amount'] = _basePrice;
                                            print(info);
                                          }
                                        },
                                      );
                                    },
                                  ),
                                  Expanded(
                                    child: Container(),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Container(
                    height: 140,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(top: Dimensions.height20),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 12,
                          child: Container(
                            width: MediaQuery.of(context).size.width / 1.1,
                            height: 105,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: const DecorationImage(
                                  image: AssetImage('assets/image/card1.png'),
                                  fit: BoxFit.fill),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 2,
                                  offset: Offset(2, 2),
                                  color:
                                      AppColors.mainBlackColor.withOpacity(0.2),
                                ),
                                BoxShadow(
                                  blurRadius: 3,
                                  offset: Offset(-5, -5),
                                  color: AppColors.iconColor1.withOpacity(0.1),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          child: Container(
                            height: 70,
                            width: MediaQuery.of(context).size.width / 2.6,
                            margin:
                                const EdgeInsets.only(right: 100, bottom: 40),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/image/card2.png'),
                                  fit: BoxFit.fill),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 20,
                          top: 15,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color(0xff9A9483).withOpacity(0.9)),
                            ),
                            child: const Text('Subscribe'),
                            onPressed: () async {
                              //       _showSettingsPanel();
                            },
                          ),
                        ),
                        Positioned(
                          top: 10,
                          child: Container(
                            width: double.maxFinite,
                            height: 100,
                            margin: EdgeInsets.only(left: 40, top: 62),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 13,
                                ),
                                Text(
                                  '                                                Get 15% off with ',
                                  style: TextStyle(
                                    color: const Color(0xff9A9483),
                                    fontWeight: FontWeight.w500,
                                    fontSize: Dimensions.font16 / 1.1,
                                    height: 0.5,
                                  ),
                                ),
                                SizedBox(
                                  height: 13,
                                ),
                                Text(
                                  '               1 weekly wash and 2 monthly callouts*',
                                  style: TextStyle(
                                    color: const Color(0xff9A9483),
                                    fontWeight: FontWeight.w400,
                                    fontSize: Dimensions.font16 / 1.2,
                                    height: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      Text(
                        'Select vehicle',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: Dimensions.font20,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: Dimensions.height10,
                ),
                //Test children below

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Container(
                    height: Dimensions.screenWidth,
                    width: Dimensions.screenWidth / 1.10,
                    child: OverflowBox(
                      maxWidth: MediaQuery.of(context).size.width,
                      child: MediaQuery.removePadding(
                        removeTop: true,
                        context: context,
                        child: GetBuilder<CartController>(
                          builder: (_cartController) {
                            return GetBuilder<CarSpecialtyController>(
                              builder: (carSpecialties) {
                                return ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: carSpecialties
                                          .carSpecialtyList.length
                                          .toDouble() ~/
                                      2, //turn this reading and rendering into pairs
                                  itemBuilder: (_, i) {
                                    int a = 2 * i; //first index is 0, 2
                                    int b = 2 * i + 1; //now b is 0 + 1, 3

                                    return GetBuilder<
                                        RecommendedSpecialtyController>(
                                      builder: (controller) {
                                        return Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                // controller.setQuantity(true);
                                                // controller.addItem(
                                                //     carSpecialties
                                                //         .carSpecialtyList[a]);
                                                // setState(() {
                                                //   vehicleType
                                                //       .add(vehicleTypes[a]);
                                                // });
                                                // Get.to(() => CarView(pageId: a),
                                                //     transition: Transition.fade,
                                                //     duration:
                                                //         Duration(seconds: 1));
                                              },
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    height: 140,
                                                    width:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width -
                                                                90) /
                                                            2,
                                                    margin: EdgeInsets.only(
                                                        left: 30,
                                                        bottom: 15,
                                                        top: 15),
                                                    padding: EdgeInsets.only(
                                                        bottom: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                      border: _cartController
                                                                  .getQuantity(
                                                                      carSpecialties
                                                                              .carSpecialtyList[
                                                                          a]) !=
                                                              0
                                                          ? Border.all(
                                                              width: 1.5,
                                                              color: const Color(
                                                                  0xff9A9483))
                                                          : Border.all(
                                                              width: 0.1),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          blurRadius: 2,
                                                          offset: Offset(2, 2),
                                                          color: AppColors
                                                              .mainBlackColor
                                                              .withOpacity(0.2),
                                                        ),
                                                        BoxShadow(
                                                          blurRadius: 3,
                                                          offset:
                                                              Offset(-5, -5),
                                                          color: AppColors
                                                              .iconColor1
                                                              .withOpacity(0.1),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child: Column(
                                                        children: [
                                                          Image(
                                                            color: _cartController.getQuantity(
                                                                        carSpecialties.carSpecialtyList[
                                                                            a]) !=
                                                                    0
                                                                ? Color(0xff9A9483)
                                                                    .withOpacity(
                                                                        0.91)
                                                                : Colors.grey
                                                                    .withOpacity(
                                                                        0.31),
                                                            image: AssetImage(
                                                                carSpecialties
                                                                    .carSpecialtyList[
                                                                        a]
                                                                    .img),
                                                            height: Dimensions
                                                                    .height45 *
                                                                2,
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            child: Text(
                                                              vehicleTypes[a]
                                                                  ['title'],
                                                              style: TextStyle(
                                                                  letterSpacing:
                                                                      0.7,
                                                                  fontSize:
                                                                      Dimensions
                                                                          .font16,
                                                                  color: _cartController.getQuantity(carSpecialties.carSpecialtyList[
                                                                              a]) !=
                                                                          0
                                                                      ? const Color(
                                                                          0xff9A9483)
                                                                      : Colors
                                                                          .black38,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  _cartController.getQuantity(
                                                              carSpecialties
                                                                      .carSpecialtyList[
                                                                  a]) !=
                                                          0
                                                      ? Positioned(
                                                          right: Dimensions
                                                              .width10,
                                                          bottom: Dimensions
                                                              .height30,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  // Get.to(
                                                                  //     () => CarView(
                                                                  //         pageId:
                                                                  //             a),
                                                                  //     transition:
                                                                  //         Transition
                                                                  //             .fade,
                                                                  //     duration: Duration(
                                                                  //         seconds:
                                                                  //             1));
                                                                },
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                    border: Border.all(
                                                                        width:
                                                                            1.5,
                                                                        color: const Color(
                                                                            0xff966C3B)),
                                                                  ),
                                                                  child: Container(
                                                                      width: 25,
                                                                      height: 25,
                                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(40 / 2), color: Colors.white),
                                                                      child: Center(
                                                                        child:
                                                                            SmallText(
                                                                          size:
                                                                              Dimensions.font16,
                                                                          text:
                                                                              '${_cartController.getQuantity(carSpecialties.carSpecialtyList[a])}',
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          color:
                                                                              const Color(0xff966C3B),
                                                                        ),
                                                                      )),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Container()
                                                ],
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                controller.setQuantity(true);
                                                controller.addItem(
                                                    carSpecialties
                                                        .carSpecialtyList[b]);
                                                setState(() {
                                                  vehicleType
                                                      .add(vehicleTypes[b]);
                                                });
                                              },
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    height: 140,
                                                    width:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width -
                                                                90) /
                                                            2,
                                                    margin: EdgeInsets.only(
                                                        left: 30,
                                                        bottom: 15,
                                                        top: 15),
                                                    padding: EdgeInsets.only(
                                                        bottom: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                      border: _cartController
                                                                  .getQuantity(
                                                                      carSpecialties
                                                                              .carSpecialtyList[
                                                                          b]) !=
                                                              0
                                                          ? Border.all(
                                                              width: 1.5,
                                                              color: const Color(
                                                                  0xff9A9483))
                                                          : Border.all(
                                                              width: 0.1),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          blurRadius: 2,
                                                          offset: Offset(2, 2),
                                                          color: AppColors
                                                              .mainBlackColor
                                                              .withOpacity(0.2),
                                                        ),
                                                        BoxShadow(
                                                          blurRadius: 3,
                                                          offset:
                                                              Offset(-5, -5),
                                                          color: AppColors
                                                              .iconColor1
                                                              .withOpacity(0.1),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child: Column(
                                                        children: [
                                                          Image(
                                                            color: _cartController.getQuantity(
                                                                        carSpecialties.carSpecialtyList[
                                                                            b]) !=
                                                                    0
                                                                ? Color(0xff9A9483)
                                                                    .withOpacity(
                                                                        0.91)
                                                                : Colors.grey
                                                                    .withOpacity(
                                                                        0.31),
                                                            image: AssetImage(
                                                                carSpecialties
                                                                    .carSpecialtyList[
                                                                        b]
                                                                    .img),
                                                            height: Dimensions
                                                                    .height45 *
                                                                2,
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            child: Text(
                                                              vehicleTypes[b]
                                                                  ['title'],
                                                              style: TextStyle(
                                                                  letterSpacing:
                                                                      0.7,
                                                                  fontSize:
                                                                      Dimensions
                                                                          .font16,
                                                                  color: _cartController.getQuantity(carSpecialties.carSpecialtyList[
                                                                              b]) !=
                                                                          0
                                                                      ? const Color(
                                                                          0xff9A9483)
                                                                      : Colors
                                                                          .black38,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  _cartController.getQuantity(
                                                              carSpecialties
                                                                      .carSpecialtyList[
                                                                  b]) !=
                                                          0
                                                      ? Positioned(
                                                          right: Dimensions
                                                              .width10,
                                                          bottom: Dimensions
                                                              .height30,
                                                          child: Stack(
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      _cartController.getQuantity(carSpecialties.carSpecialtyList[b]) ==
                                                                              1
                                                                          ? vehicleType
                                                                              .remove(vehicleTypes[b])
                                                                          : null;
                                                                      controller
                                                                          .setQuantity(
                                                                              false);
                                                                      controller
                                                                          .addItem(
                                                                              carSpecialties.carSpecialtyList[b]);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(20),
                                                                        border: Border.all(
                                                                            width:
                                                                                1.5,
                                                                            color:
                                                                                Color(0xffA0937D)),
                                                                      ),
                                                                      child:
                                                                          AppIcon(
                                                                        weight:
                                                                            10,
                                                                        size:
                                                                            22,
                                                                        iconSize:
                                                                            Dimensions.iconSize24,
                                                                        backgroundColor:
                                                                            Colors.white,
                                                                        iconColor:
                                                                            const Color(0xffA0937D),
                                                                        icon: Icons
                                                                            .remove,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: Dimensions.width30 *
                                                                            2 +
                                                                        Dimensions
                                                                            .width20,
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      controller
                                                                          .setQuantity(
                                                                              true);
                                                                      controller
                                                                          .addItem(
                                                                              carSpecialties.carSpecialtyList[b]);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(20),
                                                                        border: Border.all(
                                                                            width:
                                                                                1.5,
                                                                            color:
                                                                                const Color(0xff966C3B)),
                                                                      ),
                                                                      child:
                                                                          AppIcon(
                                                                        weight:
                                                                            10,
                                                                        size:
                                                                            22,
                                                                        iconSize:
                                                                            Dimensions.iconSize24,
                                                                        backgroundColor:
                                                                            Colors.white,
                                                                        iconColor:
                                                                            Color(0xff966C3B),
                                                                        icon: Icons
                                                                            .add,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Positioned(
                                                                top: Dimensions
                                                                        .height10 /
                                                                    2,
                                                                left: Dimensions
                                                                        .height30 *
                                                                    2.05,
                                                                child: Text(
                                                                  '${_cartController.getQuantity(carSpecialties.carSpecialtyList[b])}',
                                                                  style: TextStyle(
                                                                      color: const Color(
                                                                          0xff966C3B),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      : Container()
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : CarSkeleton();
    });
  }
}

class VenueSearch extends StatefulWidget {
  const VenueSearch({Key? key}) : super(key: key);

  @override
  State<VenueSearch> createState() => _VenueSearchState();
}

class _VenueSearchState extends State<VenueSearch> {
  final _formKey = GlobalKey<FormState>();
  final List<String> selectWash = [
    'Comprehensive',
    'Body only',
    'Interior only'
  ];
  String? _currentWash;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [Text('data')],
      ),
    );
  }
}
