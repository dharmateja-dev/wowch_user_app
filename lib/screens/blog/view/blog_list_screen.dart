import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/screens/blog/blog_repository.dart';
import 'package:booking_system_flutter/screens/blog/component/blog_item_component.dart';
import 'package:booking_system_flutter/screens/blog/model/blog_response_model.dart';
import 'package:booking_system_flutter/screens/blog/shimmer/blog_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/base_scaffold_widget.dart';
import '../../../component/empty_error_state_widget.dart';
import '../../../component/loader_widget.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({Key? key}) : super(key: key);

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  // Flag to use dummy data for UI design
  static const bool USE_DUMMY_DATA = true;

  Future<List<BlogData>>? future;

  List<BlogData> blogList = [];

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  /// Initialize blog list - uses dummy data if flag is enabled, otherwise uses API
  void init() async {
    if (USE_DUMMY_DATA) {
      // Use dummy data for UI design
      future = Future.value(_getDummyBlogList());
      blogList = _getDummyBlogList();
      isLastPage = true;
    } else {
      // Use actual API call (backend logic remains intact)
      future = getBlogListAPI(
        blogData: blogList,
        page: page,
        lastPageCallback: (b) {
          isLastPage = b;
        },
      );
    }
  }

  /// Generate dummy blog data matching the design image
  /// Returns a list of 5 identical blog posts as shown in the design
  List<BlogData> _getDummyBlogList() {
    return List.generate(5, (index) {
      return BlogData(
        id: index + 1,
        title: "Rustin Home Decor Ideas To Create A Warm And...",
        description:
            "Discover amazing home decor ideas to create a warm and inviting atmosphere in your living space.",
        isFeatured: 0,
        totalViews: 0,
        authorId: 1,
        authorName: "Abdul Kader",
        authorImage:
            "https://i.pravatar.cc/150?img=12", // Placeholder for author profile
        status: 1,
        publishDate: "November 19, 2025",
        imageAttachments: [
          "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=400&fit=crop", // Home decor image
        ],
        createdAt: "2025-11-19",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.blogs,
      showLoader: false,
      child: Stack(
        children: [
          SnapHelperWidget<List<BlogData>>(
            initialData: cachedBlogList,
            future: future,
            loadingWidget: BlogShimmer(),
            onSuccess: (snap) {
              return AnimatedListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    vertical:
                        8), // Vertical padding only, horizontal handled by card margins
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                itemCount: snap.length,
                emptyWidget: NoDataWidget(
                    title: language.noBlogsFound,
                    imageWidget: const EmptyStateWidget()),
                shrinkWrap: true,
                onNextPage: () {
                  // Pagination logic - only works when not using dummy data
                  if (!USE_DUMMY_DATA && !isLastPage) {
                    page++;
                    appStore.setLoading(true);

                    init();
                    setState(() {});
                  }
                },
                onSwipeRefresh: () async {
                  // Refresh logic - only works when not using dummy data
                  if (!USE_DUMMY_DATA) {
                    page = 1;

                    init();
                    setState(() {});

                    return await 2.seconds.delay;
                  }
                  return await 2.seconds.delay;
                },
                disposeScrollController: true,
                itemBuilder: (BuildContext context, index) {
                  return BlogItemComponent(blogData: snap[index]);
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
          Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
