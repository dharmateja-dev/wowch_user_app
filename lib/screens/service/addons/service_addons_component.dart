import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/price_widget.dart';
import '../../../component/view_all_label_component.dart';
import '../../../main.dart';
import '../../../model/service_detail_response.dart';
import '../../../utils/images.dart';

class AddonComponent extends StatefulWidget {
  final List<Serviceaddon> serviceAddon;
  final Function(List<Serviceaddon>)? onSelectionChange;
  final bool isFromBookingLastStep;
  final bool isFromBookingDetails;
  final bool showDoneBtn;
  final Function(Serviceaddon)? onDoneClick;

  AddonComponent({
    required this.serviceAddon,
    this.isFromBookingLastStep = false,
    this.isFromBookingDetails = false,
    this.onSelectionChange,
    this.showDoneBtn = false,
    this.onDoneClick,
  });

  @override
  _AddonComponentState createState() => _AddonComponentState();
}

class _AddonComponentState extends State<AddonComponent> {
  List<Serviceaddon> selectedServiceAddon = [];
  double imageHeight = 60;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.serviceAddon.isEmpty) return Offstage();

    bool isSingleAddon = widget.serviceAddon.length == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        ViewAllLabel(
          label: language.addOns,
          list: [],
          onTap: () {},
        ),
        8.height,
        isSingleAddon
            ? buildSingleAddonWidget(widget.serviceAddon[0])
            : buildMultipleAddonsWidget(),
      ],
    ).paddingSymmetric(
      horizontal:
          widget.isFromBookingLastStep || widget.isFromBookingDetails ? 0 : 16,
    );
  }

  Widget buildSingleAddonWidget(Serviceaddon addon) {
    return Container(
      width: context.width(),
      padding: EdgeInsets.all(12),
      decoration: boxDecorationWithRoundedCorners(
        border: Border.all(style: BorderStyle.none),
        backgroundColor: context.secondaryContainer,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (addon.serviceAddonImage.validate().isNotEmpty)
            CachedImageWidget(
              url: addon.serviceAddonImage.validate(),
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            ).cornerRadiusWithClipRRect(8),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        addon.name.validate(),
                        style: context.boldTextStyle(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (!widget.isFromBookingDetails) ...[
                      8.width,
                      buildAddButton(addon),
                    ],
                  ],
                ),
                4.height,
                PriceWidget(
                  price: addon.price.validate(),
                  currencySymbol: '₹',
                  size: 14,
                  isBoldText: false,
                  color: context.onSurface,
                  isFreeService: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMultipleAddonsWidget() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          widget.serviceAddon.length,
          (i) {
            Serviceaddon data = widget.serviceAddon[i];
            return Observer(builder: (context) {
              return GestureDetector(
                onTap: () {
                  if (!widget.isFromBookingLastStep &&
                      !widget.isFromBookingDetails) {
                    handleAddRemove(data);
                  }
                },
                behavior: HitTestBehavior.translucent,
                child: buildAddonContainer(data),
              );
            });
          },
        ),
      ),
    );
  }

  Widget buildAddonContainer(Serviceaddon data) {
    return Container(
      width: context.isPhone() ? context.width() - 60 : 300,
      margin: EdgeInsets.only(right: 16),
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(8),
        backgroundColor: context.surfaceContainer,
      ),
      child: Row(
        children: [
          if (data.serviceAddonImage.validate().isNotEmpty)
            CachedImageWidget(
              url: data.serviceAddonImage.validate(),
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            ).cornerRadiusWithClipRRect(8),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data.name.validate(),
                        style: context.boldTextStyle(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    //8.width,
                  ],
                ),
                10.height,
                PriceWidget(
                  price: data.price.validate(),
                  color: context.onSurface,
                  hourlyTextColor: context.onSurface,
                  isBoldText: false,
                  size: 12,
                ),
                12.width,
                if (!widget.isFromBookingDetails) buildAddButton(data),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAddButton(Serviceaddon data) {
    return Container(
      decoration: BoxDecoration(
        color: context.primary,
        borderRadius: radius(50),
      ),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Image.asset(
        data.isSelected ? ic_close : ic_add,
        height: 14,
        width: 14,
        color: context.onPrimary,
      ),
    ).onTap(() => handleAddRemove(data));
  }

  void handleAddRemove(Serviceaddon data) {
    data.isSelected = !data.isSelected;
    if (data.isSelected) {
      toast('${data.name.validate()} added successfully');
    } else {
      toast('${data.name.validate()} removed successfully');
    }

    selectedServiceAddon =
        widget.serviceAddon.where((p0) => p0.isSelected).toList();
    widget.onSelectionChange?.call(selectedServiceAddon);
    setState(() {});
  }
}
