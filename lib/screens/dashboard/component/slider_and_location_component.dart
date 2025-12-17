import 'dart:async';

import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/dashboard_model.dart';
import 'package:booking_system_flutter/screens/notification/notification_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/configs.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/service_data_model.dart';
import '../../../utils/common.dart';
import '../../service/search_service_screen.dart';

class SliderLocationComponent extends StatefulWidget {
  final List<SliderModel> sliderList;
  final List<ServiceData>? featuredList;
  final VoidCallback? callback;

  SliderLocationComponent(
      {required this.sliderList, this.callback, this.featuredList});

  @override
  State<SliderLocationComponent> createState() =>
      _SliderLocationComponentState();
}

class _SliderLocationComponentState extends State<SliderLocationComponent> {
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
      height: 325,
      width: context.width(),
      child: Stack(
        children: [
          if (appStore.isLoggedIn)
            Positioned(
              top: context.statusBarHeight + 16,
              right: 16,
              child: Container(
                decoration: boxDecorationDefault(
                    color: context.secondaryContainer, shape: BoxShape.circle),
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
                    Observer(
                      builder: (context) {
                        return Positioned(
                          top: -20,
                          right: -10,
                          child: appStore.unreadCount.validate() > 0
                              ? Container(
                                  padding: const EdgeInsets.all(4),
                                  child: FittedBox(
                                    child: Text(appStore.unreadCount.toString(),
                                        style: context.primaryTextStyle(
                                            size: 12,
                                            color: context.onPrimary)),
                                  ),
                                  decoration: boxDecorationDefault(
                                      color: Colors.red,
                                      shape: BoxShape.circle),
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
            ),
        ],
      ),
    );
  }

  Decoration get commonDecoration {
    return boxDecorationDefault(
      color: context.secondaryContainer,
      boxShadow: [
        BoxShadow(color: shadowColorGlobal, offset: const Offset(1, 0)),
        BoxShadow(color: shadowColorGlobal, offset: const Offset(0, 1)),
        BoxShadow(color: shadowColorGlobal, offset: const Offset(-1, 0)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          bottom: -24,
          right: 16,
          left: 16,
          child: Row(
            children: [
              Expanded(
                child: Observer(
                  builder: (context) {
                    return AppButton(
                      padding: const EdgeInsets.all(0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: commonDecoration,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ic_location.iconImage(context: context),
                            8.width,
                            Expanded(
                              child: Text(
                                appStore.isCurrentLocation
                                    ? getStringAsync(CURRENT_ADDRESS)
                                    : language.lblLocationOff,
                                style: context.secondaryTextStyle(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            8.width,
                            ic_active_location.iconImage(
                                size: 24,
                                context: context,
                                color: appStore.isCurrentLocation
                                    ? primaryColor
                                    : grey),
                          ],
                        ),
                      ),
                      onTap: () async {
                        locationWiseService(context, () {
                          widget.callback?.call();
                        });
                      },
                    );
                  },
                ),
              ),
              16.width,
              GestureDetector(
                onTap: () {
                  SearchServiceScreen(featuredList: widget.featuredList)
                      .launch(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: commonDecoration,
                  child: ic_search.iconImage(
                      color: context.primary, context: context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
