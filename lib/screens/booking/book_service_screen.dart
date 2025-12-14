import 'package:booking_system_flutter/component/base_scaffold_body.dart';
import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/price_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/package_data_model.dart';
import 'package:booking_system_flutter/model/service_detail_response.dart';
import 'package:booking_system_flutter/model/shop_model.dart';
import 'package:booking_system_flutter/screens/booking/component/confirm_booking_dialog.dart';
import 'package:booking_system_flutter/screens/map/map_screen.dart';
import 'package:booking_system_flutter/screens/service/service_detail_screen.dart';
import 'package:booking_system_flutter/screens/shop/shop_list_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/wallet_balance_component.dart';
import '../../../model/booking_amount_model.dart';
import '../../../utils/booking_calculations_logic.dart';
import '../../app_theme.dart';
import '../../component/back_widget.dart';
import '../../component/chat_gpt_loder.dart';
import '../../generated/assets.dart';
import '../../services/location_service.dart';
import '../../utils/permissions.dart';
import '../service/addons/service_addons_component.dart';
import 'component/applied_tax_list_bottom_sheet.dart';
import 'component/booking_slots.dart';
import 'component/coupon_list_screen.dart';

class BookServiceScreen extends StatefulWidget {
  final ServiceDetailResponse data;
  final BookingPackage? selectedPackage;
  final ShopModel? selectedShop;
  final int? serviceId;

  BookServiceScreen({
    required this.data,
    this.selectedPackage,
    this.selectedShop,
    this.serviceId,
  });

  @override
  _BookServiceScreenState createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  CouponData? appliedCouponData;

  BookingAmountModel bookingAmountModel = BookingAmountModel();
  num advancePaymentAmount = 0;

  int itemCount = 1;
  ShopModel? selectedShop;

  TextEditingController addressCont = TextEditingController();
  TextEditingController descriptionCont = TextEditingController();

  TextEditingController dateTimeCont = TextEditingController();
  DateTime currentDateTime = DateTime.now();
  DateTime? selectedDate;
  DateTime? finalDate;
  DateTime? packageExpiryDate;
  TimeOfDay? pickedTime;

  @override
  void initState() {
    super.initState();
    init();

    if (widget.selectedPackage != null &&
        widget.selectedPackage!.endDate.validate().isNotEmpty) {
      packageExpiryDate =
          DateTime.parse(widget.selectedPackage!.endDate.validate());
    }
  }

  void init() async {
    setPrice();
    // Set default selected shop if available
    if (widget.selectedShop != null) {
      selectedShop = widget.selectedShop;
    }
    try {
      if (widget.data.serviceDetail != null) {
        if (widget.data.serviceDetail!.dateTimeVal != null) {
          if (widget.data.serviceDetail!.isSlotAvailable.validate()) {
            dateTimeCont.text = formatBookingDate(
                widget.data.serviceDetail!.dateTimeVal.validate(),
                format: DATE_FORMAT_1);
            selectedDate = DateTime.parse(
                widget.data.serviceDetail!.dateTimeVal.validate());
            pickedTime = TimeOfDay.fromDateTime(selectedDate!);
          }
          addressCont.text = widget.data.serviceDetail!.address.validate();
        }
      }
    } catch (e) {}
    setState(() {});
  }

  void _handleSetLocationClick() {
    Permissions.cameraFilesAndLocationPermissionsGranted().then((value) async {
      await setValue(PERMISSION_STATUS, value);

      if (value) {
        String? res = await MapScreen(
                latitude: getDoubleAsync(LATITUDE),
                latLong: getDoubleAsync(LONGITUDE))
            .launch(context);

        addressCont.text = res.validate();
        setState(() {});
      }
    });
  }

