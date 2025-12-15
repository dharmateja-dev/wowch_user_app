import 'package:booking_system_flutter/component/image_border_component.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/screens/auth/sign_in_screen.dart';
import 'package:booking_system_flutter/screens/category/category_screen.dart';
import 'package:booking_system_flutter/screens/chat/chat_list_screen.dart';
import 'package:booking_system_flutter/screens/dashboard/fragment/booking_fragment.dart';
import 'package:booking_system_flutter/screens/dashboard/fragment/dashboard_fragment.dart';
import 'package:booking_system_flutter/screens/dashboard/fragment/profile_fragment.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/voice_search_component.dart';
import '../../utils/app_configuration.dart';
import '../newDashboard/dashboard_1/dashboard_fragment_1.dart';
import '../newDashboard/dashboard_2/dashboard_fragment_2.dart';
import '../newDashboard/dashboard_3/dashboard_fragment_3.dart';
import '../newDashboard/dashboard_4/dashboard_fragment_4.dart';

class DashboardScreen extends StatefulWidget {
  final bool? redirectToBooking;

  DashboardScreen({this.redirectToBooking});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;
  bool isInterNetConnect = true;

  @override
  void initState() {
    super.initState();
    if (widget.redirectToBooking.validate(value: false)) {
      currentIndex = 1;
    }

    afterBuildCreated(() async {
      /// Changes System theme when changed
      if (getIntAsync(THEME_MODE_INDEX) == THEME_MODE_SYSTEM) {
        appStore.setDarkMode(context.platformBrightness() == Brightness.dark);
      }

      View.of(context).platformDispatcher.onPlatformBrightnessChanged =
          () async {
        if (getIntAsync(THEME_MODE_INDEX) == THEME_MODE_SYSTEM) {
          appStore.setDarkMode(
              MediaQuery.of(context).platformBrightness == Brightness.light);
        }
      };
    });

    /// Handle Firebase Notification click and redirect to that Service & BookDetail screen
    LiveStream().on(LIVESTREAM_FIREBASE, (value) {
      if (value == 3) {
        currentIndex = 3;
        setState(() {});
      }
    });

    // Firebase.initializeApp().then((value) {
    //   //When the app is in the background and opened directly from the push notification.
    //   FirebaseMessaging.onMessageOpenedApp.listen((message) async {
    //     //Handle onClick Notification
    //     log("data 1 ==> ${message.data}");
    //     handleNotificationClick(message);
    //   });
    //
    //   FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    //     //Handle onClick Notification
    //     if (message != null) {
    //       log("data 2 ==> ${message.data}");
    //       handleNotificationClick(message);
    //     }
    //   });
    // }).catchError(onError);

    init();
  }

  /*Future<void> checkAndShowCustomForceUpdateDialog(BuildContext context) async {
    final result = await PlayxVersionUpdate.checkVersion(
      options:  PlayxUpdateOptions(
        androidPackageName: PackageInfoData().packageName,
        iosBundleId:PackageInfoData().packageName ,
        minVersion: '11.14.4',
      ),
    );

    result.when(
      success: (info) {
        showNewUpdateDialog(context, currentAppVersionCode: 99);
      },
      error: (e) {
        log('Version check failed: ${e.message}');
      },
    );
  }*/

  void init() async {
    await 3.seconds.delay;
    if (getIntAsync(FORCE_UPDATE_USER_APP).getBoolInt()) {
      showForceUpdateDialog(context);
    } /* else if (getBoolAsync(AUTO_UPDATE, defaultValue:false)) {
      checkAndShowCustomForceUpdateDialog(context);
    }*/
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    LiveStream().dispose(LIVESTREAM_FIREBASE);
  }

  @override
  Widget build(BuildContext context) {
    return DoublePressBackWidget(
      message: language.lblBackPressMsg,
      child: Scaffold(
        body: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 500),
          child: [
            Observer(
              builder: (context) {
                if (appConfigurationStore.userDashboardType == DASHBOARD_1) {
                  return DashboardFragment1();
                } else if (appConfigurationStore.userDashboardType ==
                    DASHBOARD_2) {
                  return DashboardFragment2();
                } else if (appConfigurationStore.userDashboardType ==
                    DASHBOARD_3) {
                  return DashboardFragment3();
                } else if (appConfigurationStore.userDashboardType ==
                    DASHBOARD_4) {
                  return DashboardFragment4();
                } else {
                  return DashboardFragment();
                }
              },
            ),
            Observer(
                builder: (context) => appStore.isLoggedIn
                    ? BookingFragment()
                    : const SignInScreen(isFromDashboard: true)),
            CategoryScreen(),
            Observer(
                builder: (context) => appStore.isLoggedIn
                    ? ChatListScreen()
                    : const SignInScreen(isFromDashboard: true)),
            ProfileFragment(),
          ][currentIndex],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: Colors.white,
              indicatorColor: Colors.transparent,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return context.primaryTextStyle(
                      size: 11, color: context.primaryColor);
                }
                return context.primaryTextStyle(
                    size: 11, color: appTextSecondaryColor);
              }),
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: NavigationBar(
              height: 70,
              selectedIndex: currentIndex,
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined,
                      color: appTextSecondaryColor, size: 26),
                  selectedIcon:
                      Icon(Icons.home, color: context.primaryColor, size: 26),
                  label: language.home,
                ),
                NavigationDestination(
                  icon: ic_ticket.iconImage(
                      color: appTextSecondaryColor, context: context),
                  selectedIcon: ic_ticket.iconImage(
                      color: context.primaryColor, context: context),
                  label: language.booking,
                ),
                NavigationDestination(
                  icon: Icon(Icons.category_outlined,
                      color: appTextSecondaryColor, size: 26),
                  selectedIcon: Icon(Icons.category,
                      color: context.primaryColor, size: 26),
                  label: language.category,
                ),
                NavigationDestination(
                  icon: Icon(Icons.mail_outline,
                      color: appTextSecondaryColor, size: 26),
                  selectedIcon:
                      Icon(Icons.mail, color: context.primaryColor, size: 26),
                  label: language.lblChat,
                ),
                Observer(
                  builder: (context) {
                    return NavigationDestination(
                      icon: (appStore.isLoggedIn &&
                              appStore.userProfileImage.isNotEmpty)
                          ? IgnorePointer(
                              ignoring: true,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.grey.shade300, width: 1),
                                ),
                                child: ClipOval(
                                  child: ImageBorder(
                                      src: appStore.userProfileImage,
                                      height: 26),
                                ),
                              ))
                          : Icon(Icons.person_outline,
                              color: appTextSecondaryColor, size: 26),
                      selectedIcon: (appStore.isLoggedIn &&
                              appStore.userProfileImage.isNotEmpty)
                          ? IgnorePointer(
                              ignoring: true,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                ),
                                child: ClipOval(
                                  child: ImageBorder(
                                      src: appStore.userProfileImage,
                                      height: 26),
                                ),
                              ))
                          : Icon(Icons.person,
                              color: context.primaryColor, size: 26),
                      label: language.profile,
                    );
                  },
                ),
              ],
              onDestinationSelected: (index) {
                currentIndex = index;
                setState(() {});
              },
            ),
          ),
        ),
        bottomSheet: Observer(builder: (context) {
          return VoiceSearchComponent().visible(appStore.isSpeechActivated);
        }),
      ),
    );
  }
}
