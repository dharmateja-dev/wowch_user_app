import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/base_scaffold_body.dart';
//import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/screens/auth/forgot_password_screen.dart';
import 'package:booking_system_flutter/screens/auth/otp_login_screen.dart';
import 'package:booking_system_flutter/screens/auth/sign_up_screen.dart';
import 'package:booking_system_flutter/screens/dashboard/dashboard_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/configs.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../network/rest_apis.dart';
import '../../utils/app_configuration.dart';

class SignInScreen extends StatefulWidget {
  final bool? isFromDashboard;
  final bool? isFromServiceBooking;
  final bool returnExpected;

  const SignInScreen(
      {this.isFromDashboard,
      this.isFromServiceBooking,
      this.returnExpected = false});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  bool isRemember = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    isRemember = getBoolAsync(IS_REMEMBERED);
    if (isRemember) {
      emailCont.text = getStringAsync(USER_EMAIL);
      passwordCont.text = getStringAsync(USER_PASSWORD);
    }

    /// For Demo Purpose
    if (await isIqonicProduct) {
      emailCont.text = DEFAULT_EMAIL;
      passwordCont.text = DEFAULT_PASS;
    }

    if (demoModeStore.isDemoMode) {
      emailCont.text = 'demouser@gmail.com';
      passwordCont.text = '12345678';
    }
  }

  //region Methods

  void _handleLogin() {
    hideKeyboard(context);
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      _handleLoginUsers();
    }
  }

  void _handleLoginUsers() async {
    hideKeyboard(context);
    Map<String, dynamic> request = {
      'email': emailCont.text.trim(),
      'password': passwordCont.text.trim(),
    };

    appStore.setLoading(true);

    // Demo Mode logic
    if (demoModeStore.isDemoMode) {
      // Simulate network delay
      await Future.delayed(Duration(seconds: 1));

      // Allow any login or check against default credentials
      // For now, we allow any valid-looking login in demo mode
      demoModeStore.createDemoUser(
        firstName: 'Demo',
        lastName: 'User',
        email: emailCont.text.trim(),
        password: passwordCont.text.trim(),
      );

      await setValue(USER_PASSWORD, passwordCont.text);
      await setValue(IS_REMEMBERED, isRemember);
      await appStore.setLoginType(LOGIN_TYPE_USER);

      // Mock saving user data to preferences (using demo user)
      if (demoModeStore.demoUser != null) {
        await saveUserData(demoModeStore.demoUser!);
      }

      appStore.setLoading(false);
      onLoginSuccessRedirection();
      return;
    }

    try {
      final loginResponse = await loginUser(request, isSocialLogin: false);

      await saveUserData(loginResponse.userData!);

      await setValue(USER_PASSWORD, passwordCont.text);
      await setValue(IS_REMEMBERED, isRemember);
      await appStore.setLoginType(LOGIN_TYPE_USER);

      authService.verifyFirebaseUser();
      TextInput.finishAutofillContext();

      onLoginSuccessRedirection();
    } catch (e) {
      appStore.setLoading(false);
      toast(e.toString());
    }
  }

  void googleSignIn() async {
    if (!appStore.isLoading) {
      appStore.setLoading(true);
      await authService.signInWithGoogle(context).then((googleUser) async {
        String firstName = '';
        String lastName = '';
        if (googleUser.displayName.validate().split(' ').length >= 1)
          firstName = googleUser.displayName.splitBefore(' ');
        if (googleUser.displayName.validate().split(' ').length >= 2)
          lastName = googleUser.displayName.splitAfter(' ');

        Map<String, dynamic> request = {
          'first_name': firstName,
          'last_name': lastName,
          'email': googleUser.email,
          'username': googleUser.email
              .splitBefore('@')
              .replaceAll('.', '')
              .toLowerCase(),
          // 'password': passwordCont.text.trim(),
          'social_image': googleUser.photoURL,
          'login_type': LOGIN_TYPE_GOOGLE,
        };
        var loginResponse = await loginUser(request, isSocialLogin: true);

        loginResponse.userData!.profileImage = googleUser.photoURL.validate();

        await saveUserData(loginResponse.userData!);
        appStore.setLoginType(LOGIN_TYPE_GOOGLE);

        authService.verifyFirebaseUser();

        onLoginSuccessRedirection();
        appStore.setLoading(false);
      }).catchError((e) {
        appStore.setLoading(false);
        log(e.toString());
        toast(e.toString());
      });
    }
  }

  void appleSign() async {
    if (!appStore.isLoading) {
      appStore.setLoading(true);

      await authService.appleSignIn().then((req) async {
        // Ensure first_name and last_name are not empty or null
        String email = req['email'] ??
            'unknown_${DateTime.now().millisecondsSinceEpoch}@apple.com';
        String firstName = req['first_name']?.toString().trim() ?? '';
        String lastName = req['last_name']?.toString().trim() ?? '';

        // Fallback if names are not available
        if (firstName.isEmpty || lastName.isEmpty) {
          final parts = email.split('@').first.split('.');
          firstName = parts.first.capitalizeFirstLetter();
          lastName =
              parts.length > 1 ? parts[1].capitalizeFirstLetter() : 'User';
        }

        req['first_name'] = firstName;
        req['last_name'] = lastName;

        await loginUser(req, isSocialLogin: true).then((value) async {
          await saveUserData(value.userData!);
          appStore.setLoginType(LOGIN_TYPE_APPLE);

          appStore.setLoading(false);
          authService.verifyFirebaseUser();

          onLoginSuccessRedirection();
        }).catchError((e) {
          appStore.setLoading(false);
          log(e.toString());
          throw e;
        });
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    }
  }

  void otpSignIn() async {
    hideKeyboard(context);

    const OTPLoginScreen().launch(context);
  }

  void onLoginSuccessRedirection() {
    afterBuildCreated(() {
      appStore.setLoading(false);
      toast("Your Account signed in successfully.");
      if (widget.isFromServiceBooking.validate() ||
          widget.isFromDashboard.validate() ||
          widget.returnExpected.validate()) {
        if (widget.isFromDashboard.validate()) {
          push(DashboardScreen(redirectToBooking: true),
              isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
        } else {
          finish(context, true);
        }
      } else {
        DashboardScreen().launch(context,
            isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
      }
    });
  }

//endregion

//region Widgets
//completed
  Widget _buildTopWidget() {
    return Container(
      child: Column(
        children: [
          Text("${language.lblLoginTitle}!",
                  style: context.boldTextStyle(size: 24))
              .center(),
          16.height,
          Text(language.lblLoginSubTitle,
                  style: context.primaryTextStyle(
                    size: 16,
                  ),
                  textAlign: TextAlign.center)
              .center()
              .paddingSymmetric(horizontal: 8),
          32.height,
        ],
      ),
    );
  }

  Widget _buildRememberWidget() {
    return Column(
      children: [
        8.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: isRemember,
                  onChanged: (value) async {
                    await setValue(IS_REMEMBERED, isRemember);
                    isRemember = !isRemember;
                    setState(() {});
                  },
                  activeColor: context.primary,
                  checkColor: context.onPrimary,
                  side: BorderSide(color: context.primary, width: 2.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  language.rememberMe,
                  style: context.primaryTextStyle(),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                showInDialog(
                  context,
                  contentPadding: EdgeInsets.zero,
                  dialogAnimation: DialogAnimation.SLIDE_TOP_BOTTOM,
                  backgroundColor: context.dialogBackgroundColor,
                  builder: (_) => ForgotPasswordScreen(),
                );
              },
              child: Text(
                language.forgotPassword,
                style: context.boldTextStyle(
                  color: context.primary,
                ),
                textAlign: TextAlign.right,
              ),
            ).flexible(),
          ],
        ),
        24.height,
        AppButton(
          text: language.signIn,
          color: context.primary,
          textColor: context.onPrimary,
          width: context.width() - context.navigationBarHeight,
          onTap: () {
            _handleLogin();
          },
        ),
        32.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(language.doNotHaveAccount, style: context.primaryTextStyle()),
            8.width,
            GestureDetector(
              onTap: () {
                hideKeyboard(context);
                SignUpScreen().launch(context);
              },
              child: Text(
                language.signUp,
                style: context.boldTextStyle(
                  color: context.primary,
                ),
              ),
            ),
          ],
        ),
        16.height,
        GestureDetector(
          onTap: () {
            if (isAndroid) {
              if (getStringAsync(PROVIDER_PLAY_STORE_URL).isNotEmpty) {
                launchUrl(Uri.parse(getStringAsync(PROVIDER_PLAY_STORE_URL)),
                    mode: LaunchMode.externalApplication);
              } else {
                launchUrl(
                    Uri.parse(
                        '${getSocialMediaLink(LinkProvider.PLAY_STORE)}$PROVIDER_PACKAGE_NAME'),
                    mode: LaunchMode.externalApplication);
              }
            } else if (isIOS) {
              if (getStringAsync(PROVIDER_APPSTORE_URL).isNotEmpty) {
                commonLaunchUrl(getStringAsync(PROVIDER_APPSTORE_URL));
              } else {
                commonLaunchUrl(IOS_LINK_FOR_PARTNER);
              }
            }
          },
          child: Text(language.lblRegisterAsPartner,
              style: context.boldTextStyle(color: primaryColor)),
        )
      ],
    );
  }

  Widget _buildSocialWidget() {
    List<Widget> socialButtons = [];

    // OTP Login Button
    socialButtons.add(
      GestureDetector(
        onTap: otpSignIn,
        child: Container(
          padding: const EdgeInsets.all(10),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xffffffff),
            border: Border.all(color: context.mainBorderColor, width: 2.0),
          ),
          child: Icon(Icons.phone, size: 20, color: primaryColor),
        ),
      ),
    );

    // Apple Login Button (iOS only)
    //if (isIOS) {
    socialButtons.add(
      GestureDetector(
        onTap: appleSign,
        child: Container(
          padding: const EdgeInsets.all(10),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xffffffff),
            border: Border.all(color: grey300Color, width: 2.0),
          ),
          child: Icon(
            Icons.apple,
            color: Color(0xff000000),
            size: 20,
          ),
        ),
      ),
    );
    //}

    // Google Login Button
    socialButtons.add(
      GestureDetector(
        onTap: googleSignIn,
        child: Container(
          padding: const EdgeInsets.all(10),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xffffffff),
            border: Border.all(color: grey300Color, width: 2.0),
          ),
          child: CachedNetworkImage(
            imageUrl:
                "https://res.cloudinary.com/daqvdhmw8/image/upload/v1753412480/google_gy8mpr.png",
            height: 20,
            width: 20,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );

    return Column(
      children: [
        40.height,
        Row(
          children: [
            Divider(color: context.dividerColor, thickness: 1).expand(),
            16.width,
            Text(language.lblOrContinueWith,
                style: context.primaryTextStyle(
                  size: 14,
                )),
            16.width,
            Divider(color: context.dividerColor, thickness: 1).expand(),
          ],
        ),
        24.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: socialButtons
              .map((button) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: button,
                  ))
              .toList(),
        ),
      ],
    );
  }

