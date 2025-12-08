import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/package_data_model.dart';
import 'package:booking_system_flutter/screens/blog/blog_repository.dart';
import 'package:booking_system_flutter/screens/blog/component/blog_detail_header_component.dart';
import 'package:booking_system_flutter/screens/blog/model/blog_detail_response.dart';
import 'package:booking_system_flutter/screens/blog/model/blog_response_model.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/cached_image_widget.dart';
import '../../../component/empty_error_state_widget.dart';
import '../../../component/image_border_component.dart';
import '../shimmer/blog_detail_shimmer.dart';

class BlogDetailScreen extends StatefulWidget {
  final int blogId;

  BlogDetailScreen({required this.blogId});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  Future<BlogDetailResponse>? future;
  int page = 1;

  // Flag to use dummy data (set to true to test UI with dummy data)
  static const bool USE_DUMMY_DATA = true;

  @override
  void initState() {
    super.initState();
    setStatusBarColor(transparentColor, delayInMilliSeconds: 1000);
    init();
  }

  // Generate dummy blog detail data for UI testing
  Future<BlogDetailResponse> _getDummyBlogDetail() async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay

    int blogId = widget.blogId.validate();
    List<String> authorNames = [
      'John Doe',
      'Jane Smith',
      'Mike Johnson',
      'Sarah Williams',
      'David Brown'
    ];
    String authorName = authorNames[blogId % 5];

    // Generate multiple images for the blog
    List<Attachments> attachments = List.generate(
      4, // 4 images for gallery
      (index) => Attachments(
        id: index + 1,
        url: 'https://picsum.photos/800/600?random=${blogId * 10 + index}',
      ),
    );

    // Generate rich HTML content
    String htmlDescription = '''
      <div>
        <p style="font-size: 16px; line-height: 1.6; margin-bottom: 16px;">
          Welcome to our comprehensive guide on home maintenance and improvement. This article will provide you with valuable insights and practical tips to keep your home in excellent condition.
        </p>
        
        <h2 style="font-size: 20px; font-weight: bold; margin-top: 24px; margin-bottom: 12px;">Essential Home Maintenance Tips</h2>
        
        <p style="font-size: 16px; line-height: 1.6; margin-bottom: 16px;">
          Regular home maintenance is crucial for preserving the value of your property and ensuring a safe living environment. Here are some key areas to focus on:
        </p>
        
        <ul style="margin-left: 20px; margin-bottom: 16px;">
          <li style="margin-bottom: 8px;">Inspect and clean your HVAC system regularly</li>
          <li style="margin-bottom: 8px;">Check for water leaks and fix them immediately</li>
          <li style="margin-bottom: 8px;">Maintain your roof and gutters</li>
          <li style="margin-bottom: 8px;">Test smoke detectors and carbon monoxide alarms</li>
          <li style="margin-bottom: 8px;">Service your appliances annually</li>
        </ul>
        
        <h2 style="font-size: 20px; font-weight: bold; margin-top: 24px; margin-bottom: 12px;">Seasonal Maintenance Checklist</h2>
        
        <p style="font-size: 16px; line-height: 1.6; margin-bottom: 16px;">
          Different seasons require different maintenance tasks. In spring, focus on cleaning and preparing your home for warmer weather. Summer is ideal for outdoor projects and landscaping. Fall is perfect for preparing your home for winter, and winter maintenance focuses on keeping your home warm and safe.
        </p>
        
        <h2 style="font-size: 20px; font-weight: bold; margin-top: 24px; margin-bottom: 12px;">DIY vs Professional Services</h2>
        
        <p style="font-size: 16px; line-height: 1.6; margin-bottom: 16px;">
          While many home maintenance tasks can be done yourself, some require professional expertise. Electrical work, major plumbing issues, and structural repairs should always be handled by licensed professionals. For simple tasks like changing air filters, cleaning gutters, or painting, DIY can save you money and give you a sense of accomplishment.
        </p>
        
        <p style="font-size: 16px; line-height: 1.6; margin-bottom: 16px;">
          Remember, regular maintenance is an investment in your home's future. By staying proactive, you can prevent costly repairs and maintain your property's value for years to come.
        </p>
      </div>
    ''';

    BlogData blogDetail = BlogData(
      id: blogId,
      title: 'Complete Guide to Home Maintenance: Tips and Best Practices',
      description: htmlDescription,
      isFeatured: blogId % 3 == 0 ? 1 : 0,
      totalViews: 100 + (blogId * 23),
      authorId: 1 + (blogId % 5),
      authorName: authorName,
      authorImage: 'https://i.pravatar.cc/150?img=${blogId % 70}',
      status: 1,
      publishDate: DateTime.now()
          .subtract(Duration(days: blogId % 30))
          .toString()
          .split(' ')[0],
      createdAt:
          DateTime.now().subtract(Duration(days: blogId % 30)).toString(),
      imageAttachments: attachments.map((e) => e.url.validate()).toList(),
      attachment: attachments,
      deletedAt: null,
    );

    appStore.setLoading(false);

