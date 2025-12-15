import 'dart:convert';

import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/provider_info_response.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/model/shop_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/base_scaffold_widget.dart';
import '../../component/empty_error_state_widget.dart';
import '../../utils/common.dart';
import '../../utils/constant.dart';
import '../../utils/context_extensions.dart';
import '../service/view_all_service_screen.dart';
import '../service/service_detail_screen.dart';

class ProviderInfoScreen extends StatefulWidget {
  final int? providerId;
  final bool canCustomerContact;
  final VoidCallback? onUpdate;
  final ServiceData? serviceData;

  ProviderInfoScreen({
    this.providerId,
    this.canCustomerContact = false,
    this.onUpdate,
    this.serviceData,
  });

  @override
  ProviderInfoScreenState createState() => ProviderInfoScreenState();
}

class ProviderInfoScreenState extends State<ProviderInfoScreen> {
  // TODO: Set to false when backend is ready
  static const bool _useDummyData = true;

  Future<ProviderInfoResponse>? future;
  int page = 1;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if (_useDummyData) {
      future = _getDummyProviderInfo();
    } else {
      future = getProviderDetail(widget.providerId.validate(),
          userId: appStore.userId.validate());
    }
  }

  /// Generate dummy provider info for UI testing
  Future<ProviderInfoResponse> _getDummyProviderInfo() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Create dummy provider user data
    final dummyUserData = UserData(
      id: widget.providerId ?? 1,
      firstName: "Jorge",
      lastName: "Perez",
      displayName: "Jorge Perez",
      email: "JorgePerez@gmail.com",
      contactNumber: "1234567890",
      address: "123 Main Street, New York, NY 10001",
      cityName: "New York",
      profileImage:
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
      userType: USER_TYPE_PROVIDER,
      providerType: "Company",
      description:
          "Professional handyman services with over 10 years of experience. We specialize in home repairs, renovations, and maintenance.",
      providersServiceRating: 5.0,
      totalBooking: 156,
      totalCompletedBooking: 142,
      isVerifyProvider: 1,
      isFeatured: 1,
      status: 1,
      knownLanguages: jsonEncode(["English", "Spanish", "French"]),
      skills: jsonEncode(
          ["Plumbing", "Electrical", "Carpentry", "Painting", "HVAC"]),
      designation: "Manager",
      createdAt: "2021-01-15T10:30:00.000Z",
    );

    // Create dummy services
    final dummyServices = <ServiceData>[
      ServiceData(
        id: 101,
        name: "Event Planners",
        description: "Detailing and Planners",
        price: 600,
        type: SERVICE_TYPE_FIXED,
        status: 1,
        providerId: widget.providerId ?? 1,
        providerName: "Jorge Perez",
        providerImage:
            "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200",
        categoryId: 1,
        categoryName: "Events",
        attachments: [
          "https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=400"
        ],
        totalRating: 5.0,
        totalReview: 25,
        isFeatured: 1,
      ),
      ServiceData(
        id: 102,
        name: "Event Planners",
        description: "Detailing and Planners",
        price: 600,
        type: SERVICE_TYPE_FIXED,
        status: 1,
        providerId: widget.providerId ?? 1,
        providerName: "Jorge Perez",
        providerImage:
            "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200",
        categoryId: 2,
        categoryName: "Events",
        attachments: [
          "https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=400"
        ],
        totalRating: 5.0,
        totalReview: 32,
        isFeatured: 0,
      ),
      ServiceData(
        id: 103,
        name: "Event Planners",
        description: "Detailing and Planners",
        price: 600,
        type: SERVICE_TYPE_FIXED,
        status: 1,
        providerId: widget.providerId ?? 1,
        providerName: "Jorge Perez",
        providerImage:
            "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200",
        categoryId: 3,
        categoryName: "Events",
        attachments: [
          "https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=400"
        ],
        totalRating: 5.0,
        totalReview: 45,
        isFeatured: 1,
      ),
    ];

    // Create dummy handyman staff (Team members)
    final dummyHandymanStaff = <UserData>[
      UserData(
        id: 201,
        firstName: "John",
        lastName: "Smith",
        displayName: "John Smith",
        profileImage:
            "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200",
        userType: USER_TYPE_HANDYMAN,
        handymanRating: 4.7,
        designation: "Plumber",
      ),
      UserData(
        id: 202,
        firstName: "Mike",
        lastName: "Johnson",
        displayName: "Mike Johnson",
        profileImage:
            "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200",
        userType: USER_TYPE_HANDYMAN,
        handymanRating: 4.9,
        designation: "Electrician",
      ),
      UserData(
        id: 203,
        firstName: "David",
        lastName: "Williams",
        displayName: "David Williams",
        profileImage:
            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
        userType: USER_TYPE_HANDYMAN,
        handymanRating: 4.6,
        designation: "Carpenter",
      ),
      UserData(
        id: 204,
        firstName: "Sarah",
        lastName: "Davis",
        displayName: "Sarah Davis",
        profileImage:
            "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200",
        userType: USER_TYPE_HANDYMAN,
        handymanRating: 4.8,
        designation: "Painter",
      ),
      UserData(
        id: 205,
        firstName: "Tom",
        lastName: "Wilson",
        displayName: "Tom Wilson",
        profileImage:
            "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200",
        userType: USER_TYPE_HANDYMAN,
        handymanRating: 4.5,
        designation: "HVAC Tech",
      ),
      UserData(
        id: 206,
        firstName: "Emily",
        lastName: "Brown",
        displayName: "Emily Brown",
        profileImage:
            "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200",
        userType: USER_TYPE_HANDYMAN,
        handymanRating: 4.9,
        designation: "Cleaner",
      ),
      UserData(
        id: 207,
        firstName: "Chris",
        lastName: "Lee",
        displayName: "Chris Lee",
        profileImage:
            "https://images.unsplash.com/photo-1463453091185-61582044d556?w=200",
        userType: USER_TYPE_HANDYMAN,
        handymanRating: 4.7,
        designation: "Handyman",
      ),
      UserData(
        id: 208,
        firstName: "Anna",
        lastName: "Taylor",
        displayName: "Anna Taylor",
        profileImage:
            "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200",
        userType: USER_TYPE_HANDYMAN,
        handymanRating: 4.8,
        designation: "Organizer",
      ),
    ];

    // Create dummy shops
    final dummyShops = <ShopModel>[
      ShopModel(
        id: 301,
        name: "Jorge Services - Downtown",
        address: "456 Broadway, New York",
        cityName: "New York",
        stateName: "NY",
        countryName: "USA",
        providerId: widget.providerId ?? 1,
        providerName: "Jorge Perez",
        shopImage: [
          "https://images.unsplash.com/photo-1497366216548-37526070297c?w=400"
        ],
      ),
    ];

    final response = ProviderInfoResponse(
      userData: dummyUserData,
      serviceList: dummyServices,
      shops: dummyShops,
      handymanRatingReviewList: [],
      handymanImageList: [],
    );
    response.handymanStaffList = dummyHandymanStaff;
    return response;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  /// Build the green header card with provider info
  Widget _buildProviderHeaderCard(UserData userData) {
    // Extract year from createdAt
    String memberSince = "";
    if (userData.createdAt != null && userData.createdAt!.isNotEmpty) {
      try {
        final date = DateTime.parse(userData.createdAt!);
        memberSince = date.year.toString();
      } catch (e) {
        memberSince = "2021";
      }
    }

    return Stack(children: [
      Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200,
            width: context.width(),
            decoration: BoxDecoration(
              color: context.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
          )),
      Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xffF2F4F3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // Favorite button row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : context.icon,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            // Profile image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: context.scaffoldBackgroundColor, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: CachedImageWidget(
                  url: userData.profileImage.validate(),
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            12.height,
            // Provider name
            Text(
              userData.displayName.validate(),
              style: context.boldTextStyle(
                size: 18,
              ),
            ),
            4.height,
            // Designation
            Text(
              userData.designation.validate().isNotEmpty
                  ? userData.designation.validate()
                  : userData.providerType.validate(),
              style: context.boldTextStyle(
                size: 14,
              ),
            ),
            8.height,
            // Member since and rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  language.lblMemberSince + " $memberSince",
                  style: context.boldTextStyle(
                    size: 12,
                  ),
                ),
                8.width,
                Icon(Icons.star, color: Colors.amber, size: 16),
                4.width,
                Text(
                  userData.providersServiceRating.validate().toStringAsFixed(1),
                  style: context.boldTextStyle(
                    size: 12,
                  ),
                ),
              ],
            ),
            12.height,
            // Why Choose Me link
            GestureDetector(
              onTap: () {
                _showWhyChooseMeBottomSheet(userData);
              },
              child: Text(
                language.whyChooseMe,
                style: context.boldTextStyle(
                  color: context.primaryColor,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      )
    ]);
  }

  /// Show Why Choose Me bottom sheet
  void _showWhyChooseMeBottomSheet(UserData userData) {
    // Get why choose me data
    final whyChooseMeData = userData.whyChooseMeObj;

    // Use data from user or fallback to default
    final String title = whyChooseMeData.title.isNotEmpty
        ? whyChooseMeData.title
        : language.whyChooseMeAs;

    final String description = whyChooseMeData.aboutDescription.isNotEmpty
        ? whyChooseMeData.aboutDescription
        : "My work is not just a job, but a lifelong passion. With years of experience, I've refined my skills and honed my craft to provide top-quality service to my clients.";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle at bottom
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: lightGrey,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: context.boldTextStyle(size: 18),
                    ),
                    16.height,
                    // Description
                    Text(
                      description,
                      style: context.primaryTextStyle(
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  /// Build Known Languages section
  Widget _buildKnownLanguagesSection(List<String> languages) {
    if (languages.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          language.knownLanguages,
          style: context.boldTextStyle(),
        ).paddingSymmetric(horizontal: 16),
        12.height,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: languages.map((lang) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: context.secondaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                lang,
                style: context.boldTextStyle(),
              ),
            );
          }).toList(),
        ).paddingSymmetric(horizontal: 16),
        24.height,
      ],
    );
  }

  /// Build Team section with overlapping avatars
  Widget _buildTeamSection(List<UserData> teamMembers) {
    if (teamMembers.isEmpty) return const SizedBox.shrink();

    const int maxVisible = 5;
    final int remainingCount =
        teamMembers.length > maxVisible ? teamMembers.length - maxVisible : 0;
    final displayMembers = teamMembers.take(maxVisible).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          language.team,
          style: context.boldTextStyle(),
        ).paddingSymmetric(horizontal: 16),
        12.height,
        SizedBox(
          height: 50,
          child: Stack(
            children: [
              ...displayMembers.asMap().entries.map((entry) {
                final index = entry.key;
                final member = entry.value;
                return Positioned(
                  left: 6.0 + (index * 35),
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22.5),
                      child: CachedImageWidget(
                        url: member.profileImage.validate(),
                        height: 45,
                        width: 45,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }).toList(),
              if (remainingCount > 0)
                Positioned(
                  left: 20.0 + (displayMembers.length * 35),
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: context.primaryColor, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        "+$remainingCount",
                        style: context.boldTextStyle(
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        24.height,
      ],
    );
  }

  /// Build Personal Info section
  Widget _buildPersonalInfoSection(UserData userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          language.personalInfo,
          style: context.boldTextStyle(),
        ).paddingSymmetric(horizontal: 16),
        12.height,
        // Email row
        Row(
          children: [
            ic_message.iconImage(size: 20, context: context),
            12.width,
            Expanded(
              child: Text(
                userData.email.validate(),
                style: context.primaryTextStyle(),
              ),
            ),
          ],
        ).paddingSymmetric(horizontal: 16).onTap(() {
          launchMail(userData.email.validate());
        }),
        12.height,
        // Phone row
        Row(
          children: [
            ic_calling.iconImage(size: 18, context: context),
            12.width,
            Expanded(
              child: Text(
                userData.contactNumber.validate(),
                style: context.primaryTextStyle(),
              ),
            ),
          ],
        ).paddingSymmetric(horizontal: 16).onTap(() {
          launchCall(userData.contactNumber.validate());
        }),
        24.height,
      ],
    );
  }

  /// Build Services section with modern cards
  Widget _buildServicesSection(List<ServiceData> services, int? providerId) {
    if (services.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with See All
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language.service,
              style: context.boldTextStyle(),
            ),
            GestureDetector(
              onTap: () {
                ViewAllServiceScreen(providerId: providerId).launch(
                  context,
                  pageRouteAnimation: PageRouteAnimation.Fade,
                );
              },
              child: Text(
                language.lblViewAll,
                style: context.primaryTextStyle(),
              ),
            ),
          ],
        ).paddingSymmetric(horizontal: 16),
        12.height,
        // Service cards list
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: services.length,
          separatorBuilder: (_, __) => 12.height,
          itemBuilder: (context, index) {
            final service = services[index];
            return _buildServiceCard(service);
          },
        ),
        24.height,
      ],
    );
  }

  /// Build individual service card
  Widget _buildServiceCard(ServiceData service) {
    return GestureDetector(
      onTap: () {
        ServiceDetailScreen(serviceId: service.id.validate()).launch(
          context,
          pageRouteAnimation: PageRouteAnimation.Fade,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Service image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedImageWidget(
                url: service.attachments?.isNotEmpty == true
                    ? service.attachments!.first
                    : "",
                height: 80,
                radius: 8,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            12.width,
            // Service details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and rating row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          service.name.validate(),
                          style: context.boldTextStyle(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          2.width,
                          Text(
                            service.totalRating.validate().toStringAsFixed(1),
                            style: context.boldTextStyle(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  4.height,
                  // Description
                  Text(
                    service.description.validate(),
                    style: context.primaryTextStyle(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  8.height,
                  // Price badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "₹ ${service.price.validate().toStringAsFixed(0)}",
                      style: context.boldTextStyle(color: white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.lblAboutProvider,
      showLoader: false,
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: context.scaffoldBackgroundColor,
          body: SnapHelperWidget<ProviderInfoResponse>(
            future: future,
            initialData: _useDummyData
                ? null
                : cachedProviderList
                    .firstWhere(
                        (element) =>
                            element?.$1 == widget.providerId.validate(),
                        orElse: () => null)
                    ?.$2,
            onSuccess: (data) {
              return Stack(
                children: [
                  AnimatedScrollView(
                    padding: EdgeInsets.only(bottom: 60),
                    listAnimationType: ListAnimationType.FadeIn,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      // Green header card
                      _buildProviderHeaderCard(data.userData!),

                      // Known Languages
                      _buildKnownLanguagesSection(
                          data.userData!.knownLanguagesArray),

                      // Team section
                      _buildTeamSection(data.handymanStaffList.validate()),

                      // Personal Info (only if canCustomerContact)
                      if (widget.canCustomerContact)
                        _buildPersonalInfoSection(data.userData!),

                      // Always show personal info for demo
                      if (!widget.canCustomerContact && _useDummyData)
                        _buildPersonalInfoSection(data.userData!),

                      // // Shops
                      // if (data.shops != null && data.shops!.isNotEmpty) ...[
                      //   HorizontalShopListComponent(
                      //     shopList: data.shops!.take(5).toList(),
                      //     listTitle:
                      //         '${language.lblShop} (${data.shops!.length})',
                      //     providerId: widget.providerId.validate(),
                      //     providerName: data.userData!.displayName.validate(),
                      //   ),
                      //   16.height,
                      // ],

                      // Services
                      _buildServicesSection(
                        data.serviceList.validate(),
                        widget.providerId,
                      ),
                    ],
                    onSwipeRefresh: () async {
                      page = 1;
                      init();
                      setState(() {});
                      return await 2.seconds.delay;
                    },
                  ),
                  Observer(
                    builder: (context) =>
                        LoaderWidget().visible(appStore.isLoading),
                  ),
                ],
              );
            },
            loadingWidget: LoaderWidget(),
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
          ),
        ),
      ),
    );
  }
}
