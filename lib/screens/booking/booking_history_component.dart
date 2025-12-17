import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/booking_detail_model.dart';
import 'package:booking_system_flutter/screens/booking/component/booking_history_list_widget.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class BookingHistoryComponent extends StatefulWidget {
  final List<BookingActivity> data;
  final ScrollController scrollController;

  BookingHistoryComponent({required this.data, required this.scrollController});

  @override
  BookingHistoryComponentState createState() => BookingHistoryComponentState();
}

class BookingHistoryComponentState extends State<BookingHistoryComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationWithRoundedCorners(
          borderRadius:
              radiusOnly(topLeft: defaultRadius, topRight: defaultRadius),
          backgroundColor: context.bottomSheetBackgroundColor),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            16.height,
            Container(
              width: 50,
              height: 4,
              decoration: boxDecorationDefault(color: context.mainBorderColor),
            ).center().paddingSymmetric(vertical: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(language.bookingHistory, style: context.boldTextStyle()),
                if (widget.data.validate().isNotEmpty)
                  Text(' #' + widget.data[0].bookingId.validate().toString(),
                      style: context.boldTextStyle(
                          color: context.dialogCancelColor))
              ],
            ).paddingSymmetric(horizontal: 12),
            8.height,
            Divider(color: context.primary, thickness: 0.8),
            8.height,
            widget.data.isNotEmpty
                ? AnimatedListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.data.length,
                    listAnimationType: ListAnimationType.FadeIn,
                    fadeInConfiguration:
                        FadeInConfiguration(duration: 2.seconds),
                    itemBuilder: (_, i) {
                      BookingActivity data = widget.data[i];
                      return BookingHistoryListWidget(
                          data: data,
                          index: i,
                          length: widget.data.length.validate());
                    },
                  ).paddingSymmetric(horizontal: 12)
                : Text(language.noDataAvailable).center().paddingAll(16),
          ],
        ),
      ),
    );
  }
}
