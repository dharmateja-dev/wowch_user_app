import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/add_review_dialog.dart';
import '../../component/cached_image_widget.dart';
import '../../component/disabled_rating_bar_widget.dart';
import '../../component/empty_error_state_widget.dart';
import '../../component/loader_widget.dart';
import '../../model/service_detail_response.dart';
import '../../network/rest_apis.dart';
import '../../utils/images.dart';
import '../review/shimmer/ratting_shimmer.dart';
import '../service/service_detail_screen.dart';

class CustomerRatingScreen extends StatefulWidget {
  @override
  State<CustomerRatingScreen> createState() => _CustomerRatingScreenState();
}

class _CustomerRatingScreenState extends State<CustomerRatingScreen> {
  ScrollController scrollController = ScrollController();

  // Flag to use dummy data for UI design
  static const bool USE_DUMMY_DATA = true;

  Future<List<RatingData>>? future;

  bool isLastPage = false;

  // Local list to manage dummy data (for edit/delete operations)
  List<RatingData> dummyRatingList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  /// Initialize reviews - uses dummy data if flag is enabled, otherwise uses API
  Future<void> init() async {
    if (USE_DUMMY_DATA) {
      // Generate dummy data
      dummyRatingList = _getDummyRatingList();
      future = Future.value(dummyRatingList);
    } else {
      // Use actual API call (backend logic remains intact)
      future = customerReviews();
    }
  }

