// Add this widget in your order_history_view.dart file or create a separate one
import 'package:flutter/material.dart';

import '../../../../utils/dimensions.dart';
import '../../../../widgets/texts/integers_and_doubles.dart';
import '../../../utilities/colors.dart';

class OrderTab extends StatelessWidget {
  const OrderTab({
    Key? key,
    required this.title,
    required this.isActive,
  }) : super(key: key);

  final String title;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.height45 / 1.1,
      decoration: BoxDecoration(
        border: isActive
            ? Border.all(
                width: 1,
                color: Colors.grey.withOpacity(0.1),
              )
            : null,
        borderRadius: BorderRadius.circular(Dimensions.radius30 * 2),
        color:
            isActive ? LiveColors.accent.withOpacity(0.5) : Colors.transparent,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: Dimensions.width10 / 2,
          horizontal: Dimensions.width10,
        ),
        child: Center(
          child: IntegerText(
            text: title,
            size: Dimensions.font16 / 1.1,
            fontWeight: FontWeight.w600,
            color: Color(0Xff353839),
          ),
        ),
      ),
    );
  }
}

// order_history_tab_controller
class OrderHistoryTabController extends ChangeNotifier {
  int _currentActiveTab = 0;
  int get currentActiveTab => _currentActiveTab;

  void setActiveTab(int index) {
    _currentActiveTab = index;
    notifyListeners();
  }
}
