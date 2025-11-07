import 'package:flutter/material.dart';
import 'package:izinto/live/view/address_view/controller/address_dropdown_controller.dart';
import 'package:izinto/widgets/miscellaneous/app_icon.dart';
import 'package:provider/provider.dart';

import '../../../../utils/dimensions.dart';
import '../../checkout_view/view_widgets/generic_white_container.dart';

class AddNewLabel extends StatefulWidget {
  const AddNewLabel({Key? key}) : super(key: key);

  @override
  State<AddNewLabel> createState() => _AddNewLabelState();
}

class _AddNewLabelState extends State<AddNewLabel> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Keyboard opened - you could trigger additional animations here
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Scroll to make text field visible if needed
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainAddressViewController>(
      builder: (context, _addressController, child) {
        var _isTyping = _addressController.isTyping;
        var _hasNewLabel = _addressController.hasNewLabel;

        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom > 0
                ? MediaQuery.of(context).viewInsets.bottom + 10
                : 0,
          ),
          child: GenericWhiteContainer(
            color: Colors.white,
            leftPadding: Dimensions.width20 * 1.1,
            topPadding: Dimensions.height45 / 2,
            bottomPadding: Dimensions.height45 / 2,
            child: Container(
              height: Dimensions.height30 * 1.2,
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: TextFormField(
                focusNode: _focusNode,
                controller: _addressController.addressLabelController,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (val) {
                  if (val.trim().isEmpty) {
                    _addressController.clearInput();
                  } else {
                    _addressController.setTextInput();
                  }
                },
                onFieldSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _addressController.setNewLabel();
                    _focusNode.unfocus();
                  }
                },
                keyboardType: TextInputType.text,
                obscureText: false,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.add,
                    size: Dimensions.iconSize26 * 1.3,
                    color: Colors.black,
                  ),
                  prefixIconConstraints:
                      BoxConstraints(minHeight: 30, minWidth: 30),
                  suffixIcon: _isTyping
                      ? GestureDetector(
                          onTap: () {
                            _focusNode.unfocus();
                            _addressController.setNewLabel();
                          },
                          child: AppIcon(
                            icon: Icons.check,
                            iconSize: Dimensions.iconSize26,
                            iconColor: Colors.white,
                            backgroundColor: Colors.black,
                          ),
                        )
                      : _hasNewLabel
                          ? Icon(
                              Icons.check,
                              size: Dimensions.iconSize26,
                              color: Colors.black,
                            )
                          : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font20 / 1.3,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  contentPadding:
                      EdgeInsets.only(bottom: Dimensions.height20, left: 0),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: _hasNewLabel
                      ? _addressController.label
                      : _addressController.customLabel,
                  hintStyle: TextStyle(
                    height: 1.15,
                    decoration: TextDecoration.none,
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font20 / 1.3,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                style: buildTextStyle(),
              ),
            ),
          ),
        );
      },
    );
  }
}

TextStyle buildTextStyle() {
  return TextStyle(
    fontFamily: 'Poppins',
    fontSize: Dimensions.font20 / 1.3,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.w600,
    color: Colors.black,
    decorationThickness: 0.0,
  );
}
