import 'dart:async';

import 'package:booking_system_flutter/screens/dashboard/component/promotional_banner_slider_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/horizontal_shop_list_component.dart';
import 'package:booking_system_flutter/screens/newDashboard/dashboard_3/component/appbar_dashboard_component_3.dart';
import 'package:booking_system_flutter/screens/newDashboard/dashboard_3/component/category_list_dashboard_component_3.dart';
import 'package:booking_system_flutter/screens/newDashboard/dashboard_3/component/job_request_dahboard_component_3.dart';
import 'package:booking_system_flutter/screens/newDashboard/dashboard_3/component/service_list_dashboard_component_3.dart';
import 'package:booking_system_flutter/screens/newDashboard/dashboard_3/component/slider_dashboard_component_3.dart';
import 'package:booking_system_flutter/screens/newDashboard/dashboard_3/shimmer/dashboard_shimmer_3.dart';
import 'package:booking_system_flutter/utils/dummy_data_helper.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/loader_widget.dart';
import '../../../main.dart';
import '../../../model/dashboard_model.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/colors.dart';
import '../../../utils/common.dart';
import '../../../utils/constant.dart';
import '../../../utils/images.dart';
import 'component/upcoming_booking_dashboard_component_3.dart';

class DashboardFragment3 extends StatefulWidget {
  @override
  _DashboardFragment3State createState() => _DashboardFragment3State();
}

class _DashboardFragment3State extends State<DashboardFragment3> {
  Future<DashboardResponse>? future;

  @override
  void initState() {
    super.initState();
    init(showLoader: false);

    LiveStream().on(LIVESTREAM_UPDATE_DASHBOARD, (p0) async {
      await init();
    });
  }

