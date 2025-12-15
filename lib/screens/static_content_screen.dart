import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';

class StaticContentScreen extends StatelessWidget {
  final String title;

  const StaticContentScreen({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: title,
      leading: BackWidget(),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "From among the many styles of interior design, the rustic style is one that emphasises inspiration from nature, coupled with earthy, incomplete, rough and uneven beauty. Though it may appear heavy in its original sense, rustic designs have evolved over the years to include other home styles that lend warmth, comfort, and a sense of freshness to any space.\n\n"
              "Rustic decor can be incorporated into any part of your home, be it the living room, bedroom, balcony, kitchen and more. It is one of the most popular styles in modern homes today as it helps achieve a striking balance of authenticity and elegance.\n\n"
              "From among the many styles of interior design, the rustic style is one that emphasises inspiration from nature, coupled with earthy, incomplete, rough and uneven beauty. Though it may appear heavy in its original sense, rustic designs have evolved over the years to include other home styles that lend warmth, comfort, and a sense of freshness to any space.\n\n"
              "Rustic decor can be incorporated into any part of your home, be it the living room, bedroom, balcony, kitchen and more. It is one of the most popular styles in modern homes today as it helps achieve a striking balance of authenticity and elegance.",
              style: context.primaryTextStyle(size: 14, height: 1.5),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
