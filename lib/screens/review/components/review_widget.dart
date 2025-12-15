import 'package:booking_system_flutter/component/image_border_component.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/service_detail_response.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/images.dart';

class ReviewWidget extends StatelessWidget {
  final RatingData data;
  final bool isCustomer;

  ReviewWidget({required this.data, this.isCustomer = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      width: context.width(),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(8),
        backgroundColor: appStore.isDarkMode
            ? context.cardColor
            : Color(0xFFE8F3EC), // Light green/off-white background
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageBorder(
                src: isCustomer
                    ? data.customerProfileImage.validate()
                    : data.profileImage.validate(),
                height: 60,
              ),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.customerName.validate(),
                                style: context.boldTextStyle(
                                  color: textPrimaryColorGlobal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              4.height,
                              data.createdAt.validate().isNotEmpty
                                  ? Text(
                                      formatDate(data.createdAt.validate()),
                                      style: context.secondaryTextStyle(
                                        color: textSecondaryColorGlobal,
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              ic_star_fill,
                              height: 16,
                              width: 16,
                              color: Colors.amber, // Yellow star
                            ),
                            4.width,
                            Text(
                              data.rating
                                  .validate()
                                  .toStringAsFixed(1)
                                  .toString(),
                              style: context.boldTextStyle(
                                color: appStore.isDarkMode
                                    ? Colors.white
                                    : Color(0xFF1C1F34), // Dark gray
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (data.review.validate().isNotEmpty) ...[
                      8.height,
                      ReadMoreText(
                        data.review.validate(),
                        style: context.primaryTextStyle(
                          color: textSecondaryColorGlobal,
                        ),
                        trimLines: 3,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: ' Read more',
                        trimExpandedText: ' Read less',
                        colorClickableText: context.primaryColor,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
