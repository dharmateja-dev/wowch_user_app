import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/price_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class ServiceHeaderComponent extends StatelessWidget {
  final ServiceData serviceData;
  final String? badgeText;
  final Color? badgeColor;
  final EdgeInsets? padding;
  final double? imageSize;
  final bool showBadge;

  const ServiceHeaderComponent({
    Key? key,
    required this.serviceData,
    this.badgeText,
    this.badgeColor,
    this.padding,
    this.imageSize = 80,
    this.showBadge = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CachedImageWidget(
          url: serviceData.attachments.validate().isNotEmpty
              ? serviceData.attachments!.first.validate()
              : DEMO_SERVICE_IMAGE_URL,
          height: imageSize ?? 80,
          width: imageSize ?? 80,
          fit: BoxFit.cover,
          radius: 12,
        ),
        8.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Name
              Row(
                children: [
                  Expanded(
                    child: Text(
                      serviceData.name.validate(),
                      style: boldTextStyle(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showBadge &&
                      (badgeText != null || badgeText?.isEmpty != true))
                    Text(
                      badgeText ?? language.speciallyAbled,
                      style: boldTextStyle(
                        color: badgeColor ?? primaryColor,
                        size: 12,
                      ),
                    ),
                ],
              ),
              2.height,
              // Price
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  PriceWidget(
                    price: serviceData.price.validate(),
                    size: 14,
                  ),
                  if (serviceData.discount.validate() > 0) ...[
                    6.width,
                    PriceWidget(
                      price: serviceData.getDiscountedPrice.validate(),
                      size: 12,
                      isLineThroughEnabled: true,
                      color: textSecondaryColorGlobal,
                    ),
                    6.width,
                    Text(
                      "(${serviceData.discount.validate()}% ${language.lblOff})",
                      style: boldTextStyle(
                        color: defaultActivityStatus,
                        size: 12,
                      ),
                    ),
                  ],
                ],
              ),
              2.height,
              // Duration and timing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    language.duration,
                    style: primaryTextStyle(),
                  ),
                  4.width,
                  Text(
                    convertToHourMinute(serviceData.duration.validate()),
                    style: boldTextStyle(color: primaryColor),
                  ),
                ],
              ),
              // Rating
              2.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    language.lblRating,
                    style: primaryTextStyle(size: 12),
                  ),
                  Spacer(),
                  Image.asset(
                    ic_star_fill,
                    height: 16,
                    color: Colors.amber,
                  ),
                  4.width,
                  Text(
                    serviceData.totalRating.validate().toStringAsFixed(1),
                    style: boldTextStyle(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ).paddingAll(padding?.left ?? 16);
  }
}
