import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/about_screen.dart';
import 'package:booking_system_flutter/screens/auth/edit_profile_screen.dart';
import 'package:booking_system_flutter/screens/auth/sign_in_screen.dart';
import 'package:booking_system_flutter/screens/blog/view/blog_list_screen.dart';
import 'package:booking_system_flutter/screens/dashboard/customer_rating_screen.dart';
import 'package:booking_system_flutter/screens/dashboard/dashboard_screen.dart';
import 'package:booking_system_flutter/screens/service/favourite_service_screen.dart';
import 'package:booking_system_flutter/screens/setting_screen.dart';
import 'package:booking_system_flutter/screens/wallet/user_wallet_balance_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/configs.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/extensions/num_extenstions.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/app_configuration.dart';
import '../../favourite_provider_screen.dart';
import '../component/wallet_history.dart';

class ProfileFragment extends StatefulWidget {
  @override
  ProfileFragmentState createState() => ProfileFragmentState();
}

class ProfileFragmentState extends State<ProfileFragment> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Future<num>? futureWalletBalance;

  @override
  void initState() {
    super.initState();
    init();
    afterBuildCreated(() {
      appStore.setLoading(false);
      setStatusBarColor(context.primaryColor);
    });
  }

  Future<void> init() async {
    if (appStore.isLoggedIn) {
      appStore.setUserWalletAmount();
      userDetailAPI();
    }
  }

  Future<void> userDetailAPI() async {
    await getUserDetail(appStore.userId, forceUpdate: false)
        .then((value) async {
      await saveUserData(value, forceSyncAppConfigurations: false);
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.profile,
        center: true,
        textColor: context.scaffoldBackgroundColor,
        textSize: APP_BAR_TEXT_SIZE,
        elevation: 0.0,
        color: context.primaryColor,
        showBack: false,
        actions: [
          IconButton(
            icon: ic_setting.iconImage(
                color: context.scaffoldBackgroundColor, size: 20),
            onPressed: () async {
              SettingScreen().launch(context);
            },
          ),
        ],
      ),
      body: Observer(
        builder: (BuildContext context) {
          return Stack(
            children: [
              AnimatedScrollView(
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                padding: const EdgeInsets.only(bottom: 32),
                crossAxisAlignment: CrossAxisAlignment.center,
                onSwipeRefresh: () async {
                  await removeKey(LAST_USER_DETAILS_SYNCED_TIME);
                  init();
                  setState(() {});
                  return 1.seconds.delay;
                },
                children: [
                  if (appStore.isLoggedIn)
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: radius(8),
                        color: Color(0xFFE8F3EC),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Profile Picture
                              CachedImageWidget(
                                url: appStore.userProfileImage,
                                height: 50,
                                width: 50,
                                circle: true,
                                fit: BoxFit.cover,
                              ),
                              8.width,
                              // Name and Email
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Marquee(
                                      child: Text(
                                        //appStore.userFullName,
                                        'Abdul Kader',
                                        style: boldTextStyle(
                                            size: 16,
                                            color: textPrimaryColorGlobal),
                                      ),
                                    ),
                                    Marquee(
                                      child: Text(
                                        //appStore.userEmail,
                                        'demouser@gmail.com',
                                        style: primaryTextStyle(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Edit Icon
                              ic_edit_square
                                  .iconImage(size: 20, color: context.iconColor)
                                  .paddingOnly(right: 8),
                            ],
                          ).onTap(() {
                            EditProfileScreen().launch(context);
                          }),
                        ],
                      ),
                    ).paddingOnly(left: 16, right: 16, top: 24),
                  //general settings
                  16.height,
                  Observer(
                    builder: (context) {
                      return SettingSection(
                        title:
                            Text(language.lblGENERAL, style: boldTextStyle()),
                        headingDecoration: boxDecorationDefault(
                          borderRadius: const BorderRadiusDirectional.vertical(
                              top: Radius.circular(0)),
                          color: Color(0xFFE8F3EC),
                        ),
                        divider: const Offstage(),
                        items: [
                          //wallet balance
                          //toggle after wallet balance feature is enabled
                          if (appStore.isLoggedIn &&
                              appConfigurationStore.isEnableUserWallet)
                            SettingItemWidget(
                              decoration: boxDecorationDefault(
                                  color: context.cardColor,
                                  borderRadius:
                                      const BorderRadiusDirectional.vertical(
                                          bottom: Radius.circular(0))),
                              leading: ic_wallet_cartoon.iconImage(
                                  color: context.iconColor,
                                  size: SETTING_ICON_SIZE),
                              title: language.walletBalance,
                              titleTextStyle: boldTextStyle(),
                              trailing: Observer(
                                builder: (context) => Text(
                                  appStore.userWalletAmount.toPriceFormat(),
                                  style: boldTextStyle(
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              onTap: () {
                                if (appConfigurationStore.isEnableUserWallet) {
                                  UserWalletBalanceScreen().launch(context);
                                }
                              },
                            ),
                          //wallet History
                          //toggle after wallet history feature is enabled
                          if (appStore.isLoggedIn &&
                              appConfigurationStore.isEnableUserWallet)
                            SettingItemWidget(
                              decoration: boxDecorationDefault(
                                  color: context.cardColor,
                                  borderRadius:
                                      const BorderRadiusDirectional.vertical(
                                          bottom: Radius.circular(0))),
                              leading: ic_wallet_history.iconImage(
                                  color: context.iconColor,
                                  size: SETTING_ICON_SIZE),
                              title: language.walletHistory,
                              titleTextStyle: boldTextStyle(),
                              trailing: trailing(context),
                              onTap: () {
                                const UserWalletHistoryScreen().launch(context);
                              },
                            ),
                          //bank details
                          //toggle after bank details feature is enabled
                          // if (appStore.isLoggedIn &&
                          //     rolesAndPermissionStore.bankList)
                          //   SettingItemWidget(
                          //     decoration: boxDecorationDefault(
                          //         color: context.cardColor,
                          //         borderRadius:
                          //             const BorderRadiusDirectional.vertical(
                          //                 bottom: Radius.circular(0))),
                          //     leading: ic_card.iconImage(
                          //         color: context.iconColor,
                          //         size: SETTING_ICON_SIZE),
                          //     title: language.lblBankDetails,
                          //     titleTextStyle: boldTextStyle(),
                          //     trailing: trailing(context),
                          //     onTap: () {
                          //       const BankDetails().launch(context);
                          //     },
                          //   ),

                          //favourite services
                          SettingItemWidget(
                            decoration: boxDecorationDefault(
                                color: context.cardColor,
                                borderRadius:
                                    const BorderRadiusDirectional.vertical(
                                        bottom: Radius.circular(0))),
                            leading: ic_heart.iconImage(
                                color: context.iconColor,
                                size: SETTING_ICON_SIZE),
                            title: language.lblFavorite,
                            titleTextStyle: boldTextStyle(),
                            trailing: trailing(context),
                            onTap: () {
                              doIfLoggedIn(context, () {
                                const FavouriteServiceScreen().launch(context);
                              });
                            },
                          ),
                          //favourite providers
                          SettingItemWidget(
                            decoration: boxDecorationDefault(
                                color: context.cardColor,
                                borderRadius:
                                    const BorderRadiusDirectional.vertical(
                                        bottom: Radius.circular(0))),
                            leading: ic_profile2.iconImage(
                                size: SETTING_ICON_SIZE,
                                color: context.iconColor),
                            title: language.favouriteProvider,
                            titleTextStyle: boldTextStyle(),
                            trailing: trailing(context),
                            onTap: () {
                              doIfLoggedIn(context, () {
                                const FavouriteProviderScreen().launch(context);
                              });
                            },
                          ),
                          // TODO: Uncomment this when shop favorite feature is enabled
                          // SettingItemWidget(
                          //   decoration: boxDecorationDefault(color: context.cardColor,borderRadius: BorderRadiusDirectional.vertical(bottom: Radius.circular(0))),
                          //   leading: Icon(Icons.store_outlined, size: SETTING_ICON_SIZE, color: context.iconColor),
                          //   title: language.lblFavoriteShops,
                          //   titleTextStyle: boldTextStyle(size: 14),
                          //   trailing: trailing,
                          //   padding: EdgeInsets.only(top: 20, left: 16, right: 16),
                          //   onTap: () {
                          //     doIfLoggedIn(context, () {
                          //       FavouriteShopScreen().launch(context);
                          //     });
                          //   },
                          // ),

                          //toggle after blog feature is enabled
                          //blog
                          SettingItemWidget(
                            decoration: boxDecorationDefault(
                                color: context.cardColor,
                                borderRadius:
                                    const BorderRadiusDirectional.vertical(
                                        bottom: Radius.circular(0))),
                            leading: ic_document.iconImage(
                                color: context.iconColor,
                                size: SETTING_ICON_SIZE),
                            title: language.blogs,
                            titleTextStyle: boldTextStyle(),
                            trailing: trailing(context),
                            onTap: () {
                              const BlogListScreen().launch(context);
                            },
                          ).visible(!rolesAndPermissionStore.blogList),

                          //rate us
                          SettingItemWidget(
                            decoration: boxDecorationDefault(
                                color: context.cardColor,
                                borderRadius:
                                    const BorderRadiusDirectional.vertical(
                                        bottom: Radius.circular(0))),
                            leading: ic_star.iconImage(
                                color: context.iconColor,
                                size: SETTING_ICON_SIZE),
                            title: language.rateUs,
                            titleTextStyle: boldTextStyle(),
                            trailing: trailing(context),
                            onTap: () async {
                              if (isAndroid) {
                                if (getStringAsync(CUSTOMER_PLAY_STORE_URL)
                                    .isNotEmpty) {
                                  commonLaunchUrl(
                                      getStringAsync(CUSTOMER_PLAY_STORE_URL),
                                      launchMode:
                                          LaunchMode.externalApplication);
                                } else {
                                  commonLaunchUrl(
                                      '${getSocialMediaLink(LinkProvider.PLAY_STORE)}${await getPackageName()}',
                                      launchMode:
                                          LaunchMode.externalApplication);
                                }
                              } else if (isIOS) {
                                if (getStringAsync(CUSTOMER_APP_STORE_URL)
                                    .isNotEmpty) {
                                  commonLaunchUrl(
                                      getStringAsync(CUSTOMER_APP_STORE_URL),
                                      launchMode:
                                          LaunchMode.externalApplication);
                                } else {
                                  commonLaunchUrl(IOS_LINK_FOR_USER,
                                      launchMode:
                                          LaunchMode.externalApplication);
                                }
                              }
                            },
                          ),

                          //my reviews
                          SettingItemWidget(
                            decoration: boxDecorationDefault(
                                color: context.cardColor,
                                borderRadius:
                                    const BorderRadiusDirectional.vertical(
                                        bottom: Radius.circular(0))),
                            leading: ic_my_review.iconImage(
                                color: context.iconColor,
                                size: SETTING_ICON_SIZE),
                            title: language.myReviews,
                            titleTextStyle: boldTextStyle(),
                            trailing: trailing(context),
                            onTap: () async {
                              doIfLoggedIn(context, () {
                                CustomerRatingScreen().launch(context);
                              });
                            },
                          ),

                          //toggle after help desk feature is enabled
                          // SettingItemWidget(
                          //   decoration: boxDecorationDefault(
                          //       color: context.cardColor,
                          //       borderRadius:
                          //           const BorderRadiusDirectional.vertical(
                          //               bottom: Radius.circular(16))),
                          //   title: '',
                          //   titleTextStyle: boldTextStyle(),
                          //   highlightColor: Colors.transparent,
                          //   splashColor: Colors.transparent,
                          //   onTap: () {},
                          // ),
                        ],
                      );
                    },
                  ),
                  SettingSection(
                    title: Text(language.lblAboutApp.toUpperCase(),
                        style: boldTextStyle()),
                    headingDecoration: boxDecorationDefault(
                      color: Color(0xFFE8F3EC),
                      borderRadius: const BorderRadiusDirectional.vertical(
                          top: Radius.circular(0)),
                    ),
                    divider: const Offstage(),
                    items: [
                      8.height,
                      SettingItemWidget(
                        decoration: boxDecorationDefault(
                            color: context.cardColor,
                            borderRadius:
                                const BorderRadiusDirectional.vertical(
                                    bottom: Radius.circular(0))),
                        leading: ic_about_us.iconImage(
                            color: context.iconColor, size: SETTING_ICON_SIZE),
                        trailing: trailing(context),
                        title: language.lblAboutApp,
                        titleTextStyle: boldTextStyle(),
                        onTap: () {
                          AboutScreen().launch(context);
                        }, //un commment visible after about us feature is enabled
                      ), //.visible(rolesAndPermissionStore.aboutUs),
                      SettingItemWidget(
                        decoration: boxDecorationDefault(
                            color: context.cardColor,
                            borderRadius:
                                const BorderRadiusDirectional.vertical(
                                    bottom: Radius.circular(0))),
                        leading: ic_shield_done.iconImage(
                            color: context.iconColor, size: SETTING_ICON_SIZE),
                        trailing: trailing(context),
                        title: language.privacyPolicy,
                        titleTextStyle: boldTextStyle(),
                        onTap: () {
                          checkIfLink(
                              context, appConfigurationStore.privacyPolicy,
                              title: language.privacyPolicy);
                        }, //un commment visible after privacy policy feature is enabled
                      ), //.visible(rolesAndPermissionStore.privacyPolicy),
                      SettingItemWidget(
                        decoration: boxDecorationDefault(
                            color: context.cardColor,
                            borderRadius:
                                const BorderRadiusDirectional.vertical(
                                    bottom: Radius.circular(0))),
                        leading: ic_document.iconImage(
                            color: context.iconColor, size: SETTING_ICON_SIZE),
                        trailing: trailing(context),
                        title: language.termsCondition,
                        titleTextStyle: boldTextStyle(),
                        onTap: () {
                          checkIfLink(
                              context, appConfigurationStore.termConditions,
                              title: language.termsCondition);
                        }, //un commment visible after terms condition feature is enabled
                      ), //.visible(rolesAndPermissionStore.termCondition),
                      SettingItemWidget(
                        decoration: boxDecorationDefault(
                            color: context.cardColor,
                            borderRadius:
                                const BorderRadiusDirectional.vertical(
                                    bottom: Radius.circular(0))),
                        leading: ic_refund.iconImage(
                            color: context.iconColor, size: SETTING_ICON_SIZE),
                        trailing: trailing(context),
                        title: language.refundPolicy,
                        titleTextStyle: boldTextStyle(),
                        onTap: () {
                          checkIfLink(
                              context, appConfigurationStore.refundPolicy,
                              title: language.refundPolicy);
                        }, //un commment visible after refund policy feature is enabled
                      ), //.visible(
                      //rolesAndPermissionStore.refundAndCancellationPolicy),

                      SettingItemWidget(
                        decoration: boxDecorationDefault(
                            color: context.cardColor,
                            borderRadius:
                                const BorderRadiusDirectional.vertical(
                                    bottom: Radius.circular(0))),
                        leading: ic_helpAndSupport.iconImage(
                            color: context.iconColor, size: SETTING_ICON_SIZE),
                        trailing: trailing(context),
                        title: language.helpSupport,
                        titleTextStyle: boldTextStyle(),
                        onTap: () {
                          if (appConfigurationStore.helpAndSupport.isNotEmpty) {
                            checkIfLink(
                                context, appConfigurationStore.helpAndSupport,
                                title: language.helpSupport);
                          } else {
                            checkIfLink(context,
                                appConfigurationStore.inquiryEmail.validate(),
                                title: language.helpSupport);
                          }
                        },
                      ),
                      //help desk

                      // SettingItemWidget(
                      //   decoration: boxDecorationDefault(
                      //       color: context.cardColor,
                      //       borderRadius:
                      //           const BorderRadiusDirectional.vertical(
                      //               bottom: Radius.circular(0))),
                      //   leading: ic_help_desk.iconImage(
                      //       color: context.iconColor, size: SETTING_ICON_SIZE),
                      //   title: language.helpDesk,
                      //   titleTextStyle: boldTextStyle(),
                      //   trailing: trailing(context),
                      //   highlightColor: Colors.transparent,
                      //   splashColor: Colors.transparent,
                      //   onTap: () {
                      //     HelpDeskListScreen().launch(context);
                      //   },
                      // ),

                      //toggle after help and support feature is enabled
                      if (appConfigurationStore.helplineNumber.isNotEmpty)
                        SettingItemWidget(
                          decoration: !appStore.isLoggedIn
                              ? boxDecorationDefault(
                                  color: context.cardColor,
                                  borderRadius:
                                      const BorderRadiusDirectional.vertical(
                                          bottom: Radius.circular(0)))
                              : boxDecorationDefault(
                                  color: context.cardColor,
                                  borderRadius:
                                      const BorderRadiusDirectional.vertical(
                                          bottom: Radius.circular(16))),
                          leading: ic_calling.iconImage(
                              color: context.iconColor,
                              size: SETTING_ICON_SIZE),
                          trailing: trailing(context),
                          title: language.lblHelplineNumber,
                          titleTextStyle: boldTextStyle(),
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            launchCall(appConfigurationStore.helplineNumber
                                .validate());
                          },
                        ),

                      SettingItemWidget(
                        decoration: !appStore.isLoggedIn
                            ? boxDecorationDefault(
                                color: context.cardColor,
                                borderRadius:
                                    const BorderRadiusDirectional.vertical(
                                        bottom: Radius.circular(16)))
                            : boxDecorationDefault(color: context.cardColor),
                        leading: Icon(MaterialCommunityIcons.logout,
                            color: context.iconColor, size: SETTING_ICON_SIZE),
                        trailing: trailing(context),
                        title: language.signIn,
                        titleTextStyle: boldTextStyle(),
                        onTap: () {
                          const SignInScreen().launch(context);
                        },
                      ).visible(!appStore.isLoggedIn),

                      SettingItemWidget(
                        decoration: boxDecorationDefault(
                            color: context.cardColor,
                            borderRadius:
                                const BorderRadiusDirectional.vertical(
                                    bottom: Radius.circular(16))),
                        leading: ic_delete_account.iconImage(
                            color: context.iconColor, size: SETTING_ICON_SIZE),
                        paddingBeforeTrailing: 4,
                        trailing: trailing(context),
                        title: language.lblDeleteAccount,
                        titleTextStyle: boldTextStyle(),
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          showConfirmDialogCustom(
                            context,
                            height: 80,
                            width: 290,
                            shape: dialogShape(16),
                            title: language.lblDeleteAccountQuestion,
                            subTitle: language.lblDeleteAccountConformation,
                            negativeText: language.lblCancel,
                            positiveText: language.lblDelete,
                            primaryColor: context.primaryColor,
                            negativeTextColor: context.primaryColor,
                            customCenterWidget: Image.asset(ic_warning,
                                height: 70, width: 70, fit: BoxFit.cover),
                            onAccept: (_) {
                              ifNotTester(() {
                                appStore.setLoading(true);

                                deleteAccountCompletely().then((value) async {
                                  try {
                                    await userService
                                        .removeDocument(appStore.uid);
                                    await userService.deleteUser();
                                  } catch (e) {
                                    print(e);
                                  }

                                  appStore.setLoading(false);

                                  await clearPreferences();
                                  toast(value.message);

                                  push(DashboardScreen(),
                                      isNewTask: true,
                                      pageRouteAnimation:
                                          PageRouteAnimation.Fade);
                                }).catchError((e) {
                                  appStore.setLoading(false);
                                  toast(e.toString());
                                });
                              });
                            },
                            dialogType: DialogType.CONFIRMATION,
                          );
                        },
                        //un commment visible after delete account feature is enabled
                      ), //.visible(appStore.isLoggedIn),
                      80.height,
                      //toggle after logout feature is enabled
                      if (appStore.isLoggedIn)
                        GestureDetector(
                          onTap: () {
                            showConfirmDialogCustom(
                              context,
                              height: 80,
                              width: 290,
                              shape: dialogShape(16),
                              title: language.logout,
                              subTitle: language.lblLogoutConfirmation,
                              negativeText: language.lblNo,
                              positiveText: language.lblYes,
                              primaryColor: context.primaryColor,
                              negativeTextColor: context.primaryColor,
                              customCenterWidget: Image.asset(ic_warning,
                                  height: 70, width: 70, fit: BoxFit.cover),
                              onAccept: (_) async {
                                if (await isNetworkAvailable()) {
                                  appStore.setLoading(true);

                                  logoutApi().then((value) async {
                                    //
                                  }).catchError((e) {
                                    log(e.toString());
                                  });

                                  await clearPreferences();
                                  if (cachedWalletHistoryList != null &&
                                      cachedWalletHistoryList!.isNotEmpty)
                                    cachedWalletHistoryList!.clear();

                                  appStore.setLoading(false);
                                  toast(
                                      "Your Account has logged out successfully");
                                  push(DashboardScreen(),
                                      isNewTask: true,
                                      pageRouteAnimation:
                                          PageRouteAnimation.Fade);
                                } else {
                                  toast(errorInternetNotAvailable);
                                }
                              },
                              dialogType: DialogType.CONFIRMATION,
                            );
                          },
                          child: Text(language.logout,
                              style:
                                  boldTextStyle(color: primaryColor, size: 16)),
                        ).center(),
                      //32.height,
                      // SnapHelperWidget<PackageInfoData>(
                      //   future: getPackageInfo(),
                      //   onSuccess: (data) {
                      //     return TextButton(
                      //       child: VersionInfoWidget(
                      //           prefixText: 'v',
                      //           textStyle: secondaryTextStyle()),
                      //       onPressed: () {
                      //         showAboutDialog(
                      //           context: context,
                      //           applicationName: APP_NAME,
                      //           applicationVersion: data.versionName,
                      //           applicationIcon:
                      //               Image.asset(appLogo, height: 50),
                      //         );
                      //       },
                      //     ).center();
                      //   },
                      // ),
                    ],
                  ), //.visible(appStore.isLoggedIn),
                  30.height.visible(!appStore.isLoggedIn),
                ],
              ),
              Observer(
                  builder: (context) =>
                      LoaderWidget().visible(appStore.isLoading)),
            ],
          );
        },
      ),
    );
  }
}
