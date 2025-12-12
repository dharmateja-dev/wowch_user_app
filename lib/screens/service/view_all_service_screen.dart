import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/screens/service/shimmer/view_all_service_shimmer.dart';
import 'package:booking_system_flutter/store/filter_store.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/cached_image_widget.dart';
import '../../component/empty_error_state_widget.dart';
import '../../main.dart';
import '../../model/category_model.dart';
import '../../model/service_data_model.dart';
import '../../network/rest_apis.dart';
import '../../utils/common.dart';
import '../../utils/constant.dart';
import '../../utils/images.dart';
import '../filter/filter_screen.dart';
import 'component/service_component.dart';

class ViewAllServiceScreen extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;
  final String isFeatured;
  final bool isFromProvider;
  final bool isFromCategory;
  final int? providerId;
  final int? shopId;

  final String screenTitle;

  ViewAllServiceScreen({
    this.categoryId,
    this.categoryName = '',
    this.isFeatured = '',
    this.isFromProvider = true,
    this.isFromCategory = false,
    this.providerId,
    this.shopId,
    this.screenTitle = '',
    Key? key,
  }) : super(key: key);

  @override
  State<ViewAllServiceScreen> createState() => _ViewAllServiceScreenState();
}

class _ViewAllServiceScreenState extends State<ViewAllServiceScreen> {
  Future<List<CategoryData>>? futureCategory;
  List<CategoryData> categoryList = [];

  Future<List<ServiceData>>? futureService;
  List<ServiceData> serviceList = [];

  FocusNode myFocusNode = FocusNode();
  TextEditingController searchCont = TextEditingController();

