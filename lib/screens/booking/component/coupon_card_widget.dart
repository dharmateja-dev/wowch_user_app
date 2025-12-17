import 'package:booking_system_flutter/component/dotted_line.dart';
import 'package:booking_system_flutter/model/service_detail_response.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/extensions/num_extenstions.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/price_widget.dart';
import '../../../main.dart';
import '../../../utils/app_configuration.dart';
import '../../../utils/booking_calculations_logic.dart';
import '../../../utils/colors.dart';
import '../../../utils/constant.dart';

class CouponCardWidget extends StatelessWidget {
  final CouponData data;
  final num? servicePrice;

  CouponCardWidget({required this.data, this.servicePrice});

  final double sideDotsSize = 9;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          alignment: Alignment.center,
          width: context.width(),
          height: context.height() * 0.22,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: boxDecorationDefault(
            color: context.primaryColor,
            borderRadius: radius(0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.center,
                child: data.discountType == SERVICE_TYPE_FIXED
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PriceWidget(
                              price: data.discount.validate(),
                              decimalPoint: 0,
                              color: hold,
                              size: 24),
                          Text("${language.lblDiscount.toUpperCase()}",
                              style: context.boldTextStyle(
                                  color: context.onPrimary, size: 16)),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("${data.discount.validate()}%",
                              textAlign: TextAlign.center,
                              style:
                                  context.boldTextStyle(color: hold, size: 24)),
                          Text("${language.lblDiscount.toUpperCase()}",
                              style: context.boldTextStyle(
                                  color: context.onPrimary, size: 16)),
                        ],
                      ),
              ).paddingRight(4).expand(flex: 1),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${data.code.validate()}",
                      style: context.boldTextStyle(color: context.onPrimary)),
                  8.height,
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${language.useThisCodeToGet} ',
                          style: context.primaryTextStyle(
                              color: context.onPrimary,
                              size: 12,
                              weight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: calculateCouponDiscount(
                                  couponData: data,
                                  price: servicePrice.validate())
                              .toPriceFormat(),
                          style: context.primaryTextStyle(
                              color: hold, size: 12, weight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: ' ${language.off}',
                          style: context.primaryTextStyle(
                              color: context.onPrimary,
                              size: 12,
                              weight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  8.height,
                  data.isApplied
                      ? Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                size: 16, color: completed),
                            6.width,
                            Text(language.applied,
                                style: context.boldTextStyle(
                                    color: context.onPrimary)),
                            8.width,
                          ],
                        ).paddingBottom(8)
                      : AppButton(
                          padding: EdgeInsets.zero,
                          width: context.width() * 0.35,
                          child: TextIcon(
                            text: data.isApplied
                                ? language.applied
                                : language.lblApply,
                            textStyle:
                                context.boldTextStyle(color: context.primary),
                            prefix: data.isApplied
                                ? Icon(Icons.check_circle_outline,
                                    size: 16, color: completed)
                                : Offstage(),
                          ),
                          color: context.onPrimary,
                          onTap: () {
                            data.isApplied = true;
                            finish(context, data);
                          },
                        ),
                  Text(
                    "${language.lblExpiryDate} ${formatBookingDate(data.expireDate.validate(), format: 'MMMM d, yyyy')}",
                    style: context.primaryTextStyle(
                      color: hold,
                      size: 12,
                      fontStyle: FontStyle.italic,
                      weight: FontWeight.w700,
                    ),
                  ).expand(),
                ],
              ).paddingLeft(32).expand(flex: 2),
            ],
          ),
        ),
        Positioned(
          left: -sideDotsSize,
          child: Column(
            children: List.generate(
              countOfSideCuts(context),
              (index) => CircleAvatar(
                radius: sideDotsSize,
                backgroundColor: context.scaffold,
              ),
            ),
          ),
        ),
        Positioned(
          right: -sideDotsSize,
          child: Column(
            children: List.generate(
              countOfSideCuts(context),
              (index) => CircleAvatar(
                radius: sideDotsSize,
                backgroundColor: context.scaffold,
              ),
            ),
          ),
        ),
        Positioned(
          top: -sideDotsSize * 1.8,
          child: SizedBox(
            width: context.width(),
            height: context.height() * 0.22 + (sideDotsSize * 2 * 1.8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.center,
                ).expand(flex: 1),
                Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: sideDotsSize * 1.5,
                          backgroundColor: context.scaffold,
                        ),
                        DottedLine(
                          direction: Axis.vertical,
                          dashColor: context.onPrimary.withValues(alpha: 0.12),
                          dashGapLength: 8,
                          dashLength: 10,
                        ).expand(),
                        CircleAvatar(
                          radius: sideDotsSize * 1.5,
                          backgroundColor: context.scaffold,
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 8)
                  ],
                ),
                Container(
                  alignment: Alignment.center,
                ).expand(flex: 2),
              ],
            ),
          ),
        )
      ],
    );
  }

  int countOfSideCuts(BuildContext context) {
    num dotCount = 0;
    dotCount = (context.height() * 0.22) / sideDotsSize;
    return dotCount.round();
  }
}
