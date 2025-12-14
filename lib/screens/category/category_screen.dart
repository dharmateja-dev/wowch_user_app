import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/category_model.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/screens/service/component/service_component.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../filter/filter_screen.dart';
import '../service/view_all_service_screen.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int selectedCategoryIndex = 0;
  TextEditingController searchController = TextEditingController();

  // Dummy category data
  final List<CategoryData> dummyCategories = [
    CategoryData(
      id: 1,
      name: 'Household',
      categoryImage: 'https://cdn-icons-png.flaticon.com/512/3343/3343638.png',
      color: '4CAF50',
    ),
    CategoryData(
      id: 2,
      name: 'Cooking',
      categoryImage: 'https://cdn-icons-png.flaticon.com/512/3075/3075977.png',
      color: 'FF9800',
    ),
    CategoryData(
      id: 3,
      name: 'Caretaker',
      categoryImage: 'https://cdn-icons-png.flaticon.com/512/4140/4140037.png',
      color: '2196F3',
    ),
    CategoryData(
      id: 4,
      name: 'Special Occasion Helper',
      categoryImage: 'https://cdn-icons-png.flaticon.com/512/3135/3135768.png',
      color: 'E91E63',
    ),
    CategoryData(
      id: 5,
      name: 'Cleaning',
      categoryImage: 'https://cdn-icons-png.flaticon.com/512/2873/2873054.png',
      color: '00BCD4',
    ),
    CategoryData(
      id: 6,
      name: 'Plumbing',
      categoryImage: 'https://cdn-icons-png.flaticon.com/512/4635/4635163.png',
      color: '795548',
    ),
    CategoryData(
      id: 7,
      name: 'Electrical',
      categoryImage: 'https://cdn-icons-png.flaticon.com/512/4514/4514846.png',
      color: 'FFC107',
    ),
    CategoryData(
      id: 8,
      name: 'Painting',
      categoryImage: 'https://cdn-icons-png.flaticon.com/512/1048/1048944.png',
      color: '9C27B0',
    ),
  ];

  // Dummy service data
  final List<ServiceData> dummyServices = [
    ServiceData(
      id: 1,
      name: 'Housekeepers',
      price: 600,
      duration: '30 min',
      totalRating: 4.8,
      providerName: 'Abdul Kader',
      providerImage: '',
      categoryName: 'Household',
    ),
    ServiceData(
      id: 2,
      name: 'Kitchen Cleaning',
      price: 450,
      duration: '45 min',
      totalRating: 4.5,
      providerName: 'Sarah Khan',
      providerImage: '',
      categoryName: 'Cleaning',
    ),
    ServiceData(
      id: 3,
      name: 'Plumbing Repair',
      price: 800,
      duration: '1 hour',
      totalRating: 4.9,
      providerName: 'John Smith',
      providerImage: '',
      categoryName: 'Plumbing',
    ),
    ServiceData(
      id: 4,
      name: 'Electrical Wiring',
      price: 1200,
      duration: '2 hours',
      totalRating: 4.7,
      providerName: 'Mike Johnson',
      providerImage: '',
      categoryName: 'Electrical',
    ),
    ServiceData(
      id: 5,
      name: 'House Painting',
      price: 2500,
      duration: '4 hours',
      totalRating: 4.6,
      providerName: 'David Brown',
      providerImage: '',
      categoryName: 'Painting',
    ),
    ServiceData(
      id: 6,
      name: 'Cooking Service',
      price: 500,
      duration: '1 hour',
      totalRating: 4.8,
      providerName: 'Chef Maria',
      providerImage: '',
      categoryName: 'Cooking',
    ),
  ];

  @override
  void initState() {
    super.initState();
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
        center: true,
        backWidget: BackWidget(),
        language.category,
        textColor: Colors.white,
        textSize: APP_BAR_TEXT_SIZE,
        color: context.primary,
        systemUiOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness:
              appStore.isDarkMode ? Brightness.light : Brightness.light,
          statusBarColor: context.primaryColor,
        ),
        showBack: Navigator.canPop(context),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar Section
                _buildSearchBar(context),

                // Category Section with horizontal list
                _buildCategorySection(context, dummyCategories),

                // Services Section
                _buildServicesSection(context),
              ],
            ),
          ),
          Observer(
            builder: (BuildContext context) =>
                LoaderWidget().visible(appStore.isLoading.validate()),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFE8F3EC),
          borderRadius: BorderRadius.circular(8),
        ),
        child: AppTextField(
          textFieldType: TextFieldType.OTHER,
          controller: searchController,
          decoration: InputDecoration(
            hintText:
                "${language.lblSearchFor} ${dummyCategories[selectedCategoryIndex].name}",
            prefixIcon:
                ic_search.iconImage(size: 16, context: context).paddingAll(14),
            suffixIcon: ic_filter
                .iconImage(size: 16, context: context)
                .paddingAll(14)
                .onTap(
              () {
                FilterScreen(
                  isFromProvider: true,
                  isFromCategory: false,
                ).launch(context).then((value) {
                  if (value != null && value == true) {
                    // Filter applied, refresh if needed
                    setState(() {});
                  }
                });
              },
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          onTap: () {},
        ),
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
            language.category,
            style: boldTextStyle(),
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
    String imageUrl = data.categoryImage.validate();

    return GestureDetector(
      onTap: () => _onCategoryTap(index, data),
      child: Container(
        width: 70,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Color(0xFFE8F3EC),
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: context.primary, width: 1)
                    : Border.all(color: Colors.transparent),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedImageWidget(
                  url: imageUrl,
                  fit: BoxFit.contain,
                  width: 35,
                  height: 35,
                ).paddingAll(10),
              ),
            ),
            8.height,
            Expanded(
              child: Text(
                data.name.validate(),
                style: primaryTextStyle(
                  size: 11,
                  weight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? primaryColor : null,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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
            style: boldTextStyle(size: 16),
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
