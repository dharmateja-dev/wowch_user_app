import 'dart:convert';

import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/price_widget.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/base_scaffold_widget.dart';
import '../../../main.dart';
import '../../../model/bank_list_response.dart';
import '../../../model/base_response_model.dart';
import '../../../model/static_data_model.dart';
import '../../../network/network_utils.dart';
import '../../../utils/common.dart';
import '../../../utils/constant.dart';
import '../../../utils/model_keys.dart';

class AddBankScreen extends StatefulWidget {
  final BankHistory? data;
  final num availableBalance;

  const AddBankScreen({super.key, this.data, this.availableBalance = 0});

  @override
  State<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends State<AddBankScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController bankNameCont = TextEditingController();
  TextEditingController branchNameCont = TextEditingController();
  TextEditingController accNumberCont = TextEditingController();
  TextEditingController ifscCodeCont = TextEditingController();
  TextEditingController contactNumberCont = TextEditingController();
  TextEditingController aadharCardNumberCont = TextEditingController();
  TextEditingController panNumberCont = TextEditingController();

  FocusNode bankNameFocus = FocusNode();
  FocusNode branchNameFocus = FocusNode();
  FocusNode accNumberFocus = FocusNode();
  FocusNode ifscCodeFocus = FocusNode();
  FocusNode contactNumberFocus = FocusNode();
  FocusNode aadharCardNumberFocus = FocusNode();
  FocusNode panNumberFocus = FocusNode();

