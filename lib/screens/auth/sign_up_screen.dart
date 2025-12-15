import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/configs.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

class SignUpScreen extends StatefulWidget {
  final String? phoneNumber;
  final String? countryCode;
  final bool isOTPLogin;
  final String? uid;
  final int? tokenForOTPCredentials;

  SignUpScreen(
      {Key? key,
      this.phoneNumber,
      this.isOTPLogin = false,
      this.countryCode,
      this.uid,
      this.tokenForOTPCredentials})
      : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Country selectedCountry = defaultCountry();
  ValueNotifier<Country> countryNotifier =
      ValueNotifier<Country>(defaultCountry());

  TextEditingController fNameCont = TextEditingController();
  TextEditingController lNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController userNameCont = TextEditingController();
  TextEditingController mobileCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  FocusNode fNameFocus = FocusNode();
  FocusNode lNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode mobileFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  bool isAcceptedTc = false;

  bool isFirstTimeValidation = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (widget.phoneNumber != null) {
      selectedCountry = Country.parse(
          widget.countryCode.validate(value: selectedCountry.countryCode));
      countryNotifier.value = selectedCountry;

      mobileCont.text =
          widget.phoneNumber != null ? widget.phoneNumber.toString() : "";
      passwordCont.text =
          widget.phoneNumber != null ? widget.phoneNumber.toString() : "";
      userNameCont.text =
          widget.phoneNumber != null ? widget.phoneNumber.toString() : "";
    } else {
      countryNotifier.value = selectedCountry;
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    countryNotifier.dispose();
    super.dispose();
  }

  //region Logic
  String buildMobileNumber() {
    if (mobileCont.text.isEmpty) {
      return '';
    } else {
      return '+${mobileCont.text.trim().formatPhoneNumber(selectedCountry.phoneCode)}';
    }
  }

  Future<void> registerWithOTP() async {
    hideKeyboard(context);

    if (appStore.isLoading) return;

    if (formKey.currentState!.validate()) {
      if (isAcceptedTc) {
        formKey.currentState!.save();
        appStore.setLoading(true);

        UserData userResponse = UserData()
          ..username = widget.phoneNumber.validate().trim()
          ..loginType = LOGIN_TYPE_OTP
          ..contactNumber = buildMobileNumber()
          ..email = emailCont.text.trim()
          ..firstName = fNameCont.text.trim()
          ..lastName = lNameCont.text.trim()
          ..userType = USER_TYPE_USER
          ..uid = widget.uid.validate()
          ..password = widget.phoneNumber.validate().trim();

        /// Link OTP login with Email Auth
        if (widget.tokenForOTPCredentials != null) {
          try {
            AuthCredential credential = PhoneAuthProvider.credentialFromToken(
                widget.tokenForOTPCredentials!);
            UserCredential userCredential =
                await FirebaseAuth.instance.signInWithCredential(credential);

            AuthCredential emailAuthCredential = EmailAuthProvider.credential(
                email: emailCont.text.trim(),
                password: DEFAULT_FIREBASE_PASSWORD);
            userCredential.user!.linkWithCredential(emailAuthCredential);
          } catch (e) {
            print(e);
          }
        }

        await createUsers(tempRegisterData: userResponse);
      }
    }
  }

  Future<void> changeCountry() async {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.circular(0),
        bottomSheetHeight: 600,
        textStyle: context.primaryTextStyle(),
        searchTextStyle:
            context.primaryTextStyle(color: context.searchTextColor),
        backgroundColor: context.bottomSheetBackgroundColor,
        inputDecoration: InputDecoration(
          fillColor: context.searchFillColor,
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
          hintStyle: context.primaryTextStyle(
              size: 14, color: context.searchHintColor),
          prefixIcon: Icon(Icons.search, color: context.searchHintColor),
        ),
      ),

