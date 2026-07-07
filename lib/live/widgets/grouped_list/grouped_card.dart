import 'package:flutter/material.dart';
import 'package:izinto/utils/dimensions.dart';

/// White rounded container wrapping a list of GroupedRow children —
/// the iOS-style "grouped inset list" used on the redesigned Account
/// and Settings screens.
class GroupedCard extends StatelessWidget {
  final List<Widget> children;
  const GroupedCard({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius15 * 1.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
