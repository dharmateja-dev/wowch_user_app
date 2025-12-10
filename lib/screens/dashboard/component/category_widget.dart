import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/category_model.dart';
import 'package:booking_system_flutter/utils/constant.dart';
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

  /// Get Material Icon from icon name string
  IconData? _getIconFromName(String? iconName) {
    if (iconName == null || iconName.isEmpty) return null;

    // Map icon names to Material Icons
    final iconMap = {
      'home': Icons.home,
      'restaurant': Icons.restaurant,
      'person': Icons.person,
      'celebration': Icons.celebration,
      'cleaning_services': Icons.cleaning_services,
      'plumbing': Icons.plumbing,
      'electrical_services': Icons.electrical_services,
      'format_paint': Icons.format_paint,
      'carpenter': Icons.carpenter,
      'yard': Icons.yard,
      'ac_unit': Icons.ac_unit,
      'build': Icons.build,
      'bug_report': Icons.bug_report,
      'local_shipping': Icons.local_shipping,
      'local_laundry_service': Icons.local_laundry_service,
      'spa': Icons.spa,
    };

    return iconMap[iconName.toLowerCase()];
  }

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
    final iconData = _isIconName(categoryData.categoryImage)
        ? _getIconFromName(categoryData.categoryImage)
        : null;

    return SizedBox(
      width: width ?? context.width() / 4 - 16,
      child: Column(
        children: [
          // Display Material Icon if icon name is provided
          iconData != null
              ? Container(
                  width: CATEGORY_ICON_SIZE,
                  height: CATEGORY_ICON_SIZE,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFE8F3EC), // Light green background
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    iconData,
                    size: 20,
                    color:
                        categoryData.color.validate(value: '#95E1D3').toColor(),
                  ),
                )
              : categoryData.categoryImage.validate().endsWith('.svg')
                  ? Container(
                      width: CATEGORY_ICON_SIZE,
                      height: CATEGORY_ICON_SIZE,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Color(0xFFE8F3EC),
                          borderRadius: BorderRadius.circular(8)),
                      child: SvgPicture.network(
                        categoryData.categoryImage.validate(),
                        height: CATEGORY_ICON_SIZE,
                        width: CATEGORY_ICON_SIZE,
                        colorFilter: ColorFilter.mode(
                          appStore.isDarkMode
                              ? Colors.white
                              : categoryData.color
                                  .validate(value: '000')
                                  .toColor(),
                          BlendMode.srcIn,
                        ),
                        placeholderBuilder: (context) =>
                            const PlaceHolderWidget(
                          height: CATEGORY_ICON_SIZE,
                          width: CATEGORY_ICON_SIZE,
                          color: transparentColor,
                        ),
                      ).paddingAll(10),
                    )
                  : Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: appStore.isDarkMode
                              ? Colors.white24
                              : context.cardColor,
                          shape: BoxShape.circle),
                      child: CachedImageWidget(
                        url: categoryData.categoryImage.validate(),
                        fit: BoxFit.cover,
                        width: 30,
                        height: 30,
                        circle: true,
                        placeHolderImage: '',
                      ),
                    ),
          8.height,
          Marquee(
            directionMarguee: DirectionMarguee.oneDirection,
            child: Text(
              '${categoryData.name.validate()}',
              style: primaryTextStyle(size: 12),
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
