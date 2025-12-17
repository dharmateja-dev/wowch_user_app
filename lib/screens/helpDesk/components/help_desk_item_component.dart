import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/common.dart';
import '../../../utils/constant.dart';
import '../help_desk_detail_screen.dart';
import '../model/help_desk_response.dart';

class HelpDeskItemComponent extends StatefulWidget {
  final HelpDeskListData helpDeskData;

  HelpDeskItemComponent({required this.helpDeskData});

  @override
  _HelpDeskItemComponentState createState() => _HelpDeskItemComponentState();
}

class _HelpDeskItemComponentState extends State<HelpDeskItemComponent> {
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
    return GestureDetector(
      onTap: () {
        HelpDeskDetailScreen(helpDeskData: widget.helpDeskData).launch(context);
      },
      child: Container(
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: boxDecorationWithRoundedCorners(
          borderRadius: radius(),
          backgroundColor: context.cardColor,
          border: appStore.isDarkMode
              ? Border.all(color: context.dividerColor)
              : null,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('#${widget.helpDeskData.id}',
                    style: context.boldTextStyle(color: primaryColor)),
                8.height,
                Text(
                  formatBookingDate(widget.helpDeskData.createdAt.validate(),
                      format: DATE_FORMAT_10),
                  style: context.secondaryTextStyle(),
                ),
                16.height,
                Text(
                  widget.helpDeskData.subject.validate(),
                  style: context.boldTextStyle(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                8.height,
                Text(
                  widget.helpDeskData.description.validate(),
                  style: context.secondaryTextStyle(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.helpDeskData.status == CLOSED)
                  Column(
                    children: [
                      16.height,
                      Divider(height: 0, color: context.dividerColor),
                      16.height,
                      Row(
                        children: [
                          Text(
                            language.closedOn,
                            style: context.boldTextStyle(
                                size: 12, color: Colors.green),
                          ).expand(),
                          Text(
                            formatBookingDate(
                                widget.helpDeskData.updatedAt.validate(),
                                format: DATE_FORMAT_10),
                            style: context.secondaryTextStyle(),
                          ),
                        ],
                      ),
                      16.height,
                    ],
                  ),
                if (widget.helpDeskData.status != CLOSED) 16.height,
                TextButton(
                  onPressed: () async {
                    HelpDeskDetailScreen(helpDeskData: widget.helpDeskData)
                        .launch(context);
                  },
                  style: const ButtonStyle(
                      padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 2, horizontal: 0))),
                  child: Text(
                    language.viewDetail,
                    style:
                        context.boldTextStyle(color: context.primary, size: 12),
                  ),
                ).withHeight(25),
              ],
            ).paddingAll(16),
            Positioned(
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: boxDecorationWithRoundedCorners(
                  borderRadius: radiusOnly(topRight: 8, bottomLeft: 8),
                  backgroundColor: widget.helpDeskData.status
                      .validate()
                      .getHelpDeskStatusBackgroundColor,
                ),
                child: Text(
                  widget.helpDeskData.status.validate().toHelpDeskStatus(),
                  style:
                      context.boldTextStyle(color: context.onPrimary, size: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
