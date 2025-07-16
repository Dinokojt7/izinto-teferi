import 'package:flutter/material.dart';

import '../../../utils/dimensions.dart';
import '../../../widgets/texts/integers_and_doubles.dart';

class PriceDisplay extends StatelessWidget {
  const PriceDisplay({
    super.key,
    required this.totalOrderAmount,
    required this.totalItems,
  });

  final int? totalOrderAmount;
  final int? totalItems;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: Dimensions.width30),
      child: Column(
        children: [
          Row(
            children: [
              TextVaried(
                text: 'R',
                size: Dimensions.height18 * 1.2,
              ),
              TextVaried(
                text: '$totalOrderAmount.',
                size: Dimensions.height18 * 1.5,
              ),
              TextVaried(
                text: '00',
                size: Dimensions.height18 * 1,
              ),
            ],
          ),
          SizedBox(height: Dimensions.height10 / 1.5),
          Row(
            children: [
              TextVaried(
                text: 'Total Price',
                size: Dimensions.height18 * 0.72,
              ),
              SizedBox(width: Dimensions.width30 * 1.3),
              Row(
                children: [
                  Container(
                    width: Dimensions.height45 / 1.8,
                    height: Dimensions.height45 / 1.8,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.4,
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(40 / 2),
                      color: Colors.white.withOpacity(0.15),
                    ),
                    child: Center(
                      child: Text(
                        '$totalItems',
                        style: TextStyle(
                            fontSize: Dimensions.height18 * 0.72,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                      // TextVaried(
                      //   text: '$totalItems',
                      //   size: Dimensions.height18 * 0.72,
                      // ),
                    ),
                  ),
                  SizedBox(width: Dimensions.width10),
                  TextVaried(
                    text: 'Total Discounted Items',
                    size: Dimensions.height18 * 0.72,
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

class TextVaried extends StatelessWidget {
  const TextVaried({
    super.key,
    required this.text,
    required this.size,
  });
  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IntegerText(
      size: size,
      text: text,
      color: Colors.white,
      fontWeight: FontWeight.w600,
      maxLines: 3,
      height: 1.1,
      align: TextAlign.center,
    );
  }
}
