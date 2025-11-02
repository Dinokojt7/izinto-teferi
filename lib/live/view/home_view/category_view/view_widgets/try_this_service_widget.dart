import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:izinto/live/view/home_view/car_wash_view/car_wash_view.dart';
import '../../../../../utils/dimensions.dart';
import '../../../../../widgets/texts/small_text.dart';
import '../../../../utilities/colors.dart';
import '../../../../widgets/text_widgets/heading_style_text.dart';

class TryThisServiceWidget extends StatefulWidget {
  const TryThisServiceWidget({Key? key}) : super(key: key);

  @override
  State<TryThisServiceWidget> createState() => _TryThisServiceWidgetState();
}

class _TryThisServiceWidgetState extends State<TryThisServiceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isLoading = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToCarWash() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate loading delay
    await Future.delayed(Duration(milliseconds: 800));

    setState(() {
      _isLoading = false;
    });

    Get.to(() => CarWashView(),
        transition: Transition.fade, duration: Duration(milliseconds: 600));
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: Dimensions.width15,
        right: Dimensions.width15,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: double.maxFinite,
          height: Dimensions.bottomHeightBar * 1.2,
          padding: EdgeInsets.only(left: Dimensions.width30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.5),
            color: Color(0xff66abf9),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: LiveColors.accent.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  margin: EdgeInsets.only(right: Dimensions.width30),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: Dimensions.height20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: SmallText(
                            overFlow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            maxLines: 1,
                            color: Colors.black,
                            size: Dimensions.font16 / 1.15,
                            text: 'Get Car Wash',
                          ),
                        ),
                        GestureDetector(
                          onTapDown: _onTapDown,
                          onTapUp: _onTapUp,
                          onTapCancel: _onTapCancel,
                          onTap: _navigateToCarWash,
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Opacity(
                                  opacity: _opacityAnimation.value,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: Dimensions.height10,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radius15),
                                      border: Border.all(
                                          color: Colors.black54, width: 1),
                                      color: Colors.black54
                                          .withOpacity(_isLoading ? 0.2 : 0.05),
                                      boxShadow: _isHovered
                                          ? [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 4,
                                                offset: Offset(0, 1),
                                              )
                                            ]
                                          : [],
                                    ),
                                    child: Center(
                                      child: _isLoading
                                          ? SizedBox(
                                              height: Dimensions.font20 / 1.5,
                                              width: Dimensions.font20 / 1.5,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                HeadingStyleText(
                                                  text: 'Wash now',
                                                  size: Dimensions.font20 / 1.5,
                                                  family: 'Poppins',
                                                  weight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(
                                                    width:
                                                        Dimensions.width10 / 2),
                                                AnimatedContainer(
                                                  duration: Duration(
                                                      milliseconds: 300),
                                                  transform:
                                                      Matrix4.translationValues(
                                                          _isHovered ? 4 : 0,
                                                          0,
                                                          0),
                                                  child: Icon(
                                                    Icons.arrow_forward_rounded,
                                                    size:
                                                        Dimensions.font20 / 1.5,
                                                    color: LiveColors.cartBlue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(Dimensions.radius15),
                      bottomRight: Radius.circular(Dimensions.radius15),
                    ),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(
                        'assets/image/autocare.png',
                      ),
                    ),
                    boxShadow: _isHovered
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            )
                          ]
                        : [],
                  ),
                  transform:
                      Matrix4.translationValues(_isHovered ? -2 : 0, 0, 0),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
