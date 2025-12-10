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
          Image.asset(about_us_page, fit: BoxFit.contain).center(),
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
            parseHtmlString(getStringAsync(SITE_DESCRIPTION)).isNotEmpty
                ? parseHtmlString(getStringAsync(SITE_DESCRIPTION))
                : "Welcome to ${APP_NAME}, your trusted partner for on-demand services. We connect you with skilled professionals who can help with a wide range of services including home repairs, cleaning, plumbing, electrical work, painting, and much more.\n\n"
                    "Our mission is to make your life easier by providing quick, reliable, and professional services at your doorstep. Whether you need urgent repairs or scheduled maintenance, our network of verified service providers is ready to assist you.\n\n"
                    "With ${APP_NAME}, booking a service is simple and convenient. Browse through our catalog of services, select your preferred time slot, and get connected with experienced professionals in your area. We ensure quality service delivery and customer satisfaction with every booking.\n\n"
                    "Thank you for choosing ${APP_NAME} for all your service needs. We are committed to providing you with the best experience and look forward to serving you.",
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
