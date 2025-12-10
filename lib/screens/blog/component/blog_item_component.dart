import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/screens/blog/model/blog_response_model.dart';
import 'package:booking_system_flutter/screens/blog/view/blog_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class BlogItemComponent extends StatefulWidget {
  final BlogData? blogData;

  BlogItemComponent({this.blogData});

  @override
  State<BlogItemComponent> createState() => _BlogItemComponentState();
}

class _BlogItemComponentState extends State<BlogItemComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        BlogDetailScreen(blogId: widget.blogData!.id.validate())
            .launch(context);
      },
      child: Container(
        // Card styling matching the design - light green background with rounded corners
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: boxDecorationWithRoundedCorners(
          borderRadius: radius(12), // Rounded corners as shown in design
          backgroundColor: Color(0xFFE8F3EC), // Light green background
          border: appStore.isDarkMode
              ? Border.all(color: context.dividerColor)
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail image on the left - square with rounded corners
            ClipRRect(
              borderRadius: radius(8),
              child: CachedImageWidget(
                url: widget.blogData!.imageAttachments.validate().isNotEmpty
                    ? widget.blogData!.imageAttachments!.first.validate()
                    : '',
                fit: BoxFit.cover,
                height: 80,
                width: 80,
                radius: 0, // No radius here as we're using ClipRRect
              ),
            ),
            12.width, // Spacing between image and content
            // Content section on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Blog title - truncated with ellipsis as shown in design
                  Text(
                    widget.blogData!.title.validate(),
                    style:
                        boldTextStyle(size: 14, color: textPrimaryColorGlobal),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  8.height, // Spacing between title and author info
                  // Author information row
                  Row(
                    children: [
                      // Circular author profile picture
                      ClipOval(
                        child: CachedImageWidget(
                          url: widget.blogData!.authorImage.validate(),
                          height: 30,
                          width: 30,
                          fit: BoxFit.cover,
                          radius: 0,
                        ),
                      ),
                      8.width, // Spacing between profile picture and name
                      // Author name
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.blogData!.authorName.validate(),
                            style: primaryTextStyle(size: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.blogData!.publishDate.validate(),
                            style: secondaryTextStyle(size: 11),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Publication date
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