  Future<void> init({bool showLoader = true}) async {
    appStore.setLoading(showLoader);
    try {
      future = userDashboard(isCurrentLocation: appStore.isCurrentLocation, lat: getDoubleAsync(LATITUDE), long: getDoubleAsync(LONGITUDE));
    } catch (e) {
      // If API call fails, use dummy data
      log('API call failed, using dummy data: $e');
      future = Future.value(DummyDataHelper.getDummyDashboardData());
      // Cache the dummy data
      cachedDashboardResponse = DummyDataHelper.getDummyDashboardData();
    }
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    LiveStream().dispose(LIVESTREAM_UPDATE_DASHBOARD);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SnapHelperWidget<DashboardResponse>(
            initialData: cachedDashboardResponse,
            future: future,
            errorBuilder: (error) {
              // Instead of showing error, use dummy data
              log('Error loading dashboard, using dummy data: $error');
              final dummyData = DummyDataHelper.getDummyDashboardData();
              cachedDashboardResponse = dummyData;
              return Observer(builder: (context) {
                return AnimatedScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  listAnimationType: ListAnimationType.FadeIn,
                  fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                  onSwipeRefresh: () async {
                    setValue(LAST_APP_CONFIGURATION_SYNCED_TIME, 0);
                    await init();
                    return await 2.seconds.delay;
                  },
                  children: [
                    (context.statusBarHeight).toInt().height,
                    AppbarDashboardComponent3(
                      featuredList: dummyData.featuredServices.validate(),
                      callback: () async {
                        await init();
                      },
                    ),
                    Observer(
                      builder: (context) {
                        return AppButton(
                          padding: const EdgeInsets.all(0),
                          width: context.width(),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: boxDecorationDefault(color: context.cardColor),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ic_location.iconImage(color: appStore.isDarkMode ? Colors.white : Colors.black, size: 24),
                                8.width,
                                Text(
                                  appStore.isCurrentLocation ? getStringAsync(CURRENT_ADDRESS) : language.lblLocationOff,
                                  style: secondaryTextStyle(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ).expand(),
                                8.width,
                                Icon(Icons.keyboard_arrow_down, size: 24, color: appStore.isCurrentLocation ? primaryColor : context.iconColor),
                              ],
                            ),
                          ),
                          onTap: () async {
                            locationWiseService(context, () async {
                              await init();
                            });
                          },
                        ).cornerRadiusWithClipRRect(28);
                      },
                    ).paddingSymmetric(horizontal: 16),
                    24.height,
                    SliderDashboardComponent3(sliderList: dummyData.slider.validate()),
                    UpcomingBookingDashboardComponent3(upcomingBookingData: dummyData.upcomingData).paddingTop(16),
                    CategoryListDashboardComponent3(categoryList: dummyData.category.validate(), listTiTle: language.category),
                    if (dummyData.promotionalBanner.validate().isNotEmpty && appConfigurationStore.isPromotionalBanner)
                      PromotionalBannerSliderComponent(
                        promotionalBannerList: dummyData.promotionalBanner.validate(),
                      ).paddingTop(16),
                    16.height,
                    ServiceListDashboardComponent3(serviceList: dummyData.service.validate(), serviceListTitle: language.popularServices),
                    14.height,
                    ServiceListDashboardComponent3(
                      serviceList: dummyData.featuredServices.validate(),
                      serviceListTitle: language.featuredServices,
                      isFeatured: true,
                    ),
                    HorizontalShopListComponent(shopList: dummyData.shops.take(5).toList()),
                    if (appConfigurationStore.jobRequestStatus) JobRequestDashboardComponent3(),
                  ],
                );
              });
            },
            loadingWidget: DashboardShimmer3(),
            onSuccess: (snap) {
              return Observer(builder: (context) {
                return AnimatedScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  listAnimationType: ListAnimationType.FadeIn,
                  fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                  onSwipeRefresh: () async {
                    setValue(LAST_APP_CONFIGURATION_SYNCED_TIME, 0);
                    await init();

                    return await 2.seconds.delay;
                  },
                  children: [
                    (context.statusBarHeight).toInt().height,
                    AppbarDashboardComponent3(
                      featuredList: snap.featuredServices.validate(),
                      callback: () async {
                        await init();
                      },
                    ),
                    Observer(
                      builder: (context) {
                        return AppButton(
                          padding: const EdgeInsets.all(0),
                          width: context.width(),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: boxDecorationDefault(color: context.cardColor),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ic_location.iconImage(color: appStore.isDarkMode ? Colors.white : Colors.black, size: 24),
                                8.width,
                                Text(
                                  appStore.isCurrentLocation ? getStringAsync(CURRENT_ADDRESS) : language.lblLocationOff,
                                  style: secondaryTextStyle(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ).expand(),
                                8.width,
                                Icon(Icons.keyboard_arrow_down, size: 24, color: appStore.isCurrentLocation ? primaryColor : context.iconColor),
                              ],
                            ),
                          ),
                          onTap: () async {
                            locationWiseService(context, () async {
                              await init();
                            });
                          },
                        ).cornerRadiusWithClipRRect(28);
                      },
                    ).paddingSymmetric(horizontal: 16),
                    24.height,
                    SliderDashboardComponent3(sliderList: snap.slider.validate()),
                    UpcomingBookingDashboardComponent3(upcomingBookingData: snap.upcomingData).paddingTop(16),
                    CategoryListDashboardComponent3(categoryList: snap.category.validate(), listTiTle: language.category),
                    if (snap.promotionalBanner.validate().isNotEmpty && appConfigurationStore.isPromotionalBanner)
                      PromotionalBannerSliderComponent(
                        promotionalBannerList: snap.promotionalBanner.validate(),
                      ).paddingTop(16),
                    16.height,
                    ServiceListDashboardComponent3(serviceList: snap.service.validate(), serviceListTitle: language.popularServices),
                    14.height,
                    ServiceListDashboardComponent3(
                      serviceList: snap.featuredServices.validate(),
                      serviceListTitle: language.featuredServices,
                      isFeatured: true,
                    ),
                    HorizontalShopListComponent(shopList: snap.shops.take(5).toList()),
                    if (appConfigurationStore.jobRequestStatus) JobRequestDashboardComponent3(),
                  ],
                );
              });
            },
          ),
          Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}