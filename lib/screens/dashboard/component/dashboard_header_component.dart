import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/screens/dashboard/component/dashboard_search_bar_component.dart';
import 'package:booking_system_flutter/screens/notification/notification_screen.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

class DashboardHeaderComponent extends StatelessWidget {
  final List<ServiceData>? featuredList;
  DashboardHeaderComponent({required this.featuredList});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      padding: EdgeInsets.only(
        top: context.statusBarHeight + 8,
        bottom: 18, // Extra padding for curved corners effect
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: context.primary, // Dark green background
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Location section
              Expanded(
                child: Observer(
                  builder: (context) {
                    return GestureDetector(
                      onTap: () async {
                        locationWiseService(context, () {});
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ic_location.iconImage(
                            size: 20,
                            color: context.onPrimary,
                            context: context,
                          ),
                          8.width,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Amar Harmony",
                                  style: boldTextStyle(
                                    color: context.onPrimary,
                                    size: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                2.height,
                                Text(
                                  appStore.isCurrentLocation
                                      ? getStringAsync(CURRENT_ADDRESS)
                                      : language.lblLocationOff,
                                  style: secondaryTextStyle(
                                    color: context.onPrimary
                                        .withValues(alpha: 0.9),
                                    size: 11,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              16.width,
              // Notification button
              if (appStore.isLoggedIn)
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: context.onPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ic_notification
                          .iconImage(
                              size: 20,
                              color: context.primary,
                              context: context)
                          .center(),
                      Observer(
                        builder: (context) {
                          return Positioned(
                            top: -2,
                            right: -2,
                            child: appStore.unreadCount.validate() > 0
                                ? Container(
                                    padding: const EdgeInsets.all(4),
                                    child: FittedBox(
                                      child: Text(
                                        appStore.unreadCount.toString(),
                                        style: primaryTextStyle(
                                          size: 10,
                                          color: context.onPrimary,
                                        ),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                : const Offstage(),
                          );
                        },
                      ),
                    ],
                  ),
                ).onTap(() {
                  NotificationScreen().launch(context);
                }),
            ],
          ),
          16.height,
          DashboardSearchBarComponent(
            featuredList: featuredList,
          ),
        ],
      ),
    );
  }
}
