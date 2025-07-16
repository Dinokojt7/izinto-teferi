import 'package:flutter/material.dart';

import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../texts/integers_and_doubles.dart';
import '../../texts/small_text.dart';
import '../main_dialog.dart';

class TokenStatus extends StatefulWidget {
  const TokenStatus(
      {Key? key,
      required this.tokens,
      required this.tokenStage,
      required this.showDialog})
      : super(key: key);
  final String tokens;
  final int tokenStage;
  final ValueNotifier<bool> showDialog;

  @override
  State<TokenStatus> createState() => _TokenStatusState();
}

class _TokenStatusState extends State<TokenStatus>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final List<List<String>> tokenStage = [
      [
        'assets/image/token.jpg',
        'Keep going!!',
        'You can use your rewards once they reach 100 ZAR.'
      ],
      [
        'assets/image/laundry-detergent.png',
        'Congratulations!!',
        'You have ${widget.tokens} ZAR credit, select rewards payment during checkout.'
      ]
    ];
    return DefaultTextStyle(
      style: TextStyle(decoration: TextDecoration.none),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          IntegerText(
            size: Dimensions.height18 * 1.5,
            text: tokenStage[widget.tokenStage][1],
            color: AppColors.six,
            fontWeight: FontWeight.w600,
            maxLines: 3,
            height: 1.1,
            align: TextAlign.center,
          ),
          Spacer(),
          Image(
            image: AssetImage(tokenStage[widget.tokenStage][0]),
            width: Dimensions.screenWidth / 1.5,
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width30),
            child: IntegerText(
              align: TextAlign.center,
              maxLines: 3,
              size: Dimensions.font16 / 1.05,
              color: const Color(0Xff353839),
              fontWeight: FontWeight.w500,
              height: 1.2,
              text: tokenStage[widget.tokenStage][2],
            ),
          ),
          Spacer(),
          // SizedBox(
          //   height: Dimensions.height15,
          // ),
          GestureDetector(
              onTap: () {
                widget.showDialog.value = !widget.showDialog.value;
              },
              child: DialogCtoButton(
                text: 'Got it',
              )),
          Spacer(),
        ],
      ),
    );
  }
}

class DialogCtoButton extends StatelessWidget {
  const DialogCtoButton({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.screenHeight / 18,
      width: Dimensions.screenWidth / 2.6,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xffCFC5A5),
            Color(0xff9A9483),
          ],
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(Dimensions.radius20 * 3),
        ),
      ),
      child: Center(
        child: SmallText(
          text: text,
          size: Dimensions.font16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
