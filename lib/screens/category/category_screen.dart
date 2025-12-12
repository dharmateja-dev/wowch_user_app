import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/category_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/category/shimmer/category_shimmer.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/empty_error_state_widget.dart';
import '../service/view_all_service_screen.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<CategoryData>> future;
  List<CategoryData> categoryList = [];

  int page = 1;
  bool isLastPage = false;
  bool isApiCalled = false;

  int selectedCategoryIndex = 0;
  TextEditingController searchController = TextEditingController();

  UniqueKey key = UniqueKey();

  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getCategoryListWithPagination(page, categoryList: categoryList,
        lastPageCallBack: (val) {
      isLastPage = val;
    });
    if (page == 1) {
      key = UniqueKey();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void _onCategoryTap(int index, CategoryData data) {
    setState(() {
      selectedCategoryIndex = index;
    });
    // Navigate to ViewAllServiceScreen with subcategories
    ViewAllServiceScreen(
      categoryId: data.id.validate(),
      categoryName: data.name,
      isFromCategory: true,
    ).launch(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.category,
        textColor: Colors.white,
        textSize: APP_BAR_TEXT_SIZE,
        color: primaryColor,
        systemUiOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness:
              appStore.isDarkMode ? Brightness.light : Brightness.light,
          statusBarColor: context.primaryColor,
        ),
        showBack: Navigator.canPop(context),
        backWidget: BackWidget(),
      ),
      body: Stack(
        children: [
          SnapHelperWidget<List<CategoryData>>(
            initialData: cachedCategoryList,
            future: future,
            loadingWidget: CategoryShimmer(),
            onSuccess: (snap) {
              if (snap.isEmpty) {
                return NoDataWidget(
                  title: language.noCategoryFound,
                  imageWidget: const EmptyStateWidget(),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar Section
                  _buildSearchBar(context),

                  // Category Section with horizontal list
                  _buildCategorySection(context, snap),

                  // Services Section
                  _buildServicesSection(context),
                ],
              );
            },
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
          Observer(
              builder: (BuildContext context) =>
                  LoaderWidget().visible(appStore.isLoading.validate())),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "${language.lblSearchFor} Household",
                  hintStyle: secondaryTextStyle(),
                  prefixIcon: ic_search.iconImage(size: 20).paddingAll(14),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onSubmitted: (value) {
                  // Handle search
                },
              ),
            ),
          ),
          12.width,
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.tune, color: context.iconColor, size: 24),
          ).onTap(() {
            // Handle filter
          }),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
      BuildContext context, List<CategoryData> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "Category",
            style: boldTextStyle(size: 16),
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              CategoryData data = categories[index];
              bool isSelected = selectedCategoryIndex == index;

              return _buildCategoryItem(context, data, index, isSelected);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
      BuildContext context, CategoryData data, int index, bool isSelected) {
    // Get demo image URL
    String imageUrl = data.categoryImage.validate().isEmpty
        ? getDemoCategoryImage(data.name)
        : data.categoryImage.validate();

    return GestureDetector(
      onTap: () => _onCategoryTap(index, data),
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE8F3EC) : context.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? Border.all(color: primaryColor, width: 2)
                    : Border.all(color: Colors.grey.withAlpha(26)),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? primaryColor.withAlpha(51)
                        : Colors.black.withAlpha(13),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedImageWidget(
                  url: imageUrl,
                  fit: BoxFit.contain,
                  width: 40,
                  height: 40,
                ).paddingAll(10),
              ),
            ),
            8.height,
            Text(
              data.name.validate(),
              style: primaryTextStyle(
                size: 11,
                weight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? primaryColor : null,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.height,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Services",
              style: boldTextStyle(size: 16),
            ),
          ),
          12.height,
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: 6, // Demo count
              itemBuilder: (context, index) {
                return _buildServiceCard(context, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, int index) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Image with price badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: CachedImageWidget(
                  url: DEMO_SERVICE_IMAGE_URL,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "₹ 600",
                    style: boldTextStyle(size: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          // Service Details
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Housekeepers",
                        style: boldTextStyle(size: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        4.width,
                        Text("4.8", style: secondaryTextStyle(size: 11)),
                      ],
                    ),
                  ],
                ),
                4.height,
                Text(
                  "Duration 30 min",
                  style: secondaryTextStyle(size: 11),
                ),
                6.height,
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "Hello",
                        style: boldTextStyle(size: 8, color: Colors.white),
                      ),
                    ),
                    6.width,
                    Text(
                      "Abdul Kader",
                      style: secondaryTextStyle(size: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
