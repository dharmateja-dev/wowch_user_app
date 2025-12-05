import 'dart:async';

import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/cached_image_widget.dart';
import '../../../component/price_widget.dart';
import '../../withdraw/wallet_request.dart';
import '../user_wallet_balance_screen.dart';

class WalletCard extends StatefulWidget {
  final num availableBalance;
  final FutureOr<dynamic> Function(dynamic)? callback;
  const WalletCard({super.key, required this.availableBalance, this.callback});

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      width: context.width(),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: primaryColor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 70,
            width: context.width(),
            child: Card(
              color: context.scaffoldBackgroundColor,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language.availableBalance, style: boldTextStyle()),
                    FittedBox(
                      child: PriceWidget(
                          price: widget.availableBalance.validate(),
                          size: 18,
                          color: context.primaryColor,
                          isBoldText: true),
                    ),
                  ],
                ),
              ),
            ),
          ),
          12.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextIcon(
                onTap: () {
                  WithdrawRequest(
                    availableBalance: widget.availableBalance,
                  ).launch(context).then(widget.callback!);
                },
                suffix: const CachedImageWidget(
                  url: ic_plus,
                  height: 16,
                  width: 16,
                  color: white,
                ),
                textStyle: boldTextStyle(color: whiteColor),
                text: language.withdraw,
              ),
              TextIcon(
                onTap: () {
                  UserWalletBalanceScreen(isBackScreen: true)
                      .launch(context)
                      .then(widget.callback!);
                },
                suffix: const CachedImageWidget(
                  url: ic_plus,
                  height: 16,
                  width: 16,
                  color: white,
                ),
                textStyle: boldTextStyle(color: whiteColor),
                text: language.topUp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
