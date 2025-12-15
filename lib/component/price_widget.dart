import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

class PriceWidget extends StatelessWidget {
  final num price;
  final double? size;
  final Color? color;
  final Color? hourlyTextColor;
  final bool isBoldText;
  final bool isLineThroughEnabled;
  final bool isDiscountedPrice;
  final bool isHourlyService;
  final bool isFreeService;
  final int? decimalPoint;
  final String? currencySymbol;

  PriceWidget({
    required this.price,
    this.size = 16.0,
    this.color,
    this.hourlyTextColor,
    this.isLineThroughEnabled = false,
    this.isBoldText = true,
    this.isDiscountedPrice = false,
    this.isHourlyService = false,
    this.isFreeService = false,
    this.decimalPoint,
    this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    TextDecoration? textDecoration() =>
        isLineThroughEnabled ? TextDecoration.lineThrough : null;

    TextStyle _textStyle({int? aSize}) {
      return isBoldText
          ? context.boldTextStyle(
              size: aSize ?? size!.toInt(),
              color: color ?? primaryColor,
              decoration: textDecoration(),
              textDecorationStyle: TextDecorationStyle.solid)
          : context.secondaryTextStyle(
              size: aSize ?? size!.toInt(),
              color: color ?? primaryColor,
              decoration: textDecoration(),
              textDecorationStyle: TextDecorationStyle.solid,
            );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "${isDiscountedPrice ? ' -' : ''}",
          style: _textStyle(),
        ),
        Observer(
          builder: (_) {
            String finalCurrencySymbol;
            if (currencySymbol != null && currencySymbol!.isNotEmpty) {
              finalCurrencySymbol = currencySymbol!.trim();
            } else if (appConfigurationStore.currencySymbol.isNotEmpty) {
              finalCurrencySymbol = appConfigurationStore.currencySymbol.trim();
            } else {
              // Set currency symbol based on language
              if (appStore.selectedLanguageCode == 'en') {
                finalCurrencySymbol = '₹'; // Indian Rupee for English
              } else {
                finalCurrencySymbol = '\$'; // Default to dollar
              }
            }
            return Row(
              children: [
                if (isFreeService)
                  Text(language.lblFree, style: _textStyle())
                else ...[
                  Text(
                    '$finalCurrencySymbol ',
                    style: _textStyle(),
                  ),
                  Text(
                    price
                        .toStringAsFixed(
                            appConfigurationStore.priceDecimalPoint)
                        .formatNumberWithComma(),
                    style: _textStyle(),
                  ),
                ],
                if (isHourlyService)
                  Text(
                    '/${language.lblHr}',
                    style: context.secondaryTextStyle(
                        color: hourlyTextColor, size: 12),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
