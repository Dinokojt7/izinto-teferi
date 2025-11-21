import 'package:flutter/material.dart';

class BackArrow extends StatefulWidget {
  final Color? iconColor;
  final double iconSize;
  final double? weight;
  final VoidCallback onTap;
  final bool isSpecialtyView;

  const BackArrow({
    Key? key,
    this.iconColor = Colors.white,
    this.iconSize = 30,
    this.weight,
    required this.onTap,
    this.isSpecialtyView = false,
  }) : super(key: key);

  @override
  _BackArrowState createState() => _BackArrowState();
}

class _BackArrowState extends State<BackArrow> {
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
    return Container(
      // height: Dimensions.height45 / 1.3,
      width: 40,
      height: 40,
      padding: EdgeInsets.all(2.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40 / 2),
          color: _isTapped && !widget.isSpecialtyView
              ? Colors.grey.shade200
              : Colors.transparent),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(40 / 2),
          onTap: _handleTap,
          splashColor: widget.isSpecialtyView
              ? Colors.transparent
              : Colors.grey.shade200,
          highlightColor: widget.isSpecialtyView
              ? Colors.transparent
              : Colors.grey.shade200,
          child: Padding(
            padding: EdgeInsets.all(2.0),
            child: Icon(
              Icons.keyboard_backspace_outlined,
              weight: widget.weight,
              color: widget.iconColor,
              size: _isTapped ? widget.iconSize / 1.1 : widget.iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
