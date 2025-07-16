import 'package:flutter/material.dart';
import 'package:izinto/pages/cart/cart_processes_and_widgets/cart_view_controller.dart';
import 'package:provider/provider.dart';
import '../../utils/dimensions.dart';

class MainDialog extends StatefulWidget {
  const MainDialog({
    Key? key,
    this.contents,
    this.height,
    this.width,
    this.decoration,
  }) : super(key: key);
  final Widget? contents;
  final double? height;
  final double? width;
  final Decoration? decoration;
  @override
  State<MainDialog> createState() => _MainDialogState();
}

class _MainDialogState extends State<MainDialog>
    with SingleTickerProviderStateMixin {
  bool isShowLoader = true;
  late final AnimationController _slideAnimationController =
      AnimationController(
          vsync: this, duration: const Duration(milliseconds: 1250));
  late final Animation<Offset> _slideAnimation =
      Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(_slideAnimationController);
  @override
  void initState() {
    super.initState();
    _slideAnimationController.forward();
    Future.delayed(const Duration(seconds: 2), () async {
      setState(() {
        isShowLoader = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _slideAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartViewController>(
        builder: (context, cartViewController, child) {
      return Dialog(
        backgroundColor: Colors.black38,
        insetPadding: EdgeInsets.all(0),
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radius20),
          ),
          child: isShowLoader
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.white.withOpacity(0.7),
                  ),
                )
              : Center(
                  child: AnimatedContainer(
                      // constraints: BoxConstraints(
                      //     minWidth: widget.width, minHeight: widget.height),
                      duration: Duration(milliseconds: 200),
                      curve: Curves.fastOutSlowIn,
                      width: widget.width,
                      height: cartViewController.isSubscriptionPayment
                          ? Dimensions.screenHeight / 2.1
                          : widget.height,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2.5,
                            offset: Offset(1, 1),
                          ),
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2.5,
                            offset: Offset(1, -1),
                          ),
                        ],
                        color: Colors.white,
                      ),
                      child: widget.contents),
                ),
        ),
      );
    });
  }
}
