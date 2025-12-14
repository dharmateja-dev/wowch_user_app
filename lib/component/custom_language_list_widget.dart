import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/common.dart';

/// Custom Language List Widget that shows language names in their native language
/// and uses checkbox for selected language
class CustomLanguageListWidget extends StatefulWidget {
  final ScrollPhysics? scrollPhysics;
  final void Function(LanguageDataModel)? onLanguageChange;

  const CustomLanguageListWidget({
    this.onLanguageChange,
    this.scrollPhysics,
    super.key,
  });

  @override
  CustomLanguageListWidgetState createState() =>
      CustomLanguageListWidgetState();
}

class CustomLanguageListWidgetState extends State<CustomLanguageListWidget> {
  // Map of language codes to their native names
  final Map<String, String> nativeLanguageNames = {
    'en': 'English',
    'hi': 'हिंदी',
    'ar': 'العربية',
    'fr': 'Français',
    'de': 'Deutsch',
  };

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

  String getNativeName(LanguageDataModel data) {
    return nativeLanguageNames[data.languageCode] ?? data.name.validate();
  }

  Widget buildImageWidget(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(imagePath, width: 24);
    } else {
      return Image.asset(imagePath, width: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (_, index) {
        LanguageDataModel data = languageList()[index];
        bool isSelected = getStringAsync(SELECTED_LANGUAGE_CODE) ==
            data.languageCode.validate();

        return SettingItemWidget(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: getNativeName(data),
          subTitle: data.subTitle,
          leading: (data.flag != null) ? buildImageWidget(data.flag!) : null,
          trailing: Checkbox(
            value: isSelected,
            onChanged: (value) async {
              await setValue(SELECTED_LANGUAGE_CODE, data.languageCode);
              setState(() {});
              widget.onLanguageChange?.call(data);
            },
            activeColor: context.primary,
            checkColor: Colors.white,
            side: BorderSide(color: context.primary, width: 2.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          onTap: () async {
            await setValue(SELECTED_LANGUAGE_CODE, data.languageCode);
            setState(() {});
            widget.onLanguageChange?.call(data);
          },
        );
      },
      shrinkWrap: true,
      physics: widget.scrollPhysics,
      itemCount: languageList().length,
    );
  }
}
