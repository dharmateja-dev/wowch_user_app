import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

class SlotWidget extends StatelessWidget {
  final bool isAvailable;
  final bool isSelected;
  final String value;
  final Color? activeColor;
  final Color? inActiveColor;
  final Function() onTap;

  SlotWidget({
    required this.isAvailable,
    required this.isSelected,
    required this.value,
    this.activeColor,
    this.inActiveColor,
    required this.onTap,
  });

  Color _getActiveColor(BuildContext context) => activeColor ?? context.primary;

  Color _getBackgroundColor(BuildContext context) {
    if (isAvailable && isSelected) {
      return _getActiveColor(context);
    } else if (isSelected) {
      return _getActiveColor(context);
    } else {
      return context.cardColor;
    }
  }

  Color _getTextColor(BuildContext context) {
    if (isAvailable && isSelected) {
      return context.onPrimary;
    } else if (isSelected) {
      return context.onPrimary;
    } else {
      return context.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.width() / 3 - 22,
        decoration: boxDecorationDefault(
          boxShadow: defaultBoxShadow(blurRadius: 0, spreadRadius: 0),
          border: Border.all(
            color: isAvailable ? _getActiveColor(context) : transparentColor,
          ),
          color: _getBackgroundColor(context),
        ),
        padding: EdgeInsets.all(12),
        child: Observer(builder: (context) {
          return Text(
            appStore.is24HourFormat
                ? value.splitBefore(':00')
                : TimeOfDay(hour: value.split(':').first.toInt(), minute: 00)
                    .format(context),
            style: context.primaryTextStyle(color: _getTextColor(context)),
          ).center();
        }),
      ),
    );
  }
}
