import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/category_model.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../newDashboard/dashboard_3/component/category_dashboard_component_3.dart';
import '../../newDashboard/dashboard_4/component/category_dashboard_component_4.dart';

class CategoryWidget extends StatelessWidget {
  final CategoryData categoryData;
  final double? width;
  final bool? isFromCategory;

  CategoryWidget({required this.categoryData, this.width, this.isFromCategory});

  /// Check if categoryImage is an icon name (not a URL)
  bool _isIconName(String? image) {
    if (image == null || image.isEmpty) return false;
    // If it doesn't start with http/https and doesn't end with image extensions, it's likely an icon name
    return !image.startsWith('http') &&
        !image.endsWith('.svg') &&
        !image.endsWith('.png') &&
        !image.endsWith('.jpg') &&
        !image.endsWith('.jpeg');
  }

  Widget buildDefaultComponent(BuildContext context) {
    // Get demo image URL based on category name if no valid image exists
    final String imageUrl = categoryData.categoryImage.validate().isEmpty ||
            _isIconName(categoryData.categoryImage)
        ? getDemoCategoryImage(categoryData.name)
        : categoryData.categoryImage.validate();

    return SizedBox(
      width: width ?? context.width() / 4 - 16,
      child: Column(
        children: [
          // Display demo category image from URL
          Container(
            width: CATEGORY_ICON_SIZE,
            height: CATEGORY_ICON_SIZE,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.secondaryContainer, // Light green background
              borderRadius: BorderRadius.circular(12),
            ),
            child: categoryData.categoryImage.validate().endsWith('.svg')
                ? SvgPicture.network(
                    categoryData.categoryImage.validate(),
                    height: CATEGORY_ICON_SIZE - 16,
                    width: CATEGORY_ICON_SIZE - 16,
                    colorFilter: ColorFilter.mode(
                      appStore.isDarkMode
                          ? context.onPrimary
                          : categoryData.color.validate(value: '000').toColor(),
                      BlendMode.srcIn,
                    ),
                    placeholderBuilder: (context) => const PlaceHolderWidget(
                      height: CATEGORY_ICON_SIZE - 16,
                      width: CATEGORY_ICON_SIZE - 16,
                      color: transparentColor,
                    ),
                  )
                : CachedImageWidget(
                    url: imageUrl,
                    fit: BoxFit.contain,
                    width: CATEGORY_ICON_SIZE - 16,
                    height: CATEGORY_ICON_SIZE - 16,
                    placeHolderImage: '',
                  ),
          ),
          8.height,
          Marquee(
            directionMarguee: DirectionMarguee.oneDirection,
            child: Text(
              '${categoryData.name.validate()}',
              style: context.primaryTextStyle(size: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget categoryComponent() {
      return Observer(builder: (context) {
        if (appConfigurationStore.userDashboardType == DASHBOARD_1) {
          return buildDefaultComponent(context);
        } else if (appConfigurationStore.userDashboardType == DASHBOARD_2) {
          return buildDefaultComponent(context);
        } else if (appConfigurationStore.userDashboardType == DASHBOARD_3) {
          return CategoryDashboardComponent3(
              categoryData: categoryData, width: context.width() / 4 - 20);
        } else if (appConfigurationStore.userDashboardType == DASHBOARD_4) {
          return CategoryDashboardComponent4(categoryData: categoryData);
        } else {
          return buildDefaultComponent(context);
        }
      });
    }

    return categoryComponent();
  }
}
