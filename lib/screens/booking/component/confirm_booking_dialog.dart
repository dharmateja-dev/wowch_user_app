import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/package_data_model.dart';
import 'package:booking_system_flutter/model/service_detail_response.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/service/service_detail_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/extensions/num_extenstions.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:booking_system_flutter/model/booking_data_model.dart';
import '../../../model/booking_amount_model.dart';
import '../../../model/shop_model.dart';
import '../../../utils/app_configuration.dart';
import '../../../utils/common.dart';
import '../../../utils/constant.dart';
import '../../../utils/images.dart';
import '../../payment/payment_screen.dart';
import 'booking_confirmation_dialog.dart';

class ConfirmBookingDialog extends StatefulWidget {
  final ServiceDetailResponse data;
  final num? bookingPrice;
  final int qty;
  final String? couponCode;
  final BookingPackage? selectedPackage;
  final BookingAmountModel? bookingAmountModel;
  final ShopModel? shopModel;

  ConfirmBookingDialog(
      {required this.data,
      required this.bookingPrice,
      this.qty = 1,
      this.couponCode,
      this.selectedPackage,
      this.bookingAmountModel,
      this.shopModel});

  @override
  State<ConfirmBookingDialog> createState() => _ConfirmBookingDialogState();
}

class _ConfirmBookingDialogState extends State<ConfirmBookingDialog> {
  Map? selectedPackage;
  List<int> selectedService = [];

  bool isSelected = false;