  int? subCategory;

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
    filterStore = FilterStore();
    print(serviceList);
  }

  void init() async {
    fetchAllServiceData();
    if (widget.categoryId != null) {
      fetchCategoryList();
    }
  }

  void fetchCategoryList() async {
    futureCategory = getSubCategoryListAPI(
      catId: widget.categoryId!,
    );
  }

  void fetchAllServiceData() async {
    futureService = searchServiceAPI(
      page: page,
      list: serviceList,
      isZoneId: filterStore.zoneId.validate(),
      categoryId: widget.categoryId != null
          ? widget.categoryId.validate().toString()
          : filterStore.categoryId.join(','),
      subCategory: subCategory != null ? subCategory.validate().toString() : '',
      providerId: widget.providerId != null
          ? widget.providerId.toString()
          : filterStore.providerId.join(","),
      isPriceMin: filterStore.isPriceMin,
      isPriceMax: filterStore.isPriceMax,
      ratingId: filterStore.ratingId.join(','),
      search: searchCont.text,
      latitude:
          appStore.isCurrentLocation ? getDoubleAsync(LATITUDE).toString() : "",
      longitude: appStore.isCurrentLocation
          ? getDoubleAsync(LONGITUDE).toString()
          : "",
      lastPageCallBack: (p0) {
        isLastPage = p0;
      },
      shopId: widget.shopId != null ? widget.shopId.toString() : '',
      isFeatured: widget.isFeatured,
    );
  }

  String get setSearchString {
    if (!widget.categoryName.isEmptyOrNull) {
      return widget.categoryName!;
    } else if (widget.isFeatured == "1") {
      return language.lblFeatured;
    } else if (widget.screenTitle.isNotEmpty) {
      return widget.screenTitle;
    } else {
      return language.allServices;
    }
  }

  Widget subCategoryWidget() {
    // Demo subcategory data for Household category
    final List<Map<String, String>> demoSubcategories = [
      {'name': 'View All', 'image': 'view_all'},
      {'name': 'Washing Utensils', 'image': 'washing_utensils'},
      {'name': 'Washing Clothes', 'image': 'washing_clothes'},
      {'name': 'Washing Tiles', 'image': 'washing_tiles'},
      {'name': 'Bathroom Cleaning', 'image': 'bathroom_cleaning'},
      {'name': 'Kitchen Cleaning', 'image': 'kitchen_cleaning'},
      {'name': 'Car Washing', 'image': 'car_washing'},
    ];

    return SnapHelperWidget<List<CategoryData>>(
      future: futureCategory,
      initialData: cachedSubcategoryList
          .firstWhere((element) => element?.$1 == widget.categoryId.validate(),
              orElse: () => null)
          ?.$2,
      loadingWidget: const Offstage(),
      onSuccess: (list) {
        // Use demo data if list is empty or only has 'All' item
        final bool useDemoData = list.isEmpty || list.length <= 1;
        final int itemCount =
            useDemoData ? demoSubcategories.length : list.validate().length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            16.height,
            Text(
              language.lblSubcategories,
              style: boldTextStyle(size: LABEL_TEXT_SIZE),
            ).paddingSymmetric(horizontal: 16),
            12.height,
            // Grid layout for subcategories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(itemCount, (index) {
                  if (useDemoData) {
                    final demo = demoSubcategories[index];
                    return _buildSubcategoryItem(
                      context,
                      name: demo['name']!,
                      imageKey: demo['image']!,
                      index: index,
                      isSelected: filterStore.selectedSubCategoryId == index,
                      onTap: () {
                        filterStore.setSelectedSubCategory(catId: index);
                        if (index != 0) {
                          subCategory = index;
                        } else {
                          subCategory = null;
                        }
                        page = 1;
                        appStore.setLoading(true);
                        fetchAllServiceData();
                        setState(() {});
                      },
                    );
                  } else {
                    CategoryData data = list[index];
                    return Observer(
                      builder: (_) {
                        bool isSelected =
                            filterStore.selectedSubCategoryId == index;
                        return _buildSubcategoryItemFromData(
                          context,
                          data: data,
                          index: index,
                          isSelected: isSelected,
                          onTap: () {
                            filterStore.setSelectedSubCategory(catId: index);
                            subCategory = data.id;
                            page = 1;
                            appStore.setLoading(true);
                            fetchAllServiceData();
                            setState(() {});
                          },
                        );
                      },
                    );
                  }
                }),
              ),
            ),
            16.height,
          ],
        );
      },
    );
  }

  Widget _buildSubcategoryItem(
    BuildContext context, {
    required String name,
    required String imageKey,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final double itemWidth =
        (context.width() - 48) / 4; // 4 items per row with spacing
    final String imageUrl = getDemoSubcategoryImage(imageKey);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: itemWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE8F3EC)
                        : context.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(color: context.primaryColor, width: 2)
                        : Border.all(color: Colors.grey.withAlpha(26)),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? context.primaryColor.withAlpha(51)
                            : Colors.black.withAlpha(10),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: index == 0
                      ? Icon(
                          Icons.grid_view_rounded,
                          size: 28,
                          color: isSelected
                              ? context.primaryColor
                              : context.iconColor,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CachedImageWidget(
                            url: imageUrl,
                            fit: BoxFit.contain,
                            width: 36,
                            height: 36,
                          ),
                        ).paddingAll(12),
                ),
                if (isSelected)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: context.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.check,
                          size: 14, color: Colors.white),
                    ),
                  ),
              ],
            ),
            8.height,
            Text(
              name,
              style: primaryTextStyle(
                size: 10,
                weight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? context.primaryColor : null,
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

  Widget _buildSubcategoryItemFromData(
    BuildContext context, {
    required CategoryData data,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final double itemWidth = (context.width() - 48) / 4;
    final String imageUrl = data.categoryImage.validate().isEmpty
        ? getDemoSubcategoryImage(data.name)
        : data.categoryImage.validate();

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: itemWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE8F3EC)
                        : context.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(color: context.primaryColor, width: 2)
                        : Border.all(color: Colors.grey.withAlpha(26)),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? context.primaryColor.withAlpha(51)
                            : Colors.black.withAlpha(10),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: index == 0
                      ? Center(
                          child: Text(
                            data.name.validate(),
                            style: boldTextStyle(size: 10),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : data.categoryImage.validate().endsWith('.svg')
                          ? SvgPicture.network(
                              data.categoryImage.validate(),
                              height: 32,
                              width: 32,
                              colorFilter: ColorFilter.mode(
                                appStore.isDarkMode
                                    ? Colors.white
                                    : data.color
                                        .validate(value: '000')
                                        .toColor(),
                                BlendMode.srcIn,
                              ),
                              placeholderBuilder: (context) =>
                                  const PlaceHolderWidget(
                                      height: 32,
                                      width: 32,
                                      color: transparentColor),
                            ).paddingAll(14)
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: CachedImageWidget(
                                url: imageUrl,
                                fit: BoxFit.contain,
                                width: 36,
                                height: 36,
                              ),
                            ).paddingAll(12),
                ),
                if (isSelected)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: context.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.check,
                          size: 14, color: Colors.white),
                    ),
                  ),
              ],
            ),
            8.height,
            Text(
              index == 0 ? language.lblViewAll : data.name.validate(),
              style: primaryTextStyle(
                size: 10,
                weight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? context.primaryColor : null,
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

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    filterStore.clearFilters();
    myFocusNode.dispose();
    filterStore.setSelectedSubCategory(catId: 0);
    super.dispose();
  }

  // Disable refresh and next page if showing shop-specific services
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: AppScaffold(
        appBarTitle: setSearchString,
        child: SizedBox(
          height: context.height(),
          width: context.width(),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    AppTextField(
                      textFieldType: TextFieldType.OTHER,
                      focus: myFocusNode,
                      controller: searchCont,
                      suffix: CloseButton(
                        onPressed: () {
                          page = 1;
                          searchCont.clear();
                          filterStore.setSearch('');
                          appStore.setLoading(true);
                          fetchAllServiceData();
                          setState(() {});
                        },
                      ).visible(searchCont.text.isNotEmpty),
                      onFieldSubmitted: (s) {
                        page = 1;

                        filterStore.setSearch(s);
                        appStore.setLoading(true);

                        fetchAllServiceData();
                        setState(() {});
                      },
                      decoration: inputDecoration(context).copyWith(
                        hintText: "${language.lblSearchFor} $setSearchString",
                        prefixIcon:
                            ic_search.iconImage(size: 10).paddingAll(14),
                        hintStyle: secondaryTextStyle(),
                      ),
                    ).expand(),
                    16.width,
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration:
                          boxDecorationDefault(color: context.primaryColor),
                      child: const CachedImageWidget(
                        url: ic_filter,
                        height: 26,
                        width: 26,
                        color: Colors.white,
                      ),
                    ).onTap(() {
                      hideKeyboard(context);

                      FilterScreen(
                        isFromProvider: widget.isFromProvider,
                        isFromCategory: widget.isFromCategory,
                        // isFromShop: true,
                      ).launch(context).then((value) {
                        if (value != null) {
                          page = 1;
                          appStore.setLoading(true);

                          fetchAllServiceData();
                          setState(() {});
                        }
                      });
                    }, borderRadius: radius())
                  ],
                ),
              ),
              AnimatedScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                onSwipeRefresh: () {
                  page = 1;
                  appStore.setLoading(true);
                  fetchAllServiceData();
                  setState(() {});
                  return Future.value(false);
                },
                onNextPage: () {
                  if (!isLastPage) {
                    page++;
                    appStore.setLoading(true);
                    fetchAllServiceData();
                    setState(() {});
                  }
                },
                children: [
                  if (widget.categoryId != null) subCategoryWidget(),
                  16.height,
                  SnapHelperWidget(
                    future: futureService,
                    loadingWidget: const ViewAllServiceShimmer(),
                    errorBuilder: (p0) {
                      return NoDataWidget(
                        title: p0,
                        retryText: language.reload,
                        imageWidget: const ErrorStateWidget(),
                        onRetry: () {
                          page = 1;
                          appStore.setLoading(true);

                          fetchAllServiceData();
                          setState(() {});
                        },
                      );
                    },
                    onSuccess: (data) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language.service,
                                  style: boldTextStyle(size: LABEL_TEXT_SIZE))
                              .paddingSymmetric(horizontal: 16),
                          AnimatedListView(
                            itemCount: serviceList.length,
                            listAnimationType: ListAnimationType.FadeIn,
                            fadeInConfiguration:
                                FadeInConfiguration(duration: 2.seconds),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            emptyWidget: NoDataWidget(
                              title: language.lblNoServicesFound,
                              subTitle: (searchCont.text.isNotEmpty ||
                                      filterStore.providerId.isNotEmpty ||
                                      filterStore.categoryId.isNotEmpty)
                                  ? language.noDataFoundInFilter
                                  : null,
                              imageWidget: const EmptyStateWidget(),
                            ),
                            itemBuilder: (_, index) {
                              return ServiceComponent(
                                serviceData: serviceList[index],
                                isFromViewAllService: true,
                              ).paddingAll(8);
                            },
                          ).paddingAll(8),
                        ],
                      );
                    },
                  ),
                ],
              ).expand(),
            ],
          ),
        ),
      ),
    );
  }
}
