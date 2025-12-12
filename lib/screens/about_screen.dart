import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/configs.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/app_configuration.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: LightThemeColors.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark));
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      leading: BackWidget(),
      appBarTitle: language.about,
      child: AnimatedScrollView(
        crossAxisAlignment: CrossAxisAlignment.center,
        listAnimationType: ListAnimationType.FadeIn,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
        children: [
          // Illustration
          Image.asset(no_conversation, fit: BoxFit.contain).center(),
          24.height,
          // App Name
          Text(
            APP_NAME,
            style: boldTextStyle(size: 24, color: appTextPrimaryColor),
            textAlign: TextAlign.center,
          ),
          8.height,
          // Tagline
          Text(
            APP_NAME_TAG_LINE,
            style: secondaryTextStyle(size: 14, color: appTextSecondaryColor),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          30.height,
          // Call and Email buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Call button
              if (appConfigurationStore.helplineNumber.isNotEmpty)
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        ic_calling,
                        height: 24,
                        width: 24,
                        color: primaryColor,
                      ),
                      8.height,
                      Text(
                        language.lblCall,
                        style: primaryTextStyle(size: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).onTap(
                  () {
                    launchCall(appConfigurationStore.helplineNumber);
                  },
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                ),
              if (appConfigurationStore.helplineNumber.isNotEmpty &&
                  appConfigurationStore.inquiryEmail.isNotEmpty)
                40.width,
              // Email button
              if (appConfigurationStore.inquiryEmail.isNotEmpty)
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        ic_message,
                        height: 24,
                        width: 24,
                        color: primaryColor,
                      ),
                      8.height,
                      Text(
                        language.email,
                        style: primaryTextStyle(size: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).onTap(
                  () {
                    launchMail(appConfigurationStore.inquiryEmail);
                  },
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                ),
            ],
          ),
          30.height,
          // About text
          Text(
            "From among the many styles of interior design, the rustic style is one that emphasises inspiration from nature, coupled with earthy, incomplete, rough and uneven beauty. Though it may appear heavy in its original sense, rustic designs have evolved over the years to include other home styles that lend warmth, comfort, and a sense of freshness to any space.\n\n"
            "Rustic decor can be incorporated into any part of your home, be it the living room, bedroom, balcony, kitchen and more. It is one of the most popular styles in modern homes today as it helps achieve a striking balance of authenticity and elegance.\n\n"
            "From among the many styles of interior design, the rustic style is one that emphasises inspiration from nature, coupled with earthy, incomplete, rough and uneven beauty. Though it may appear heavy in its original sense, rustic designs have evolved over the years to include other home styles that lend warmth, comfort, and a sense of freshness to any space.\n\n"
            "Rustic decor can be incorporated into any part of your home, be it the living room, bedroom, balcony, kitchen and more. It is one of the most popular styles in modern homes today as it helps achieve a striking balance of authenticity and elegance.",
            style: primaryTextStyle(size: 14, height: 1.5),
            textAlign: TextAlign.justify,
          ),
          16.height,
          // Copyright text
          Text(
            "Copyright © ${DateTime.now().year} ${getStringAsync(SITE_NAME).isNotEmpty ? getStringAsync(SITE_NAME) : APP_NAME} All rights reserved.",
            style: secondaryTextStyle(size: 12),
            textAlign: TextAlign.center,
          ),
          25.height,
        ],
      ),
    );
  }
}