  Future<void> update() async {
    MultipartRequest multiPartRequest = await getMultiPartRequest('save-bank');
    multiPartRequest.fields[UserKeys.id] =
        isUpdate ? widget.data!.id.toString() : "";
    multiPartRequest.fields[UserKeys.providerId] = appStore.userId.toString();
    multiPartRequest.fields[BankServiceKey.bankName] = bankNameCont.text;
    multiPartRequest.fields[BankServiceKey.branchName] = branchNameCont.text;
    multiPartRequest.fields[BankServiceKey.accountNo] = accNumberCont.text;
    multiPartRequest.fields[BankServiceKey.ifscNo] = ifscCodeCont.text;
    multiPartRequest.fields[BankServiceKey.mobileNo] = contactNumberCont.text;
    multiPartRequest.fields[BankServiceKey.aadharNo] =
        aadharCardNumberCont.text;
    multiPartRequest.fields[BankServiceKey.panNo] = panNumberCont.text;
    multiPartRequest.fields[BankServiceKey.bankAttachment] = '';
    multiPartRequest.fields[UserKeys.status] = getStatusValue().toString();
    multiPartRequest.fields[UserKeys.isDefault] =
        widget.data?.isDefault.toString() ?? "0";

    multiPartRequest.headers.addAll(buildHeaderTokens());

    appStore.setLoading(true);

    sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        appStore.setLoading(false);
        if (data != null) {
          print(data);
          if ((data as String).isJson()) {
            BaseResponseModel res =
                BaseResponseModel.fromJson(jsonDecode(data));
            finish(context, [true, bankNameCont.text]);
            snackBar(context, title: res.message!);
          }
        }
      },
      onError: (error) {
        toast(error.toString(), print: true);
        appStore.setLoading(false);
      },
    ).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  String bankStatus = 'ACTIVE';
  int getStatusValue() {
    if (bankStatus == 'ACTIVE') {
      return 1;
    } else {
      return 0;
    }
  }

  bool isUpdate = true;

  List<StaticDataModel> statusListStaticData = [
    StaticDataModel(key: ACTIVE, value: language.active),
    StaticDataModel(key: INACTIVE, value: language.inactive),
  ];
  StaticDataModel? blogStatusModel;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    isUpdate = widget.data != null;

    if (isUpdate) {
      bankNameCont.text = widget.data!.bankName.validate();
      branchNameCont.text = widget.data!.branchName.validate();
      accNumberCont.text = widget.data!.accountNo.validate();
      ifscCodeCont.text = widget.data!.ifscNo.validate();
      contactNumberCont.text = widget.data!.mobileNo.validate();
      aadharCardNumberCont.text = widget.data!.aadharNo.validate();
      panNumberCont.text = widget.data!.panNo.validate();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: AppScaffold(
        leading: BackWidget(),
        appBarTitle: language.addBank,
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                return await update();
              },
              child: Form(
                key: formKey,
                child: AnimatedScrollView(
                  padding: EdgeInsets.all(16),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Color(0xFFE8F3EC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language.availableBalance,
                              style: boldTextStyle(size: 14)),
                          PriceWidget(
                              price: widget.availableBalance.validate(),
                              color: context.primaryColor,
                              isBoldText: true),
                        ],
                      ),
                    ),
                    (context.height() * 0.04).toInt().height,
                    Text(language.lblBankName, style: boldTextStyle(size: 14)),
                    8.height,
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      controller: bankNameCont,
                      focus: bankNameFocus,
                      nextFocus: branchNameFocus,
                      decoration: inputDecoration(context,
                          hintText: language.bankName,
                          borderRadius: 8,
                          fillColor: Colors.transparent),
                      //suffix: ic_piggy_bank.iconImage(size: 10).paddingAll(14),
                    ),
                    16.height,
                    Text(language.lblFullNameOnBankAccount,
                        style: boldTextStyle(size: 14)),
                    8.height,
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      controller: branchNameCont,
                      focus: branchNameFocus,
                      nextFocus: accNumberFocus,
                      decoration: inputDecoration(context,
                          hintText: language.hintEnterFullName,
                          borderRadius: 8,
                          fillColor: Colors.transparent),
                      //suffix: ic_piggy_bank.iconImage(size: 10).paddingAll(14),
                    ),
                    16.height,
                    Text(language.lblAccountNumber,
                        style: boldTextStyle(size: 14)),
                    8.height,
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      controller: accNumberCont,
                      focus: accNumberFocus,
                      nextFocus: ifscCodeFocus,
                      decoration: inputDecoration(context,
                          hintText: language.hintEnterAccountNumber,
                          borderRadius: 8,
                          fillColor: Colors.transparent),
                      // suffix: ic_password
                      //     .iconImage(size: 10, fit: BoxFit.contain)
                      //     .paddingAll(14),
                    ),
                    16.height,
                    Text(language.lblIFSCCode, style: boldTextStyle(size: 14)),
                    8.height,
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      controller: ifscCodeCont,
                      focus: ifscCodeFocus,
                      nextFocus: contactNumberFocus,
                      decoration: inputDecoration(context,
                          hintText: language.hintEnterIFSCCode,
                          counter: false,
                          borderRadius: 8,
                          fillColor: Colors.transparent),
                      //suffix: ic_profile2.iconImage(size: 10).paddingAll(14),
                      isValidationRequired: false,
                    ),
                    16.height,
                    Text(language.lblStatus, style: boldTextStyle(size: 14)),
                    8.height,
                    DropdownButtonFormField<StaticDataModel>(
                      isExpanded: true,
                      dropdownColor: context.cardColor,
                      initialValue: blogStatusModel != null
                          ? blogStatusModel
                          : statusListStaticData.first,
                      items: statusListStaticData.map((StaticDataModel data) {
                        return DropdownMenuItem<StaticDataModel>(
                          value: data,
                          child: Text(data.value.validate(),
                              style: primaryTextStyle()),
                        );
                      }).toList(),
                      decoration: inputDecoration(context,
                          hintText: language.lblStatus,
                          borderRadius: 8,
                          fillColor: Colors.transparent),
                      onChanged: (StaticDataModel? value) async {
                        bankStatus = value!.key.validate();
                        setState(() {});
                      },
                      validator: (value) {
                        if (value == null) return errorThisFieldRequired;
                        return null;
                      },
                    ),
                    100.height,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 16,
              right: 16,
              child: AppButton(
                text: language.btnSave,
                color: context.primary,
                textStyle: boldTextStyle(color: context.onPrimary),
                width: context.width(),
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    update();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
