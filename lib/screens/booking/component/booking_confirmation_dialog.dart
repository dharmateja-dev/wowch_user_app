import 'package:booking_system_flutter/model/package_data_model.dart';
import 'package:booking_system_flutter/screens/booking/booking_detail_screen.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../model/booking_detail_model.dart';
import '../../../model/service_detail_response.dart';
import '../../../utils/common.dart';
import '../../../utils/constant.dart';
import '../../../utils/images.dart';
import '../../dashboard/dashboard_screen.dart';

class BookingConfirmationDialog extends StatefulWidget {
  final ServiceDetailResponse data;
  final int? bookingId;
  final num? bookingPrice;
  final BookingPackage? selectedPackage;
  final BookingDetailResponse? bookingDetailResponse;

  const BookingConfirmationDialog({
    required this.data,
    required this.bookingId,
    this.bookingPrice,
    this.selectedPackage,
    this.bookingDetailResponse,
  });

  @override
  State<BookingConfirmationDialog> createState() =>
      _BookingConfirmationDialogState();
}

class _BookingConfirmationDialogState extends State<BookingConfirmationDialog> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  Widget buildDateWidget() {
    if (widget.data.serviceDetail!.isSlotAvailable) {
      return Text(
          formatBookingDate(widget.data.serviceDetail!.bookingDate.validate(),
              format: DATE_FORMAT_2),
          style: context.boldTextStyle(size: 14, color: context.primaryColor));
    }
    return Text(
        formatBookingDate(widget.data.serviceDetail!.dateTimeVal.validate(),
            format: DATE_FORMAT_2),
        style: context.boldTextStyle(size: 14, color: context.primaryColor));
  }

  Widget buildTimeWidget() {
    if (widget.data.serviceDetail!.bookingSlot == null) {
      return Text(
          formatBookingDate(widget.data.serviceDetail!.dateTimeVal.validate(),
              format: HOUR_12_FORMAT),
          style: context.boldTextStyle(size: 14, color: context.primaryColor),
          textAlign: TextAlign.end);
    }
    return Text(
      TimeOfDay(
        hour: widget.data.serviceDetail!.bookingSlot
            .validate()
            .splitBefore(':')
            .split(":")
            .first
            .toInt(),
        minute: widget.data.serviceDetail!.bookingSlot
            .validate()
            .splitBefore(':')
            .split(":")
            .last
            .toInt(),
      ).format(context),
      style: context.boldTextStyle(size: 14, color: context.primaryColor),
      textAlign: TextAlign.end,
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: radius(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Verified check icon
          SvgPicture.asset(
            icVerifiedCheck,
            height: 80,
            width: 80,
          ),
          20.height,
          // Thank You title
          Text(
            language.thankYou,
            style: context.boldTextStyle(size: 22),
            textAlign: TextAlign.center,
          ),
          8.height,
          // Booking confirmed message
          Text(
            language.bookingConfirmedMsg,
            style: context.primaryTextStyle(size: 14),
            textAlign: TextAlign.center,
          ),
          24.height,
          // Date and Time container with dashed border
          DottedBorderWidget(
            color: context.primaryColor.withValues(alpha: 0.7),
            strokeWidth: 1,
            gap: 2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            radius: 2,
            child: Row(
              children: [
                // Date column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(language.lblDate, style: context.primaryTextStyle()),
                      4.height,
                      buildDateWidget(),
                    ],
                  ),
                ),
                // Time column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(language.lblTime, style: context.primaryTextStyle()),
                    4.height,
                    buildTimeWidget(),
                  ],
                ),
              ],
            ),
          ),
          24.height,
          // Buttons row
          Row(
            children: [
              // Go To Review button (outlined)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    DashboardScreen(redirectToBooking: true).launch(context,
                        isNewTask: true,
                        pageRouteAnimation: PageRouteAnimation.Fade);
                    BookingDetailScreen(bookingId: widget.bookingId.validate())
                        .launch(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide.none,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    language.goToReview,
                    style: context.boldTextStyle(
                        color: context.primaryColor, size: 14),
                  ),
                ),
              ),
              16.width,
              // Go To Home button (filled)
              Expanded(
                child: AppButton(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  text: language.goToHome,
                  textStyle:
                      context.boldTextStyle(size: 14, color: Colors.white),
                  color: context.primaryColor,
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () {
                    DashboardScreen().launch(context, isNewTask: true);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
