import '../../../utils/dimensions.dart';
import '../../../widgets/miscellaneous/app_icon.dart';
import '../../../widgets/texts/big_text.dart';
import 'package:flutter/material.dart';
import 'package:izinto/widgets/texts/small_text.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TermsPanel extends StatefulWidget {
  final String title;
  final String text;
  const TermsPanel({Key? key, required this.title, required this.text})
      : super(key: key);

  @override
  State<TermsPanel> createState() => _TermsPanelState();
}

class _TermsPanelState extends State<TermsPanel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), topLeft: Radius.circular(20))),
      height: Dimensions.screenHeight,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      right: 8,
                      left: 20,
                      top: Dimensions.screenWidth / 6,
                      bottom: 0),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Column(
                            children: [
                              Column(
                                children: [
                                  Wrap(
                                    alignment: WrapAlignment.start,
                                    children: [
                                      Text(
                                        widget.title,
                                        style: TextStyle(
                                            overflow: TextOverflow.fade,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: Dimensions.font20),
                                      ),
                                    ],
                                  ),
                                  SmallText(
                                    text: widget.text,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w400,
                                    size: Dimensions.font16,
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(Dimensions.screenWidth / 20),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppIcon(
                    backgroundColor: Colors.white,
                    weight: 20,
                    icon: Icons.close,
                    iconColor: Color(0Xff353839),
                    iconSize: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
