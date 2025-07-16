import 'package:flutter/material.dart';

import '../../../../utils/dimensions.dart';

class ViewAsGuestText extends StatefulWidget {
  final VoidCallback onTap;
  const ViewAsGuestText({
    super.key,
    required this.onTap,
  });

  @override
  State<ViewAsGuestText> createState() => _ViewAsGuestTextState();
}

class _ViewAsGuestTextState extends State<ViewAsGuestText> {
  bool _isTapped = false;

  void _handleTap() {
    setState(() {
      _isTapped = true;
    });

    widget.onTap();

    // Optional: Reset border visibility after a short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isTapped = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 26.0, right: 26.0),
      child: Container(
        height: Dimensions.bottomHeightBar / 1.3,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300, // Set the border color
              width: 1.0, // Set the border width
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: Dimensions.height20 * 1.4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Just browsing',
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: Dimensions.font20 / 1.3,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                '?',
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: Dimensions.font20 / 1.3,
                  fontFamily: 'Onest',
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                  height: 1.4,
                ),
              ),
              SizedBox(
                width: Dimensions.width10 / 1.5,
              ),
              Container(
                height: Dimensions.height30,
                width: Dimensions.width30 * 6,
                padding: EdgeInsets.all(2.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _handleTap,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Text(
                      'Continue as a guest',
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: _isTapped
                            ? Dimensions.font20 / 1.33
                            : Dimensions.font20 / 1.3,
                        fontFamily: 'Poppins',
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
