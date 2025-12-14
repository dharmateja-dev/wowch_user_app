import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class ThemeSelectionDaiLog extends StatefulWidget {
  @override
  ThemeSelectionDaiLogState createState() => ThemeSelectionDaiLogState();
}

class ThemeSelectionDaiLogState extends State<ThemeSelectionDaiLog> {
  List<String> themeModeList = [
    language.appThemeLight,
    language.appThemeDark,
    language.appThemeDefault
  ];

  int? currentIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    currentIndex =
        getIntAsync(THEME_MODE_INDEX, defaultValue: THEME_MODE_SYSTEM);
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Close Button Row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    language.chooseTheme,
                    style: boldTextStyle(
                      size: 20,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    finish(context);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: Icon(
                      Icons.close,
                      color: context.icon,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Radio Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: themeModeList.length,
              itemBuilder: (BuildContext context, int index) {
                final isSelected = currentIndex == index;
                return InkWell(
                  onTap: () async {
                    int val = index;
                    currentIndex = val;

                    if (val == THEME_MODE_SYSTEM) {
                      appStore.setDarkMode(
                          context.platformBrightness() == Brightness.dark);
                    } else if (val == THEME_MODE_LIGHT) {
                      appStore.setDarkMode(false);
                      defaultToastBackgroundColor = Colors.black;
                      defaultToastTextColor = Colors.white;
                    } else if (val == THEME_MODE_DARK) {
                      appStore.setDarkMode(true);
                      defaultToastBackgroundColor = Colors.white;
                      defaultToastTextColor = Colors.black;
                    }
                    await setValue(THEME_MODE_INDEX, val);
                    setState(() {});

                    finish(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        // Custom Radio Button
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : primaryColor.withValues(alpha: 0.5),
                              width: isSelected ? 2.0 : 1.5,
                            ),
                            color:
                                isSelected ? primaryColor : Colors.transparent,
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        // Option Text
                        Text(
                          themeModeList[index],
                          style: primaryTextStyle(
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
