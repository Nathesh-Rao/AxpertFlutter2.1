import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:flutter/material.dart';

class WidgetHorizontalProgressIndicator extends StatelessWidget {
  const WidgetHorizontalProgressIndicator(
      {super.key, this.height = 7, this.value = 1});
  final double height;
  final double value;
  @override
  Widget build(BuildContext context) {
    _validateValue(value);
    int parsValue = (value * 100).toInt();
    return Stack(
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Color(0xffE4ECF7),
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        Row(
          children: [
            Flexible(
              flex: parsValue,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                    gradient: MyColors.subBGGradientHorizontal,
                    borderRadius: BorderRadius.circular(100)),
              ),
            ),
            value == 1
                ? SizedBox.shrink()
                : Spacer(
                    flex: 100 - parsValue,
                  ),
          ],
        ),
      ],
    );
  }

  void _validateValue(double value) {
    if (value > 1) {
      throw Exception(
          "════════ Exception caught by WidgetHorizontalProgressIndicator ════════\nInvalid value range - $value, Expected Value range is from 0.0 to 1.0");
    }
  }
}
