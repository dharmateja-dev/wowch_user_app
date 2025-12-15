import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailCont = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  Future<void> forgotPwd() async {
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      appStore.setLoading(true);

      Map req = {
        UserKeys.email: emailCont.text.validate(),
      };

      forgotPassword(req).then((res) {
        appStore.setLoading(false);
        finish(context);

        toast(res.message.validate());
      }).catchError((e) {
        toast(e.toString(), print: true);
      }).whenComplete(() => appStore.setLoading(false));
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.height,
            Text(language.forgotPassword,
                    style: context.boldTextStyle(size: 22))
                .center(),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${language.hintEmailAddressTxt}",
                    style: context.primaryTextStyle(
                      size: 14,
                    )),
                6.height,
                Text(language.lblForgotPwdSubtitle,
                    style: context.primaryTextStyle(
                      size: 12,
                      weight: FontWeight.w400,
                    )),
                24.height,
                Observer(
                  builder: (_) => AppTextField(
                    textStyle: context.primaryTextStyle(),
                    textFieldType: TextFieldType.EMAIL_ENHANCED,
                    controller: emailCont,
                    autoFocus: true,
                    errorThisFieldRequired: language.requiredText,
                    decoration: inputDecoration(context,
                        fillColor: context.fillColor,
                        hintText: language.lblEmail,
                        borderRadius: 8),
                  ).visible(!appStore.isLoading, defaultWidget: Loader()),
                ),
                32.height,
                AppButton(
                  text: language.confirm,
                  color: context.primary,
                  textColor: context.onPrimary,
                  width: context.width() - context.navigationBarHeight,
                  onTap: () {
                    forgotPwd();
                  },
                ),
              ],
            ).paddingAll(16),
            8.height,
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text(
                language.lblCancel,
                style: context.primaryTextStyle(
                    size: 14,
                    weight: FontWeight.bold,
                    color: context.primaryColor),
              ),
            ).center(),
            32.height,
          ],
        ),
      ),
    );
  }
}
