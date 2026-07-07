import 'package:flutter/material.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:izinto/live/widgets/text_widgets/primary_style_text.dart';
import 'package:izinto/utils/dimensions.dart';

/// A single row inside a GroupedCard — icon chip, label, optional trailing
/// text/widget, chevron. Matches the grouped inset-list rows used on the
/// redesigned Account/Settings screens.
class GroupedRow extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final String label;
  final String? trailing;
  final Widget? trailingWidget;
  final bool divider;
  final bool showChevron;
  final VoidCallback? onTap;

  const GroupedRow({
    Key? key,
    required this.icon,
    this.tint = const Color(0xFFEFECE4),
    required this.label,
    this.trailing,
    this.trailingWidget,
    this.divider = true,
    this.showChevron = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          border: divider
              ? Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05)))
              : null,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width15,
          vertical: Dimensions.height15 * 0.85,
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, size: 17, color: LiveColors.primary),
            ),
            SizedBox(width: Dimensions.width15),
            Expanded(
              child: PrimaryStyleText(
                text: label,
                size: Dimensions.font16 * 0.95,
                weight: FontWeight.w500,
              ),
            ),
            if (trailingWidget != null) trailingWidget!,
            if (trailing != null)
              PrimaryStyleText(
                text: trailing!,
                size: Dimensions.font16 * 0.8,
                weight: FontWeight.w600,
                color: Colors.black54,
              ),
            if (showChevron) ...[
              SizedBox(width: Dimensions.width10 * 0.6),
              const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFC3BCAB)),
            ],
          ],
        ),
      ),
    );
  }
}
