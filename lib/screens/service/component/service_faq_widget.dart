import 'package:booking_system_flutter/model/service_detail_response.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class ServiceFaqWidget extends StatelessWidget {
  const ServiceFaqWidget({Key? key, required this.serviceFaq})
      : super(key: key);

  final ServiceFaq serviceFaq;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        splashColor: Colors.transparent,
        clipBehavior: Clip.none,
        title: Text(
          serviceFaq.title.validate(),
          style: context.boldTextStyle(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          ListTile(
            contentPadding: const EdgeInsets.only(left: 8),
            title: Text(
              serviceFaq.description.validate(),
              style: context.primaryTextStyle(),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }
}
