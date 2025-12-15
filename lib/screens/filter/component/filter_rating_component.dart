import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class FilterRatingComponent extends StatefulWidget {
  @override
  State<FilterRatingComponent> createState() => _FilterRatingComponentState();
}

class _FilterRatingComponentState extends State<FilterRatingComponent> {
  int? selectedRating; // Single selection instead of multi-selection

  @override
  void initState() {
    super.initState();
    // Initialize from filterStore if already set
    if (filterStore.ratingId.isNotEmpty) {
      selectedRating = filterStore.ratingId.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: context.width(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            reverse: true,
            itemBuilder: (context, index) {
              int ratingValue = index + 1;
              bool isSelected = selectedRating == ratingValue;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: context.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Stars Row
                    Expanded(
                      child: Row(
                        children: List.generate(5, (starIndex) {
                          return Icon(
                            starIndex < ratingValue
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: starIndex < ratingValue
                                ? Colors.amber
                                : lightGrey,
                            size: 24,
                          );
                        }),
                      ),
                    ),
                    // Rating Number
                    Text(
                      '$ratingValue',
                      style: context.boldTextStyle(size: 16),
                    ),
                    24.width,
                    // Radio Button
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? context.primaryColor
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                        color: isSelected ? context.primaryColor : Colors.white,
                      ),
                      child: isSelected
                          ? const Icon(Icons.circle,
                              size: 10, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ).onTap(() {
                setState(() {
                  if (selectedRating == ratingValue) {
                    selectedRating = null;
                    filterStore.ratingId.clear();
                  } else {
                    selectedRating = ratingValue;
                    filterStore.ratingId.clear();
                    filterStore.ratingId.add(ratingValue);
                  }
                });
              });
            },
          ),
        ],
      ),
    );
  }
}
