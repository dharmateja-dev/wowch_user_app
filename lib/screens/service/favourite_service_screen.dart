import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/service/component/service_component.dart';
import 'package:booking_system_flutter/screens/service/shimmer/favourite_service_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/empty_error_state_widget.dart';
import '../../utils/constant.dart';

// Set this to true to show dummy data for UI testing
const bool USE_DUMMY_DATA = true;

class FavouriteServiceScreen extends StatefulWidget {
  const FavouriteServiceScreen({Key? key}) : super(key: key);

  @override
  _FavouriteServiceScreenState createState() => _FavouriteServiceScreenState();
}

class _FavouriteServiceScreenState extends State<FavouriteServiceScreen> {
  Future<List<ServiceData>>? future;

  List<ServiceData> services = [];
  List<ServiceData> dummyServices = [];

  int page = 1;

  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if (USE_DUMMY_DATA) {
      _generateDummyData();
      return;
    }
    future = getWishlist(page, services: services, lastPageCallBack: (p0) {
      isLastPage = p0;
    });
  }

  void _generateDummyData() {
    dummyServices = [
      ServiceData(
        id: 1,
        name: 'Housekeepers',
        price: 600,
        totalRating: 4.8,
        totalReview: 120,
        duration: '30 min',
        providerName: 'Abdul Kader',
        providerImage: 'https://via.placeholder.com/150/4CAF50/FFFFFF?text=AK',
        isFavourite: 1,
        categoryName: 'Cleaning',
        serviceAttachments: [
          'https://via.placeholder.com/400/4CAF50/FFFFFF?text=Housekeeper'
        ],
        type: SERVICE_TYPE_FIXED,
        status: 1,
      ),
      ServiceData(
        id: 2,
        name: 'Housekeepers',
        price: 600,
        totalRating: 4.8,
        totalReview: 120,
        duration: '30 min',
        providerName: 'Abdul Kader',
        providerImage: 'https://via.placeholder.com/150/4CAF50/FFFFFF?text=AK',
        isFavourite: 1,
        categoryName: 'Cleaning',
        serviceAttachments: [
          'https://via.placeholder.com/400/4CAF50/FFFFFF?text=Housekeeper'
        ],
        type: SERVICE_TYPE_FIXED,
        status: 1,
      ),
      ServiceData(
        id: 3,
        name: 'Housekeepers',
        price: 600,
        totalRating: 4.8,
        totalReview: 120,
        duration: '30 min',
        providerName: 'Abdul Kader',
        providerImage: 'https://via.placeholder.com/150/4CAF50/FFFFFF?text=AK',
        isFavourite: 1,
        categoryName: 'Cleaning',
        serviceAttachments: [
          'https://via.placeholder.com/400/4CAF50/FFFFFF?text=Housekeeper'
        ],
        type: SERVICE_TYPE_FIXED,
        status: 1,
      ),
      ServiceData(
        id: 4,
        name: 'Housekeepers',
        price: 600,
        totalRating: 4.8,
        totalReview: 120,
        duration: '30 min',
        providerName: 'Abdul Kader',
        providerImage: 'https://via.placeholder.com/150/4CAF50/FFFFFF?text=AK',
        isFavourite: 1,
        categoryName: 'Cleaning',
        serviceAttachments: [
          'https://via.placeholder.com/400/4CAF50/FFFFFF?text=Housekeeper'
        ],
        type: SERVICE_TYPE_FIXED,
        status: 1,
      ),
    ];
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.lblFavorite,
        color: context.primaryColor,
        textColor: white,
        backWidget: BackWidget(),
        textSize: APP_BAR_TEXT_SIZE,
      ),
      body: Stack(
        children: [
          USE_DUMMY_DATA
              ? _buildDummyDataList()
              : FutureBuilder<List<ServiceData>>(
                  future: future,
                  initialData: cachedServiceFavList,
                  builder: (context, snap) {
                    if (snap.hasData) {
                      if (snap.data.validate().isEmpty)
                        return NoDataWidget(
                          title: language.lblNoServicesFound,
                          subTitle: language.noFavouriteSubTitle,
                          imageWidget: const EmptyStateWidget(),
                        );

                      return AnimatedScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
                        listAnimationType: ListAnimationType.FadeIn,
                        fadeInConfiguration:
                            FadeInConfiguration(duration: 2.seconds),
                        physics: const AlwaysScrollableScrollPhysics(),
                        onNextPage: () {
                          if (!isLastPage) {
                            page++;
                            appStore.setLoading(true);

                            init();
                            setState(() {});
                          }
                        },
                        onSwipeRefresh: () async {
                          page = 1;

                          init();
                          setState(() {});

                          return await 2.seconds.delay;
                        },
                        children: [
                          AnimatedWrap(
                            spacing: 16,
                            runSpacing: 16,
                            listAnimationType: ListAnimationType.FadeIn,
                            fadeInConfiguration:
                                FadeInConfiguration(duration: 2.seconds),
                            scaleConfiguration: ScaleConfiguration(
                                duration: 300.milliseconds,
                                delay: 50.milliseconds),
                            itemCount: snap.data!.length,
                            itemBuilder: (_, index) {
                              return ServiceComponent(
                                serviceData: snap.data![index],
                                width:
                                    appConfigurationStore.userDashboardType ==
                                            DEFAULT_USER_DASHBOARD
                                        ? context.width() / 2 - 24
                                        : context.width(),
                                isFavouriteService: true,
                                onUpdate: () async {
                                  page = 1;
                                  await init();
                                  setState(() {});
                                },
                              );
                            },
                          )
                        ],
                      );
                    }

                    return snapWidgetHelper(
                      snap,
                      loadingWidget: FavouriteServiceShimmer(),
                      errorBuilder: (error) {
                        return NoDataWidget(
                          title: error,
                          imageWidget: const ErrorStateWidget(),
                          retryText: language.reload,
                          onRetry: () {
                            page = 1;
                            appStore.setLoading(true);

                            init();
                            setState(() {});
                          },
                        );
                      },
                    );
                  },
                ),
          Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }

  Widget _buildDummyDataList() {
    if (dummyServices.isEmpty) {
      return NoDataWidget(
        title: language.lblNoServicesFound,
        subTitle: language.noFavouriteSubTitle,
        imageWidget: const EmptyStateWidget(),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _generateDummyData();
        setState(() {});
        return await 2.seconds.delay;
      },
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.7,
        ),
        itemCount: dummyServices.length,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return ServiceComponent(
            serviceData: dummyServices[index],
            width: context.width() / 2 - 24,
            isFavouriteService: true,
            onUpdate: () {
              // Remove from dummy list when unfavorited
              dummyServices.removeAt(index);
              setState(() {});
            },
          );
        },
      ),
    );
  }
}
