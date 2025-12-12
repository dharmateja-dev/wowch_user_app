import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/package_data_model.dart';
import 'package:booking_system_flutter/screens/blog/blog_repository.dart';
import 'package:booking_system_flutter/screens/blog/model/blog_detail_response.dart';
import 'package:booking_system_flutter/screens/blog/model/blog_response_model.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/cached_image_widget.dart';
import '../../../component/empty_error_state_widget.dart';
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

  /// Generate dummy blog detail data matching the design image
  /// Returns blog data with title "Rustin Home Decor ideas.", author "Abdul Kader", date "November 19, 2025"
  Future<BlogDetailResponse> _getDummyBlogDetail() async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay

    int blogId = widget.blogId.validate();

    // Hero image - woman with dark skin, dark hair, dark blue top
    List<Attachments> attachments = [
      Attachments(
        id: 1,
        url:
            'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&h=600&fit=crop',
      ),
    ];

    // Blog content text matching the design - about rustic interior design
    String htmlDescription = '''
      <div>
        <p style="font-size: 16px; line-height: 1.6; margin-bottom: 16px; color: #333333;">
          Rustic interior design style emphasizes nature, earthy beauty, and has evolved to include warmth, comfort, and freshness. The rustic style brings the outdoors inside, creating a cozy and inviting atmosphere that celebrates natural materials and textures.
        </p>
        
        <p style="font-size: 16px; line-height: 1.6; margin-bottom: 16px; color: #333333;">
          Rustic decor can be incorporated into various parts of a home, from the living room to the bedroom, kitchen, and even outdoor spaces. This style is popular for its balance of authenticity and elegance, making it a timeless choice for homeowners who appreciate natural beauty and comfort.
        </p>
        
        <p style="font-size: 16px; line-height: 1.6; margin-bottom: 16px; color: #333333;">
          The key elements of rustic design include exposed wood beams, stone accents, natural fabrics, and earthy color palettes. These elements work together to create a warm and welcoming environment that feels both sophisticated and down-to-earth.
        </p>
        
        <p style="font-size: 16px; line-height: 1.6; margin-bottom: 16px; color: #333333;">
          Whether you're looking to transform your entire home or just add rustic touches to specific rooms, this design style offers endless possibilities for creating a space that reflects your personal style and connection to nature.
        </p>
      </div>
    ''';

    BlogData blogDetail = BlogData(
      id: blogId,
      title: 'Rustin Home Decor ideas.',
      description: htmlDescription,
      isFeatured: 0,
      totalViews: 0,
      authorId: 1,
      authorName: 'Abdul Kader',
      authorImage:
          'https://i.pravatar.cc/150?img=12', // Man with glasses and beard
      status: 1,
      publishDate: 'November 19, 2025',
      createdAt: '2025-11-19',
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

  /// Get related blogs matching the design - returns list of blog cards for horizontal scrolling
  List<BlogData> _getRelatedBlogs() {
    List<BlogData> relatedBlogs = [];

    if (USE_DUMMY_DATA) {
      // Generate dummy related blogs matching the design
      // All show "Rustin Home Decor Ideas." with date "November 19, 2025"
      for (int i = 1; i <= 5; i++) {
        int relatedId = widget.blogId.validate() + i;
        relatedBlogs.add(BlogData(
          id: relatedId,
          title: 'Rustin Home Decor Ideas.',
          description: 'Sample blog description',
          isFeatured: 0,
          totalViews: 0,
          authorId: 1,
          authorName: 'Abdul Kader',
          authorImage: 'https://i.pravatar.cc/150?img=12',
          status: 1,
          publishDate: 'November 19, 2025',
          createdAt: '2025-11-19',
          imageAttachments: [
            'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=300&fit=crop'
          ],
          attachment: [
            Attachments(
              id: 1,
              url:
                  'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=300&fit=crop',
            )
          ],
          deletedAt: null,
        ));
      }
    } else {
      // Use cached blogs if available
      if (cachedBlogList != null && cachedBlogList!.isNotEmpty) {
        relatedBlogs = cachedBlogList!
            .where((blog) => blog.id != widget.blogId.validate())
            .take(5)
            .toList();
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
              // Column layout with overlapping card using Transform
              Column(
                children: [
                  // Hero image
                  SizedBox(
                    height: 280,
                    width: context.width(),
                    child: CachedImageWidget(
                      url: data.blogDetail!.imageAttachments
                              .validate()
                              .isNotEmpty
                          ? data.blogDetail!.imageAttachments!.first.validate()
                          : data.blogDetail!.attachment.validate().isNotEmpty
                              ? data.blogDetail!.attachment!.first.url
                                  .validate()
                              : '',
                      fit: BoxFit.cover,
                      height: 280,
                      width: context.width(),
                    ),
                  ),
                  // White content card with negative margin to overlap image
                  Transform.translate(
                    offset: Offset(0, -30),
                    child: Container(
                      width: context.width(),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          24.height,
                          // Blog title - large and bold
                          Text(
                            data.blogDetail!.title.validate(),
                            style: boldTextStyle(
                                size: 22, color: textPrimaryColorGlobal),
                          ).paddingSymmetric(horizontal: 16),

                          16.height,

                          // Author info section - profile picture, name, and date
                          Row(
                            children: [
                              // Circular author profile picture
                              ClipOval(
                                child: CachedImageWidget(
                                  url: data.blogDetail!.authorImage.validate(),
                                  height: 44,
                                  width: 44,
                                  fit: BoxFit.cover,
                                  radius: 0,
                                ),
                              ),
                              12.width,
                              // Author name and date column
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data.blogDetail!.authorName.validate(),
                                    style: boldTextStyle(
                                        size: 14,
                                        color: textPrimaryColorGlobal),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  4.height,
                                  Text(
                                    data.blogDetail!.publishDate.validate(),
                                    style: secondaryTextStyle(
                                        size: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ).paddingSymmetric(horizontal: 16),

                          24.height,

                          // Blog content text
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
                                    : Color(0xFF333333),
                              ),
                            },
                          ).paddingSymmetric(horizontal: 16),

                          // Related Blogs Section
                          if (relatedBlogs.isNotEmpty) ...[
                            32.height,
                            Text(
                              'Related Blogs',
                              style: boldTextStyle(
                                  size: 20, color: textPrimaryColorGlobal),
                            ).paddingSymmetric(horizontal: 16),
                            16.height,
                            // Horizontal scrollable related blogs
                            SizedBox(
                              height: 210,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                itemCount: relatedBlogs.length,
                                itemBuilder: (context, index) {
                                  BlogData blog = relatedBlogs[index];
                                  return Container(
                                    width: 130,
                                    margin: EdgeInsets.only(right: 12),
                                    decoration: boxDecorationWithRoundedCorners(
                                      borderRadius: radius(8),
                                    ),
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
                                          // Blog image
                                          ClipRRect(
                                            borderRadius: radiusOnly(
                                              topLeft: 8,
                                              topRight: 8,
                                              bottomLeft: 8,
                                              bottomRight: 8,
                                            ),
                                            child: CachedImageWidget(
                                              url: blog.imageAttachments
                                                      .validate()
                                                      .isNotEmpty
                                                  ? blog.imageAttachments!.first
                                                      .validate()
                                                  : '',
                                              fit: BoxFit.cover,
                                              height: 110,
                                              width: 150,
                                            ),
                                          ),
                                          8.height,
                                          // Blog title
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Text(
                                              blog.title.validate(),
                                              style: boldTextStyle(
                                                  size: 14,
                                                  color:
                                                      textPrimaryColorGlobal),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          4.height,
                                          // Publication date
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Text(
                                              blog.publishDate.validate(),
                                              style:
                                                  secondaryTextStyle(size: 12),
                                            ),
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
