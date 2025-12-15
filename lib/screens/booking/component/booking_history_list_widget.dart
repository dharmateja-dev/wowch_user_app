import 'package:booking_system_flutter/model/booking_detail_model.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/dashed_rect.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class BookingHistoryListWidget extends StatelessWidget {
  const BookingHistoryListWidget(
      {Key? key, required this.data, required this.index, required this.length})
      : super(key: key);

  final BookingActivity data;
  final int index;
  final int length;

  String _getActivityTypeLabel(String activityType) {
    final normalized = activityType.toLowerCase().replaceAll(' ', '_');
    switch (normalized) {
      case ADD_BOOKING:
        return 'Add Booking';
      case PAYMENT_MESSAGE_STATUS:
        return 'Payment Message Status';
      case UPDATE_BOOKING_STATUS:
        // Check activityData for status label
        try {
          final activityData = data.activityData;
          if (activityData != null && activityData.contains('"label"')) {
            // Try to extract label from JSON
            final match =
                RegExp(r'"label":\s*"([^"]+)"').firstMatch(activityData);
            if (match != null) {
              return match.group(1) ?? 'Update Booking';
            }
          }
        } catch (e) {
          // Fallback to default
        }
        return 'Update Booking';
      case CANCEL_BOOKING:
        // Check activityData for status label
        try {
          final activityData = data.activityData;
          if (activityData != null && activityData.contains('"label"')) {
            final match =
                RegExp(r'"label":\s*"([^"]+)"').firstMatch(activityData);
            if (match != null) {
              return match.group(1) ?? 'Cancel Booking';
            }
          }
        } catch (e) {
          // Fallback to default
        }
        return 'Cancel Booking';
      case ASSIGNED_BOOKING:
        return 'Assigned Booking';
      case TRANSFER_BOOKING:
        return 'Transfer Booking';
      default:
        return activityType.replaceAll('_', ' ').capitalizeFirstLetter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            data.datetime.validate().toString().isNotEmpty
                ? Text(
                    formatDate(data.datetime..validate().toString()),
                    style: context.primaryTextStyle(
                      size: 12,
                    ),
                  )
                : const SizedBox(),
            8.height,
            data.datetime.validate().toString().isNotEmpty
                ? Text(
                    formatDate(data.datetime..validate().toString(),
                        isTime: true),
                    style: context.primaryTextStyle(size: 12),
                  )
                : const SizedBox(),
          ],
        ).withWidth(70),
        16.width,
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                color:
                    data.activityType.validate().getBookingActivityStatusColor,
                borderRadius: radius(16),
              ),
            ),
            SizedBox(
              height: 65,
              child: DashedRect(
                gap: 3,
                color:
                    data.activityType.validate().getBookingActivityStatusColor,
                strokeWidth: 1.5,
              ),
            ).visible(index != length - 1),
          ],
        ),
        16.width,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _getActivityTypeLabel(data.activityType.validate()),
              style: context.boldTextStyle(size: 14),
            ),
            Text(
              data.activityMessage.validate().replaceAll('_', ' '),
              style: context.primaryTextStyle(size: 12),
            ).paddingOnly(left: 4, bottom: 4),
          ],
        ).paddingOnly(bottom: 18).expand()
      ],
    );
  }
}
