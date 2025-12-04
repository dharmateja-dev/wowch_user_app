import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/dashboard/dashboard_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController oldPasswordCont = TextEditingController();
  TextEditingController newPasswordCont = TextEditingController();
  TextEditingController reenterPasswordCont = TextEditingController();

  FocusNode oldPasswordFocus = FocusNode();
  FocusNode newPasswordFocus = FocusNode();
  FocusNode reenterPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> changePassword() async {
    if (formKey.currentState!.validate()) {
      if (oldPasswordCont.text.trim() != getStringAsync(USER_PASSWORD)) {
        return toast(language.provideValidCurrentPasswordMessage);
      }

      formKey.currentState!.save();
      hideKeyboard(context);

      var request = {
        UserKeys.oldPassword: oldPasswordCont.text,
        UserKeys.newPassword: newPasswordCont.text,
      };
      appStore.setLoading(true);

      await changeUserPassword(request).then((res) async {
        toast(res.message.validate());
        await setValue(USER_PASSWORD, newPasswordCont.text);
        DashboardScreen().launch(context,
            isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
      }).catchError((e) {
        toast(e.toString(), print: true);
      });
      appStore.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      leading: BackWidget(),
      appBarTitle: language.changePassword,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              16.height,
              Text(language.lblChangePwdTitle,
                  style: primaryTextStyle(size: 14)),
              24.height,
              Text(language.hintOldPasswordTxt, style: boldTextStyle(size: 14)),
              8.height,
              AppTextField(
                textFieldType: TextFieldType.PASSWORD,
                controller: oldPasswordCont,
                focus: oldPasswordFocus,
                nextFocus: newPasswordFocus,
                obscureText: true,
                suffixPasswordVisibleWidget: const SizedBox.shrink(),
                suffixPasswordInvisibleWidget: const SizedBox.shrink(),
                decoration: inputDecoration(
                  context,
                  fillColor: Colors.transparent,
                  hintText: language.hintOldPasswordTxt,
                  borderRadius: 8,
                ),
                isValidationRequired: true,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return language.requiredText;
                  } else if (val.length < 8 || val.length > 12) {
                    return language.passwordLengthShouldBe;
                  }
                  return null;
                },
              ),
              16.height,
              Text(language.hintNewPasswordTxt, style: boldTextStyle(size: 14)),
              8.height,
              AppTextField(
                textFieldType: TextFieldType.PASSWORD,
                controller: newPasswordCont,
                focus: newPasswordFocus,
                obscureText: true,
                nextFocus: reenterPasswordFocus,
                suffixPasswordVisibleWidget: const SizedBox.shrink(),
                suffixPasswordInvisibleWidget: const SizedBox.shrink(),
                decoration: inputDecoration(
                  context,
                  fillColor: Colors.transparent,
                  hintText: language.hintNewPasswordTxt,
                  borderRadius: 8,
                ),
                isValidationRequired: true,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return language.requiredText;
                  } else if (val.length < 8 || val.length > 12) {
                    return language.passwordLengthShouldBe;
                  }
                  return null;
                },
              ),
              16.height,
              Text(language.hintReenterPasswordTxt,
                  style: boldTextStyle(size: 14)),
              8.height,
              AppTextField(
                textFieldType: TextFieldType.PASSWORD,
                controller: reenterPasswordCont,
                obscureText: true,
                focus: reenterPasswordFocus,
                suffixPasswordVisibleWidget: const SizedBox.shrink(),
                suffixPasswordInvisibleWidget: const SizedBox.shrink(),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return errorThisFieldRequired;
                  } else if (v.length < 8 || v.length > 12) {
                    return language.passwordLengthShouldBe;
                  } else if (newPasswordCont.text != v) {
                    return language.passwordNotMatch;
                  } else if (reenterPasswordCont.text.isEmpty) {
                    return errorThisFieldRequired;
                  }
                  return null;
                },
                onFieldSubmitted: (s) {
                  ifNotTester(() {
                    changePassword();
                  });
                },
                decoration: inputDecoration(
                  context,
                  fillColor: Colors.transparent,
                  hintText: language.hintReenterPasswordTxt,
                  borderRadius: 8,
                ),
              ),
              24.height,
              AppButton(
                text: language.confirm,
                color: primaryColor,
                textColor: Colors.white,
                width: context.width() - context.navigationBarHeight,
                onTap: () {
                  ifNotTester(() {
                    changePassword();
                  });
                },
              ),
              24.height,
            ],
          ),
        ),
      ),
    );
  }
}
