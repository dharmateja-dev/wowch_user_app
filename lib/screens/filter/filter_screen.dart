import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/screens/filter/component/filter_price_component.dart';
import 'package:booking_system_flutter/screens/filter/component/filter_provider_component.dart';
import 'package:booking_system_flutter/screens/filter/component/filter_rating_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

class FilterScreen extends StatefulWidget {
  final bool isFromProvider;
  final bool isFromCategory;
  final bool isFromShop;

  FilterScreen({
    this.isFromProvider = true,
    this.isFromCategory = false,
    this.isFromShop = false,
  });

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  int isSelected = 0;

  List<UserData> providerList = [];

  num? minPrice;
  num? maxPrice;

  @override
  void initState() {
    super.initState();
    appStore.setLoading(true);
    afterBuildCreated(() => init());
  }

  void init() async {
    getProviders();
  }

  Future<void> getProviders() async {
    appStore.setLoading(true);

    // Using dummy provider data
    minPrice = 100;
    maxPrice = 5000;

    providerList = [
      UserData(
        id: 1,
        displayName: 'Jorge Perez',
        profileImage: '',
        providersServiceRating: 5.0,
        createdAt: '2020-01-15T00:00:00.000Z',
        totalBooking: 150,
      ),
      UserData(
        id: 2,
        displayName: 'Jorge Perez',
        profileImage: '',
        providersServiceRating: 5.0,
        createdAt: '2020-03-20T00:00:00.000Z',
        totalBooking: 120,
      ),
      UserData(
        id: 3,
        displayName: 'Jorge Perez',
        profileImage: '',
        providersServiceRating: 5.0,
        createdAt: '2020-05-10T00:00:00.000Z',
        totalBooking: 200,
      ),
      UserData(
        id: 4,
        displayName: 'Jorge Perez',
        profileImage: '',
        providersServiceRating: 5.0,
        createdAt: '2020-07-25T00:00:00.000Z',
        totalBooking: 85,
      ),
      UserData(
        id: 5,
        displayName: 'Jorge Perez',
        profileImage: '',
        providersServiceRating: 5.0,
        createdAt: '2020-09-12T00:00:00.000Z',
        totalBooking: 175,
      ),
      UserData(
        id: 6,
        displayName: 'Jorge Perez',
        profileImage: '',
        providersServiceRating: 5.0,
        createdAt: '2020-11-30T00:00:00.000Z',
        totalBooking: 95,
      ),
      UserData(
        id: 7,
        displayName: 'Jorge Perez',
        profileImage: '',
        providersServiceRating: 5.0,
        createdAt: '2020-02-18T00:00:00.000Z',
        totalBooking: 140,
      ),
      UserData(
        id: 8,
        displayName: 'Jorge Perez',
        profileImage: '',
        providersServiceRating: 5.0,
        createdAt: '2020-04-05T00:00:00.000Z',
        totalBooking: 110,
      ),
      UserData(
        id: 9,
        displayName: 'Jorge Perez',
        profileImage: '',
        providersServiceRating: 5.0,
        createdAt: '2020-06-22T00:00:00.000Z',
        totalBooking: 165,
      ),
    ];

    // Apply any existing filter selections
    for (var element in providerList) {
      if (filterStore.providerId.contains(element.id)) {
        element.isSelected = true;
      }
    }

    setState(() {});
    appStore.setLoading(false);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget buildItem({required String name, required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
      width: context.width(),
      decoration: boxDecorationDefault(
        color: isSelected ? context.cardColor : context.scaffoldBackgroundColor,
        borderRadius: radius(0),
      ),
      child: Text(name, style: boldTextStyle(size: 12)),
    );
  }

  void clearFilter() {
    filterStore.clearFilters();
    finish(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: AppScaffold(
        appBarTitle: language.lblFilterBy,
        scaffoldBackgroundColor: context.cardColor,
        child: Column(
          children: [
            Row(
              children: [
                /// LEFT FILTER MENU - Only 3 options: Provider, Price, Ratings
                Container(
                  decoration: boxDecorationDefault(
                    color: context.scaffoldBackgroundColor,
                    borderRadius: radius(0),
                  ),
                  child: Column(
                    children: [
                      // Provider Filter
                      buildItem(
                        isSelected: isSelected == 0,
                        name: language.textProvider,
                      ).onTap(() {
                        if (!appStore.isLoading) {
                          isSelected = 0;
                          setState(() {});
                        }
                      }),
                      // Price Filter
                      buildItem(
                        isSelected: isSelected == 1,
                        name: language.lblPrice,
                      ).onTap(() {
                        if (!appStore.isLoading) {
                          isSelected = 1;
                          setState(() {});
                        }
                      }),
                      // Ratings Filter
                      buildItem(
                        isSelected: isSelected == 2,
                        name: language.lblRating,
                      ).onTap(() {
                        if (!appStore.isLoading) {
                          isSelected = 2;
                          setState(() {});
                        }
                      }),
                    ],
                  ),
                ).expand(flex: 2),

                /// RIGHT FILTER PANEL - Only 3 panels
                [
                  // Provider Panel (index 0)
                  Observer(
                    builder: (context) => FilterProviderComponent(
                      providerList: providerList,
                      showLoader: appStore.isLoading,
                    ),
                  ),
                  // Price Panel (index 1)
                  FilterPriceComponent(
                    min: minPrice.validate(),
                    max: maxPrice.validate(),
                  ),
                  // Rating Panel (index 2)
                  FilterRatingComponent(),
                ][isSelected]
                    .flexible(flex: 5),
              ],
            ).expand(),

            /// BOTTOM BUTTONS
            Observer(
              builder: (_) => Container(
                decoration: boxDecorationDefault(
                    color: context.scaffoldBackgroundColor),
                width: context.width(),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (filterStore.providerId.validate().isNotEmpty ||
                        (filterStore.isPriceMin.validate().isNotEmpty &&
                            filterStore.isPriceMax.validate().isNotEmpty) ||
                        filterStore.ratingId.validate().isNotEmpty)
                      AppButton(
                        text: language.lblClearFilter,
                        textColor: context.primaryColor,
                        shapeBorder: RoundedRectangleBorder(
                          side: BorderSide(color: context.primaryColor),
                          borderRadius: radius(),
                        ),
                        onTap: () {
                          clearFilter();
                        },
                      ).expand(),
                    16.width,
                    AppButton(
                      text: language.lblApply,
                      textColor: Colors.white,
                      color: context.primaryColor,
                      onTap: () {
                        filterStore.providerId = [];
                        providerList.forEach((element) {
                          if (element.isSelected) {
                            filterStore.addToProviderList(
                                prodId: element.id.validate());
                          }
                        });
                        finish(context, true);
                      },
                    ).expand(),
                  ],
                ),
              ).visible(!appStore.isLoading),
            ),
          ],
        ),
      ),
    );
  }
}
