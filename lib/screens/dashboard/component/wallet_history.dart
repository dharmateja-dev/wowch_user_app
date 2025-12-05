import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/extensions/num_extenstions.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/base_scaffold_widget.dart';
import '../../../component/empty_error_state_widget.dart';
import '../../../component/loader_widget.dart';
import '../../../model/user_wallet_history.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/common.dart';
import '../../wallet/component/wallet_card.dart';
import 'wallet_history_shimmer.dart';

class UserWalletHistoryScreen extends StatefulWidget {
  const UserWalletHistoryScreen({Key? key}) : super(key: key);

  @override
  State<UserWalletHistoryScreen> createState() =>
      _UserWalletHistoryScreenState();
}

class _UserWalletHistoryScreenState extends State<UserWalletHistoryScreen> {
  Future<List<WalletDataElement>>? future;

  List<WalletDataElement> walletHistoryList = [];
  int page = 1;
  bool isLastPage = false;
  num availableBalance = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  // Dummy data generator for wallet history
  Future<List<WalletDataElement>> getDummyWalletHistory() async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay

    final now = DateTime.now();
    final dummyData = <WalletDataElement>[
      WalletDataElement(
        id: 1,
        datetime: now.subtract(Duration(days: 1, hours: 2)).toIso8601String(),
        activityType: 'wallet',
        activityMessage: 'Payment received for Plumbing Service',
        activityData: ActivityData(
          title: 'Payment Received',
          userId: 1,
          providerName: 'John Plumbing Services',
          amount: 150.00,
          creditDebitAmount: 150.00,
          transactionId: 'TXN001',
          transactionType: 'credit',
        ),
      ),
      WalletDataElement(
        id: 2,
        datetime: now.subtract(Duration(days: 2, hours: 5)).toIso8601String(),
        activityType: 'wallet',
        activityMessage: 'Payment for Electrical Repair',
        activityData: ActivityData(
          title: 'Payment Made',
          userId: 1,
          providerName: 'Electric Solutions',
          amount: 200.00,
          creditDebitAmount: 200.00,
          transactionId: 'TXN002',
          transactionType: PAYMENT_STATUS_DEBIT,
        ),
      ),
      WalletDataElement(
        id: 3,
        datetime: now.subtract(Duration(days: 3, hours: 10)).toIso8601String(),
        activityType: 'wallet',
        activityMessage: 'Refund for Cancelled Booking',
        activityData: ActivityData(
          title: 'Refund Received',
          userId: 1,
          providerName: 'Home Services',
          amount: 75.50,
          creditDebitAmount: 75.50,
          transactionId: 'TXN003',
          transactionType: 'credit',
        ),
      ),
      WalletDataElement(
        id: 4,
        datetime: now.subtract(Duration(days: 4, hours: 3)).toIso8601String(),
        activityType: 'wallet',
        activityMessage: 'Payment for AC Installation',
        activityData: ActivityData(
          title: 'Payment Made',
          userId: 1,
          providerName: 'Cool Air Services',
          amount: 500.00,
          creditDebitAmount: 500.00,
          transactionId: 'TXN004',
          transactionType: PAYMENT_STATUS_DEBIT,
        ),
      ),
      WalletDataElement(
        id: 5,
        datetime: now.subtract(Duration(days: 5, hours: 8)).toIso8601String(),
        activityType: 'wallet',
        activityMessage: 'Top-up via Credit Card',
        activityData: ActivityData(
          title: 'Wallet Top-up',
          userId: 1,
          providerName: '',
          amount: 1000.00,
          creditDebitAmount: 1000.00,
          transactionId: 'TXN005',
          transactionType: 'credit',
        ),
      ),
      WalletDataElement(
        id: 6,
        datetime: now.subtract(Duration(days: 6, hours: 12)).toIso8601String(),
        activityType: 'wallet',
        activityMessage: 'Payment for Carpet Cleaning',
        activityData: ActivityData(
          title: 'Payment Made',
          userId: 1,
          providerName: 'Clean Pro Services',
          amount: 120.00,
          creditDebitAmount: 120.00,
          transactionId: 'TXN006',
          transactionType: PAYMENT_STATUS_DEBIT,
        ),
      ),
      WalletDataElement(
        id: 7,
        datetime: now.subtract(Duration(days: 7, hours: 6)).toIso8601String(),
        activityType: 'wallet',
        activityMessage: 'Payment received for Painting Service',
        activityData: ActivityData(
          title: 'Payment Received',
          userId: 1,
          providerName: 'Paint Masters',
          amount: 350.00,
          creditDebitAmount: 350.00,
          transactionId: 'TXN007',
          transactionType: 'credit',
        ),
      ),
      WalletDataElement(
        id: 8,
        datetime: now.subtract(Duration(days: 8, hours: 15)).toIso8601String(),
        activityType: 'wallet',
        activityMessage: 'Payment for Appliance Repair',
        activityData: ActivityData(
          title: 'Payment Made',
          userId: 1,
          providerName: 'Fix It Fast',
          amount: 85.00,
          creditDebitAmount: 85.00,
          transactionId: 'TXN008',
          transactionType: PAYMENT_STATUS_DEBIT,
        ),
      ),
    ];

