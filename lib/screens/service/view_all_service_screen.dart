import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/store/filter_store.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/cached_image_widget.dart';
import '../../main.dart';
import '../../model/category_model.dart';
import '../../model/service_data_model.dart';
import '../../network/rest_apis.dart';
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

  // Dummy service data for subcategories
  final List<ServiceData> dummyServices = [
    ServiceData(
      id: 1,
      name: 'Washing Utensils Service',
      price: 250,
      duration: '30 min',
      totalRating: 4.8,
      providerName: 'Priya Sharma',
      providerImage: '',
      categoryName: 'Household',
    ),
    ServiceData(
      id: 2,
      name: 'Clothes Washing',
      price: 350,
      duration: '45 min',
      totalRating: 4.6,
      providerName: 'Rahul Verma',
      providerImage: '',
      categoryName: 'Household',
    ),
    ServiceData(
      id: 3,
      name: 'Floor Tile Cleaning',
      price: 500,
      duration: '1 hour',
      totalRating: 4.9,
      providerName: 'Amit Kumar',
      providerImage: '',
      categoryName: 'Cleaning',
    ),
    ServiceData(
      id: 4,
      name: 'Bathroom Deep Clean',
      price: 600,
      duration: '1.5 hours',
      totalRating: 4.7,
      providerName: 'Sunita Devi',
      providerImage: '',
      categoryName: 'Cleaning',
    ),
    ServiceData(
      id: 5,
      name: 'Kitchen Cleaning',
      price: 450,
      duration: '1 hour',
      totalRating: 4.5,
      providerName: 'Mohan Lal',
      providerImage: '',
      categoryName: 'Cleaning',
    ),
    ServiceData(
      id: 6,
      name: 'Car Washing',
      price: 300,
      duration: '40 min',
      totalRating: 4.8,
      providerName: 'Vijay Singh',
      providerImage: '',
      categoryName: 'Cleaning',
    ),
  ];

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

    // Always show dummy subcategories
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        16.height,
        Text(
          language.lblSubcategories,
          style: context.boldTextStyle(),
        ).paddingSymmetric(horizontal: 16),
        12.height,
        // Grid layout for subcategories
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(demoSubcategories.length, (index) {
              final demo = demoSubcategories[index];
              return Observer(
                builder: (_) {
                  bool isSelected = filterStore.selectedSubCategoryId == index;
                  return _buildSubcategoryItem(
                    context,
                    name: demo['name']!,
                    imageKey: demo['image']!,
                    index: index,
                    isSelected: isSelected,
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
                },
              );
            }),
          ),
        ),
        16.height,
      ],
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
                    color: Color(0xFFE8F3EC),
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: context.primaryColor, width: 2)
                        : Border.all(color: Colors.transparent),
                  ),
                  child: index == 0
                      ? Icon(
                          Icons.grid_view_rounded,
                          size: 28,
                          color:
                              isSelected ? context.primaryColor : context.icon,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
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
              style: context.primaryTextStyle(
                size: 10,
                weight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? context.primaryColor : null,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
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
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                page = 1;
                appStore.setLoading(true);
                fetchAllServiceData();
                setState(() {});
              },
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar Section (matching CategoryScreen style)
                    _buildSearchBar(context),

                    // Subcategory Section
                    if (widget.categoryId != null) subCategoryWidget(),

                    // Services Section
                    _buildServicesSection(context),
                  ],
                ),
              ),
            ),
            Observer(
              builder: (_) => Positioned.fill(
                child: Container(
                  color: Colors.transparent,
                ).visible(appStore.isLoading),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE8F3EC),
          borderRadius: BorderRadius.circular(8),
        ),
        child: AppTextField(
          textFieldType: TextFieldType.OTHER,
          focus: myFocusNode,
          controller: searchCont,
          decoration: InputDecoration(
            hintText: "${language.lblSearchFor} $setSearchString",
            prefixIcon:
                ic_search.iconImage(size: 16, context: context).paddingAll(14),
            suffixIcon: ic_filter
                .iconImage(size: 16, context: context)
                .paddingAll(14)
                .onTap(
              () {
                hideKeyboard(context);
                FilterScreen(
                  isFromProvider: widget.isFromProvider,
                  isFromCategory: widget.isFromCategory,
                ).launch(context).then((value) {
                  if (value != null) {
                    page = 1;
                    appStore.setLoading(true);
                    fetchAllServiceData();
                    setState(() {});
                  }
                });
              },
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          onFieldSubmitted: (s) {
            page = 1;
            filterStore.setSearch(s);
            appStore.setLoading(true);
            fetchAllServiceData();
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            language.service,
            style: context.boldTextStyle(size: LABEL_TEXT_SIZE),
          ),
        ),
        12.height,
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemCount: dummyServices.length,
          itemBuilder: (context, index) {
            return ServiceComponent(
              serviceData: dummyServices[index],
              isFromViewAllService: true,
            );
          },
        ),
        16.height, // Bottom padding
      ],
    );
  }
}