//endregion

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    if (widget.isFromServiceBooking.validate()) {
      setStatusBarColor(Colors.transparent,
          statusBarIconBrightness: Brightness.dark);
    } else if (widget.isFromDashboard.validate()) {
      setStatusBarColor(Colors.transparent,
          statusBarIconBrightness: Brightness.light);
    } else {
      setStatusBarColor(primaryColor,
          statusBarIconBrightness: Brightness.light);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: Scaffold(
        backgroundColor: context.scaffold,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Navigator.of(context).canPop()
              ? BackWidget(iconColor: context.icon)
              : null,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarIconBrightness: context.statusBarBrightness,
              statusBarColor: context.scaffold),
        ),
        body: Body(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Observer(builder: (context) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    (context.height() * 0.085).toInt().height,
                    //
                    _buildTopWidget(),
                    AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language.lblEmail,
                              style: context.boldTextStyle(size: 14)),
                          8.height,
                          AppTextField(
                            textStyle: context.primaryTextStyle(),
                            textFieldType: TextFieldType.EMAIL_ENHANCED,
                            controller: emailCont,
                            focus: emailFocus,
                            nextFocus: passwordFocus,
                            errorThisFieldRequired: language.requiredText,
                            decoration: inputDecoration(context,
                                fillColor: context.fillColor,
                                hintText: language.hintEmailTxt,
                                borderRadius: 8),
                            suffix: ic_message
                                .iconImage(size: 12, context: context)
                                .paddingAll(12),
                            autoFillHints: [AutofillHints.email],
                          ),
                          16.height,
                          Text(language.lblPassword,
                              style: context.boldTextStyle(size: 14)),
                          8.height,
                          AppTextField(
                            textStyle: context.primaryTextStyle(),
                            textFieldType: TextFieldType.PASSWORD,
                            controller: passwordCont,
                            focus: passwordFocus,
                            obscureText: true,
                            suffixPasswordVisibleWidget: ic_show
                                .iconImage(size: 10, context: context)
                                .paddingAll(14),
                            suffixPasswordInvisibleWidget: ic_hide
                                .iconImage(size: 10, context: context)
                                .paddingAll(14),
                            decoration: inputDecoration(context,
                                fillColor: context.fillColor,
                                hintText: language.hintPasswordTxt,
                                borderRadius: 8),
                            autoFillHints: [AutofillHints.password],
                            isValidationRequired: true,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return language.requiredText;
                              } else if (val.length < 8 || val.length > 12) {
                                return language.passwordLengthShouldBe;
                              }
                              return null;
                            },
                            onFieldSubmitted: (s) {
                              _handleLogin();
                            },
                          ),
                        ],
                      ),
                    ),
                    _buildRememberWidget(),
                    if (!getBoolAsync(HAS_IN_REVIEW)) _buildSocialWidget(),
                    30.height,
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
