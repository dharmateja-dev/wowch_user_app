import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/jobRequest/createService/create_service_screen.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/chat_gpt_loder.dart';
import '../../component/empty_error_state_widget.dart';

class CreatePostRequestScreen extends StatefulWidget {
  @override
  _CreatePostRequestScreenState createState() =>
      _CreatePostRequestScreenState();
}

class _CreatePostRequestScreenState extends State<CreatePostRequestScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Toggle dummy data for UI showcase
  static const bool USE_DUMMY_DATA = true;

  TextEditingController postTitleCont = TextEditingController();
  TextEditingController descriptionCont = TextEditingController();
  TextEditingController priceCont = TextEditingController();

  FocusNode descriptionFocus = FocusNode();
  FocusNode priceFocus = FocusNode();

  List<ServiceData> myServiceList = [];
  List<ServiceData> selectedServiceList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setLoading(true);

    if (USE_DUMMY_DATA) {
      // Showcase dummy services similar to the mock
      myServiceList = [
        ServiceData(
          id: 1,
          name: 'Nurses',
          categoryName: 'Nurses',
          attachments: [
            'https://images.pexels.com/photos/3985166/pexels-photo-3985166.jpeg?auto=compress&cs=tinysrgb&w=800'
          ],
        ),
        ServiceData(
          id: 2,
          name: 'Nurses',
          categoryName: 'Nurses',
          attachments: [
            'https://images.pexels.com/photos/3985166/pexels-photo-3985166.jpeg?auto=compress&cs=tinysrgb&w=800'
          ],
        ),
      ];
      selectedServiceList = [];
      cachedServiceFavList = []; // keep other caches untouched
      appStore.setLoading(false);
      setState(() {});
    } else {
      await getMyServiceList().then((value) {
        appStore.setLoading(false);

        if (value.userServices != null) {
          myServiceList = value.userServices.validate();
        }
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });

      setState(() {});
    }
  }

  void createPostJobClick() {
    appStore.setLoading(true);
    List<int> serviceList = [];

    if (selectedServiceList.isNotEmpty) {
      selectedServiceList.forEach((element) {
        serviceList.add(element.id.validate());
      });
    }

    Map request = {
      PostJob.postTitle: postTitleCont.text.validate(),
      PostJob.description: descriptionCont.text.validate(),
      PostJob.serviceId: serviceList,
      PostJob.price: priceCont.text.validate(),
      PostJob.status: JOB_REQUEST_STATUS_REQUESTED,
      PostJob.latitude: appStore.latitude,
      PostJob.longitude: appStore.longitude,
    };

    savePostJob(request).then((value) {
      appStore.setLoading(false);
      toast(value.message.validate());

      finish(context, true);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  void deleteService(ServiceData data) {
    appStore.setLoading(true);

    deleteServiceRequest(data.id.validate()).then((value) {
      appStore.setLoading(false);
      toast(value.message.validate());
      init();
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: AppScaffold(
        appBarTitle: language.newPostJobRequest,
        child: Stack(children: [
          AnimatedScrollView(
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
            padding: const EdgeInsets.only(bottom: 60),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Post Title
                        16.height,
                        Text(language.postJobTitle,
                            style: context.boldTextStyle()),
                        8.height,
                        AppTextField(
                          textStyle: context.primaryTextStyle(),
                          controller: postTitleCont,
                          textFieldType: TextFieldType.NAME,
                          errorThisFieldRequired: language.requiredText,
                          nextFocus: descriptionFocus,
                          decoration: inputDecoration(
                            context,
                            hintText: language.lblEnterJobTitle,
                            fillColor: context.secondaryContainer,
                            borderRadius: 8,
                            showBorder: false,
                          ),
                        ),
                        //Post Description
                        16.height,
                        Text(language.postJobDescription,
                            style: context.boldTextStyle()),
                        8.height,
                        AppTextField(
                          textStyle: context.primaryTextStyle(),
                          controller: descriptionCont,
                          textFieldType: TextFieldType.MULTILINE,
                          errorThisFieldRequired: language.requiredText,
                          maxLines: 4,
                          focus: descriptionFocus,
                          nextFocus: priceFocus,
                          enableChatGPT: appConfigurationStore.chatGPTStatus,
                          promptFieldInputDecorationChatGPT:
                              inputDecoration(context).copyWith(
                            hintText: language.lblEnterJobDescription,
                            fillColor: context.secondaryContainer,
                            filled: true,
                          ),
                          testWithoutKeyChatGPT:
                              appConfigurationStore.testWithoutKey,
                          loaderWidgetForChatGPT: const ChatGPTLoadingWidget(),
                          decoration: inputDecoration(
                            context,
                            hintText: language.lblEnterJobDescription,
                            fillColor: context.secondaryContainer,
                            borderRadius: 8,
                            showBorder: false,
                          ),
                        ),
                        16.height,
                        Text(language.price, style: context.boldTextStyle()),
                        8.height,
                        AppTextField(
                          textStyle: context.primaryTextStyle(),
                          textFieldType: TextFieldType.PHONE,
                          controller: priceCont,
                          focus: priceFocus,
                          errorThisFieldRequired: language.requiredText,
                          decoration: inputDecoration(
                            context,
                            hintText: language.price,
                            fillColor: context.secondaryContainer,
                            borderRadius: 8,
                            showBorder: false,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          validator: (s) {
                            if (s!.isEmpty) return errorThisFieldRequired;

                            if (s.toDouble() <= 0)
                              return language.priceAmountValidationMessage;
                            return null;
                          },
                        )
                      ],
                    ).paddingAll(16),
                  ),
                  16.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(language.services,
                          style: context.boldTextStyle(size: LABEL_TEXT_SIZE)),
                      GestureDetector(
                        onTap: () async {
                          hideKeyboard(context);
                          bool? res =
                              await CreateServiceScreen().launch(context);
                          if (res ?? false) init();
                        },
                        child: Text(language.addNewService,
                            style: context.boldTextStyle(
                                color: context.primaryColor)),
                      ),
                    ],
                  ).paddingOnly(right: 8, left: 16),
                  8.height,
                  if (myServiceList.isNotEmpty)
                    AnimatedListView(
                      itemCount: myServiceList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      listAnimationType: ListAnimationType.FadeIn,
                      itemBuilder: (_, i) {
                        ServiceData data = myServiceList[i];

                        return Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          width: context.width(),
                          decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: context.secondaryContainer,
                            borderRadius: radius(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CachedImageWidget(
                                url: data.attachments.validate().isNotEmpty
                                    ? data.attachments!.first.validate()
                                    : "",
                                fit: BoxFit.cover,
                                height: 70,
                                width: 70,
                                radius: 12,
                              ),
                              12.width,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.name.validate(),
                                      style: context.boldTextStyle(size: 18),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    6.height,
                                    Text(data.categoryName.validate(),
                                        style: context.primaryTextStyle()),
                                  ],
                                ),
                              ),
                              12.width,
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  selectedServiceList
                                          .any((e) => e.id == data.id)
                                      ? AppButton(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 4),
                                          shapeBorder: RoundedRectangleBorder(
                                              borderRadius: radius(8),
                                              side: BorderSide(
                                                color: context.primaryColor,
                                              )),
                                          color: context.scaffold,
                                          elevation: 0,
                                          onTap: () {
                                            selectedServiceList.remove(data);
                                            setState(() {});
                                          },
                                        )
                                      : AppButton(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 4),
                                          shapeBorder: RoundedRectangleBorder(
                                              borderRadius: radius(8),
                                              side: BorderSide(
                                                color: context.primaryColor,
                                              )),
                                          color:
                                              context.scaffoldBackgroundColor,
                                          elevation: 0,
                                          onTap: () {
                                            selectedServiceList.add(data);
                                            setState(() {});
                                          },
                                          child: Text(language.add,
                                              style: context.boldTextStyle(
                                                  size: 12,
                                                  color: context.primaryColor)),
                                        ),
                                  //8.height,
                                  IconButton(
                                    icon: ic_trash.iconImage(
                                        size: 20, context: context),
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () {
                                      showConfirmDialogCustom(
                                        width: 290,
                                        height: 80,
                                        context,
                                        dialogType: DialogType.DELETE,
                                        positiveText: language.lblDelete,
                                        negativeText: language.lblCancel,
                                        titleColor: context.dialogTitleColor,
                                        backgroundColor:
                                            context.dialogBackgroundColor,
                                        primaryColor: context.primary,
                                        negativeTextColor:
                                            context.dialogCancelColor,
                                        customCenterWidget: Image.asset(
                                            ic_warning,
                                            color: context.dialogIconColor,
                                            height: 70,
                                            width: 70,
                                            fit: BoxFit.cover),
                                        onAccept: (p0) {
                                          deleteService(data);
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  if (myServiceList.isEmpty && !appStore.isLoading)
                    NoDataWidget(
                      imageWidget: const EmptyStateWidget(),
                      title: language.noServiceAdded,
                      imageSize: const Size(90, 90),
                    ).paddingOnly(top: 16),
                  30.height,
                  AppButton(
                    child: Text(language.save,
                        style: context.boldTextStyle(
                            color: context.onPrimary, size: 18)),
                    color: context.primaryColor,
                    height: 52,
                    width: context.width(),
                    onTap: () {
                      hideKeyboard(context);

                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();

                        if (selectedServiceList.isNotEmpty) {
                          createPostJobClick();
                        } else {
                          toast(language.createPostJobWithoutSelectService);
                        }
                      }
                    },
                  ).paddingOnly(left: 16, right: 16),
                ],
              ),
            ],
          ),
          Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ]),
      ),
    );
  }
}
