import 'package:booking_system_flutter/component/image_border_component.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/empty_error_state_widget.dart';

class FilterProviderComponent extends StatefulWidget {
  final List<UserData> providerList;
  final bool showLoader;

  FilterProviderComponent(
      {required this.providerList, this.showLoader = false});

  @override
  State<FilterProviderComponent> createState() =>
      _FilterProviderComponentState();
}

class _FilterProviderComponentState extends State<FilterProviderComponent> {
  @override
  Widget build(BuildContext context) {
    if (widget.providerList.isEmpty && !appStore.isLoading)
      return NoDataWidget(
        title: language.noProviderFound,
        imageWidget: const EmptyStateWidget(),
      );
    else if (widget.showLoader) {
      return Observer(
          builder: (_) => LoaderWidget().visible(appStore.isLoading));
    }
    return AnimatedListView(
      slideConfiguration: sliderConfigurationGlobal,
      itemCount: widget.providerList.length,
      listAnimationType: ListAnimationType.FadeIn,
      fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
      itemBuilder: (context, index) {
        UserData data = widget.providerList[index];

        return Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: context.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Provider Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  border: Border.all(color: context.primaryColor, width: 1),
                ),
                child: data.profileImage.validate().isNotEmpty
                    ? ImageBorder(
                        src: data.profileImage.validate(),
                        height: 50,
                      )
                    : Center(
                        child: Text(
                          'Hello',
                          style: context.boldTextStyle(
                              color: Colors.white, size: 10),
                        ),
                      ),
              ),
              12.width,
              // Provider Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Rating Row
                    Row(
                      children: [
                        Text(
                          data.displayName.validate(),
                          style: context.boldTextStyle(size: 14),
                        ),
                        16.width,
                        // Rating Badge
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              ic_star_fill,
                              height: 10,
                              width: 10,
                              color: Colors.amber,
                            ),
                            4.width,
                            Text(
                              data.providersServiceRating
                                  .validate()
                                  .toStringAsFixed(1),
                              style: context.primaryTextStyle(
                                size: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    4.height,
                    // Date
                    Text(
                      DateFormat('MMMM dd, yyyy')
                          .format(DateTime.parse(data.createdAt.validate())),
                      style: context.secondaryTextStyle(size: 12),
                    ),
                    6.height,
                    // Services Member Since
                    Text(
                      'Services\nMember Since ${DateFormat(YEAR).format(DateTime.parse(data.createdAt.validate()))}',
                      style: context.secondaryTextStyle(size: 11),
                    ),
                  ],
                ),
              ),
              // Selection Radio Button
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: data.isSelected
                        ? context.primaryColor
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                  color: data.isSelected ? context.primaryColor : white,
                ),
                child: data.isSelected
                    ? const Icon(Icons.circle, size: 12, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ).onTap(() {
          if (data.isSelected) {
            data.isSelected = false;
          } else {
            data.isSelected = true;
          }
          setState(() {});
        });
      },
    );
  }
}
