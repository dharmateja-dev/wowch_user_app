import 'dart:async';

import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../component/cached_image_widget.dart';
import '../../../../main.dart';
import '../../../../model/dashboard_model.dart';
import '../../../../model/service_data_model.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/common.dart';
import '../../../../utils/configs.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/images.dart';
import '../../../notification/notification_screen.dart';
import '../../../service/search_service_screen.dart';
import '../../../service/service_detail_screen.dart';

class SliderDashboardComponent1 extends StatefulWidget {
  final List<SliderModel> sliderList;
  final List<ServiceData>? featuredList;
  final VoidCallback? callback;

  SliderDashboardComponent1(
      {required this.sliderList, this.callback, this.featuredList});

  @override
  _SliderDashboardComponent1State createState() =>
      _SliderDashboardComponent1State();
}

class _SliderDashboardComponent1State extends State<SliderDashboardComponent1> {
  PageController sliderPageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (getBoolAsync(AUTO_SLIDER_STATUS, defaultValue: true) &&
        widget.sliderList.length >= 2) {
      _timer = Timer.periodic(
          const Duration(seconds: DASHBOARD_AUTO_SLIDER_SECOND), (Timer timer) {
        if (_currentPage < widget.sliderList.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        sliderPageController.animateToPage(_currentPage,
            duration: const Duration(milliseconds: 950),
            curve: Curves.easeOutQuart);
      });

      sliderPageController.addListener(() {
        _currentPage = sliderPageController.page!.toInt();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    sliderPageController.dispose();
  }

  Widget getSliderWidget() {
    return SizedBox(
      height: 300,
      width: context.width(),
      child: Stack(
        children: [
          widget.sliderList.isNotEmpty
              ? PageView(
                  controller: sliderPageController,
                  children: List.generate(
                    widget.sliderList.length,
                    (index) {
                      SliderModel data = widget.sliderList[index];
                      return CachedImageWidget(
                              url: data.sliderImage.validate(),
                              height: 250,
                              width: context.width(),
                              fit: BoxFit.cover)
                          .onTap(() {
                        if (data.type == SERVICE) {
                          ServiceDetailScreen(
                                  serviceId: data.typeId.validate().toInt())
                              .launch(context,
                                  pageRouteAnimation: PageRouteAnimation.Fade);
                        }
                      });
                    },
                  ),
                )
              : CachedImageWidget(url: '', height: 250, width: context.width()),
          if (widget.sliderList.length.validate() > 1)
            Positioned(
              bottom: 25,
              left: 16,
              child: DotIndicator(
                pageController: sliderPageController,
                pages: widget.sliderList,
                indicatorColor: primaryColor,
                unselectedIndicatorColor: white,
                currentBoxShape: BoxShape.rectangle,
                boxShape: BoxShape.rectangle,
                borderRadius: radius(16),
                currentBorderRadius: radius(16),
                currentDotSize: 70,
                currentDotWidth: 20,
                dotSize: 40,
              ).scale(scale: 0.4),
            ),
          if (appStore.isLoggedIn)
            Positioned(
              top: context.statusBarHeight + 16,
              right: 16,
              child: Container(
                decoration: boxDecorationDefault(
                    color: context.cardColor, shape: BoxShape.circle),
                height: 36,
                padding: const EdgeInsets.all(8),
                width: 36,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ic_notification
                        .iconImage(
                            size: 24, color: context.primary, context: context)
                        .center(),
                    Observer(builder: (context) {
                      return Positioned(
                        top: -20,
                        right: -10,
                        child: appStore.unreadCount.validate() > 0
                            ? Container(
                                padding: const EdgeInsets.all(4),
                                child: FittedBox(
                                  child: Text(appStore.unreadCount.toString(),
                                      style: primaryTextStyle(
                                          size: 12, color: Colors.white)),
                                ),
                                decoration: boxDecorationDefault(
                                    color: Colors.red, shape: BoxShape.circle),
                              )
                            : const Offstage(),
                      );
                    })
                  ],
                ),
              ).onTap(() {
                NotificationScreen().launch(context);
              }),
            )
        ],
      ),
    );
  }

  Decoration get commonDecoration {
    return boxDecorationDefault(
      color: context.cardColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.primary,
      child: Column(
        children: [
          // Header section with dark green background
          Container(
            color: context.primary,
            padding: EdgeInsets.only(
              top: context.statusBarHeight + 16,
              left: 16,
              right: 16,
              bottom: 24,
            ),
            child: Column(
              children: [
                // Location row with notification bell
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: Colors.white, size: 20),
                    8.width,
                    Expanded(
                      child: Observer(
                        builder: (context) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appStore.isCurrentLocation
                                    ? 'Current Location'
                                    : language.lblLocationOff,
                                style: boldTextStyle(
                                    color: Colors.white, size: 14),
                              ),
                              2.height,
                              Text(
                                appStore.isCurrentLocation
                                    ? getStringAsync(CURRENT_ADDRESS)
                                    : 'Enable location',
                                style: secondaryTextStyle(
                                    color: Colors.white70, size: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    if (appStore.isLoggedIn)
                      Container(
                        decoration: boxDecorationDefault(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        height: 40,
                        width: 40,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(Icons.notifications_outlined,
                                    color: Colors.white, size: 22)
                                .center(),
                            Observer(builder: (context) {
                              return Positioned(
                                top: 0,
                                right: 0,
                                child: appStore.unreadCount.validate() > 0
                                    ? Container(
                                        padding: const EdgeInsets.all(4),
                                        child: FittedBox(
                                          child: Text(
                                            appStore.unreadCount.toString(),
                                            style: primaryTextStyle(
                                                size: 10, color: Colors.white),
                                          ),
                                        ),
                                        decoration: boxDecorationDefault(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    : const Offstage(),
                              );
                            })
                          ],
                        ),
                      ).onTap(() {
                        NotificationScreen().launch(context);
                      }),
                  ],
                ).onTap(() {
                  locationWiseService(context, () {
                    widget.callback?.call();
                  });
                }),
                16.height,
                // Search bar
                GestureDetector(
                  onTap: () {
                    SearchServiceScreen(featuredList: widget.featuredList)
                        .launch(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: boxDecorationDefault(
                      color: Colors.white,
                      borderRadius: radius(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey, size: 22),
                        12.width,
                        Text(
                          'Search',
                          style:
                              secondaryTextStyle(color: Colors.grey, size: 14),
                        ),
                        Spacer(),
                        Icon(Icons.my_location_outlined,
                            color: Colors.grey, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
