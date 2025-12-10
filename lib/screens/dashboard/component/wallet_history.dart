import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/extensions/num_extenstions.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/base_scaffold_widget.dart';
import '../../../component/empty_error_state_widget.dart';
import '../../../component/loader_widget.dart';
import '../../../model/user_wallet_history.dart';
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

    // Use a fixed date (June 6, 2025) or recent date
    final baseDate = DateTime(2025, 6, 6, 10, 30);

    final dummyData = <WalletDataElement>[
      // Debit - Paid For Booking ID #267
      WalletDataElement(
        id: 1,
        datetime: baseDate.subtract(Duration(hours: 1)).toIso8601String(),
        activityType: 'wallet',
        activityMessage: 'Paid For Booking ID #267',
        activityData: ActivityData(
          title: 'Debit',
          userId: 1,
          providerName: '',
          amount: 600.00,
          creditDebitAmount: 600.00,
          transactionId: 'TXN001',
          transactionType: PAYMENT_STATUS_DEBIT,
        ),
      ),
      // Credit - Wallet Topped up
      WalletDataElement(
        id: 2,
        datetime: baseDate.subtract(Duration(hours: 2)).toIso8601String(),
        activityType: 'wallet',
        activityMessage: 'Your Wallet has been Successfully Topped up.',
        activityData: ActivityData(
          title: 'Credit',
          userId: 1,
          providerName: '',
          amount: 600.00,
          creditDebitAmount: 600.00,
          transactionId: 'TXN002',
          transactionType: 'credit',
        ),
      ),
      // Credit - Wallet Topped up
      WalletDataElement(
        id: 3,
        datetime: baseDate.subtract(Duration(hours: 3)).toIso8601String(),
        activityType: 'wallet',
        activityMessage: 'Your Wallet has been Successfully Topped up.',
        activityData: ActivityData(
          title: 'Credit',
          userId: 1,
          providerName: '',
          amount: 600.00,
          creditDebitAmount: 600.00,
          transactionId: 'TXN003',
          transactionType: 'credit',
        ),
      ),
      // Debit - Paid For Booking ID #267
      WalletDataElement(
        id: 4,
        datetime: baseDate.subtract(Duration(hours: 4)).toIso8601String(),
        activityType: 'wallet',
        activityMessage: 'Paid For Booking ID #267',
        activityData: ActivityData(
          title: 'Debit',
          userId: 1,
          providerName: '',
          amount: 600.00,
          creditDebitAmount: 600.00,
          transactionId: 'TXN004',
          transactionType: PAYMENT_STATUS_DEBIT,
        ),
      ),
      // Debit - Paid For Booking ID #267
      WalletDataElement(
        id: 5,
        datetime: baseDate.subtract(Duration(hours: 5)).toIso8601String(),
        activityType: 'wallet',
        activityMessage: 'Paid For Booking ID #267',
        activityData: ActivityData(
          title: 'Debit',
          userId: 1,
          providerName: '',
          amount: 600.00,
          creditDebitAmount: 600.00,
          transactionId: 'TXN005',
          transactionType: PAYMENT_STATUS_DEBIT,
        ),
      ),
      // Credit - Wallet Topped up
      WalletDataElement(
        id: 6,
        datetime: baseDate.subtract(Duration(hours: 6)).toIso8601String(),
        activityType: 'wallet',
        activityMessage: 'Your Wallet has been Successfully Topped up.',
        activityData: ActivityData(
          title: 'Credit',
          userId: 1,
          providerName: '',
          amount: 800.00,
          creditDebitAmount: 800.00,
          transactionId: 'TXN006',
          transactionType: 'credit',
        ),
      ),
      // Debit - Paid For Booking ID #268
      WalletDataElement(
        id: 7,
        datetime: baseDate.subtract(Duration(hours: 7)).toIso8601String(),
        activityType: 'wallet',
        activityMessage: 'Paid For Booking ID #268',
        activityData: ActivityData(
          title: 'Debit',
          userId: 1,
          providerName: '',
          amount: 500.00,
          creditDebitAmount: 500.00,
          transactionId: 'TXN007',
          transactionType: PAYMENT_STATUS_DEBIT,
        ),
      ),
      // Credit - Wallet Topped up
      WalletDataElement(
        id: 8,
        datetime: baseDate.subtract(Duration(hours: 8)).toIso8601String(),
        activityType: 'wallet',
        activityMessage: 'Your Wallet has been Successfully Topped up.',
        activityData: ActivityData(
          title: 'Credit',
          userId: 1,
          providerName: '',
          amount: 1000.00,
          creditDebitAmount: 1000.00,
          transactionId: 'TXN008',
          transactionType: 'credit',
        ),
      ),
      // Debit - Paid For Booking ID #269
      WalletDataElement(
        id: 9,
        datetime: baseDate.subtract(Duration(hours: 9)).toIso8601String(),
        activityType: 'wallet',
        activityMessage: 'Paid For Booking ID #269',
        activityData: ActivityData(
          title: 'Debit',
          userId: 1,
          providerName: '',
          amount: 400.00,
          creditDebitAmount: 400.00,
          transactionId: 'TXN009',
          transactionType: PAYMENT_STATUS_DEBIT,
        ),
      ),
      // Credit - Wallet Topped up
      WalletDataElement(
        id: 10,
        datetime: baseDate.subtract(Duration(hours: 10)).toIso8601String(),
        activityType: 'wallet',
        activityMessage: 'Your Wallet has been Successfully Topped up.',
        activityData: ActivityData(
          title: 'Credit',
          userId: 1,
          providerName: '',
          amount: 1200.00,
          creditDebitAmount: 1200.00,
          transactionId: 'TXN010',
          transactionType: 'credit',
        ),
      ),
    ];

    // Set dummy available balance
    if (mounted) {
      setState(() {
        availableBalance = 2000.00;
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
                    32.height,
                    Text(language.lastTransaction,
                        style: boldTextStyle(size: 20)),
                    16.height,
                    AnimatedListView(
                      physics: const NeverScrollableScrollPhysics(),
                      //padding: const EdgeInsets.all(8),
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

                        // Determine if it's a debit transaction
                        final isDebit = data.activityData != null &&
                            (data.activityData!.transactionType.isEmptyOrNull ||
                                data.activityData!.transactionType
                                    .toLowerCase()
                                    .contains(PAYMENT_STATUS_DEBIT));

                        // Format date as "Month Day, Year" (e.g., "June 6, 2025")
                        String formattedDate = '';
                        try {
                          final dateTime = DateTime.parse(data.datetime);
                          formattedDate =
                              DateFormat('MMMM d, yyyy').format(dateTime);
                        } catch (e) {
                          formattedDate = formatDate(data.datetime);
                        }

                        // Get transaction type text
                        final transactionTypeText =
                            isDebit ? language.debit : language.credit;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: boxDecorationWithRoundedCorners(
                            borderRadius: BorderRadius.circular(8),
                            backgroundColor:
                                Color(0xFFE8F3EC),
                          ),
                          width: context.width(),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon with circular border
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDebit
                                      ? Colors.red.shade50
                                      : Colors.green.shade50,
                                  border: Border.all(
                                    color: isDebit ? Colors.red : Colors.green,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    isDebit
                                        ? ic_diagonal_right_up_arrow
                                        : ic_diagonal_left_down_arrow,
                                    height: 18,
                                    width: 18,
                                    color: isDebit ? Colors.red : Colors.green,
                                  ),
                                ),
                              ),
                              12.width,
                              // Transaction details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Transaction type (Debit/Credit)
                                    Text(
                                      transactionTypeText,
                                      style: boldTextStyle(size: 16),
                                    ),
                                    4.height,
                                    // Transaction description
                                    if (data.activityMessage
                                        .validate()
                                        .isNotEmpty)
                                      Text(
                                        data.activityMessage.validate(),
                                        style: primaryTextStyle(size: 12),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              12.width,
                              // Date and Amount on the right
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date on top
                                  Text(
                                    formattedDate,
                                    style: boldTextStyle(size: 12),
                                  ),
                                  8.height,
                                  // Amount below date
                                  Text(
                                    textAlign: TextAlign.start,
                                    data.activityData!.creditDebitAmount
                                        .validate()
                                        .toPriceFormat(),
                                    style: boldTextStyle(
                                      size: 14,
                                      color:
                                          isDebit ? Colors.red : Colors.green,
                                    ),
                                  ),
                                ],
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
            ).paddingAll(10),
            Observer(
                builder: (_) =>
                    LoaderWidget().visible(appStore.isLoading && page != 1)),
          ],
        ));
  }
}