      showPhoneCode:
          true, // optional. Shows phone code before the country name.
      onSelect: (Country country) {
        selectedCountry = country;
        countryNotifier.value = country;
        setState(() {});
      },
    );
  }

  void registerUser() async {
    hideKeyboard(context);

    if (appStore.isLoading) return;

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      /// If Terms and condition is Accepted then only the user will be registered
      if (isAcceptedTc) {
        appStore.setLoading(true);

        /// Create a temporary request to send
        UserData tempRegisterData = UserData()
          ..contactNumber = buildMobileNumber()
          ..firstName = fNameCont.text.trim()
          ..lastName = lNameCont.text.trim()
          ..userType = USER_TYPE_USER
          ..username = userNameCont.text.trim()
          ..email = emailCont.text.trim()
          ..password = passwordCont.text.trim();

        createUsers(tempRegisterData: tempRegisterData);
      } else {
        toast(language.termsConditionsAccept);
      }
    } else {
      isFirstTimeValidation = false;
      setState(() {});
    }
  }

  Future<void> createUsers({required UserData tempRegisterData}) async {
    if (demoModeStore.isDemoMode) {
      appStore.setLoading(true);
      await Future.delayed(Duration(seconds: 1));
      appStore.setLoading(false);
      toast("Registration successful (Demo Mode)");

      // Simulate successful registration
      finish(context);
      return;
    }

    await createUser(tempRegisterData.toJson()).then((registerResponse) async {
      registerResponse.userData!.password = passwordCont.text.trim();

      appStore.setLoading(false);
      toast(registerResponse.message.validate());
      await appStore.setLoginType(tempRegisterData.loginType.validate());

      /// Back to sign in screen
      finish(context);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  //endregion

  //region Widget
  Widget _buildTopWidget() {
    return Column(
      children: [
        (context.height() * 0.08).toInt().height,
        Text(language.lblHelloAgain, style: context.boldTextStyle(size: 24))
            .center(),
        16.height,
        Text(language.lblSignUpSubTitle,
                style: context.primaryTextStyle(size: 16),
                textAlign: TextAlign.center)
            .center()
            .paddingSymmetric(horizontal: 8),
        16.height,
      ],
    );
  }

  Widget _buildFormWidget() {
    setState(() {});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Text(language.lblFirstName, style: context.boldTextStyle(size: 14)),
        8.height,
        //First Name
        AppTextField(
          textStyle: context.primaryTextStyle(),
          textFieldType: TextFieldType.NAME,
          controller: fNameCont,
          focus: fNameFocus,
          nextFocus: lNameFocus,
          errorThisFieldRequired: language.requiredText,
          decoration: inputDecoration(context,
              hintText: language.hintFirstNameTxt, borderRadius: 8),
          suffix: ic_user.iconImage(size: 10, context: context).paddingAll(14),
        ),
        16.height,
        Text(language.lblLastName, style: context.boldTextStyle(size: 14)),
        8.height,
        //Last Name
        AppTextField(
          textStyle: context.primaryTextStyle(),
          textFieldType: TextFieldType.NAME,
          controller: lNameCont,
          focus: lNameFocus,
          nextFocus: userNameFocus,
          errorThisFieldRequired: language.requiredText,
          decoration: inputDecoration(context,
              hintText: language.hintLastNameTxt, borderRadius: 8),
          suffix: ic_user.iconImage(size: 10, context: context).paddingAll(14),
        ),
        16.height,
        Text(language.lblUserName, style: context.boldTextStyle(size: 14)),
        8.height,
        AppTextField(
          textStyle: context.primaryTextStyle(),
          textFieldType: TextFieldType.USERNAME,
          controller: userNameCont,
          focus: userNameFocus,
          nextFocus: emailFocus,
          readOnly: widget.isOTPLogin.validate() ? widget.isOTPLogin : false,
          errorThisFieldRequired: language.requiredText,
          decoration: inputDecoration(context,
              hintText: language.hintUserNameTxt, borderRadius: 8),
          suffix: ic_user.iconImage(size: 10, context: context).paddingAll(14),
        ),
        16.height,
        Text(language.lblEmail, style: context.boldTextStyle(size: 14)),
        8.height,
        AppTextField(
          textStyle: context.primaryTextStyle(),
          textFieldType: TextFieldType.EMAIL_ENHANCED,
          controller: emailCont,
          focus: emailFocus,
          errorThisFieldRequired: language.requiredText,
          nextFocus: mobileFocus,
          decoration: inputDecoration(context,
              hintText: language.hintEmailTxt, borderRadius: 8),
          suffix:
              ic_message.iconImage(size: 12, context: context).paddingAll(12),
        ),
        16.height,
        Text(language.lblContactNumber, style: context.boldTextStyle(size: 14)),
        8.height,
        // Mobile number text field...
        AppTextField(
          textStyle: context.primaryTextStyle(),
          textFieldType: isAndroid ? TextFieldType.PHONE : TextFieldType.NAME,
          controller: mobileCont,
          focus: mobileFocus,
          errorThisFieldRequired: language.requiredText,
          nextFocus: passwordFocus,
          decoration: inputDecoration(context,
              hintText: "${language.hintContactNumberTxt}",
              counter: false,
              borderRadius: 8,
              prefixIcon: ValueListenableBuilder<Country>(
                valueListenable: countryNotifier,
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
                            style: context.primaryTextStyle(size: 14),
                          ),
                          4.width,
                          Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: context.icon,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )),
          maxLength: 15,
          suffix: ic_call.iconImage(size: 8, context: context).paddingAll(15),
        ),
        8.height,
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => changeCountry(),
            child: Text(
              language.selectCountry,
              style: context.boldTextStyle(size: 13),
            ),
          ),
        ),
        8.height,
        if (!widget.isOTPLogin)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(language.lblPassword,
                  style: context.boldTextStyle(size: 14)),
              8.height,
              AppTextField(
                textStyle: context.primaryTextStyle(),
                textFieldType: TextFieldType.PASSWORD,
                controller: passwordCont,
                focus: passwordFocus,
                obscureText: true,
                readOnly:
                    widget.isOTPLogin.validate() ? widget.isOTPLogin : false,
                suffixPasswordVisibleWidget: ic_show
                    .iconImage(size: 10, context: context)
                    .paddingAll(14),
                suffixPasswordInvisibleWidget: ic_hide
                    .iconImage(size: 10, context: context)
                    .paddingAll(14),
                errorThisFieldRequired: language.requiredText,
                decoration: inputDecoration(context,
                    hintText: language.hintPasswordTxt, borderRadius: 8),
                isValidationRequired: true,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return language.requiredText;
                  } else if (val.length < 8 || val.length > 12) {
                    return language.passwordLengthShouldBe;
                  }
                  return null;
                },
                onFieldSubmitted: (s) {},
              ),
              20.height,
            ],
          ),
        _buildTcAcceptWidget(),
        8.height,
        AppButton(
          text: language.signUp,
          color: context.primary,
          textColor: context.onPrimary,
          width: context.width() - context.navigationBarHeight,
          onTap: () {
            if (widget.isOTPLogin) {
              registerWithOTP();
            } else {
              registerUser();
            }
          },
        ),
      ],
    );
  }

  Widget _buildTcAcceptWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          value: isAcceptedTc,
          onChanged: (value) {
            isAcceptedTc = !isAcceptedTc;
            setState(() {});
          },
          activeColor: context.primary,
          checkColor: Colors.white,
          side: BorderSide(color: context.primary, width: 2.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        //16.width,
        RichTextWidget(
          list: [
            TextSpan(
                text: '${language.lblAgree} ',
                style: context.primaryTextStyle(size: 14)),
            TextSpan(
              text: language.lblTermsOfService,
              style: context.boldTextStyle(color: context.primary, size: 14),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  checkIfLink(context, appConfigurationStore.termConditions,
                      title: language.termsCondition);
                },
            ),
            TextSpan(text: ' & ', style: context.primaryTextStyle(size: 14)),
            TextSpan(
              text: language.privacyPolicy,
              style: context.boldTextStyle(color: context.primary, size: 14),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  checkIfLink(context, appConfigurationStore.privacyPolicy,
                      title: language.privacyPolicy);
                },
            ),
          ],
        ).flexible(flex: 2),
      ],
    ).paddingSymmetric(vertical: 16);
  }

  Widget _buildFooterWidget() {
    return Column(
      children: [
        16.height,
        RichTextWidget(
          list: [
            TextSpan(
                text: "${language.alreadyHaveAccountTxt} ",
                style: context.primaryTextStyle(size: 14)),
            TextSpan(
              text: language.signIn,
              style: context.boldTextStyle(color: context.primary, size: 14),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  finish(context);
                },
            ),
          ],
        ),
        30.height,
      ],
    );
  }

  //endregion

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: context.scaffold,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            leading: Navigator.of(context).canPop()
                ? BackWidget(iconColor: context.icon)
                : null,
            backgroundColor: transparentColor,
            scrolledUnderElevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
                statusBarIconBrightness: context.statusBarBrightness,
                statusBarColor: context.scaffold),
          ),
          body: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Form(
                key: formKey,
                autovalidateMode: isFirstTimeValidation
                    ? AutovalidateMode.disabled
                    : AutovalidateMode.onUserInteraction,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTopWidget(),
                      _buildFormWidget(),
                      8.height,
                      _buildFooterWidget(),
                    ],
                  ),
                ),
              ),
              Observer(
                  builder: (_) =>
                      LoaderWidget().center().visible(appStore.isLoading)),
            ],
          ),
        ),
      ),
    );
  }
}
