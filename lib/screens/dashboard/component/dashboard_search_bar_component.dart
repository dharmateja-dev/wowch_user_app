import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/screens/service/search_service_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class DashboardSearchBarComponent extends StatelessWidget {
  final List<ServiceData>? featuredList;

  DashboardSearchBarComponent({this.featuredList});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ic_search.iconImage(size: 20, context: context),
          12.width,
          Expanded(
            child: Text(
              language.search, // localized placeholder "Search"
              style: secondaryTextStyle(
                color: appTextSecondaryColor,
                size: 14,
              ),
            ),
          ),
          8.width,
          GestureDetector(
            onTap: () {
              locationWiseService(context, () {});
            },
            child: ic_active_location.iconImage(
                size: 20, context: context, color: primaryColor),
          ),
        ],
      ),
    ).onTap(() {
      SearchServiceScreen(featuredList: featuredList).launch(context);
    });
  }
}