  /// Generate dummy rating data matching the design
  /// Returns a list of review cards with service images, ratings, and reviews
  List<RatingData> _getDummyRatingList() {
    return [
      RatingData(
        id: 1,
        bookingId: 101,
        serviceId: 1,
        customerId: 1,
        serviceName: 'Event Planners',
        rating: 5,
        review:
            'Incredible selection and quality in contemporary style clothing my new go to for fashion. Incredible selection and quality in contemporary style clothing my new go to for fashion.',
        createdAt: '2025-11-15',
        attachments: [
          'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=400&h=400&fit=crop',
        ],
        customerName: 'Abdul Kader',
        customerProfileImage: 'https://i.pravatar.cc/150?img=12',
      ),
      RatingData(
        id: 2,
        bookingId: 102,
        serviceId: 2,
        customerId: 1,
        serviceName: 'Plumbing Repair',
        rating: 4,
        review:
            'Good service overall. The plumber arrived on time and fixed the issue quickly.',
        createdAt: '2025-11-10',
        attachments: [
          'https://images.unsplash.com/photo-1621905251918-48416bd8575a?w=400&h=400&fit=crop',
        ],
        customerName: 'Abdul Kader',
        customerProfileImage: 'https://i.pravatar.cc/150?img=12',
      ),
      RatingData(
        id: 3,
        bookingId: 103,
        serviceId: 3,
        customerId: 1,
        serviceName: 'Electrical Installation',
        rating: 5,
        review:
            'Outstanding work! Very satisfied with the electrical installation. Highly recommended.',
        createdAt: '2025-11-05',
        attachments: [
          'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=400&h=400&fit=crop',
        ],
        customerName: 'Abdul Kader',
        customerProfileImage: 'https://i.pravatar.cc/150?img=12',
      ),
      RatingData(
        id: 4,
        bookingId: 104,
        serviceId: 4,
        customerId: 1,
        serviceName: 'Painting Service',
        rating: 4,
        review:
            'Great painting job! The colors look amazing and the finish is perfect.',
        createdAt: '2025-10-28',
        attachments: [
          'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=400&h=400&fit=crop',
        ],
        customerName: 'Abdul Kader',
        customerProfileImage: 'https://i.pravatar.cc/150?img=12',
      ),
      RatingData(
        id: 5,
        bookingId: 105,
        serviceId: 5,
        customerId: 1,
        serviceName: 'Carpentry Work',
        rating: 5,
        review:
            'Excellent craftsmanship! The carpenter did an amazing job with the custom furniture.',
        createdAt: '2025-10-20',
        attachments: [
          'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=400&h=400&fit=crop',
        ],
        customerName: 'Abdul Kader',
        customerProfileImage: 'https://i.pravatar.cc/150?img=12',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.myReviews,
      child: Stack(
        children: [
          SnapHelperWidget<List<RatingData>>(
            future: future,
            initialData: cachedRatingList,
            loadingWidget: RattingShimmer(),
            onSuccess: (snap) {
              return AnimatedListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
                slideConfiguration: sliderConfigurationGlobal,
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                itemCount: snap.length,
                onSwipeRefresh: () async {
                  init();
                  setState(() {});

                  return await 2.seconds.delay;
                },
                itemBuilder: (context, index) {
                  RatingData data = snap[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.transparent,
                      border: Border.all(
                        color: context.primaryColor,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top container - Service image and name section with light green background
                        Container(
                          width: context.width(),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Color(0xFFE8F3EC), // Light green background
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Service image - square with rounded corners
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedImageWidget(
                                  url: data.attachments.validate().isNotEmpty
                                      ? data.attachments!.first
                                      : '',
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                  radius: 0,
                                ),
                              ),
                              12.width,
                              // Service name and view detail
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      data.serviceName.validate(),
                                      style: boldTextStyle(
                                        size: 16,
                                        color: textPrimaryColorGlobal,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    4.height,
                                    GestureDetector(
                                      onTap: () {
                                        ServiceDetailScreen(
                                                serviceId:
                                                    data.serviceId.validate())
                                            .launch(context);
                                      },
                                      child: Text(
                                        language.viewDetail,
                                        style: secondaryTextStyle(
                                          size: 12,
                                          color: textSecondaryColorGlobal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        16.height,
                        Container(
                          width: context.width(),
                          decoration: BoxDecoration(
                            color: Color(0xFFE8F3EC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header row with "Your Comment" and action buttons
                              Row(
                                children: [
                                  Text(
                                    language.lblYourComment,
                                    style: boldTextStyle(
                                      size: 14,
                                      color: textPrimaryColorGlobal,
                                    ),
                                  ).expand(),
                                  // Edit icon - simple dark grey icon
                                  ic_edit_square
                                      .iconImage(
                                    size: 18,
                                    color: textPrimaryColorGlobal,
                                  )
                                      .onTap(() async {
                                    Map<String, dynamic>? dialogData =
                                        await showInDialog(
                                      context,
                                      contentPadding: EdgeInsets.zero,
                                      builder: (p0) {
                                        return AddReviewDialog(
                                          customerReview: RatingData(
                                            bookingId: data.bookingId,
                                            createdAt: data.createdAt,
                                            customerId: data.customerId,
                                            id: data.id,
                                            profileImage: data.profileImage,
                                            rating: data.rating,
                                            review: data.review,
                                            serviceId: data.serviceId,
                                            customerName: data.customerName,
                                            serviceName: data.serviceName,
                                            attachments: data.attachments,
                                          ),
                                          isCustomerRating: true,
                                        );
                                      },
                                    );

                                    if (dialogData != null) {
                                      // Update dummy data if using dummy data
                                      if (USE_DUMMY_DATA) {
                                        int index = dummyRatingList.indexWhere(
                                          (item) => item.id == data.id,
                                        );
                                        if (index != -1) {
                                          dummyRatingList[index].rating =
                                              dialogData['rating'];
                                          dummyRatingList[index].review =
                                              dialogData['review'];
                                          future =
                                              Future.value(dummyRatingList);
                                        }
                                      } else {
                                        data.rating = dialogData['rating'];
                                        data.review = dialogData['review'];
                                      }

                                      setState(() {});
                                      LiveStream()
                                          .emit(LIVESTREAM_UPDATE_DASHBOARD);
                                    }
                                  }),
                                  10.width,
                                  // Delete icon - simple dark grey icon
                                  ic_delete
                                      .iconImage(
                                    size: 18,
                                    color: textPrimaryColorGlobal,
                                  )
                                      .onTap(() {
                                    showConfirmDialogCustom(
                                      height: 80,
                                      width: 290,
                                      context,
                                      title: language.lblConfirmReviewSubTitle,
                                      positiveText: language.lblYes,
                                      negativeText: language.lblNo,
                                      dialogType: DialogType.DELETE,
                                      primaryColor: context.primaryColor,
                                      negativeTextColor: context.primaryColor,
                                      customCenterWidget: Image.asset(
                                        ic_warning,
                                        height: 70,
                                        width: 70,
                                        fit: BoxFit.cover,
                                      ),
                                      onAccept: (p0) async {
                                        appStore.setLoading(true);

                                        if (USE_DUMMY_DATA) {
                                          // Remove from dummy data
                                          dummyRatingList.removeWhere(
                                            (item) => item.id == data.id,
                                          );
                                          future =
                                              Future.value(dummyRatingList);
                                          toast('Review deleted successfully');
                                        } else {
                                          // Use actual API
                                          if (getStringAsync(USER_EMAIL) !=
                                              DEFAULT_EMAIL) {
                                            await deleteReview(
                                                    id: data.id.validate())
                                                .then((value) {
                                              toast(value.message);
                                              init();
                                            }).catchError((e) {
                                              toast(e.toString(), print: true);
                                            });
                                          } else {
                                            toast(language.lblUnAuthorized);
                                          }
                                        }
                                        appStore.setLoading(false);
                                        setState(() {});
                                      },
                                    );
                                  }),
                                ],
                              ),

                              12.height,
                              // Rating stars - yellow color
                              DisabledRatingBarWidget(
                                rating: data.rating.validate().toDouble(),
                                size: 20,
                              ),
                              12.height,
                              // Review text - light grey color
                              Text(
                                data.review.validate(),
                                style: secondaryTextStyle(
                                  color: textSecondaryColorGlobal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                emptyWidget: NoDataWidget(
                  title: language.lblNoRateYet,
                  image: no_rating_bar,
                  subTitle: language.customerRatingMessage,
                ),
              );
            },
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                imageWidget: const ErrorStateWidget(),
                retryText: language.reload,
                onRetry: () {
                  appStore.setLoading(true);

                  init();
                  setState(() {});
                },
              );
            },
          ),
          Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