  Future<void> bookServices() async {
    // Demo Mode logic
    if (demoModeStore.isDemoMode) {
      appStore.setLoading(true);

      // Simulate API delay
      await Future.delayed(Duration(seconds: 1));

      // Create mock booking data to add to store
      final bookingId = DateTime.now().millisecondsSinceEpoch % 100000;

      final booking = BookingData(
        id: bookingId,
        serviceName: widget.data.serviceDetail?.name,
        serviceId: widget.data.serviceDetail?.id,
        customerId: appStore.userId,
        customerName: appStore.userFullName,
        providerId: widget.data.provider?.id,
        providerName: widget.data.provider?.displayName,
        providerImage: widget.data.provider?.profileImage,
        status: BookingStatusKeys.pending,
        statusLabel: "Pending",
        date:
            widget.data.serviceDetail?.bookingDate ?? DateTime.now().toString(),
        bookingSlot: widget.data.serviceDetail?.bookingSlot,
        address: widget.data.serviceDetail?.address,
        description: widget.data.serviceDetail?.bookingDescription,
        type: widget.data.serviceDetail?.type,
        amount: widget.data.serviceDetail?.price,
        totalAmount: widget.bookingPrice,
        taxes: widget.data.taxes,
        discount: widget.data.serviceDetail?.discount,
        couponData: widget.couponCode != null
            ? CouponData(code: widget.couponCode)
            : null,
        finalTotalServicePrice:
            widget.bookingAmountModel?.finalTotalServicePrice,
        finalTotalTax: widget.bookingAmountModel?.finalTotalTax,
        finalSubTotal: widget.bookingAmountModel?.finalSubTotal,
        finalDiscountAmount: widget.bookingAmountModel?.finalDiscountAmount,
        finalCouponDiscountAmount:
            widget.bookingAmountModel?.finalCouponDiscountAmount,
        quantity: widget.qty,
        serviceAttachments: widget.data.serviceDetail?.attachments,
        handyman: [],
      );

      demoModeStore.addDemoBooking(booking);

      // Show success
      appStore.setLoading(false);
      finish(context);

      showInDialog(
        context,
        barrierDismissible: false,
        builder: (BuildContext context) => BookingConfirmationDialog(
          data: widget.data,
          bookingId: bookingId,
          bookingPrice: widget.bookingPrice,
          selectedPackage: widget.selectedPackage,
          bookingDetailResponse: null,
        ),
        backgroundColor: transparentColor,
        contentPadding: EdgeInsets.zero,
      );
      return;
    }

    if (widget.selectedPackage != null) {
      if (widget.selectedPackage!.serviceList != null) {
        widget.selectedPackage!.serviceList!.forEach((element) {
          selectedService.add(element.id.validate());
        });
      }

      selectedPackage = {
        PackageKey.packageId: widget.selectedPackage!.id.validate(),
        PackageKey.categoryId: widget.selectedPackage!.categoryId != -1
            ? widget.selectedPackage!.categoryId.validate()
            : null,
        PackageKey.name: widget.selectedPackage!.name.validate(),
        PackageKey.price: widget.selectedPackage!.price.validate(),
        PackageKey.serviceId: selectedService.join(','),
        PackageKey.startDate: widget.selectedPackage!.startDate.validate(),
        PackageKey.endDate: widget.selectedPackage!.endDate.validate(),
        PackageKey.isFeatured:
            widget.selectedPackage!.isFeatured == 1 ? '1' : '0',
        PackageKey.packageType: widget.selectedPackage!.packageType.validate(),
      };
    }

    log("selectedPackage: ${[selectedPackage]}");

    Map request = {
      CommonKeys.id: "",
      CommonKeys.serviceId: widget.data.serviceDetail!.id.toString(),
      CommonKeys.providerId: widget.data.provider!.id.validate().toString(),
      CommonKeys.customerId: appStore.userId.toString(),
      BookingServiceKeys.description:
          widget.data.serviceDetail!.bookingDescription.validate(),
      CommonKeys.address: widget.data.serviceDetail!.address.validate(),
      CommonKeys.date: widget.data.serviceDetail!.isSlotAvailable
          ? widget.data.serviceDetail!.bookingDate.validate()
          : widget.data.serviceDetail!.dateTimeVal.validate(),
      BookingServiceKeys.couponId: widget.couponCode.validate(),
      BookService.amount: widget.selectedPackage != null
          ? widget.selectedPackage!.price
          : widget.data.serviceDetail!.price,
      BookService.quantity: '${widget.qty}',
      BookingServiceKeys.totalAmount: !widget.data.serviceDetail!.isFreeService
          ? widget.bookingPrice
              .validate()
              .toStringAsFixed(getIntAsync(PRICE_DECIMAL_POINTS))
          : 0,
      CouponKeys.discount: widget.data.serviceDetail!.discount != null
          ? widget.data.serviceDetail!.discount.toString()
          : "",
      BookService.bookingAddressId:
          widget.data.serviceDetail!.bookingAddressId != -1
              ? widget.data.serviceDetail!.bookingAddressId
              : null,
      BookingServiceKeys.type: BOOKING_TYPE_SERVICE,
      BookingServiceKeys.bookingPackage:
          widget.selectedPackage != null ? selectedPackage : null,
      BookingServiceKeys.serviceAddonId:
          serviceAddonStore.selectedServiceAddon.map((e) => e.id).toList(),
    };

    // Add shop information if this is a shop service
    if (widget.data.serviceDetail!.visitType?.trim().toLowerCase() ==
            VISIT_OPTION_ON_SHOP &&
        widget.data.shops.isNotEmpty) {
      final selectedShop = widget.shopModel ?? widget.data.shops.first;
      request.putIfAbsent(ShopKey.shopId, () => selectedShop.id);
      request.putIfAbsent(ShopKey.shopName, () => selectedShop.name);
      request.putIfAbsent(ShopKey.shopAddress, () => selectedShop.address);
      request.putIfAbsent(ShopKey.shopCity, () => selectedShop.cityName);
      request.putIfAbsent(ShopKey.shopState, () => selectedShop.stateName);
      request.putIfAbsent(ShopKey.shopCountry, () => selectedShop.countryName);
      request.putIfAbsent(ShopKey.shopEmail, () => selectedShop.email);
      request.putIfAbsent(
          ShopKey.shopContactNumber, () => selectedShop.contactNumber);
      request.putIfAbsent(ShopKey.shopImage, () => selectedShop.shopImage);
    }

    if (widget.bookingAmountModel != null) {
      request.addAll(widget.bookingAmountModel!.toJson());
    }

    if (widget.data.serviceDetail!.isSlotAvailable) {
      request.putIfAbsent(BookingServiceKeys.bookingDate,
          () => widget.data.serviceDetail!.bookingDate.validate().toString());
      request.putIfAbsent(BookingServiceKeys.bookingSlot,
          () => widget.data.serviceDetail!.bookingSlot.validate().toString());
      request.putIfAbsent(BookingServiceKeys.bookingDay,
          () => widget.data.serviceDetail!.bookingDay.validate().toString());
    }

    if (!widget.data.serviceDetail!.isFreeService &&
        widget.data.taxes.validate().isNotEmpty) {
      request.putIfAbsent(BookingServiceKeys.tax, () => widget.data.taxes);
    }
    if (widget.data.serviceDetail != null &&
        widget.data.serviceDetail!.isAdvancePayment &&
        !widget.data.serviceDetail!.isFreeService &&
        widget.data.serviceDetail!.isFixedService) {
      request.putIfAbsent(
          CommonKeys.status, () => BookingStatusKeys.waitingAdvancedPayment);
    }

    appStore.setLoading(true);

    await saveBooking(request).then((bookingDetailResponse) async {
      appStore.setLoading(false);

      if (widget.data.serviceDetail != null &&
          widget.data.serviceDetail!.isAdvancePayment &&
          !widget.data.serviceDetail!.isFreeService &&
          widget.data.serviceDetail!.isFixedService) {
        finish(context);
        PaymentScreen(
                bookings: bookingDetailResponse, isForAdvancePayment: true)
            .launch(context);
      } else {
        finish(context);
        showInDialog(
          context,
          barrierDismissible: false,
          builder: (BuildContext context) => BookingConfirmationDialog(
            data: widget.data,
            bookingId: bookingDetailResponse.bookingDetail!.id,
            bookingPrice: widget.bookingPrice,
            selectedPackage: widget.selectedPackage,
            bookingDetailResponse: bookingDetailResponse,
          ),
          backgroundColor: transparentColor,
          contentPadding: EdgeInsets.zero,
        );
      }
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Checkmark icon in circle
            SvgPicture.asset(
              icVerifiedCheck,
              height: 90,
              width: 90,
            ),
            16.height,
            // Title
            Text(
              language.lblConfirmBooking,
              style: boldTextStyle(size: 24),
              textAlign: TextAlign.center,
            ),
            12.height,
            // Subtitle
            Text(
              language.doYouWantToConfirmBooking,
              style: primaryTextStyle(
                size: 16,
              ),
              textAlign: TextAlign.center,
            ),

            // Cancellation notice
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: boxDecorationWithRoundedCorners(
                borderRadius: BorderRadius.circular(8),
                backgroundColor: cancellationsBgColor,
              ),
              child: Text(
                '* ${language.a} ${appConfigurationStore.cancellationChargeAmount}% ${language.feeAppliesForCancellations} ${appConfigurationStore.cancellationChargeHours} ${language.hoursOfTheScheduled}',
                style: secondaryTextStyle(
                    size: 10,
                    color: redColor,
                    fontStyle: FontStyle.italic,
                    weight: FontWeight.w600),
              ),
            ).visible(!widget.data.serviceDetail!.isFreeService &&
                appConfigurationStore.cancellationCharge),
            16.height,
            // Checkbox with Terms and Privacy Policy
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    shape: RoundedRectangleBorder(borderRadius: radius(2)),
                    activeColor: context.primaryColor,
                    checkColor: Colors.white,
                    value: isSelected,
                    onChanged: (val) {
                      isSelected = !isSelected;
                      setState(() {});
                    },
                  ),
                ),
                10.width,
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${language.iAgreeToYour}  ',
                          style: boldTextStyle(size: 14),
                        ),
                        TextSpan(
                          text: language.termsAndPrivacy,
                          style: boldTextStyle(
                              color: context.primaryColor, size: 14),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              checkIfLink(
                                  context, appConfigurationStore.termConditions,
                                  title: language.termsCondition);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            16.height,
            // Buttons row
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      finish(context);
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide.none,
                    ),
                    child: Text(
                      language.lblCancel,
                      style:
                          boldTextStyle(color: context.primaryColor, size: 16),
                    ),
                  ),
                ),
                16.width,
                // Confirm button
                Expanded(
                  child: AppButton(
                    textStyle: boldTextStyle(
                        size: 16, color: isSelected ? Colors.white : darkGray),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    text: language.confirm,
                    color: isSelected
                        ? context.primaryColor
                        : context.dividerColor,
                    shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: () {
                      if (isSelected) {
                        bookServices();
                      } else {
                        toast(language.termsConditionsAccept);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ).paddingAll(12).visible(
              !appStore.isLoading,
              defaultWidget: LoaderWidget().withSize(width: 250, height: 280),
            );
      },
    );
  }
}

Widget serviceDetailsWidget(String title, String value, bool isPrice) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title,
              style: secondaryTextStyle(
                  size: 12,
                  color:
                      appStore.isDarkMode ? darkGray : appTextSecondaryColor))
          .expand(flex: 2),
      Text(isPrice ? num.parse(value).toPriceFormat() : value,
              style: boldTextStyle(size: 12))
          .expand(flex: 3),
    ],
  ).paddingBottom(6.0);
}
