import 'package:booking_system_flutter/component/view_all_label_component.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/category_model.dart';
import 'package:booking_system_flutter/screens/category/category_screen.dart';
import 'package:booking_system_flutter/screens/dashboard/component/category_widget.dart';
import 'package:booking_system_flutter/screens/service/view_all_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class CategoryComponent extends StatefulWidget {
  final List<CategoryData>? categoryList;
  final bool isNewDashboard;

  CategoryComponent({this.categoryList, this.isNewDashboard = false});

  @override
  CategoryComponentState createState() => CategoryComponentState();
}

class CategoryComponentState extends State<CategoryComponent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categoryList.validate().isEmpty) return const Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViewAllLabel(
            label: language.category,
            list: widget.categoryList,
            onTap: () {
              CategoryScreen().launch(context).then((value) {
                setStatusBarColor(Colors.transparent);
              });
            }).paddingSymmetric(horizontal: 16),
        12.height,
        if (widget.categoryList.validate().isNotEmpty)
          HorizontalList(
            itemCount: widget.categoryList.validate().length,
            spacing: 0,
            padding: const EdgeInsets.only(bottom: 4),
            itemBuilder: (context, index) {
              CategoryData data = widget.categoryList![index];
              return GestureDetector(
                onTap: () {
                  ViewAllServiceScreen(
                    categoryId: data.id.validate(),
                    categoryName: data.name,
                    isFromCategory: true,
                  ).launch(context);
                },
                child: CategoryWidget(
                  categoryData: data,
                  width: 80, // Fixed width for horizontal scroll
                ),
              );
            },
          ).paddingSymmetric(horizontal: 12),
      ],
    );
  }
}
