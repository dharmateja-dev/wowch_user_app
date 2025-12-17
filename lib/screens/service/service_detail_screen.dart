import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/empty_error_state_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/component/price_widget.dart';
import 'package:booking_system_flutter/component/view_all_label_component.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/package_data_model.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/model/service_detail_response.dart';
import 'package:booking_system_flutter/model/shop_model.dart';
import 'package:booking_system_flutter/model/slot_data.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/booking/book_service_screen.dart';
import 'package:booking_system_flutter/screens/booking/component/booking_detail_provider_widget.dart';
import 'package:booking_system_flutter/screens/auth/sign_in_screen.dart';
import 'package:booking_system_flutter/screens/booking/provider_info_screen.dart';
import 'package:booking_system_flutter/screens/dashboard/component/horizontal_shop_list_component.dart';
import 'package:booking_system_flutter/screens/review/components/review_widget.dart';
import 'package:booking_system_flutter/screens/review/rating_view_all_screen.dart';
import 'package:booking_system_flutter/screens/service/component/service_component.dart';
import 'package:booking_system_flutter/screens/service/component/service_faq_widget.dart';
import 'package:booking_system_flutter/screens/service/component/service_header_component.dart';
import 'package:booking_system_flutter/screens/service/package/package_component.dart';
import 'package:booking_system_flutter/screens/service/shimmer/service_detail_shimmer.dart';
import 'package:booking_system_flutter/screens/shop/shop_list_screen.dart';
import 'package:booking_system_flutter/store/service_addon_store.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/images.dart';
import 'addons/service_addons_component.dart';

