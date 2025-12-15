import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../auth/sign_in_screen.dart';
import '../../jobRequest/my_post_request_list_screen.dart';

class NewJobRequestComponent extends StatelessWidget {
  const NewJobRequestComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      padding: const EdgeInsets.all(10),
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor: context.primaryColor,
        borderRadius: radius(defaultRadius),
      ),
      child: Column(
        children: [
          Text(language.jobRequestSubtitle,
                  style:
                      context.boldTextStyle(color: context.onPrimary, size: 20),
                  textAlign: TextAlign.center)
              .paddingSymmetric(horizontal: 12, vertical: 12),
          AppButton(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
            color: context.buttonBackgroundAlt,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: context.onSurface),
                4.width,
                Text(language.newPostJobRequest,
                    style: context.boldTextStyle(color: context.onSurface)),
              ],
            ),
            textStyle: context.primaryTextStyle(color: context.onSurface),
            onTap: () async {
              if (appStore.isLoggedIn) {
                MyPostRequestListScreen().launch(context);
              } else {
                setStatusBarColor(Colors.transparent,
                    statusBarIconBrightness: context.statusBarBrightness);
                bool? res = await const SignInScreen(returnExpected: true)
                    .launch(context);

                if (res ?? false) {
                  MyPostRequestListScreen().launch(context);
                }
              }
            },
          ),
          16.height,
        ],
      ),
    );
  }
}
