import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../component/empty_error_state_widget.dart';
import '../component/favourite_provider_component.dart';
import '../network/rest_apis.dart';
import '../utils/constant.dart';
import 'shimmer/favourite_provider_shimmer.dart';

// Set this to true to show dummy data for UI testing
const bool USE_DUMMY_DATA = true;

class FavouriteProviderScreen extends StatefulWidget {
  const FavouriteProviderScreen({Key? key}) : super(key: key);

  @override
  _FavouriteProviderScreenState createState() =>
      _FavouriteProviderScreenState();
}

class _FavouriteProviderScreenState extends State<FavouriteProviderScreen> {
  Future<List<UserData>>? future;

  List<UserData> providers = [];
  List<UserData> dummyProviders = [];

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
    future =
        getProviderWishlist(page, providers: providers, lastPageCallBack: (p0) {
      isLastPage = p0;
    });
  }

  void _generateDummyData() {
    dummyProviders = [
      UserData(
        id: 1,
        providerId: 1,
        firstName: 'Jorge',
        lastName: 'Perez',
        displayName: 'Jorge Perez',
        profileImage:
            'https://res.cloudinary.com/daqvdhmw8/image/upload/v1765533347/Rectangle_303_zaodmv.png',
        isFavourite: 1, // First one is favorited (filled green heart)
        email: 'jorge.perez1@example.com',
        contactNumber: '+1234567890',
        userType: USER_TYPE_PROVIDER,
        status: 1,
      ),
      UserData(
        id: 2,
        providerId: 2,
        firstName: 'Jorge',
        lastName: 'Perez',
        displayName: 'Jorge Perez',
        profileImage:
            'https://res.cloudinary.com/daqvdhmw8/image/upload/v1765533347/Rectangle_303_zaodmv.png',
        isFavourite: 0, // Outlined heart
        email: 'jorge.perez2@example.com',
        contactNumber: '+1234567891',
        userType: USER_TYPE_PROVIDER,
        status: 1,
      ),
      UserData(
        id: 3,
        providerId: 3,
        firstName: 'Jorge',
        lastName: 'Perez',
        displayName: 'Jorge Perez',
        profileImage:
            'https://res.cloudinary.com/daqvdhmw8/image/upload/v1765533347/Rectangle_303_zaodmv.png',
        isFavourite: 0,
        email: 'jorge.perez3@example.com',
        contactNumber: '+1234567892',
        userType: USER_TYPE_PROVIDER,
        status: 1,
      ),
      UserData(
        id: 4,
        providerId: 4,
        firstName: 'Jorge',
        lastName: 'Perez',
        displayName: 'Jorge Perez',
        profileImage:
            'https://res.cloudinary.com/daqvdhmw8/image/upload/v1765533347/Rectangle_303_zaodmv.png',
        isFavourite: 0,
        email: 'jorge.perez4@example.com',
        contactNumber: '+1234567893',
        userType: USER_TYPE_PROVIDER,
        status: 1,
      ),
      UserData(
        id: 5,
        providerId: 5,
        firstName: 'Jorge',
        lastName: 'Perez',
        displayName: 'Jorge Perez',
        profileImage:
            'https://res.cloudinary.com/daqvdhmw8/image/upload/v1765533347/Rectangle_303_zaodmv.png',
        isFavourite: 0,
        email: 'jorge.perez5@example.com',
        contactNumber: '+1234567894',
        userType: USER_TYPE_PROVIDER,
        status: 1,
      ),
      UserData(
        id: 6,
        providerId: 6,
        firstName: 'Jorge',
        lastName: 'Perez',
        displayName: 'Jorge Perez',
        profileImage:
            'https://res.cloudinary.com/daqvdhmw8/image/upload/v1765533347/Rectangle_303_zaodmv.png',
        isFavourite: 0,
        email: 'jorge.perez6@example.com',
        contactNumber: '+1234567895',
        userType: USER_TYPE_PROVIDER,
        status: 1,
      ),
    ];
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffold,
      appBar: appBarWidget(
        center: true,
        language.favouriteProvider,
        textSize: APP_BAR_TEXT_SIZE,
        color: context.primary,
        textColor: context.onPrimary,
        backWidget: BackWidget(),
      ),
      body: Stack(
        children: [
          USE_DUMMY_DATA
              ? _buildDummyDataList()
              : FutureBuilder<List<UserData>>(
                  future: future,
                  initialData: cachedProviderFavList,
                  builder: (context, snap) {
                    if (snap.hasData) {
                      if (snap.data.validate().isEmpty)
                        return NoDataWidget(
                          title: language.noProviderFound,
                          subTitle: language.noProviderFoundMessage,
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
                              return FavouriteProviderComponent(
                                data: snap.data![index],
                                width: context.width() * 0.5 - 26,
                                onUpdate: () {
                                  page = 1;
                                  init();
                                  setState(() {});
                                },
                              );
                            },
                          ),
                        ],
                      );
                    }

                    return snapWidgetHelper(
                      snap,
                      loadingWidget: FavouriteProviderShimmer(),
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
    if (dummyProviders.isEmpty) {
      return NoDataWidget(
        title: language.noProviderFound,
        subTitle: language.noProviderFoundMessage,
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
          crossAxisSpacing: 12,
          mainAxisSpacing: 14,
          childAspectRatio: 0.85,
        ),
        itemCount: dummyProviders.length,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return FavouriteProviderComponent(
            data: dummyProviders[index],
            width: context.width() / 2 - 24,
            isFavouriteProvider: true,
            onUpdate: () {
              // Toggle favorite status for dummy data
              dummyProviders[index].isFavourite =
                  dummyProviders[index].isFavourite == 1 ? 0 : 1;
              setState(() {});
            },
          );
        },
      ),
    );
  }
}