    return BlogDetailResponse(blogDetail: blogDetail);
  }

  void init() async {
    if (USE_DUMMY_DATA) {
      future = _getDummyBlogDetail();
    } else {
      future = getBlogDetailAPI({BlogKey.blogId: widget.blogId.validate()});
    }
  }

  // Get related blogs (excluding current blog)
  List<BlogData> _getRelatedBlogs() {
    List<BlogData> relatedBlogs = [];
    if (cachedBlogList != null && cachedBlogList!.isNotEmpty) {
      relatedBlogs = cachedBlogList!
          .where((blog) => blog.id != widget.blogId.validate())
          .take(5)
          .toList();
    }

    // If no cached blogs or not enough, generate dummy related blogs
    if (relatedBlogs.length < 3 && USE_DUMMY_DATA) {
      for (int i = 1; i <= 5; i++) {
        int relatedId = widget.blogId.validate() + i;
        if (relatedId != widget.blogId.validate()) {
          relatedBlogs.add(BlogData(
            id: relatedId,
            title: 'Rustin Home Decor Ideas',
            description: 'Sample blog description',
            isFeatured: 0,
            totalViews: 100 + (relatedId * 23),
            authorId: 1 + (relatedId % 5),
            authorName: [
              'John Doe',
              'Jane Smith',
              'Mike Johnson',
              'Sarah Williams',
              'David Brown'
            ][relatedId % 5],
            authorImage: 'https://i.pravatar.cc/150?img=${relatedId % 70}',
            status: 1,
            publishDate: DateTime.now()
                .subtract(Duration(days: relatedId % 30))
                .toString()
                .split(' ')[0],
            createdAt: DateTime.now()
                .subtract(Duration(days: relatedId % 30))
                .toString(),
            imageAttachments: [
              'https://picsum.photos/400/300?random=$relatedId'
            ],
            attachment: [
              Attachments(
                  id: 1, url: 'https://picsum.photos/400/300?random=$relatedId')
            ],
            deletedAt: null,
          ));
        }
      }
    }

    return relatedBlogs.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      leading: BackWidget(),
      appBarTitle: language.blogs,
      child: SnapHelperWidget<BlogDetailResponse>(
        future: future,
        initialData: cachedBlogDetail
            .firstWhere((element) => element?.$1 == widget.blogId.validate(),
                orElse: () => null)
            ?.$2,
        loadingWidget: BlogDetailShimmer(),
        onSuccess: (data) {
          List<BlogData> relatedBlogs = _getRelatedBlogs();

          return AnimatedScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
            padding: EdgeInsets.only(bottom: 120),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlogDetailHeaderComponent(blogData: data.blogDetail!),
                  // White card section with content - overlapping the image with rounded corners
                  Transform.translate(
                    offset:
                        const Offset(0, -20), // slight overlap over the image
                    child: Container(
                      width: context.width(),
                      decoration: boxDecorationWithRoundedCorners(
                        borderRadius: radiusOnly(topLeft: 20, topRight: 20),
                        backgroundColor: context.cardColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            data.blogDetail!.title.validate(),
                            style: boldTextStyle(size: 20),
                          ).paddingAll(16),

                          // Author info
                          Row(
                            children: [
                              ImageBorder(
                                src: data.blogDetail!.authorImage.validate(),
                                height: 30,
                              ),
                              8.width,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data.blogDetail!.authorName.validate(),
                                    style: primaryTextStyle(size: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (data.blogDetail!.publishDate
                                      .validate()
                                      .isNotEmpty)
                                    2.height,
                                  if (data.blogDetail!.publishDate
                                      .validate()
                                      .isNotEmpty)
                                    Text(
                                      data.blogDetail!.publishDate.validate(),
                                      style: secondaryTextStyle(size: 12),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ).expand(),
                            ],
                          ).paddingSymmetric(horizontal: 16),

                          16.height,

                          // Content
                          Html(
                            data: data.blogDetail!.description.validate(),
                            style: {
                              "div": Style(
                                margin: Margins.zero,
                              ),
                              "p": Style(
                                fontSize: FontSize(16),
                                lineHeight: LineHeight(1.6),
                                margin: Margins.only(bottom: 16),
                                color: appStore.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              "h2": Style(
                                fontSize: FontSize(20),
                                fontWeight: FontWeight.bold,
                                margin: Margins.only(top: 24, bottom: 12),
                                color: appStore.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              "ul": Style(
                                margin: Margins.only(left: 20, bottom: 16),
                              ),
                              "li": Style(
                                margin: Margins.only(bottom: 8),
                                color: appStore.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              "span": Style(
                                color: appStore.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            },
                          ).paddingSymmetric(horizontal: 16),

                          // Related Blogs Section
                          if (relatedBlogs.isNotEmpty) ...[
                            32.height,
                            Text(
                              'Related Blogs',
                              style: boldTextStyle(size: 18),
                            ).paddingSymmetric(horizontal: 16),
                            16.height,
                            SizedBox(
                              height: 220,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.symmetric(horizontal: 14),
                                itemCount: relatedBlogs.length,
                                itemBuilder: (context, index) {
                                  BlogData blog = relatedBlogs[index];
                                  return Container(
                                    //height: 160,
                                    width: 160,
                                    margin: EdgeInsets.only(right: 4),
                                    child: GestureDetector(
                                      onTap: () {
                                        BlogDetailScreen(
                                                blogId: blog.id.validate())
                                            .launch(context);
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: radius(),
                                            child: CachedImageWidget(
                                              url: blog.imageAttachments
                                                      .validate()
                                                      .isNotEmpty
                                                  ? blog.imageAttachments!.first
                                                      .validate()
                                                  : '',
                                              fit: BoxFit.cover,
                                              height: 150,
                                              width: 140,
                                            ),
                                          ),
                                          8.height,
                                          Text(
                                            blog.title.validate(),
                                            style: boldTextStyle(size: 14),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          4.height,
                                          Text(
                                            blog.publishDate.validate(),
                                            style: secondaryTextStyle(size: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            16.height,
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        errorBuilder: (error) {
          return NoDataWidget(
            title: error,
            imageWidget: ErrorStateWidget(),
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
    );
  }
}