ServiceAddonStore serviceAddonStore = ServiceAddonStore();

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;
  final ServiceData? service;
  final bool isFromProviderInfo;

  ServiceDetailScreen({
    required this.serviceId,
    this.service,
    this.isFromProviderInfo = false,
  });

  @override
  _ServiceDetailScreenState createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen>
    with TickerProviderStateMixin {
  static const bool USE_DUMMY_DATA = true;
  PageController pageController = PageController();

  Future<ServiceDetailResponse>? future;

  int selectedAddressId = 0;
  int selectedBookingAddressId = -1;
  BookingPackage? selectedPackage;

  ShopModel? selectedShop;

  @override
  void initState() {
    super.initState();
    serviceAddonStore.selectedServiceAddon.clear();
    setStatusBarColor(transparentColor);
    init();
  }

  ServiceDetailResponse _dummyResponse() {
    final demoImage =
        'https://images.pexels.com/photos/3985166/pexels-photo-3985166.jpeg?auto=compress&cs=tinysrgb&w=800';

    final addon = Serviceaddon(
      id: 1,
      name: 'Home Visit Add-on',
      price: 150,
      serviceAddonImage: demoImage,
    );

    final faqList = [
      ServiceFaq(
          id: 1,
          title: 'What is included?',
          description: 'Basic care, hygiene assistance, vitals check.'),
      ServiceFaq(
          id: 2,
          title: 'Do you provide 24/7?',
          description: 'Yes, round-the-clock support can be arranged.'),
    ];

    final ratingList = [
      RatingData(
        id: 1,
        customerName: 'Jorge Perez',
        rating: 5.0,
        review: 'Great experience, very caring and professional.',
        createdAt: '2025-09-29 10:30:00',
        profileImage: demoImage,
      ),
    ];

    final related = [
      ServiceData(
        id: 2,
        name: 'Housekeepers',
        categoryName: 'Cleaning',
        price: 600,
        discount: 0,
        duration: '00:30',
        attachments: [demoImage],
        totalRating: 4.8,
        totalReview: 20,
        providerId: 1,
        providerName: 'Abdul Kader',
        providerImage: demoImage,
      ),
      ServiceData(
        id: 3,
        name: 'Housekeepers',
        categoryName: 'Cleaning',
        price: 600,
        discount: 0,
        duration: '00:30',
        attachments: [demoImage],
        totalRating: 4.8,
        totalReview: 20,
        providerId: 1,
        providerName: 'Abdul Kader',
        providerImage: demoImage,
      ),
    ];

    final service = ServiceData(
      id: widget.serviceId,
      name: 'Nurses',
      categoryName: 'Health Care',
      price: 600,
      discount: 0,
      duration: '01:00',
      description:
          'Basic nursing care, hygiene assistance, and patient monitoring.',
      attachments: [demoImage],
      visitType: VISIT_OPTION_ON_SITE,
      bookingSlots: [],
      serviceAddressMapping: [],
      servicePackage: [],
      totalRating: 4.8,
      totalReview: 12,
    );

    final provider = UserData(
      id: 1,
      displayName: 'Abdul Kader',
      email: 'abdul@example.com',
      contactNumber: '+91 90000 00000',
      profileImage: demoImage,
      providersServiceRating: 4.8,
      knownLanguages: 'English, Hindi',
      skills: 'Caregiving, First Aid',
    );

    final zones = <Zones>[
      Zones(id: 1, name: 'Navi Mumbai'),
      Zones(id: 2, name: 'Chennai, Tamil Nadu'),
    ];

    return ServiceDetailResponse(
      serviceDetail: service,
      provider: provider,
      ratingData: ratingList,
      relatedService: related,
      serviceFaq: faqList,
      serviceaddon: [addon],
      shops: [],
      zones: zones,
    );
  }

  void init() async {
    if (USE_DUMMY_DATA) {
      future = Future.value(_dummyResponse());
    } else {
      future = getServiceDetails(
        serviceId: widget.serviceId.validate(),
        customerId: appStore.userId,
      );
    }
    setState(() {});
  }

  //region Widgets
  Widget availableWidget(
      {required ServiceDetailResponse zone, required ServiceData data}) {
    if (zone.zones.validate().isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          8.height,
          Text(language.lblAvailableAt, style: context.boldTextStyle()),
          8.height,
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                zone.zones.validate().length,
                (index) {
                  Zones value = zone.zones.validate()[index];
                  if (value.id == null) return Offstage();
                  bool isSelected = selectedAddressId == index;
                  if (selectedBookingAddressId == -1) {
                    selectedBookingAddressId =
                        zone.zones.validate().first.id.validate();
                  }
                  return GestureDetector(
                    onTap: () {
                      selectedAddressId = index;
                      selectedBookingAddressId = value.id.validate();
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 8),
                      decoration: boxDecorationDefault(
                          borderRadius: radius(8),
                          color: isSelected
                              ? context.primary
                              : context.secondaryContainer),
                      child: Text(
                        value.name.validate(),
                        style: context.boldTextStyle(
                            color: isSelected
                                ? context.onPrimary
                                : context.onSurface),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          8.height,
        ],
      );
    }
    if (data.serviceAddressMapping.validate().isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          8.height,
          Text(language.lblAvailableAt,
              style: context.boldTextStyle(size: LABEL_TEXT_SIZE)),
          8.height,
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: List.generate(
                zone.zones.validate().length,
                (index) {
                  Zones value = zone.zones.validate()[index];
                  if (value.id == null) return Offstage();
                  bool isSelected = selectedAddressId == index;
                  if (selectedBookingAddressId == -1) {
                    selectedBookingAddressId =
                        zone.zones.validate().first.id.validate();
                  }
                  return GestureDetector(
                    onTap: () {
                      selectedAddressId = index;
                      selectedBookingAddressId = value.id.validate();
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 10),
                      decoration: boxDecorationDefault(
                          color: appStore.isDarkMode
                              ? isSelected
                                  ? primaryColor
                                  : Colors.black
                              : isSelected
                                  ? primaryColor
                                  : context.secondaryContainer),
                      child: Text(
                        value.name.validate(),
                        style: context.boldTextStyle(
                            color: isSelected
                                ? context.onPrimary
                                : textPrimaryColorGlobal),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          8.height,
        ],
      );
    }
    return const Offstage();
  }

  Widget providerWidget({required UserData data}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.lblAboutProvider,
            style: context.boldTextStyle(size: LABEL_TEXT_SIZE)),
        16.height,
        BookingDetailProviderWidget(
                providerData: data, showContactButtons: false)
            .onTap(() async {
          await ProviderInfoScreen(providerId: data.id).launch(context);
          setStatusBarColor(Colors.transparent);
        }),
      ],
    ).paddingAll(16);
  }

  Widget serviceFaqWidget({required List<ServiceFaq> data}) {
    if (data.isEmpty) return const Offstage();

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          8.height,
          ViewAllLabel(label: language.lblFaq, list: data),
          8.height,
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            padding: const EdgeInsets.all(0),
            itemBuilder: (_, index) =>
                ServiceFaqWidget(serviceFaq: data[index]),
          ),
          8.height,
        ],
      ),
    );
  }

  Widget slotsAvailable(
      {required List<SlotData> data, required bool isSlotAvailable}) {
    if (!isSlotAvailable ||
        data.where((element) => element.slot.validate().isNotEmpty).isEmpty)
      return const Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        8.height,
        Text(language.lblAvailableOnTheseDays,
            style: context.boldTextStyle(size: LABEL_TEXT_SIZE)),
        8.height,
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: List.generate(
              data
                  .where((element) => element.slot.validate().isNotEmpty)
                  .length, (index) {
            SlotData value = data
                .where((element) => element.slot.validate().isNotEmpty)
                .toList()[index];

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              decoration: boxDecorationDefault(
                color: context.cardColor,
                border: appStore.isDarkMode
                    ? Border.all(color: context.dividerColor)
                    : null,
              ),
              child: Text(value.day.capitalizeFirstLetter(),
                  style: context.secondaryTextStyle(
                      size: LABEL_TEXT_SIZE, color: primaryColor)),
            );
          }),
        ),
        8.height,
      ],
    );
  }

  Widget reviewWidget(
      {required List<RatingData> data,
      required ServiceDetailResponse serviceDetailResponse}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViewAllLabel(
          //label: language.review,
          label:
              '${language.review} (${serviceDetailResponse.serviceDetail!.totalReview})',
          list: data,
          onTap: () {
            RatingViewAllScreen(serviceId: widget.serviceId).launch(context);
          },
        ),
        data.isNotEmpty
            ? Wrap(
                children: List.generate(
                  data.length,
                  (index) => ReviewWidget(data: data[index]),
                ),
              ).paddingTop(8)
            : Text(language.lblNoReviews, style: context.primaryTextStyle()),
      ],
    ).paddingSymmetric(horizontal: 16);
  }

  Widget relatedServiceWidget(
      {required List<ServiceData> serviceList, required int serviceId}) {
    if (serviceList.isEmpty) return const Offstage();

    serviceList.removeWhere((element) => element.id == serviceId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (serviceList.isNotEmpty)
          Text(
            language.lblRelatedServices,
            style: context.boldTextStyle(size: LABEL_TEXT_SIZE),
          ).paddingSymmetric(horizontal: 16),
        8.height,
        if (serviceList.isNotEmpty)
          GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            itemCount: serviceList.length,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (_, index) => ServiceComponent(
              imageHeight: 150,
              serviceData: serviceList[index],
              width: appConfigurationStore.userDashboardType ==
                      DEFAULT_USER_DASHBOARD
                  ? context.width() / 2 - 26
                  : 280,
            ),
          ),
      ],
    );
  }

  Widget _frequentlyBoughtCard(ServiceData data) {
    return Container(
      width: context.width(),
      padding: const EdgeInsets.all(12),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(8),
        backgroundColor: context.secondaryContainer,
      ),
      child: Row(
        children: [
          CachedImageWidget(
            url: data.attachments.validate().isNotEmpty
                ? data.attachments!.first.validate()
                : DEMO_SERVICE_IMAGE_URL,
            height: 50,
            width: 50,
            fit: BoxFit.cover,
            radius: 8,
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.name.validate(),
                    style: context.boldTextStyle(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                4.height,
                PriceWidget(
                  price: data.price.validate(),
                  size: 14,
                  color: context.onSurface,
                  isFreeService: false,
                  isBoldText: false,
                  currencySymbol: '₹',
                ),
              ],
            ),
          ),
          12.width,
          AppButton(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: context.primary,
            elevation: 0,
            shapeBorder: RoundedRectangleBorder(borderRadius: radius(8)),
            onTap: () {
              // Dummy interaction; in live mode integrate with cart/booking flow
              toast(language.lblBookNow);
            },
            child: Text(language.buy,
                style: context.boldTextStyle(
                  color: context.onPrimary,
                )),
          ),
        ],
      ),
    );
  }

  //endregion
  void bookNow(ServiceDetailResponse serviceDetailResponse) {
    doIfLoggedIn(context, () async {
      serviceDetailResponse.serviceDetail!.bookingAddressId =
          selectedBookingAddressId;
      if (serviceDetailResponse.serviceDetail!.isOnShopService &&
          serviceDetailResponse.shops.validate().length > 1) {
        await showModalBottomSheet(
          context: context,
          backgroundColor: context.bottomSheetBackgroundColor,
          barrierColor:
              context.bottomSheetBackgroundColor.withValues(alpha: 0.5),
          showDragHandle: true,
          isScrollControlled: true,
          constraints: BoxConstraints(maxHeight: context.height() * 0.9),
          enableDrag: true,
          shape: RoundedRectangleBorder(
            borderRadius: radiusOnly(topRight: 16, topLeft: 16),
          ),
          builder: (context) {
            return ShopListScreen(
              serviceId: widget.serviceId,
              selectedShop: selectedShop,
              isShopChange: false,
              isForBooking: true,
            );
          },
        ).then(
          (value) {
            if (value != null) {
              selectedShop = value;
              handleBookNow(serviceDetailResponse, serviceId: widget.serviceId);
            }
          },
        );
      } else {
        if (serviceDetailResponse.serviceDetail!.isOnShopService &&
            serviceDetailResponse.shops.validate().length == 1) {
          selectedShop = serviceDetailResponse.shops.first;
        }
        handleBookNow(serviceDetailResponse, serviceId: widget.serviceId);
      }
    });
  }

  handleBookNow(ServiceDetailResponse serviceDetailResponse, {int? serviceId}) {
    BookServiceScreen(
      serviceId: serviceId,
      data: serviceDetailResponse,
      selectedPackage: selectedPackage,
      selectedShop: selectedShop,
    ).launch(context).then((value) {
      setStatusBarColor(transparentColor);
    });
  }

  Future<void> _onTapFavourite(ServiceData serviceDetail) async {
    if (serviceDetail.isFavourite == 1) {
      serviceDetail.isFavourite = 0;
      setState(() {});

      await removeToWishList(serviceId: serviceDetail.id.validate())
          .then((value) {
        if (!value) {
          serviceDetail.isFavourite = 1;
          setState(() {});
        }
      });
    } else {
      serviceDetail.isFavourite = 1;
      setState(() {});

      await addToWishList(serviceId: serviceDetail.id.validate()).then((value) {
        if (!value) {
          serviceDetail.isFavourite = 0;
          setState(() {});
        }
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    setStatusBarColor(
        widget.isFromProviderInfo ? primaryColor : transparentColor);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildBodyWidget(AsyncSnapshot<ServiceDetailResponse> snap) {
      if (snap.hasError) {
        return NoDataWidget(
          title: snap.error.toString(),
          imageWidget: ErrorStateWidget(),
          retryText: language.reload,
          onRetry: () {
            init();
          },
        ).center();
      } else if (snap.hasData) {
        return AppScaffold(
          appBarTitle: snap.data!.serviceDetail?.categoryName.validate() ?? '',
          showLoader: false,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: boxDecorationWithShadow(
                boxShape: BoxShape.circle,
                backgroundColor: context.secondaryContainer,
              ),
              child: snap.data!.serviceDetail!.isFavourite == 1
                  ? ic_fill_heart.iconImage(
                      color: favouriteColor, size: 20, context: context)
                  : ic_heart.iconImage(
                      color: unFavouriteColor, size: 20, context: context),
            ).onTap(() async {
              if (appStore.isLoggedIn) {
                await _onTapFavourite(snap.data!.serviceDetail!);
                setState(() {});
              } else {
                push(const SignInScreen(returnExpected: true)).then((value) {
                  setStatusBarColor(Colors.transparent,
                      delayInMilliSeconds: 1000);
                  if (value) {
                    _onTapFavourite(snap.data!.serviceDetail!);
                    setState(() {});
                  }
                });
              }
            },
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent),
          ],
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: AnimatedScrollView(
                    padding: const EdgeInsets.only(bottom: 120),
                    listAnimationType: ListAnimationType.FadeIn,
                    fadeInConfiguration:
                        FadeInConfiguration(duration: 2.seconds),
                    onSwipeRefresh: () async {
                      appStore.setLoading(true);
                      init();
                      setState(() {});
                      return await 2.seconds.delay;
                    },
                    children: [
                      // ServiceDetailHeaderComponent(
                      //     serviceDetail: snap.data!.serviceDetail!),
                      16.height,
                      ServiceHeaderComponent(
                        serviceData: snap.data!.serviceDetail!,
                        badgeText: language.speciallyAbled,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      8.height,

                      //Service Visit Type
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            language.serviceVisitType,
                            style: context.boldTextStyle(),
                          ),
                          8.height,
                          Text(
                            snap.data!.serviceDetail!.isOnlineService
                                ? language.thisServiceIsOnlineRemote
                                : snap.data!.serviceDetail!.isOnShopService
                                    ? 'This Service will be completed ${language.lblAtShop.toLowerCase()}.'
                                    : snap.data!.serviceDetail!.isOnSiteService
                                        ? 'This Service will be completed at your location.'
                                        : language.notAvailable,
                            style: context.primaryTextStyle(),
                          ),
                        ],
                      ).paddingSymmetric(horizontal: 16, vertical: 16),
                      8.height,

                      //Description
                      2.height,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language.hintDescription,
                              style: context.boldTextStyle()),
                          8.height,
                          snap.data!.serviceDetail!.description
                                  .validate()
                                  .isNotEmpty
                              ? ReadMoreText(
                                  snap.data!.serviceDetail!.description
                                      .validate(),
                                  style: context.primaryTextStyle(),
                                  colorClickableText: context.primaryColor,
                                  textAlign: TextAlign.justify,
                                )
                              : Text(language.lblNotDescription,
                                  style: context.primaryTextStyle()),
                          12.height,
                          slotsAvailable(
                            data: snap.data!.serviceDetail!.bookingSlots
                                .validate(),
                            isSlotAvailable:
                                snap.data!.serviceDetail!.isSlotAvailable,
                          ),
                          availableWidget(
                            data: snap.data!.serviceDetail!,
                            zone: snap.data!,
                          ),
                        ],
                      ).paddingSymmetric(horizontal: 16, vertical: 8),
                      providerWidget(data: snap.data!.provider!),
                      if (snap.data!.shops.validate().isNotEmpty)
                        HorizontalShopListComponent(
                          listTitle: language.lblAboutShop,
                          shopList: snap.data!.shops.validate(),
                          cardWidth: context.width() * 0.9,
                          serviceId: snap.data!.serviceDetail!.id.validate(),
                          serviceName:
                              snap.data!.serviceDetail!.name.validate(),
                          showServices: false,
                        ),
                      //Frequently Bought Together
                      if (snap.data!.relatedService.validate().isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            16.height,
                            Text(language.frequentlyBoughtTogether,
                                style: context.boldTextStyle()),
                            8.height,
                            _frequentlyBoughtCard(
                                snap.data!.relatedService!.first),
                          ],
                        ).paddingSymmetric(horizontal: 16),
                      //
                      if (snap.data!.serviceDetail!.servicePackage
                          .validate()
                          .isNotEmpty)
                        PackageComponent(
                          servicePackage: snap
                              .data!.serviceDetail!.servicePackage
                              .validate(),
                          callBack: (v) {
                            if (v != null) {
                              selectedPackage = v;
                            } else {
                              selectedPackage = null;
                            }
                            bookNow(snap.data!);
                          },
                        ),
                      //Add-ons
                      if (snap.data!.serviceaddon.validate().isNotEmpty)
                        AddonComponent(
                          serviceAddon: snap.data!.serviceaddon.validate(),
                          onSelectionChange: (v) {
                            serviceAddonStore.setSelectedServiceAddon(v);
                          },
                        ),
                      8.height,
                      //FAQ
                      serviceFaqWidget(data: snap.data!.serviceFaq.validate())
                          .paddingSymmetric(horizontal: 16),
                      8.height,
                      //Reviews
                      reviewWidget(
                          data: snap.data!.ratingData!,
                          serviceDetailResponse: snap.data!),
                      24.height,
                      if (snap.data!.relatedService.validate().isNotEmpty)
                        relatedServiceWidget(
                          serviceList: snap.data!.relatedService.validate(),
                          serviceId: snap.data!.serviceDetail!.id.validate(),
                        ),
                    ],
                  ),
                ),
                AppButton(
                  onTap: () {
                    selectedPackage = null;
                    bookNow(snap.data!);
                  },
                  color: context.primary,
                  child: Text(language.lblBookNow,
                      style: context.boldTextStyle(color: context.onPrimary)),
                  width: context.width(),
                  textColor: context.onPrimary,
                ).paddingSymmetric(horizontal: 16.0, vertical: 10.0)
              ],
            ),
          ),
        );
      }
      return ServiceDetailShimmer();
    }

    return FutureBuilder<ServiceDetailResponse>(
      initialData: listOfCachedData
          .firstWhere((element) => element?.$1 == widget.serviceId.validate(),
              orElse: () => null)
          ?.$2,
      future: future,
      builder: (context, snap) {
        return Scaffold(
          body: Stack(
            children: [
              buildBodyWidget(snap),
              Observer(
                  builder: (context) =>
                      LoaderWidget().visible(appStore.isLoading)),
            ],
          ),
        );
      },
    );
  }
}
