import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/component/theme_selection_dialog.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/screens/language_screen.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/firebase_messaging_utils.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import 'auth/change_password_screen.dart';

class SettingScreen extends StatefulWidget {
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.lblAppSetting,
      child: AnimatedScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        listAnimationType: ListAnimationType.FadeIn,
        fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
        children: [
          if (isLoginTypeUser)
            SettingItemWidget(
              leading: ic_lock.iconImage(
                  size: SETTING_ICON_SIZE, color: context.iconColor),
              title: language.changePassword,
              trailing: trailing(context),
              titleTextStyle: boldTextStyle(),
              onTap: () {
                doIfLoggedIn(context, () {
                  ChangePasswordScreen().launch(context);
                });
              },
            ),
          SettingItemWidget(
            leading: ic_language
                .iconImage(size: 17, color: context.iconColor)
                .paddingOnly(left: 2),
            title: language.language,
            trailing: trailing(context),
            titleTextStyle: boldTextStyle(),
            onTap: () {
              LanguagesScreen().launch(context).then((value) {
                setState(() {});
              });
            },
          ),
          SettingItemWidget(
            leading: ic_dark_mode.iconImage(size: 22, color: context.iconColor),
            title: language.appTheme,
            paddingAfterLeading: 12,
            trailing: trailing(context),
            titleTextStyle: boldTextStyle(),
            onTap: () async {
              await showInDialog(
                context,
                builder: (context) => ThemeSelectionDaiLog(),
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
          SettingItemWidget(
            leading: ic_slider_status.iconImage(
                size: SETTING_ICON_SIZE, color: context.iconColor),
            title: language.lblAutoSliderStatus,
            titleTextStyle: boldTextStyle(),
            trailing: Transform.scale(
              scale: 0.8,
              child: Switch.adaptive(
                value: getBoolAsync(AUTO_SLIDER_STATUS, defaultValue: true),
                onChanged: (v) {
                  setValue(AUTO_SLIDER_STATUS, v);
                  setState(() {});
                },
              ).withHeight(18),
            ),
          ),
          SettingItemWidget(
            leading: ic_check_update.iconImage(
                size: SETTING_ICON_SIZE, color: context.iconColor),
            title: language.lblOptionalUpdateNotify,
            titleTextStyle: boldTextStyle(),
            trailing: Transform.scale(
              scale: 0.8,
              child: Switch.adaptive(
                value: getBoolAsync(UPDATE_NOTIFY, defaultValue: true),
                onChanged: (v) {
                  setValue(UPDATE_NOTIFY, v);
                  setState(() {});
                },
              ).withHeight(18),
            ),
          ),
          // SettingItemWidget(
          //   leading: ic_check_update.iconImage(size: SETTING_ICON_SIZE),
          //   title: 'Auto Update',
          //   titleTextStyle: boldTextStyle(size: 12),
          //   trailing: Transform.scale(
          //     scale: 0.8,
          //     child: Switch.adaptive(
          //       value: getBoolAsync(AUTO_UPDATE, defaultValue: false),
          //       onChanged: getIntAsync(FORCE_UPDATE_USER_APP).getBoolInt()
          //           ? null
          //           : (v) {
          //               setValue(AUTO_UPDATE, v);
          //               setState(() {});
          //             },
          //     ).withHeight(16),
          //   ),
          // ),
          if (appStore.isLoggedIn)
            SettingItemWidget(
              leading: ic_notification.iconImage(
                  size: SETTING_ICON_SIZE, color: context.iconColor),
              title: language.pushNotification,
              titleTextStyle: boldTextStyle(),
              trailing: Transform.scale(
                scale: 0.8,
                child: Observer(
                  builder: (context) {
                    return Switch.adaptive(
                      value: FirebaseAuth.instance.currentUser != null &&
                          appStore.isSubscribedForPushNotification,
                      onChanged: (v) async {
                        if (appStore.isLoading) return;
                        appStore.setLoading(true);

                        if (v) {
                          await subscribeToFirebaseTopic();
                        } else {
                          await unsubscribeFirebaseTopic(appStore.userId);
                        }
                        appStore.setLoading(false);
                        setState(() {});
                      },
                    ).withHeight(18);
                  },
                ),
              ),
            ),
          // SnapHelperWidget<bool>(
          //   future: isAndroid12Above(),
          //   onSuccess: (data) {
          //     if (data) {
          //       return SettingItemWidget(
          //         leading: ic_android_12.iconImage(
          //             size: SETTING_ICON_SIZE, color: context.iconColor),
          //         title: language.lblMaterialTheme,
          //         titleTextStyle: boldTextStyle(),
          //         trailing: Transform.scale(
          //           scale: 0.8,
          //           child: Switch.adaptive(
          //             value: appStore.useMaterialYouTheme,
          //             onChanged: (v) {
          //               showConfirmDialogCustom(
          //                 context,
          //                 onAccept: (_) {
          //                   appStore.setUseMaterialYouTheme(v.validate());

          //                   RestartAppWidget.init(context);
          //                 },
          //                 title: language.lblAndroid12Support,
          //                 primaryColor: context.primaryColor,
          //                 positiveText: language.lblYes,
          //                 negativeText: language.lblCancel,
          //               );
          //             },
          //           ).withHeight(18),
          //         ),
          //       );
          //     }
          //     return const Offstage();
          //   },
          // ),
        ],
      ),
    );
  }
}
