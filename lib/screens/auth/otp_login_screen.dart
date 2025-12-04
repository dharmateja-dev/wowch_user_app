import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/base_scaffold_body.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/screens/auth/sign_up_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../network/rest_apis.dart';
import '../../utils/configs.dart';
import '../../utils/constant.dart';
import '../dashboard/dashboard_screen.dart';

class OTPLoginScreen extends StatefulWidget {
  const OTPLoginScreen({Key? key}) : super(key: key);

  @override
  State<OTPLoginScreen> createState() => _OTPLoginScreenState();
}

class _OTPLoginScreenState extends State<OTPLoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController numberController = TextEditingController();
  FocusNode _mobileNumberFocus = FocusNode();

  Country selectedCountry = defaultCountry();

  String otpCode = '';
  String verificationId = '';

  //ValueNotifier _valueNotifier = ValueNotifier(true);

  bool isCodeSent = false;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() => init());
  }

  Future<void> init() async {
    appStore.setLoading(false);
  }

  //region Methods
  Future<void> changeCountry() async {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.circular(0),
        bottomSheetHeight: 600,
        textStyle: primaryTextStyle(),
        searchTextStyle: primaryTextStyle(),
        backgroundColor: Colors.grey.shade200,
        inputDecoration: InputDecoration(
          fillColor: context.scaffoldBackgroundColor,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
            ),
          ),
          hintText: language.search,
          hintStyle: primaryTextStyle(size: 14),
          prefixIcon: const Icon(
            Icons.search,
          ),
        ),
      ),

      showPhoneCode:
          true, // optional. Shows phone code before the country name.
      onSelect: (Country country) {
        selectedCountry = country;
        setState(() {});
      },
    );
  }

  Future<void> sendOTP() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);

      appStore.setLoading(true);

      toast(language.sendingOTP);

      try {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber:
              "+${selectedCountry.phoneCode}${numberController.text.trim()}",
          verificationCompleted: (PhoneAuthCredential credential) async {
            toast(language.verified);

            if (isAndroid) {
              await FirebaseAuth.instance.signInWithCredential(credential);
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            appStore.setLoading(false);
            if (e.code == 'invalid-phone-number') {
              toast(language.theEnteredCodeIsInvalidPleaseTryAgain,
                  print: true);
            } else {
              toast(e.toString(), print: true);
            }
          },
          codeSent: (String _verificationId, int? resendToken) async {
            toast(language.otpCodeIsSentToYourMobileNumber);

            appStore.setLoading(false);

            verificationId = _verificationId;

            if (verificationId.isNotEmpty) {
              isCodeSent = true;
              setState(() {});
            } else {
              //Handle
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            FirebaseAuth.instance.signOut();
            isCodeSent = false;
            setState(() {});
          },
        );
      } on Exception catch (e) {
        log(e);
        appStore.setLoading(false);

        toast(e.toString(), print: true);
      }
    }
  }

  Future<void> submitOtp() async {
    log(otpCode);
    if (otpCode.validate().isNotEmpty) {
      if (otpCode.validate().length >= OTP_TEXT_FIELD_LENGTH) {
        hideKeyboard(context);
        appStore.setLoading(true);

        try {
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId, smsCode: otpCode);
          UserCredential credentials =
              await FirebaseAuth.instance.signInWithCredential(credential);

          Map<String, dynamic> request = {
            'username': numberController.text.trim(),
            'password': numberController.text.trim(),
            'login_type': LOGIN_TYPE_OTP,
            "uid": credentials.user!.uid.validate(),
          };

          try {
            await loginUser(request, isSocialLogin: true)
                .then((loginResponse) async {
              if (loginResponse.isUserExist.validate(value: true)) {
                await saveUserData(loginResponse.userData!);
                await appStore.setLoginType(LOGIN_TYPE_OTP);
                DashboardScreen().launch(context,
                    isNewTask: true,
                    pageRouteAnimation: PageRouteAnimation.Fade);
              } else {
                appStore.setLoading(false);
                finish(context);

                SignUpScreen(
                  isOTPLogin: true,
                  phoneNumber: numberController.text.trim(),
                  countryCode: selectedCountry.countryCode,
                  uid: credentials.user!.uid.validate(),
                  tokenForOTPCredentials: credential.token,
                ).launch(context);
              }
            }).catchError((e) {
              finish(context);
              toast(e.toString());
              appStore.setLoading(false);
            });
          } catch (e) {
            appStore.setLoading(false);
            toast(e.toString(), print: true);
          }
        } on FirebaseAuthException catch (e) {
          appStore.setLoading(false);
          if (e.code.toString() == 'invalid-verification-code') {
            toast(language.theEnteredCodeIsInvalidPleaseTryAgain, print: true);
          } else {
            toast(e.message.toString(), print: true);
          }
        } on Exception catch (e) {
          appStore.setLoading(false);
          toast(e.toString(), print: true);
        }
      } else {
        toast(language.pleaseEnterValidOTP);
      }
    } else {
      toast(language.pleaseEnterValidOTP);
    }
  }

  // endregion

  Widget _buildMainWidget() {
    if (isCodeSent) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(language.confirmOTP, style: boldTextStyle(size: 24)).center(),
            (context.height() * 0.10).toInt().height,
            OTPTextField(
              pinLength: OTP_TEXT_FIELD_LENGTH,
              textStyle: primaryTextStyle(size: 30),
              decoration: inputDecoration(context).copyWith(
                fillColor: Colors.transparent,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                isDense: true,
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: context.primaryColor, width: 2),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: greyColor,
                    width: 2,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: context.primaryColor,
                    width: 2,
                  ),
                ),
                counter: const Offstage(),
              ),
              onChanged: (s) {
                otpCode = s;
                log(otpCode);
              },
              onCompleted: (pin) {
                otpCode = pin;
                submitOtp();
              },
            ).fit(),
            (context.height() * 0.08).toInt().height,
            AppButton(
              onTap: () {
                submitOtp();
              },
              text: language.confirm,
              color: primaryColor,
              textColor: context.scaffoldBackgroundColor,
              width: context.width(),
            ),
          ],
        ),
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language.lblEnterPhnNumber,
                  style: boldTextStyle(size: APP_BAR_TEXT_SIZE))
              .center(),
          (context.height() * 0.08).toInt().height,
          Form(
            key: formKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Mobile number text field...
                AppTextField(
                  textFieldType:
                      isAndroid ? TextFieldType.PHONE : TextFieldType.NAME,
                  controller: numberController,
                  focus: _mobileNumberFocus,
                  errorThisFieldRequired: language.requiredText,
                  decoration: inputDecoration(context,
                      fillColor: Colors.transparent,
                      hintText: "${language.hintContactNumberTxt}",
                      counter: false,
                      borderRadius: 8,
                      prefixIcon: ValueListenableBuilder<Country>(
                        valueListenable:
                            ValueNotifier<Country>(selectedCountry),
                        builder: (context, country, child) {
                          return GestureDetector(
                            onTap: () => changeCountry(),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    country.flagEmoji,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  6.width,
                                  Text(
                                    "+${country.phoneCode}",
                                    style: primaryTextStyle(size: 14),
                                  ),
                                  4.width,
                                  Icon(
                                    Icons.arrow_drop_down,
                                    size: 18,
                                    color: context.iconColor,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )),
                  maxLength: 15,
                ).flexible(),
              ],
            ),
          ),
          (context.height() * 0.08).toInt().height,
          AppButton(
            onTap: () {
              sendOTP();
            },
            text: language.btnSendOtp,
            color: primaryColor,
            textColor: Colors.white,
            width: context.width(),
          ),
          16.height,
          GestureDetector(
            onTap: () => changeCountry(),
            child: Text(language.selectCountry, style: boldTextStyle(size: 14))
                .center(),
          ),
        ],
      );
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: context.scaffoldBackgroundColor,
          leading: Navigator.of(context).canPop()
              ? BackWidget(iconColor: context.iconColor)
              : null,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarIconBrightness:
                  appStore.isDarkMode ? Brightness.light : Brightness.dark,
              statusBarColor: context.scaffoldBackgroundColor),
        ),
        body: Body(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: _buildMainWidget(),
          ),
        ),
      ),
    );
  }
}
