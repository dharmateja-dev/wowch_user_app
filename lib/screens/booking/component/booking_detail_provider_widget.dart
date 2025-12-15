import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../model/booking_data_model.dart';
import '../../../utils/model_keys.dart';
import '../../chat/user_chat_screen.dart';

class BookingDetailProviderWidget extends StatefulWidget {
  final UserData providerData;
  final bool canCustomerContact;
  final bool providerIsHandyman;
  final BookingData? bookingDetail;
  final bool showContactButtons;

  BookingDetailProviderWidget(
      {required this.providerData,
      this.canCustomerContact = false,
      this.providerIsHandyman = false,
      this.bookingDetail,
      this.showContactButtons = true});

  @override
  BookingDetailProviderWidgetState createState() =>
      BookingDetailProviderWidgetState();
}

class BookingDetailProviderWidgetState
    extends State<BookingDetailProviderWidget> {
  UserData userData = UserData();

  bool isChattingAllow = false;

  int? flag;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    userData = widget.providerData;

    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.secondaryContainer,
        borderRadius: radius(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Provider info row
          Row(
            children: [
              // Circular profile image
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2D2D2D),
                  border: Border.all(color: context.onPrimary, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: CachedImageWidget(
                    url: widget.providerData.profileImage.validate(),
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              16.width,
              // Provider name and rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name with info icon
                    Row(
                      children: [
                        Text(
                          widget.providerData.displayName.validate(),
                          style: context.boldTextStyle(size: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        8.width,
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: context.taxIconColor,
                        ),
                      ],
                    ),
                    6.height,
                    // Star rating
                    Row(
                      children: List.generate(
                        5,
                        (index) {
                          final rating = widget
                              .providerData.providersServiceRating
                              .validate()
                              .toDouble();
                          final filledStars = rating.round();
                          final isFilled = index < filledStars;
                          return Padding(
                            padding: EdgeInsets.only(right: 2),
                            child: Icon(
                              Icons.star,
                              size: 16,
                              color: isFilled
                                  ? context.starColor
                                  : Color(0xFFE0E0E0),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          8.height,

          // Action buttons row - only show when showContactButtons is true

          if (widget.showContactButtons) ...[
            16.height,
            Row(
              children: [
                // Call button
                AppButton(
                  padding: EdgeInsets.zero,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.call_outlined,
                        size: 18,
                      ),
                      8.width,
                      Text(language.lblCall,
                          style: context.boldTextStyle(size: 14)),
                    ],
                  ),
                  color: context.onPrimary,
                  elevation: 0,
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: context.primary),
                  ),
                  onTap: () {
                    if (widget.providerData.contactNumber
                        .validate()
                        .isNotEmpty) {
                      launchCall(widget.providerData.contactNumber.validate());
                    }
                  },
                ).expand(),
                12.width,
                // Chat button
                AppButton(
                  padding: EdgeInsets.zero,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 18,
                      ),
                      8.width,
                      Text(language.lblChat,
                          style: context.boldTextStyle(size: 14)),
                    ],
                  ),
                  color: context.onPrimary,
                  elevation: 0,
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: context.primaryColor),
                  ),
                  onTap: () async {
                    toast(language.pleaseWaitWhileWeLoadChatDetails);
                    UserData? user = await userService.getUserNull(
                        email: widget.providerData.email.validate());
                    if (user != null) {
                      Fluttertoast.cancel();
                      if (widget.bookingDetail != null) {
                        isChattingAllow = widget.bookingDetail!.status ==
                                BookingStatusKeys.complete ||
                            widget.bookingDetail!.status ==
                                BookingStatusKeys.cancelled;
                      }
                      UserChatScreen(
                              receiverUser: user,
                              isChattingAllow: isChattingAllow)
                          .launch(context);
                    } else {
                      Fluttertoast.cancel();
                      toast(
                          "${widget.providerData.firstName} ${language.isNotAvailableForChat}");
                    }
                  },
                ).expand(),
                12.width,
                // WhatsApp button
                AppButton(
                  padding: EdgeInsets.zero,
                  child: CachedImageWidget(
                    url: ic_whatsapp,
                    height: 20,
                    width: 20,
                  ),
                  color: context.onPrimary,
                  elevation: 0,
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: context.primary),
                  ),
                  onTap: () async {
                    String phoneNumber = "";
                    if (widget.providerData.contactNumber
                        .validate()
                        .contains('+')) {
                      phoneNumber =
                          "${widget.providerData.contactNumber.validate().replaceAll('-', '')}";
                    } else {
                      phoneNumber =
                          "+${widget.providerData.contactNumber.validate().replaceAll('-', '')}";
                    }
                    launchUrl(
                        Uri.parse(
                            '${getSocialMediaLink(LinkProvider.WHATSAPP)}$phoneNumber'),
                        mode: LaunchMode.externalApplication);
                  },
                ).expand(),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
