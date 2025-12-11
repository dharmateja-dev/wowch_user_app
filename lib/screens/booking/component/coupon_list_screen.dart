import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/service_detail_response.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/booking/component/coupon_card_widget.dart';
import 'package:booking_system_flutter/screens/booking/shimmer/coupon_list_shimmer.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/empty_error_state_widget.dart';
import '../../../model/coupon_list_model.dart';

class CouponsScreen extends StatefulWidget {
  final int serviceId;
  final num price;
  final CouponData? appliedCouponData;
  final num? servicePrice;

  const CouponsScreen(
      {required this.serviceId,
      this.servicePrice,
      this.appliedCouponData,
      required this.price});

  @override
  _CouponsScreenState createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  Future<CouponListResponse>? future;

  // TODO: Remove dummy data when backend is ready - This is for UI testing only
  static const bool _useDummyData =
      true; // Set to false to use only backend data

  // Dummy coupons for UI testing
  List<CouponData> get _dummyCoupons => [
        CouponData(
          id: 1001,
          code: 'WELCOME20',
          discount: 20,
          discountType: 'percentage',
          expireDate: DateTime.now().add(Duration(days: 30)).toString(),
          status: 1,
        ),
        CouponData(
          id: 1002,
          code: 'FLAT100',
          discount: 100,
          discountType: 'fixed',
          expireDate: DateTime.now().add(Duration(days: 15)).toString(),
          status: 1,
        ),
        CouponData(
          id: 1003,
          code: 'SAVE15',
          discount: 15,
          discountType: 'percentage',
          expireDate: DateTime.now().add(Duration(days: 7)).toString(),
          status: 1,
        ),
        CouponData(
          id: 1004,
          code: 'MEGA50',
          discount: 50,
          discountType: 'fixed',
          expireDate: DateTime.now().add(Duration(days: 60)).toString(),
          status: 1,
        ),
        CouponData(
          id: 1005,
          code: 'SPECIAL25',
          discount: 25,
          discountType: 'percentage',
          expireDate: DateTime.now().add(Duration(days: 10)).toString(),
          status: 1,
        ),
      ];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init({Map? req}) async {
    future = getCouponList(serviceId: widget.serviceId, price: widget.price);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.coupons,
      child: SnapHelperWidget<CouponListResponse>(
        future: future,
        loadingWidget: CouponListShimmer(),
        errorBuilder: (error) {
          // If API fails but dummy data is enabled, show dummy coupons
          if (_useDummyData) {
            return _buildCouponList(_dummyCoupons);
          }
          return NoDataWidget(
            title: error,
            imageWidget: const ErrorStateWidget(),
            retryText: language.reload,
            onRetry: () {
              appStore.setLoading(true);

              init();
              setState(() {});
            },
          ).center();
        },
        onSuccess: (couponsRes) {
          // Merge API coupons with dummy coupons for testing
          List<CouponData> validCoupons =
              List<CouponData>.from(couponsRes.validCupon);

          // Add dummy coupons if enabled
          if (_useDummyData) {
            validCoupons.addAll(_dummyCoupons);
          }

          if (validCoupons.isEmpty) {
            return NoDataWidget(
              title: language.lblNoCouponsAvailable,
              subTitle: language.noCouponsAvailableMsg,
              imageWidget: const EmptyStateWidget(),
            ).center();
          }

          return _buildCouponList(validCoupons);
        },
      ).paddingSymmetric(horizontal: 8),
    );
  }

  Widget _buildCouponList(List<CouponData> validCoupons) {
    return AnimatedListView(
      shrinkWrap: true,
      itemCount: validCoupons.length,
      slideConfiguration: sliderConfigurationGlobal,
      listAnimationType: ListAnimationType.FadeIn,
      fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
      emptyWidget: NoDataWidget(
        title: language.lblNoCouponsAvailable,
        subTitle: language.noCouponsAvailableMsg,
        imageWidget: const EmptyStateWidget(),
      ),
      onSwipeRefresh: () {
        appStore.setLoading(true);
        init();
        setState(() {});
        return 2.seconds.delay;
      },
      itemBuilder: (context, index) {
        final CouponData data = validCoupons[index];

        if (widget.appliedCouponData != null &&
            widget.appliedCouponData!.code == data.code) {
          data.isApplied = widget.appliedCouponData!.isApplied;
        }
        return CouponCardWidget(data: data, servicePrice: widget.servicePrice)
            .paddingOnly(top: 16);
      },
    );
  }
}
