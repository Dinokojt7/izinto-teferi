import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:izinto/controllers/laundry_support_questions_controller.dart';
import 'package:izinto/pages/notifications/inbox_view.dart';
import 'package:izinto/widgets/texts/small_text.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/car_wash_support_questions_controller.dart';
import '../../../models/user.dart';
import '../../../widgets/skeletons.dart';
import '../../../widgets/texts/integers_and_doubles.dart';
import '../../home/specialty_page_body.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/texts/big_text.dart';
import '../../../live/wrapper.dart';

class GetHelpPopUp extends StatefulWidget {
  const GetHelpPopUp({Key? key}) : super(key: key);

  @override
  State<GetHelpPopUp> createState() => _GetHelpPopUpState();
}

class _GetHelpPopUpState extends State<GetHelpPopUp> {
  bool laundry = true;
  bool carWash = false;
  String contact = '';
  double value = 0.0;
  bool showText = false;
  CollectionReference _referenceUserInfo =
      FirebaseFirestore.instance.collection('izinto');
  late Stream<QuerySnapshot> _streamUserInfo;
  final _controller = TextEditingController();
  var instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _streamUserInfo = _referenceUserInfo.snapshots();
    _getPrimaryContact();
  }

  _getPrimaryContact() async {
    await FirebaseFirestore.instance
        .collection('contacts')
        .doc('primary contact')
        .snapshots()
        .listen((userData) {
      if (mounted)
        setState(() {
          contact = userData['mobile'];
        });
    });
  }

  _launchPhoneDialer(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch phone dialer';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: Dimensions.bottomHeightBar,
        elevation: 0.4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: IconThemeData(
          weight: 900,
          color: AppColors.fontColor,
          size: Dimensions.height18 + Dimensions.height18,
        ),
        titleTextStyle: TextStyle(
            fontSize: Dimensions.height18 + Dimensions.height18,
            color: AppColors.fontColor,
            fontWeight: FontWeight.w700),
        title: Text('Help'),
        centerTitle: false,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20, top: 20, right: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            laundry = true;
                            carWash = false;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.only(
                              top: Dimensions.height20 / 1.5,
                              bottom: Dimensions.height20 / 1.5,
                              left: Dimensions.width20,
                              right: Dimensions.width20),
                          child: BigText(
                            text: 'Laundry',
                            color: carWash ? Colors.black54 : Colors.white,
                            weight: FontWeight.w600,
                          ),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radius20),
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                carWash ? Colors.black12 : Color(0xff9A9483),
                                carWash ? Colors.black12 : Color(0xff9A9483),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: Dimensions.width10,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            carWash = true;
                            laundry = false;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.only(
                              top: Dimensions.height20 / 1.5,
                              bottom: Dimensions.height20 / 1.5,
                              left: Dimensions.width20,
                              right: Dimensions.width20),
                          child: BigText(
                            text: 'Car wash',
                            color: !carWash ? Colors.black54 : Colors.white,
                            weight: FontWeight.w600,
                          ),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radius20),
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                !carWash ? Colors.black12 : Color(0xff9A9483),
                                !carWash ? Colors.black12 : Color(0xff9A9483),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: Dimensions.height10 / 2,
                  ),
                  const Divider(
                    color: Colors.black45,
                  ),
                  SizedBox(
                    height: Dimensions.height10,
                  ),
                  GetBuilder<LaundrySupportQuestionsController>(
                      builder: (faqs) {
                    return faqs.isLoaded
                        ? Container(
                            height: Dimensions.screenHeight / 2.9,
                            width: double.maxFinite,
                            margin: EdgeInsets.only(bottom: 15, top: 15),
                            padding: EdgeInsets.only(
                                left: 10, bottom: 10, right: 10, top: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                width: 1,
                                color: Color(0xff9A9484).withOpacity(0.4),
                              ),
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radius15),
                            ),
                            //show the faq
                            child: SingleChildScrollView(
                              child: Wrap(
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GetBuilder<
                                          LaundrySupportQuestionsController>(
                                        builder: (questions) {
                                          return GetBuilder<
                                              CarWashSupportQuestionsController>(
                                            builder: (carWashQuestions) {
                                              return laundry
                                                  ? ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount: questions
                                                          .laundrySupportQuestionsList
                                                          .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return FAQ(
                                                          question: questions
                                                              .laundrySupportQuestionsList[
                                                                  index]
                                                              .title!,
                                                          answer: questions
                                                              .laundrySupportQuestionsList[
                                                                  index]
                                                              .text!,
                                                        );
                                                      },
                                                    )
                                                  : ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount: carWashQuestions
                                                          .carWashSupportQuestionsList
                                                          .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return FAQ(
                                                          question: carWashQuestions
                                                              .carWashSupportQuestionsList[
                                                                  index]
                                                              .title!,
                                                          answer: carWashQuestions
                                                              .carWashSupportQuestionsList[
                                                                  index]
                                                              .text!,
                                                        );
                                                      },
                                                    );
                                            },
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.only(bottom: 15, top: 15),
                            child: Skeleton(
                              height: Dimensions.screenHeight / 2.9,
                              width: double.maxFinite,
                              color: Colors.black.withOpacity(0.04),
                            ),
                          );
                  }),
                  SizedBox(
                    height: Dimensions.height20,
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: Dimensions.width15,
                        top: Dimensions.width10,
                        right: Dimensions.height15,
                        bottom: Dimensions.width10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Dimensions.radius15),
                      border: Border.all(
                        width: 0.4,
                        color: AppColors.mainColor.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.perm_phone_msg_outlined,
                          size: Dimensions.iconSize26 * 1.4,
                          color: Color(0xff9A9483),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SmallText(
                              text: 'Not what you wanted?',
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              size: Dimensions.font16 / 1.2,
                              height: 0.6,
                            ),
                            SizedBox(
                              height: Dimensions.height10,
                            ),
                            SmallText(
                              text: 'Speak to an agent',
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              size: Dimensions.font16 / 1.2,
                              height: 0.6,
                            ),
                          ],
                        ),
                        GetBuilder<LaundrySupportQuestionsController>(
                            builder: (faq) {
                          return faq.isLoaded
                              ? GestureDetector(
                                  onTap: () {
                                    if (user != null) {
                                      _launchPhoneDialer('$contact');
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          duration: Duration(seconds: 4),
                                          elevation: 20,
                                          backgroundColor: Color(0xff9A9484)
                                              .withOpacity(0.9),
                                          behavior: SnackBarBehavior.floating,
                                          content: Container(
                                            margin: EdgeInsets.zero,
                                            child: const Text(
                                                'Please login to proceed'),
                                          ),
                                          action: SnackBarAction(
                                            label: 'LOGIN',
                                            disabledTextColor: Colors.white,
                                            textColor: Colors.white,
                                            onPressed: () {
                                              Get.to(() => const Wrapper(),
                                                  transition: Transition.fade,
                                                  duration:
                                                      Duration(seconds: 1));
                                            },
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Dimensions.width10,
                                      vertical: Dimensions.height10,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radius15),
                                      border: Border.all(
                                        width: 0.9,
                                        color: Colors.black,
                                      ),
                                    ),
                                    child: SmallText(
                                        color: Colors.black87,
                                        size: Dimensions.height18,
                                        text: 'Call us'),
                                  ),
                                )
                              : Skeleton(
                                  width: 65,
                                  height: 50,
                                  color: Colors.black.withOpacity(0.04),
                                );
                          ;
                        })
                      ],
                    ),
                  ),
                  SizedBox(
                    height: Dimensions.height30,
                  ),
                  const Divider(
                    color: Colors.black45,
                  ),
                  SizedBox(
                    height: Dimensions.height30,
                  ),
                  Row(
                    children: [
                      SmallText(
                        text: 'Support messages',
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                        size: Dimensions.font16,
                        height: 0.5,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: Dimensions.height30,
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (user != null) {
                            Get.to(() => const InboxView(),
                                transition: Transition.rightToLeft,
                                duration: Duration(milliseconds: 100));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: Duration(seconds: 4),
                                elevation: 20,
                                backgroundColor:
                                    Color(0xff9A9484).withOpacity(0.9),
                                behavior: SnackBarBehavior.floating,
                                content: Container(
                                  margin: EdgeInsets.zero,
                                  child: const Text('Please login to proceed'),
                                ),
                                action: SnackBarAction(
                                  label: 'LOGIN',
                                  disabledTextColor: Colors.white,
                                  textColor: Colors.white,
                                  onPressed: () {
                                    Get.to(() => const Wrapper(),
                                        transition: Transition.fade,
                                        duration: Duration(seconds: 1));
                                  },
                                ),
                              ),
                            );
                          }
                        },
                        child: SmallText(
                          text: 'View all messages',
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          size: Dimensions.font20,
                          height: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FAQ extends StatelessWidget {
  FAQ({
    Key? key,
    required this.question,
    required this.answer,
  }) : super(key: key);

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          runAlignment: WrapAlignment.start,
          children: [
            SizedBox(
              height: Dimensions.height30,
            ),
            IntegerText(
              overFlow: TextOverflow.ellipsis,
              text: question,
              color: Color(0xff9A9483),
              fontWeight: FontWeight.w500,
              size: Dimensions.font20 / 1.2,
            ),
          ],
        ),
        SizedBox(
          height: Dimensions.height10 / 5,
        ),
        SmallText(
          overFlow: TextOverflow.ellipsis,
          text: answer,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
          size: Dimensions.font16,
        ),
        SizedBox(
          height: Dimensions.height30,
        ),
      ],
    );
  }
}
