import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import '../utils/constant.dart';

class AppScaffold extends StatelessWidget {
  final String? appBarTitle;
  final List<Widget>? actions;
  final Widget child;
  final Color? scaffoldBackgroundColor;
  final Widget? bottomNavigationBar;
  final Observable<bool>? isLoading;
  final bool showLoader;
  final Widget? leading;

  AppScaffold({
    this.appBarTitle,
    required this.child,
    this.actions,
    this.scaffoldBackgroundColor,
    this.bottomNavigationBar,
    this.showLoader = true,
    this.isLoading,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final loading = showLoader && (isLoading?.value ?? false);
    return Scaffold(
      appBar: appBarTitle != null
          ? AppBar(
              centerTitle: true,
              title: Text(
                appBarTitle.validate(),
                style: boldTextStyle(
                    size: APP_BAR_TEXT_SIZE,
                    color: context.scaffoldBackgroundColor),
              ),
              elevation: 0.0,
              backgroundColor: context.primaryColor,
              leading: leading ?? (context.canPop ? BackWidget() : null),
              actions: actions,
            )
          : null,
      backgroundColor: scaffoldBackgroundColor,
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: loading,
            child: child,
          ),
          if (loading) LoaderWidget().center(),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
