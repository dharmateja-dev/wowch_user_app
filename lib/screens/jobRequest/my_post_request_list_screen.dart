import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/get_my_post_job_list_response.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/jobRequest/components/my_post_request_item_component.dart';
import 'package:booking_system_flutter/screens/jobRequest/create_post_request_screen.dart';
import 'package:booking_system_flutter/screens/jobRequest/shimmer/my_post_job_shimmer.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/base_scaffold_widget.dart';
import '../../component/empty_error_state_widget.dart';

class MyPostRequestListScreen extends StatefulWidget {
  @override
  _MyPostRequestListScreenState createState() =>
      _MyPostRequestListScreenState();
}

class _MyPostRequestListScreenState extends State<MyPostRequestListScreen> {
  static const bool USE_DUMMY_DATA = true;

  late Future<List<PostJobData>> future;
  List<PostJobData> postJobList = [];

  int page = 1;
  bool isLastPage = false;
  bool isApiCalled = false;

  @override
  void initState() {
    super.initState();
    init();
    getLocation();
  }

  List<PostJobData> getDummyPostJobs() {
    return [
      PostJobData(
        id: 1,
        title: 'Nurses',
        price: 600,
        jobPrice: 60,
        status: JOB_REQUEST_STATUS_REQUESTED,
        createdAt: '2025-06-10',
        service: [
          ServiceData(attachments: [
            'https://images.pexels.com/photos/3985166/pexels-photo-3985166.jpeg?auto=compress&cs=tinysrgb&w=800'
          ])
        ],
      ),
      PostJobData(
        id: 2,
        title: 'Nurses',
        price: 600,
        jobPrice: 60,
        status: JOB_REQUEST_STATUS_REQUESTED,
        createdAt: '2025-06-10',
        service: [
          ServiceData(attachments: [
            'https://images.pexels.com/photos/3985166/pexels-photo-3985166.jpeg?auto=compress&cs=tinysrgb&w=800'
          ])
        ],
      ),
      PostJobData(
        id: 3,
        title: 'Nurses',
        price: 600,
        jobPrice: 60,
        status: JOB_REQUEST_STATUS_REQUESTED,
        createdAt: '2025-06-10',
        service: [
          ServiceData(attachments: [
            'https://images.pexels.com/photos/3985166/pexels-photo-3985166.jpeg?auto=compress&cs=tinysrgb&w=800'
          ])
        ],
      ),
    ];
  }

  Future<void> init() async {
    if (USE_DUMMY_DATA) {
      final dummy = getDummyPostJobs();
      cachedPostJobList = dummy;
      future = Future.value(dummy);
      appStore.setLoading(false);
    } else {
      future = getPostJobList(page, postJobList: postJobList,
          lastPageCallBack: (val) {
        isLastPage = val;
      });
    }
  }

  void getLocation() {
    Geolocator.requestPermission().then((value) {
      if (value == LocationPermission.whileInUse ||
          value == LocationPermission.always) {
        Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        )).then((value) {
          appStore.setLatitude(value.latitude);
          appStore.setLongitude(value.longitude);
          setState(() {});
        }).catchError(onError);
      }
    });
  }

  @override
  void dispose() {
    setStatusBarColor(Colors.transparent,
        statusBarIconBrightness:
            appStore.isDarkMode ? Brightness.light : Brightness.dark);
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.myPostJobList,
      child: Stack(
        children: [
          SnapHelperWidget<List<PostJobData>>(
            future: future,
            initialData: cachedPostJobList,
            onSuccess: (data) {
              return AnimatedListView(
                itemCount: data.length,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 12, bottom: 70),
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                itemBuilder: (_, i) {
                  PostJobData postJob = data[i];

                  return MyPostRequestItemComponent(
                    data: postJob,
                    callback: (v) {
                      appStore.setLoading(v);

                      if (v) {
                        page = 1;
                        init();
                        setState(() {});
                      }
                    },
                  );
                },
                emptyWidget: NoDataWidget(
                  title: language.noPostJobFound,
                  subTitle: language.noPostJobFoundSubtitle,
                  imageWidget: const EmptyStateWidget(),
                ),
                onNextPage: () {
                  if (!isLastPage) {
                    page++;
                    appStore.setLoading(true);

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
            loadingWidget: MyPostJobShimmer(),
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
          Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading))
        ],
      ),
      bottomNavigationBar: AppButton(
        child: Text(language.requestNewJob,
            style: context.boldTextStyle(color: white)),
        color: context.primaryColor,
        width: context.width(),
        onTap: () async {
          bool? res = await CreatePostRequestScreen().launch(context);

          if (res ?? false) {
            page = 1;
            init();
            setState(() {});
          }
        },
      ).paddingAll(16),
    );
  }
}
