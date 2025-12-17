import 'package:booking_system_flutter/component/price_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/booking_data_model.dart';
import 'package:booking_system_flutter/model/package_data_model.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/model/service_detail_response.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import 'applied_tax_list_bottom_sheet.dart';

class PriceCommonWidget extends StatelessWidget {
  final BookingData bookingDetail;
  final ServiceData serviceDetail;
  final List<TaxData> taxes;
  final CouponData? couponData;
  final BookingPackage? bookingPackage;

  const PriceCommonWidget({
    Key? key,
    required this.bookingDetail,
    required this.serviceDetail,
    required this.taxes,
    required this.couponData,
    required this.bookingPackage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (bookingDetail.isFreeService &&
        bookingDetail.bookingType.validate() == BOOKING_TYPE_SERVICE)
      return const Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        Text(
          language.paymentDetail,
          style: context.boldTextStyle(),
        ),
        16.height,
        Container(
          padding: const EdgeInsets.all(12),
          width: context.width(),
          decoration: BoxDecoration(
            color: context.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Price row
              if (bookingDetail.bookingType.validate() ==
                      BOOKING_TYPE_SERVICE ||
                  bookingDetail.bookingType.validate() ==
                      BOOKING_TYPE_USER_POST_JOB)
                _buildPriceRow(
                  context: context,
                  label: language.lblPrice,
                  price: bookingPackage != null
                      ? bookingPackage!.price.validate()
                      : bookingDetail.isFixedService
                          ? bookingDetail.finalTotalServicePrice.validate()
                          : bookingDetail.amount.validate(),
                ),

              // Coupon row
              if (couponData != null)
                _buildPriceRow(
                  context: context,
                  label: '${language.lblCoupon} (${couponData!.code})',
                  price: bookingDetail.finalCouponDiscountAmount.validate(),
                  priceColor: context.primaryColor,
                  isDiscount: true,
                ),

              // Discount row
              if (bookingDetail.finalDiscountAmount != 0 &&
                  bookingDetail.bookingType.validate() == BOOKING_TYPE_SERVICE)
                _buildPriceRow(
                  context: context,
                  label:
                      '${language.lblDiscount} (${bookingDetail.discount.validate()}%)',
                  price: bookingDetail.finalDiscountAmount.validate(),
                  priceColor: context.primaryColor,
                  isDiscount: true,
                ),

              // Service Add-ons
              if (bookingDetail.serviceaddon.validate().isNotEmpty)
                _buildPriceRow(
                  context: context,
                  label: language.serviceAddOns,
                  price: bookingDetail.serviceaddon
                      .validate()
                      .sumByDouble((p0) => p0.price),
                ),

              // Extra Charges
              if (bookingDetail.totalExtraChargeAmount != 0)
                _buildPriceRow(
                  context: context,
                  label: language.lblTotalExtraCharges,
                  price: bookingDetail.totalExtraChargeAmount,
                ),

              // Subtotal row
              if (bookingDetail.isHourlyService || bookingDetail.isFixedService)
                _buildPriceRow(
                  context: context,
                  label: language.lblSubTotal,
                  price: (bookingDetail.finalSubTotal == null &&
                          bookingDetail.bookingType.validate() ==
                              BOOKING_TYPE_USER_POST_JOB)
                      ? bookingDetail.amount.validate()
                      : bookingDetail.finalSubTotal.validate(),
                ),

              // Tax row
              if (bookingDetail.finalTotalTax.validate() != 0 &&
                  bookingDetail.bookingType.validate() == BOOKING_TYPE_SERVICE)
                _buildTaxRow(context),

              // Advance Payment row
              if (serviceDetail.isAdvancePayment &&
                  serviceDetail.isFixedService &&
                  !serviceDetail.isFreeService)
                _buildPriceRow(
                  context: context,
                  label: bookingDetail.paidAmount.validate() != 0
                      ? '${language.advancePaid} (${serviceDetail.advancePaymentPercentage.validate()}%)'
                      : '${language.advancePayment} (${serviceDetail.advancePaymentPercentage.validate()}%)',
                  price: getAdvancePaymentAmount,
                  priceColor: primaryColor,
                ),

              // Remaining Amount row
              if (serviceDetail.isAdvancePayment &&
                  bookingDetail.paidAmount.validate() != 0 &&
                  serviceDetail.isFixedService &&
                  !serviceDetail.isFreeService &&
                  bookingDetail.status.validate().toLowerCase() !=
                      BOOKING_STATUS_CANCELLED)
                _buildPriceRow(
                  context: context,
                  label: language.remainingAmount,
                  price: getRemainingAmount,
                  priceColor: primaryColor,
                ),

              // Total Amount row
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        language.totalAmount,
                        style: context.primaryTextStyle(size: 12),
                      ).expand(),
                      PriceWidget(
                        currencySymbol: '₹',
                        size: 12,
                        price: bookingDetail.totalAmount.validate(),
                        color: context.primary,
                        isBoldText: true,
                      ),
                    ],
                  ),
                ],
              ),

              // Hourly Service Detail
              if (bookingDetail.isHourlyService &&
                  bookingDetail.status == BookingStatusKeys.complete)
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    "${language.lblOnBase} ${calculateTimer(bookingDetail.durationDiff.validate().toInt())} ${getMinHour(durationDiff: bookingDetail.durationDiff.validate())}",
                    style: context.primaryTextStyle(size: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow({
    required BuildContext context,
    required String label,
    required num price,
    Color? priceColor,
    bool isDiscount = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: context.primaryTextStyle(size: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            16.width,
            PriceWidget(
              currencySymbol: '₹',
              size: 12,
              price: price,
              color: priceColor ?? context.onSurface,
              isBoldText: true,
              isDiscountedPrice: isDiscount,
            ),
          ],
        ),
        Divider(
          height: 26,
          color: context.dividerOnSecondaryContainerColor,
          thickness: 0.5,
        ),
      ],
    );
  }

  Widget _buildTaxRow(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Row(
              children: [
                Text(
                  language.lblTax,
                  style: context.primaryTextStyle(size: 12),
                ),
                8.width,
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return AppliedTaxListBottomSheet(
                          taxes: bookingDetail.taxes.validate(),
                          subTotal: bookingDetail.finalSubTotal.validate(),
                        );
                      },
                    );
                  },
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: context.primaryColor,
                  ),
                ),
              ],
            ).expand(),
            16.width,
            PriceWidget(
              currencySymbol: '₹',
              size: 12,
              price: bookingDetail.finalTotalTax.validate(),
              color: context.error,
              isBoldText: true,
            ),
          ],
        ),
        Divider(
          height: 26,
          color: context.dividerOnSecondaryContainerColor,
          thickness: 0.5,
        ),
      ],
    );
  }

  num get getAdvancePaymentAmount {
    if (bookingDetail.paidAmount.validate() != 0) {
      return bookingDetail.paidAmount!;
    } else {
      return bookingDetail.totalAmount.validate() *
          serviceDetail.advancePaymentPercentage.validate() /
          100;
    }
  }

  num get getRemainingAmount {
    if (bookingDetail.paidAmount.validate() == 0) {
      return bookingDetail.totalAmount.validate();
    } else {
      return bookingDetail.totalAmount.validate() - getAdvancePaymentAmount;
    }
  }

  String getMinHour({required String durationDiff}) {
    String totalTime = calculateTimer(durationDiff.toInt());
    List<String> totalHours = totalTime.split(":");
    if (totalHours.first == "00") {
      return language.min;
    } else {
      return language.hour;
    }
  }
}