    // Set dummy available balance
    if (mounted) {
      setState(() {
        availableBalance = 1250.50;
        isLastPage = true;
      });
    }

    return dummyData;
  }

  void init() async {
    // Use dummy data instead of API call
    future = getDummyWalletHistory();

    // Uncomment below to use real API
    // future = getUserWalletHistory(
    //   page,
    //   walletDataList: walletHistoryList,
    //   availableBalance: (p0) {
    //     availableBalance = p0;
    //   },
    //   lastPageCallBack: (p) {
    //     isLastPage = p;
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      leading: BackWidget(),
      appBarTitle: language.walletHistory,
      showLoader: false,
      child: Stack(
        children: [
          SnapHelperWidget<List<WalletDataElement>>(
            initialData: cachedWalletHistoryList,
            future: future,
            loadingWidget: WalletHistoryShimmer(),
            onSuccess: (snap) {
              return AnimatedScrollView(
                children: [
                  16.height,
                  WalletCard(
                    availableBalance: availableBalance,
                    callback: (value) {
                      if (value ?? false) {
                        init();
                        setState(() {});
                      }
                    },
                  ),
                  20.height,
                  AnimatedListView(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8),
                    listAnimationType: ListAnimationType.FadeIn,
                    fadeInConfiguration:
                        FadeInConfiguration(duration: 2.seconds),
                    itemCount: snap.length,
                    emptyWidget: NoDataWidget(
                        title: language.noDataAvailable,
                        imageWidget: const EmptyStateWidget()),
                    shrinkWrap: true,
                    disposeScrollController: true,
                    itemBuilder: (BuildContext context, index) {
                      WalletDataElement data = snap[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        margin: const EdgeInsets.all(8),
                        decoration: boxDecorationWithRoundedCorners(
                          borderRadius: BorderRadius.circular(8),
                          backgroundColor: context.cardColor,
                        ),
                        width: context.width(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: data.activityData != null &&
                                        data.activityData!.transactionType
                                            .isEmptyOrNull
                                    ? Colors.red.shade50
                                    : data.activityData != null &&
                                            data.activityData!.transactionType
                                                .toLowerCase()
                                                .contains(PAYMENT_STATUS_DEBIT)
                                        ? Colors.red.shade50
                                        : Colors.green.shade50,
                              ),
                              child: Image.asset(
                                data.activityData!.transactionType.isEmptyOrNull
                                    ? ic_diagonal_right_up_arrow
                                    : data.activityData != null &&
                                            data.activityData!.transactionType
                                                .toLowerCase()
                                                .contains(PAYMENT_STATUS_DEBIT)
                                        ? ic_diagonal_right_up_arrow
                                        : ic_diagonal_left_down_arrow,
                                height: 18,
                                width: 18,
                                color: data.activityData != null &&
                                        data.activityData!.transactionType
                                            .isEmptyOrNull
                                    ? Colors.red
                                    : data.activityData != null &&
                                            data.activityData!.transactionType
                                                .toLowerCase()
                                                .contains(PAYMENT_STATUS_DEBIT)
                                        ? Colors.red
                                        : Colors.green,
                              ),
                            ),
                            16.width,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (data.activityMessage.validate().isNotEmpty)
                                  Text(
                                    data.activityMessage.validate(),
                                    style: boldTextStyle(size: 12),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                4.height,
                                Text(
                                  formatDate(data.datetime,
                                      showDateWithTime: true),
                                  style: secondaryTextStyle(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ).expand(),
                            16.width,
                            Text(
                              data.activityData!.creditDebitAmount
                                  .validate()
                                  .toPriceFormat(),
                              style: boldTextStyle(
                                color: data.activityData != null &&
                                        data.activityData!.transactionType
                                            .isEmptyOrNull
                                    ? Colors.red
                                    : data.activityData != null &&
                                            data.activityData!.transactionType
                                                .toLowerCase()
                                                .contains(PAYMENT_STATUS_DEBIT)
                                        ? Colors.redAccent
                                        : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
                onNextPage: () {
                  if (!isLastPage) {
                    page++;
                    init();
                    setState(() {});
                  }
                },
                onSwipeRefresh: () async {
                  page = 1;
                  init();
                  setState(() {});
                  return await 2.seconds.delay;
                },
              );
            },
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                imageWidget: const ErrorStateWidget(),
                retryText: language.reload,
                onRetry: () {
                  page = 1;
                  appStore.setLoading(true);

                  init();
                  setState(() {});
                },
              );
            },
          ),
          Observer(
              builder: (_) =>
                  LoaderWidget().visible(appStore.isLoading && page != 1)),
        ],
      ),
    );
  }
}
