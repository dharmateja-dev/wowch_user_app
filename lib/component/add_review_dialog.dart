import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/service_detail_response.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import 'chat_gpt_loder.dart';

class AddReviewDialog extends StatefulWidget {
  final RatingData? customerReview;
  final int? bookingId;
  final int? serviceId;
  final int? handymanId;
  final bool? isCustomerRating;

  AddReviewDialog(
      {this.customerReview,
      this.bookingId,
      this.serviceId,
      this.handymanId,
      this.isCustomerRating});

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  double selectedRating = 0;

  TextEditingController reviewCont = TextEditingController();

  bool isUpdate = false;
  bool isHandymanUpdate = false;

  @override
  void initState() {
    isUpdate = widget.customerReview != null;
    isHandymanUpdate =
        widget.customerReview != null && widget.handymanId != null;

    if (isUpdate) {
      selectedRating = widget.customerReview!.rating.validate().toDouble();
      reviewCont.text = widget.customerReview!.review.validate();
    }

    super.initState();
  }

  void submit() async {
    hideKeyboard(context);
    Map<String, dynamic> req = {};
    if (isUpdate) {
      req = {
        "id": widget.customerReview!.id.validate(),
        "booking_id": widget.customerReview!.bookingId.validate(),
        "service_id": widget.customerReview!.serviceId.validate(),
        "customer_id": appStore.userId.validate(),
        "rating": selectedRating.validate(),
        "review": reviewCont.text.validate(),
      };
      if (widget.handymanId != null) {
        req.putIfAbsent("handyman_id", () => widget.handymanId);
      }
      appStore.setLoading(true);

      if (widget.handymanId == null) {
        await updateReview(req).then((value) {
          toast(value.message);
          if (widget.isCustomerRating.validate(value: false)) {
            finish(context, req);
          } else {
            finish(context, true);
          }
        }).catchError((e) {
          toast(e.toString());
          finish(context, false);
        });
      } else {
        await handymanRating(req).then((value) {
          finish(context, true);
          toast(value.message);
        }).catchError((e) {
          toast(e.toString());
          finish(context, false);
        });
      }

      appStore.setLoading(false);

      return;
    }
    req = {
      "id": "",
      "booking_id": widget.bookingId.validate(),
      "service_id": widget.serviceId.validate(),
      "customer_id": appStore.userId.validate(),
      "rating": selectedRating.validate(),
      "review": reviewCont.text.validate(),
    };
    if (widget.handymanId != null) {
      req.putIfAbsent("handyman_id", () => widget.handymanId);
    }
    appStore.setLoading(true);

    if (widget.handymanId == null) {
      await updateReview(req).then((value) {
        finish(context, true);
        toast(value.message);
      }).catchError((e) {
        toast(e.toString());
        finish(context, false);
      });
    } else {
      await handymanRating(req).then((value) {
        finish(context, true);
        toast(value.message);
      }).catchError((e) {
        toast(e.toString());
        finish(context, false);
      });
    }

    appStore.setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title: "Your Review" - bold black text at top
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  child: Text(language.yourReview,
                      style: context.boldTextStyle(
                        size: 18,
                        color: textPrimaryColorGlobal,
                      )).center(),
                ),
                // Your Rating Section - Light green background
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFE8F3EC), // Light green background
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // "Your Rating" text on left
                      Text(
                        language.lblYourRating,
                        style: context.primaryTextStyle(
                          size: 14,
                          color: textPrimaryColorGlobal,
                        ),
                      ),
                      8.width,
                      // Rating stars on right - yellow color
                      RatingBarWidget(
                        onRatingChanged: (rating) {
                          selectedRating = rating;
                          setState(() {});
                        },
                        activeColor: Color(0xFFFFC107), // Yellow stars
                        inActiveColor: Colors.grey[300]!,
                        rating: selectedRating,
                        size: 18,
                      ),
                    ],
                  ),
                ),
                16.height,
                // Review Input Field - Light green background
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFE8F3EC), // Light green background
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AppTextField(
                    textStyle: context.primaryTextStyle(),
                    controller: reviewCont,
                    textFieldType: TextFieldType.OTHER,
                    minLines: 5,
                    maxLines: 10,
                    enableChatGPT: appConfigurationStore.chatGPTStatus,
                    promptFieldInputDecorationChatGPT: InputDecoration(
                      hintText: 'Enter Your Review (Optional)',
                      hintStyle: context.secondaryTextStyle(
                        color: textSecondaryColorGlobal,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    testWithoutKeyChatGPT: appConfigurationStore.testWithoutKey,
                    loaderWidgetForChatGPT: const ChatGPTLoadingWidget(),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Enter Your Review (Optional)',
                      hintStyle: context.secondaryTextStyle(
                        color: textSecondaryColorGlobal,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                24.height,
                // Action Buttons Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Row(
                    children: [
                      // Cancel Button - Transparent background with dark green text
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            if (isHandymanUpdate) {
                              showConfirmDialogCustom(
                                context,
                                primaryColor: context.primaryColor,
                                title: language.lblDeleteRatingMsg,
                                positiveText: language.lblYes,
                                negativeText: language.lblCancel,
                                onAccept: (c) async {
                                  appStore.setLoading(true);

                                  await deleteHandymanReview(
                                          id: widget.customerReview!.id
                                              .validate()
                                              .toInt())
                                      .then((value) {
                                    toast(value.message);
                                    finish(context, true);
                                  }).catchError((e) {
                                    toast(e.toString());
                                  });

                                  setState(() {});

                                  appStore.setLoading(false);
                                },
                              );
                            } else {
                              finish(context);
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isHandymanUpdate
                                ? language.lblDelete
                                : language.lblCancel,
                            style: context.boldTextStyle(
                              size: 14,
                              color: isHandymanUpdate
                                  ? Colors.red
                                  : context.primaryColor, // Dark green text
                            ),
                          ),
                        ),
                      ),
                      16.width,
                      // Submit Button - Solid dark green background with white text
                      Expanded(
                        child: AppButton(
                          textColor: Colors.white,
                          text: language.btnSubmit,
                          color: context.primaryColor, // Dark green background
                          shapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onTap: () {
                            if (selectedRating == 0) {
                              toast(language.lblSelectRating);
                            } else {
                              submit();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Observer(
            builder: (context) => LoaderWidget()
                .visible(appStore.isLoading)
                .withSize(height: 80, width: 80))
      ],
    );
  }
}
