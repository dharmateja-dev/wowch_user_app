import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/price_widget.dart';
import 'package:booking_system_flutter/model/get_my_post_job_list_response.dart';
import 'package:booking_system_flutter/screens/jobRequest/my_post_detail_screen.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/images.dart';

class MyPostRequestItemComponent extends StatefulWidget {
  final PostJobData data;
  final Function(bool) callback;

  MyPostRequestItemComponent({required this.data, required this.callback});

  @override
  _MyPostRequestItemComponentState createState() =>
      _MyPostRequestItemComponentState();
}

class _MyPostRequestItemComponentState
    extends State<MyPostRequestItemComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  void deletePost(num id) {
    widget.callback.call(true);

    deletePostRequest(id: id.validate()).then((value) {
      appStore.setLoading(false);
      toast(value.message.validate());

      widget.callback.call(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        MyPostDetailScreen(
          postRequestId: widget.data.id.validate().toInt(),
          callback: () {
            widget.callback.call(true);
          },
        ).launch(context);
      },
      child: Container(
        decoration: boxDecorationWithRoundedCorners(
          borderRadius: radius(defaultRadius),
          backgroundColor: const Color(0xFFEAF3EE),
        ),
        width: context.width(),
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedImageWidget(
              url: (widget.data.service.validate().isNotEmpty &&
                      widget.data.service
                          .validate()
                          .first
                          .attachments
                          .validate()
                          .isNotEmpty)
                  ? widget.data.service
                      .validate()
                      .first
                      .attachments
                      .validate()
                      .first
                      .validate()
                  : "",
              fit: BoxFit.cover,
              height: 80,
              width: 80,
              circle: false,
            ).cornerRadiusWithClipRRect(defaultRadius),
            16.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(widget.data.title.validate(),
                            style: boldTextStyle(size: 18),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis)
                        .expand(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.data.status
                            .validate()
                            .getJobStatusColor
                            .withValues(alpha: 0.1),
                        borderRadius: radius(8),
                      ),
                      child: Text(
                        widget.data.status.validate().toPostJobStatus(),
                        style: boldTextStyle(
                            color:
                                widget.data.status.validate().getJobStatusColor,
                            size: 10),
                      ),
                    ),
                  ],
                ),
                4.height,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    PriceWidget(
                      price: widget.data.jobPrice.validate(),
                      isHourlyService: true,
                      color: textPrimaryColorGlobal,
                      isFreeService: false,
                      size: 14,
                    ),
                    // 8.width,
                    // RichText(
                    //   text: TextSpan(
                    //     children: [
                    //       TextSpan(
                    //         text: '₹${widget.data.jobPrice.validate()}',
                    //         style: secondaryTextStyle(size: 14),
                    //       ),
                    //       TextSpan(
                    //         text: '/hr',
                    //         style: secondaryTextStyle(size: 12),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDate(widget.data.createdAt.validate()),
                      style: boldTextStyle(size: 14),
                    ),
                    IconButton(
                      icon: ic_delete.iconImage(
                        size: 18,
                        context: context,
                      ),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        showConfirmDialogCustom(
                          height: 80,
                          width: 290,
                          context,
                          dialogType: DialogType.DELETE,
                          title: language.lblDeletePostJob,
                          customCenterWidget: Image.asset(ic_warning,
                              height: 70, width: 70, fit: BoxFit.cover),
                          positiveText: language.lblYes,
                          negativeText: language.lblNo,
                          primaryColor: context.primaryColor,
                          negativeTextColor: context.primaryColor,
                          onAccept: (p0) {
                            ifNotTester(() {
                              deletePost(widget.data.id.validate());
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ).expand(),
          ],
        ),
      ),
    );
  }
}
