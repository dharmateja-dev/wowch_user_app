import 'package:booking_system_flutter/component/app_common_dialog.dart';
import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/price_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/booking_data_model.dart';
import 'package:booking_system_flutter/screens/booking/component/edit_booking_service_dialog.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/service_detail_response.dart';
import '../../../network/rest_apis.dart';
import 'booking_slots.dart';

class BookingItemComponent extends StatefulWidget {
  final BookingData bookingData;

  BookingItemComponent({required this.bookingData});

  @override
  State<BookingItemComponent> createState() => _BookingItemComponentState();
}

class _BookingItemComponentState extends State<BookingItemComponent> {
  Widget _buildEditBookingWidget() {
    if (widget.bookingData.status == BookingStatusKeys.pending &&
        isDateTimeAfterNow) {
      return IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        style: const ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: ic_edit_square.iconImage(size: 16, color: context.iconColor),
        visualDensity: VisualDensity.compact,
        onPressed: () async {
          ServiceDetailResponse res = await getServiceDetails(
            serviceId: widget.bookingData.serviceId.validate(),
            customerId: appStore.userId,
            fromBooking: true,
          );

          if (widget.bookingData.isSlotBooking) {
            showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              isScrollControlled: true,
              isDismissible: true,
              shape: RoundedRectangleBorder(
                  borderRadius: radiusOnly(
                      topLeft: defaultRadius, topRight: defaultRadius)),
              builder: (_) {
                return DraggableScrollableSheet(
                  initialChildSize: 0.65,
                  minChildSize: 0.65,
                  maxChildSize: 1,
                  builder: (context, scrollController) => BookingSlotsComponent(
                    data: res,
                    bookingData: widget.bookingData,
                    showAppbar: true,
                    scrollController: scrollController,
                    onApplyClick: () {
                      setState(() {});
                    },
                  ),
                );
              },
            );
          } else {
            showInDialog(
              context,
              contentPadding: EdgeInsets.zero,
              hideSoftKeyboard: true,
              backgroundColor: context.cardColor,
              builder: (p0) {
                return AppCommonDialog(
                  title: language.lblUpdateDateAndTime,
                  child: EditBookingServiceDialog(data: widget.bookingData),
                );
              },
            );
          }
        },
      );
    }
    return const Offstage();
  }

  String buildTimeWidget({required BookingData bookingDetail}) {
    if (bookingDetail.bookingSlot == null) {
      return formatDate(bookingDetail.date.validate(), isTime: true);
    }
    return formatDate(
      getSlotWithDate(
          date: bookingDetail.date.validate(),
          slotTime: bookingDetail.bookingSlot.validate()),
      isTime: true,
    );
  }

  String get bookingAddress => widget.bookingData.isShopService
      ? widget.bookingData.shopInfo != null
          ? widget.bookingData.shopInfo!.buildFullAddress()
          : '---'
      : widget.bookingData.address.validate();

  String get providerName {
    if (widget.bookingData.handyman!.isEmpty) {
      return widget.bookingData.providerName.validate();
    } else if (widget.bookingData.isProviderAndHandymanSame) {
      return widget.bookingData.providerName.validate();
    } else {
      return widget.bookingData.handyman!.first.handyman!.displayName
          .validate();
    }
  }

  String get serviceImageUrl {
    if (widget.bookingData.isPackageBooking) {
      return widget.bookingData.bookingPackage!.imageAttachments
              .validate()
              .isNotEmpty
          ? widget.bookingData.bookingPackage!.imageAttachments
              .validate()
              .first
              .validate()
          : DEMO_SERVICE_IMAGE_URL;
    } else {
      return widget.bookingData.serviceAttachments.validate().isNotEmpty
          ? widget.bookingData.serviceAttachments!.first.validate()
          : DEMO_SERVICE_IMAGE_URL;
    }
  }

  String get serviceName {
    return widget.bookingData.isPackageBooking
        ? widget.bookingData.bookingPackage!.name.validate()
        : widget.bookingData.serviceName.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: darkGrey, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header Section - Image, Title, Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedImageWidget(
                  url: serviceImageUrl,
                  radius: 8,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              8.width,
              // Title, Booking ID, Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Name and Status Badge Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            serviceName,
                            style: boldTextStyle(size: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: widget.bookingData.status
                                .validate()
                                .getPaymentStatusBackgroundColor
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            widget.bookingData.status
                                .validate()
                                .toBookingStatus(),
                            style: TextStyle(
                              color: widget.bookingData.status
                                  .validate()
                                  .getPaymentStatusBackgroundColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    4.height,
                    // Booking ID
                    Text(
                      '${language.lblBookingID} #${widget.bookingData.id.validate()}',
                      style: primaryTextStyle(size: 12),
                    ),
                    8.height,
                    // Price Row
                    Row(
                      children: [
                        PriceWidget(
                            currencySymbol: '₹',
                            isFreeService:
                                widget.bookingData.type == SERVICE_TYPE_FREE,
                            price: widget.bookingData.totalAmount.validate(),
                            color: textPrimaryColorGlobal),
                        if (widget.bookingData.isHourlyService) ...[
                          6.width,
                          Text(
                            '₹ ${widget.bookingData.amount.validate().toStringAsFixed(0)}/hr',
                            style: primaryTextStyle(size: 12),
                          ),
                        ],
                        const Spacer(),
                        _buildEditBookingWidget(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          16.height,
          // Details Section
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFE8F3EC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Your Address Row
                _buildDetailRow(
                  label: widget.bookingData.isShopService
                      ? language.lblShopAddress
                      : language.hintAddress,
                  value: bookingAddress.isNotEmpty ? bookingAddress : '---',
                ),
                _buildDivider(),

                // Date & Time Row
                _buildDetailRow(
                  label: '${language.lblDate} & ${language.lblTime}',
                  value:
                      "${formatDate(widget.bookingData.date.validate())} ${language.at} ${buildTimeWidget(bookingDetail: widget.bookingData)}",
                ),
                _buildDivider(),

                // Provider Row
                _buildDetailRow(
                  label: widget.bookingData.handyman!.isEmpty
                      ? language.textProvider
                      : language.textHandyman,
                  value: providerName,
                ),

                // Payment Status Row (conditional)
                if (_shouldShowPaymentStatus()) ...[
                  _buildDivider(),
                  _buildDetailRow(
                    label: language.paymentStatus,
                    value: _getPaymentStatusText(),
                    valueColor: widget.bookingData.status
                        .validate()
                        .getPaymentStatusBackgroundColor,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: primaryTextStyle(size: 12),
          ),
          Expanded(
            child: Text(
              value,
              style: boldTextStyle(
                size: 12,
                color: valueColor,
              ),
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 4,
      color: context.dividerColor,
      thickness: 0.5,
    );
  }

  bool _shouldShowPaymentStatus() {
    if (widget.bookingData.paymentStatus != null &&
        (widget.bookingData.status == BookingStatusKeys.complete ||
            widget.bookingData.status == BookingStatusKeys.cancelled ||
            widget.bookingData.status == BookingStatusKeys.pending ||
            widget.bookingData.paymentStatus ==
                SERVICE_PAYMENT_STATUS_ADVANCE_PAID ||
            widget.bookingData.paymentStatus == SERVICE_PAYMENT_STATUS_PAID ||
            widget.bookingData.paymentStatus == PENDING_BY_ADMIN)) {
      return true;
    }

    if (widget.bookingData.paymentStatus == null &&
        (widget.bookingData.status == BookingStatusKeys.pending ||
            widget.bookingData.status == BookingStatusKeys.cancelled ||
            widget.bookingData.status == BookingStatusKeys.complete)) {
      return true;
    }

    return false;
  }

  String _getPaymentStatusText() {
    if (widget.bookingData.paymentStatus != null) {
      if ((widget.bookingData.paymentStatus == SERVICE_PAYMENT_STATUS_PAID ||
              widget.bookingData.paymentStatus == PENDING_BY_ADMIN) ||
          getPaymentStatusText(widget.bookingData.paymentStatus,
                  widget.bookingData.paymentMethod)
              .isNotEmpty) {
        return buildPaymentStatusWithMethod(
          widget.bookingData.paymentStatus.validate(),
          widget.bookingData.paymentMethod.validate(),
        );
      }
    }
    return widget.bookingData.status.validate().toBookingStatus();
  }

  bool get isDateTimeAfterNow {
    try {
      if (widget.bookingData.bookingSlot != null) {
        final bookingDateTimeForTimeSlots =
            widget.bookingData.date.validate().split(" ").isNotEmpty
                ? widget.bookingData.date.validate().split(" ").first
                : "";
        final bookingTimeForTimeSlots =
            widget.bookingData.bookingSlot.validate();
        return DateTime.parse(
                bookingDateTimeForTimeSlots + " " + bookingTimeForTimeSlots)
            .isAfter(DateTime.now());
      } else {
        return DateTime.parse(widget.bookingData.date.validate())
            .isAfter(DateTime.now());
      }
    } catch (e) {
      log('Error parsing date: $e');
      return false;
    }
  }
}