  void _handleCurrentLocationClick() {
    Permissions.cameraFilesAndLocationPermissionsGranted().then((value) async {
      await setValue(PERMISSION_STATUS, value);

      if (value) {
        appStore.setLoading(true);

        await getUserLocation().then((value) {
          addressCont.text = value;
          widget.data.serviceDetail!.address = value.toString();
          setState(() {});
        }).catchError((e) {
          log(e);
          // toast(e.toString());
        });

        appStore.setLoading(false);
      }
    }).catchError((e) {
      //
    }).whenComplete(() => appStore.setLoading(false));
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void setPrice() {
    bookingAmountModel = finalCalculations(
      servicePrice: widget.data.serviceDetail!.price.validate(),
      appliedCouponData: appliedCouponData,
      serviceAddons: serviceAddonStore.selectedServiceAddon,
      discount: widget.data.serviceDetail!.discount.validate(),
      taxes: widget.data.taxes,
      quantity: itemCount,
      selectedPackage: widget.selectedPackage,
    );

    if (bookingAmountModel.finalSubTotal.isNegative) {
      appliedCouponData = null;
      setPrice();

      toast(language.youCannotApplyThisCoupon);
    } else {
      advancePaymentAmount = bookingAmountModel.finalGrandTotalAmount *
          (widget.data.serviceDetail!.advancePaymentPercentage.validate() / 100)
              .toStringAsFixed(appConfigurationStore.priceDecimalPoint)
              .toDouble();
    }
    setState(() {});
  }

  void applyCoupon({bool isApplied = false}) async {
    hideKeyboard(context);
    if (widget.data.serviceDetail != null &&
        widget.data.serviceDetail!.id != null) {
      var value = await CouponsScreen(
              serviceId: widget.data.serviceDetail!.id!.toInt(),
              servicePrice: bookingAmountModel.finalTotalServicePrice,
              appliedCouponData: appliedCouponData,
              price: (widget.data.serviceDetail!.price.validate() * itemCount))
          .launch(context);
      if (value != null) {
        if (value is bool && !value) {
          appliedCouponData = null;
        } else if (value is CouponData) {
          appliedCouponData = value;
        } else {
          appliedCouponData = null;
        }
        setPrice();
      }
    }
  }

  void selectDateAndTime(BuildContext context) async {
    if (packageExpiryDate != null &&
        currentDateTime.isAfter(packageExpiryDate!)) {
      return toast(language.packageIsExpired);
    }

    await showDatePicker(
      context: context,
      initialDate: selectedDate ?? currentDateTime,
      firstDate: currentDateTime,
      lastDate: packageExpiryDate ?? currentDateTime.add(30.days),
      locale: Locale(appStore.selectedLanguageCode),
      cancelText: language.lblCancel,
      confirmText: language.lblOk,
      helpText: language.lblSelectDate,
      builder: (_, child) {
        return Theme(
          data: appStore.isDarkMode ? ThemeData.dark() : AppTheme.lightTheme(),
          child: child!,
        );
      },
    ).then((date) async {
      TimeOfDay initialTime = pickedTime ??
          (selectedShop != null
              ? TimeOfDay.fromDateTime(currentDateTime.add(1.hours))
              : TimeOfDay.now());
      if (date != null) {
        await showTimePicker(
          context: context,
          initialTime: initialTime,
          cancelText: language.lblCancel,
          confirmText: language.lblOk,
          builder: (_, child) {
            return Theme(
              data: appStore.isDarkMode
                  ? ThemeData.dark()
                  : AppTheme.lightTheme(),
              child: child!,
            );
          },
        ).then((time) {
          if (time != null) {
            finalDate = DateTime(
                date.year, date.month, date.day, time.hour, time.minute);

            DateTime now = DateTime.now().subtract(1.minutes);
            if (date.isToday &&
                finalDate!.millisecondsSinceEpoch <
                    now.millisecondsSinceEpoch) {
              return toast(language.selectedOtherBookingTime);
            }

            selectedDate = date;
            pickedTime = time;
            widget.data.serviceDetail!.dateTimeVal = finalDate.toString();
            dateTimeCont.text =
                "${formatBookingDate(selectedDate.toString(), format: DATE_FORMAT_3)} ${pickedTime!.format(context).toString()}";
          }
          setState(() {});
        }).catchError((e) {
          toast(e.toString());
        });
      }
    });
  }

  void handleDateTimePick() {
    hideKeyboard(context);
    if (widget.data.serviceDetail!.isSlot == 1) {
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        shape: RoundedRectangleBorder(
            borderRadius:
                radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
        builder: (_) {
          return DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.65,
            maxChildSize: 1,
            builder: (context, scrollController) => BookingSlotsComponent(
              data: widget.data,
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
      selectDateAndTime(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    log("-------------${widget.data.serviceDetail!.toJson()}");
    log("-----------------------${widget.data.serviceDetail!.bookingAddressId}");
    return Scaffold(
      appBar: appBarWidget(
        center: true,
        widget.selectedPackage == null
            ? language.bookTheService
            : language.bookPackage,
        textColor: Colors.white,
        color: context.primaryColor,
        backWidget: BackWidget(),
      ),
      body: Body(
        showLoader: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.selectedPackage == null)
                Text(language.service, style: boldTextStyle()),
              if (widget.selectedPackage == null) 8.height,
              if (widget.selectedPackage == null) serviceWidget(context),
              16.height,
              packageWidget(),
              16.height,

              addressAndDescriptionWidget(context),
              //Description
              32.height,
              Text("${language.hintDescription}", style: boldTextStyle()),
              8.height,
              AppTextField(
                textFieldType: TextFieldType.MULTILINE,
                controller: descriptionCont,
                maxLines: 10,
                minLines: 3,
                isValidationRequired: false,
                enableChatGPT: appConfigurationStore.chatGPTStatus,
                promptFieldInputDecorationChatGPT: inputDecoration(
                  context,
                  hintText: language.writeHere,
                  borderRadius: 8,
                  fillColor: Color(0xFFE8F3EC),
                ),
                testWithoutKeyChatGPT: appConfigurationStore.testWithoutKey,
                loaderWidgetForChatGPT: const ChatGPTLoadingWidget(),
                onFieldSubmitted: (s) {
                  widget.data.serviceDetail!.bookingDescription = s;
                },
                onChanged: (s) {
                  widget.data.serviceDetail!.bookingDescription = s;
                },
                suffix: Icon(Icons.mode_edit_outline_outlined,
                    size: 18, color: context.icon),
                decoration: inputDecoration(
                  context,
                  hintText: language.writeHere,
                  borderRadius: 8,
                  fillColor: Color(0xFFE8F3EC),
                ).copyWith(
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                  disabledBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  errorBorder: OutlineInputBorder(borderSide: BorderSide.none),
                  focusedErrorBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),

              /// Only active status package display
              if (serviceAddonStore.selectedServiceAddon.validate().isNotEmpty)
                AddonComponent(
                  isFromBookingLastStep: true,
                  serviceAddon: serviceAddonStore.selectedServiceAddon,
                  onSelectionChange: (v) {
                    serviceAddonStore.setSelectedServiceAddon(v);
                    setPrice();
                  },
                ),
              //Booking data & slot
              16.height,
              Text(language.bookingDateAndSlot, style: boldTextStyle()),
              8.height,
              buildBookingSummaryWidget(),

              16.height,
              priceWidget(),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Observer(builder: (context) {
                    return const WalletBalanceComponent().visible(
                        appConfigurationStore.isEnableUserWallet &&
                            widget.data.serviceDetail!.isFixedService);
                  }),
                  16.height,
                  Text(language.disclaimer, style: boldTextStyle()),
                  8.height,
                  Text(
                    language.disclaimerContent,
                    style: primaryTextStyle(size: 12),
                  ),
                ],
              ).paddingSymmetric(vertical: 16),

              36.height,

              Row(
                children: [
                  AppButton(
                    color: context.primaryColor,
                    text: widget.data.serviceDetail!.isAdvancePayment &&
                            !widget.data.serviceDetail!.isFreeService &&
                            widget.data.serviceDetail!.isFixedService
                        ? language.advancePayment
                        : language.confirm,
                    textColor: Colors.white,
                    onTap: () {
                      if (widget.data.serviceDetail!.isOnSiteService &&
                          addressCont.text.isEmpty &&
                          widget.data.serviceDetail!.dateTimeVal
                              .validate()
                              .isEmpty) {
                        toast(language.pleaseEnterAddressAnd);
                      } else if (widget.data.serviceDetail!.isOnSiteService &&
                          addressCont.text.isEmpty) {
                        toast(language.pleaseEnterYourAddress);
                      } else if ((widget.data.serviceDetail!.isSlot != 1 &&
                              widget.data.serviceDetail!.dateTimeVal
                                  .validate()
                                  .isEmpty) ||
                          (widget.data.serviceDetail!.isSlot == 1 &&
                              (widget.data.serviceDetail!.bookingSlot == null ||
                                  widget.data.serviceDetail!.bookingSlot
                                      .validate()
                                      .isEmpty))) {
                        toast(language.pleaseSelectBookingDate);
                      } else {
                        widget.data.serviceDetail!.address = addressCont.text;
                        showInDialog(
                          context,
                          barrierDismissible: false,
                          insetPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          builder: (p0) {
                            return ConfirmBookingDialog(
                              data: widget.data,
                              bookingPrice:
                                  bookingAmountModel.finalGrandTotalAmount,
                              selectedPackage: widget.selectedPackage,
                              qty: itemCount,
                              couponCode: appliedCouponData?.code,
                              shopModel: selectedShop,
                              bookingAmountModel: BookingAmountModel(
                                finalCouponDiscountAmount: bookingAmountModel
                                    .finalCouponDiscountAmount,
                                finalDiscountAmount:
                                    bookingAmountModel.finalDiscountAmount,
                                finalSubTotal: bookingAmountModel.finalSubTotal,
                                finalTotalServicePrice:
                                    bookingAmountModel.finalTotalServicePrice,
                                finalTotalTax:
                                    !widget.data.serviceDetail!.isFreeService
                                        ? bookingAmountModel.finalTotalTax
                                        : 0,
                              ),
                            );
                          },
                        );
                      }
                    },
                  ).expand(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget addressFieldWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(language.landmark, style: boldTextStyle()),
        8.height,
        AppTextField(
            textFieldType: TextFieldType.MULTILINE,
            controller: addressCont,
            maxLines: 3,
            minLines: 3,
            onFieldSubmitted: (s) {
              widget.data.serviceDetail!.address = s;
            },
            decoration: inputDecoration(context,
                hintText: language.enterYourLocation,
                borderRadius: 8,
                fillColor: Color(0xFFE8F3EC),
                prefixIcon: Align(
                  alignment: Alignment.topLeft,
                  widthFactor: 1.0,
                  heightFactor: 2.0,
                  child: ic_location.iconImage(size: 18).paddingAll(14),
                )).copyWith(
              enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
              disabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
              border: OutlineInputBorder(borderSide: BorderSide.none),
              errorBorder: OutlineInputBorder(borderSide: BorderSide.none),
              focusedErrorBorder:
                  OutlineInputBorder(borderSide: BorderSide.none),
            )),
        8.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              child: Text(language.lblChooseFromMap,
                  style: boldTextStyle(color: primaryColor, size: 12)),
              onTap: () {
                _handleSetLocationClick();
              },
            ).flexible(),
            GestureDetector(
              onTap: _handleCurrentLocationClick,
              child: Text(language.lblUseCurrentLocation,
                  style: boldTextStyle(color: primaryColor, size: 12),
                  textAlign: TextAlign.right),
            ).flexible(),
          ],
        ),
      ],
    );
  }

  Widget addressAndDescriptionWidget(BuildContext context) {
    return Column(
      children: [
        if (widget.data.isAvailableAtShop && selectedShop != null)
          shopWidget()
        else if (widget.data.serviceDetail!.isOnSiteService)
          addressFieldWidget()
        else if (widget.selectedPackage != null &&
            !widget.selectedPackage!.isAllServiceOnline)
          addressFieldWidget()
        else if ((widget.selectedPackage != null &&
                widget.selectedPackage!.isAllServiceOnline) &&
            widget.data.serviceDetail!.isOnlineService)
          Text(language.noteAddressIsNot, style: secondaryTextStyle())
              .paddingTop(16),
        16.height.visible(!widget.data.serviceDetail!.isOnSiteService &&
            !widget.data.isAvailableAtShop),
      ],
    );
  }

  Widget serviceWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: boxDecorationWithRoundedCorners(
          borderRadius: radius(8), backgroundColor: Color(0xFFE8F3EC)),
      width: context.width(),
      child: Row(
        children: [
          CachedImageWidget(
            url: widget.data.serviceDetail!.attachments.validate().isNotEmpty
                ? widget.data.serviceDetail!.attachments!.first.validate()
                : '',
            height: 80,
            width: 80,
            fit: BoxFit.cover,
            radius: 8,
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Name
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.data.serviceDetail!.name.validate(),
                        style: boldTextStyle(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      language.speciallyAbled,
                      style: boldTextStyle(color: primaryColor, size: 12),
                    ),
                  ],
                ),

                4.height,
                //Duration and timing
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language.duration, style: primaryTextStyle()),
                    4.height,
                    Text(
                      convertToHourMinute(
                          widget.data.serviceDetail!.duration.validate()),
                      style: boldTextStyle(color: primaryColor, size: 14),
                    ),
                  ],
                ),
                //Rating
                4.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PriceWidget(
                      price: widget.data.serviceDetail!.price.validate(),
                      size: 14,
                    ),
                    if (widget.data.serviceDetail!.discount.validate() > 0) ...[
                      6.width,
                      PriceWidget(
                        price: widget.data.serviceDetail!.getDiscountedPrice
                            .validate(),
                        size: 12,
                        isLineThroughEnabled: true,
                        color: textSecondaryColorGlobal,
                      ),
                      6.width,
                      Text(
                        "(${widget.data.serviceDetail!.discount.validate()}% ${language.lblOff})",
                        style: boldTextStyle(
                            color: defaultActivityStatus, size: 12),
                      ),
                      Spacer(),
                    ],
                    if (!widget.data.serviceDetail!.isFixedService)
                      Container(
                        width: 58,
                        height: 28,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: boxDecorationWithRoundedCorners(
                          borderRadius: radius(4),
                          backgroundColor: Color(0xFFE8F3EC),
                          border: Border.all(
                            color: context.dividerColor,
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: itemCount,
                            isExpanded: true,
                            icon: ic_down_arrow.iconImage(
                                size: 16, color: context.icon),
                            style: boldTextStyle(size: 14),
                            dropdownColor: context.cardColor,
                            items: List.generate(10, (index) {
                              int value = index + 1;
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Center(
                                  child: Text(
                                    value.toString(),
                                    style: primaryTextStyle(),
                                  ),
                                ),
                              );
                            }),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                itemCount = newValue;
                                setPrice();
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget priceWidget() {
    if (!widget.data.serviceDetail!.isFreeService)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.selectedPackage == null) 12.height,
          if (widget.selectedPackage == null)
            //coupon container
            Container(
              width: context.width(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: boxDecorationWithRoundedCorners(
                borderRadius: radius(8),
                backgroundColor: Color(0xFFE8F3EC),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.lightGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '%',
                        style: boldTextStyle(color: Colors.white, size: 12),
                      ),
                    ),
                  ),
                  8.width,
                  Text(language.lblCoupon, style: primaryTextStyle()),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (appliedCouponData != null) {
                        showConfirmDialogCustom(
                          height: 75,
                          width: 290,
                          context,
                          title: language.doYouWantTo,
                          positiveText: language.lblYes,
                          negativeText: language.lblNo,
                          dialogType: DialogType.DELETE,
                          primaryColor: context.primaryColor,
                          negativeTextColor: context.primaryColor,
                          customCenterWidget: Image.asset(
                            ic_warning,
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                          ),
                          onAccept: (p0) {
                            appliedCouponData = null;
                            setPrice();
                            setState(() {});
                          },
                        );
                      } else {
                        applyCoupon();
                      }
                    },
                    child: Text(
                      appliedCouponData != null
                          ? language.lblRemoveCoupon
                          : language.applyCoupon,
                      style: boldTextStyle(
                        color: context.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          24.height,
          Text(language.priceDetail, style: boldTextStyle()),
          16.height,
          Container(
            padding: const EdgeInsets.all(12),
            width: context.width(),
            decoration: boxDecorationDefault(color: Color(0xFFE8F3EC)),
            child: Column(
              children: [
                /// Service or Package Price
                Row(
                  children: [
                    Text(language.lblPrice, style: primaryTextStyle(size: 12))
                        .expand(),
                    16.width,
                    if (widget.selectedPackage != null)
                      PriceWidget(
                          price: bookingAmountModel.finalTotalServicePrice,
                          color: textPrimaryColorGlobal,
                          currencySymbol: "₹",
                          isBoldText: true)
                    else if (!widget.data.serviceDetail!.isHourlyService)
                      Marquee(
                        child: PriceWidget(
                            size: 12,
                            currencySymbol: "₹",
                            isBoldText: true,
                            price: bookingAmountModel.finalTotalServicePrice,
                            color: textPrimaryColorGlobal),
                      )
                    else
                      PriceWidget(
                          price: bookingAmountModel.finalTotalServicePrice,
                          size: 12,
                          currencySymbol: "₹",
                          color: textPrimaryColorGlobal,
                          isBoldText: true)
                  ],
                ),

                /// Fix Discount on Base Price
                if (widget.data.serviceDetail!.discount.validate() != 0 &&
                    widget.selectedPackage == null)
                  Column(
                    children: [
                      Divider(
                        height: 26,
                        color: context.dividerColor,
                        thickness: 0.5,
                      ),
                      Row(
                        children: [
                          Text(language.lblDiscount,
                              style: primaryTextStyle(size: 12)),
                          Text(
                            " (${widget.data.serviceDetail!.discount.validate()}% ${language.lblOff.toLowerCase()})",
                            style: boldTextStyle(color: Colors.green, size: 12),
                          ).expand(),
                          16.width,
                          PriceWidget(
                            size: 12,
                            currencySymbol: "₹",
                            price: bookingAmountModel.finalDiscountAmount,
                            color: Colors.green,
                            isBoldText: true,
                          ),
                        ],
                      ),
                    ],
                  ),

                /// Coupon Discount on Base Price
                if (widget.selectedPackage == null)
                  Column(
                    children: [
                      if (appliedCouponData != null)
                        Divider(
                          height: 26,
                          color: context.dividerColor,
                          thickness: 0.5,
                        ),
                      if (appliedCouponData != null)
                        Row(
                          children: [
                            Row(
                              children: [
                                Text(language.lblCoupon,
                                    style: primaryTextStyle(size: 12)),
                                Text(
                                  " (${appliedCouponData!.code})",
                                  style: boldTextStyle(
                                      color: primaryColor, size: 12),
                                ).onTap(() {
                                  applyCoupon(
                                      isApplied: appliedCouponData!.code
                                          .validate()
                                          .isNotEmpty);
                                }).expand(),
                              ],
                            ).expand(),
                            PriceWidget(
                              size: 12,
                              currencySymbol: "₹",
                              price:
                                  bookingAmountModel.finalCouponDiscountAmount,
                              color: Colors.green,
                              isBoldText: true,
                            ),
                          ],
                        ),
                    ],
                  ),

                /// Itemized Service Add-ons
                if (serviceAddonStore.selectedServiceAddon
                    .validate()
                    .isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        height: 26,
                        color: context.dividerColor,
                        thickness: 0.5,
                      ),
                      ...serviceAddonStore.selectedServiceAddon
                          .map((a) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(a.name.validate(),
                                          style: primaryTextStyle(size: 12))
                                      .flexible(fit: FlexFit.loose),
                                  16.width,
                                  PriceWidget(
                                      price: a.price.validate(),
                                      color: textPrimaryColorGlobal,
                                      isBoldText: false,
                                      size: 12,
                                      currencySymbol: "₹"),
                                ],
                              ))
                          .toList(),
                      8.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language.serviceAddOns,
                                  style: boldTextStyle(size: 12))
                              .flexible(fit: FlexFit.loose),
                          16.width,
                          PriceWidget(
                            price: bookingAmountModel.finalServiceAddonAmount,
                            color: textPrimaryColorGlobal,
                            currencySymbol: "₹",
                            isBoldText: true,
                            size: 12,
                          ),
                        ],
                      ),
                    ],
                  ),

                /// Show Subtotal, Total Amount and Apply Discount, Coupon if service is Fixed or Hourly
                if (widget.selectedPackage == null)
                  Column(
                    children: [
                      Divider(
                        height: 26,
                        color: context.dividerColor,
                        thickness: 0.5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language.lblSubTotal,
                                  style: primaryTextStyle(size: 12))
                              .flexible(fit: FlexFit.loose),
                          16.width,
                          PriceWidget(
                            price: bookingAmountModel.finalSubTotal,
                            color: textPrimaryColorGlobal,
                            currencySymbol: "₹",
                            isBoldText: true,
                            size: 12,
                          ),
                        ],
                      ),
                    ],
                  ),

                /// Tax Amount Applied on Price
                Column(
                  children: [
                    Divider(
                      height: 26,
                      color: context.dividerColor,
                      thickness: 0.5,
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            Text(language.lblTax,
                                    style: primaryTextStyle(size: 12))
                                .expand(),
                            if (widget.data.taxes.validate().isNotEmpty)
                              Icon(Icons.info_outline_rounded,
                                      size: 20, color: context.primaryColor)
                                  .onTap(
                                () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (_) {
                                      return AppliedTaxListBottomSheet(
                                          taxes: widget.data.taxes.validate(),
                                          subTotal:
                                              bookingAmountModel.finalSubTotal);
                                    },
                                  );
                                },
                              ),
                          ],
                        ).expand(),
                        16.width,
                        PriceWidget(
                            price: bookingAmountModel.finalTotalTax,
                            color: Colors.red,
                            isBoldText: true,
                            size: 12,
                            currencySymbol: "₹"),
                      ],
                    ),
                  ],
                ),

                /// Final Amount
                Column(
                  children: [
                    Divider(
                      height: 26,
                      color: context.dividerColor,
                      thickness: 0.5,
                    ),
                    Row(
                      children: [
                        Text(language.totalAmount,
                                style: primaryTextStyle(size: 12))
                            .expand(),
                        PriceWidget(
                          price: bookingAmountModel.finalGrandTotalAmount,
                          color: primaryColor,
                          currencySymbol: "₹",
                          isBoldText: true,
                          size: 12,
                        )
                      ],
                    ),
                  ],
                ),

                /// Advance Payable Amount if it is required by Service Provider
                if (widget.data.serviceDetail!.isAdvancePayment &&
                    widget.data.serviceDetail!.isFixedService &&
                    !widget.data.serviceDetail!.isFreeService)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        height: 26,
                        color: context.dividerColor,
                        thickness: 0.5,
                      ),
                      Row(
                        children: [
                          Row(
                            children: [
                              Text(language.advancePayAmount,
                                  style: primaryTextStyle(size: 12)),
                              Text(
                                  " (${widget.data.serviceDetail!.advancePaymentPercentage.validate().toString()}%)  ",
                                  style: boldTextStyle(color: Colors.green)),
                            ],
                          ).expand(),
                          PriceWidget(
                              price: advancePaymentAmount,
                              color: primaryColor,
                              currencySymbol: "₹",
                              isBoldText: true,
                              size: 12),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          )
        ],
      );

    return const Offstage();
  }

  Widget buildDateWidget() {
    if (widget.data.serviceDetail!.isSlotAvailable) {
      return Text(widget.data.serviceDetail!.dateTimeVal.validate(),
          style: boldTextStyle(size: 12));
    }
    return Text(
        formatBookingDate(widget.data.serviceDetail!.dateTimeVal.validate(),
            format: DATE_FORMAT_3),
        style: boldTextStyle(size: 12));
  }

  Widget buildTimeWidget() {
    if (widget.data.serviceDetail!.bookingSlot == null) {
      return Text(
          formatBookingDate(
            widget.data.serviceDetail!.dateTimeVal.validate(),
            format: HOUR_12_FORMAT,
            isTime: true,
          ),
          style: boldTextStyle(size: 12));
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
      style: boldTextStyle(size: 12),
    );
  }

  Widget buildBookingSummaryWidget() {
    return Column(
      children: [
        8.height,
        widget.data.serviceDetail!.dateTimeVal == null
            ? GestureDetector(
                onTap: () async {
                  handleDateTimePick();
                },
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.all(12),
                  alignment: Alignment.topCenter,
                  decoration: boxDecorationWithShadow(
                      blurRadius: 0,
                      backgroundColor: Color(0xFFE8F3EC),
                      borderRadius: radius(8)),
                  child: Row(
                    children: [
                      Text(language.chooseDateTime,
                          style: secondaryTextStyle()),
                      Spacer(),
                      ic_calendar.iconImage(size: 18),
                    ],
                  ),
                ),
              )
            : Container(
                padding: const EdgeInsets.all(12),
                decoration: boxDecorationWithShadow(
                    blurRadius: 0,
                    backgroundColor: Color(0xFFE8F3EC),
                    borderRadius: radius(8)),
                width: context.width(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("${language.lblDate}: ",
                                style: primaryTextStyle()),
                            4.width,
                            buildDateWidget(),
                          ],
                        ),
                        8.height,
                        Row(
                          children: [
                            Text("${language.lblTime}: ",
                                style: primaryTextStyle()),
                            4.width,
                            buildTimeWidget(),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: ic_edit_square.iconImage(
                          size: 18, color: context.icon),
                      visualDensity: VisualDensity.compact,
                      onPressed: () async {
                        handleDateTimePick();
                      },
                    )
                  ],
                ),
              ),
      ],
    );
  }

  Widget packageWidget() {
    if (widget.selectedPackage != null)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language.package, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
          16.height,
          Container(
            padding: const EdgeInsets.all(16),
            decoration: boxDecorationDefault(color: context.cardColor),
            width: context.width(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Marquee(
                            child: Text(widget.selectedPackage!.name.validate(),
                                style: boldTextStyle())),
                        4.height,
                        Text(
                            "${language.services}: ${widget.selectedPackage!.serviceList.validate().map((e) => e.name).join(", ")}",
                            style: secondaryTextStyle()),
                      ],
                    ).expand(),
                    16.width,
                    CachedImageWidget(
                      url: widget.selectedPackage!.imageAttachments
                              .validate()
                              .isNotEmpty
                          ? widget.selectedPackage!.imageAttachments!.first
                              .validate()
                          : '',
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ).cornerRadiusWithClipRRect(defaultRadius),
                  ],
                ),
              ],
            ),
          ),
        ],
      );

    return const Offstage();
  }

  Widget _buildFallbackImage() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Image.asset(
        Assets.iconsIcDefaultShop,
        height: 14,
        width: 14,
        color: primaryColor,
      ),
    );
  }

  Widget shopWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Space between items
          children: [
            Text(language.lblShopDetails,
                style: boldTextStyle(size: LABEL_TEXT_SIZE)),
            Spacer(),
            TextButton(
              onPressed: () async {
                await showModalBottomSheet(
                  context: context,
                  backgroundColor: context.scaffoldBackgroundColor,
                  barrierColor:
                      appStore.isDarkMode ? Colors.white10 : Colors.black26,
                  showDragHandle: true,
                  constraints:
                      BoxConstraints(maxHeight: context.height() * 0.9),
                  enableDrag: true,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: radiusOnly(topRight: 16, topLeft: 16),
                  ),
                  builder: (context) {
                    return ShopListScreen(
                      serviceId: widget.serviceId.validate(),
                      selectedShop: selectedShop,
                      isForBooking: true,
                      isShopChange: false,
                    );
                  },
                ).then(
                  (value) {
                    if (value != null) {
                      selectedShop = value;
                      setState(() {});
                    }
                  },
                );
              },
              child: Text("Change",
                  style: boldTextStyle(size: 14, color: primaryColor)),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.all(16),
          decoration: boxDecorationDefault(
            color: context.cardColor,
            border: appStore.isDarkMode
                ? Border.all(color: context.dividerColor)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: selectedShop!.shopFirstImage.isNotEmpty
                          ? CachedImageWidget(
                              url: selectedShop!.shopFirstImage,
                              fit: BoxFit.cover,
                              width: 60,
                              height: 60,
                              usePlaceholderIfUrlEmpty: true,
                            )
                          : _buildFallbackImage(),
                    ),
                  ),
                  16.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(selectedShop!.name, style: boldTextStyle()),
                      4.height,
                      // if (selectedShop!.shopStartTime, selectedShop!.shopEndTime).isNotEmpty) ...[
                      TextIcon(
                        spacing: 10,
                        prefix: Image.asset(ic_clock,
                            width: 12, height: 12, color: context.icon),
                        text: selectedShop!.shopStartTime
                                    .validate()
                                    .isNotEmpty &&
                                selectedShop!.shopEndTime.isNotEmpty
                            ? '${selectedShop!.shopStartTime} - ${selectedShop!.shopEndTime}'
                            : '---',
                        textStyle: secondaryTextStyle(size: 12),
                        expandedText: true,
                        edgeInsets: EdgeInsets.zero,
                      ),
                      // ]
                    ],
                  ).expand(),
                ],
              ),
              8.height,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((selectedShop!.email.validate().isNotEmpty) ||
                      (selectedShop!.contactNumber.validate().isNotEmpty)) ...[
                    if (selectedShop!.email.validate().isNotEmpty) ...[
                      4.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${language.email}:',
                            style: boldTextStyle(
                                size: 12,
                                color: appStore.isDarkMode
                                    ? textSecondaryColor
                                    : textPrimaryColor),
                          ).expand(),
                          8.width,
                          Expanded(
                            flex: 4,
                            child: GestureDetector(
                              onTap: () {
                                launchMail("${selectedShop!.email.validate()}");
                              },
                              child: Text(
                                selectedShop!.email.validate(),
                                style: boldTextStyle(
                                    size: 12,
                                    color: appStore.isDarkMode
                                        ? white
                                        : textSecondaryColor,
                                    weight: FontWeight.w400),
                              ),
                            ),
                          ),
                        ],
                      ),
                      4.height,
                    ],
                    if (selectedShop!.contactNumber.validate().isNotEmpty) ...[
                      4.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            language.mobile,
                            style: boldTextStyle(
                                size: 12,
                                color: appStore.isDarkMode
                                    ? textSecondaryColor
                                    : textPrimaryColor),
                          ).expand(),
                          8.width,
                          Expanded(
                            flex: 4,
                            child: GestureDetector(
                              onTap: () {
                                launchCall(
                                    "${selectedShop!.contactNumber.validate()}");
                              },
                              child: Text(
                                selectedShop!.contactNumber.validate(),
                                style: boldTextStyle(
                                    size: 12,
                                    color: appStore.isDarkMode
                                        ? white
                                        : textSecondaryColor,
                                    weight: FontWeight.w400),
                              ),
                            ),
                          ),
                        ],
                      ),
                      4.height,
                    ]
                  ],
                  if (selectedShop!.latitude != 0 &&
                      selectedShop!.longitude != 0) ...[
                    4.height,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${language.hintAddress}:',
                          style: boldTextStyle(
                              size: 12,
                              color: appStore.isDarkMode
                                  ? textSecondaryColor
                                  : textPrimaryColor),
                        ).expand(),
                        8.width,
                        Expanded(
                          flex: 4,
                          child: GestureDetector(
                            onTap: () {
                              if (selectedShop!.latitude != 0 &&
                                  selectedShop!.longitude != 0) {
                                launchMapFromLatLng(
                                    latitude: selectedShop!.latitude,
                                    longitude: selectedShop!.longitude);
                              } else {
                                launchMap(selectedShop!.address);
                              }
                            },
                            child: Text(
                              "${selectedShop!.address}, ${selectedShop!.cityName}, ${selectedShop!.stateName}, ${selectedShop!.countryName}",
                              style: boldTextStyle(
                                  size: 12,
                                  color: appStore.isDarkMode
                                      ? white
                                      : textSecondaryColor,
                                  weight: FontWeight.w400),
                              softWrap: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    4.height,
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
