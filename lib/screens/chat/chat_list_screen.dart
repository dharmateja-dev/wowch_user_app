import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/screens/auth/sign_in_screen.dart';
import 'package:booking_system_flutter/screens/chat/widget/user_item_widget.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/base_scaffold_widget.dart';
import '../../component/cached_image_widget.dart';
import '../../component/empty_error_state_widget.dart';
import 'user_chat_screen.dart';

// Set this to true to show dummy data for UI testing
const bool USE_DUMMY_DATA = true;

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<UserData> dummyUsers = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (USE_DUMMY_DATA) {
      _generateDummyData();
    }
  }

  void _generateDummyData() {
    dummyUsers = [
      UserData(
        uid: 'dummy_uid_1',
        firstName: 'John',
        lastName: 'Smith',
        displayName: 'John Smith',
        profileImage: '',
        email: 'john.smith@example.com',
        contactNumber: '+1234567890',
        isOnline: 1,
      ),
      UserData(
        uid: 'dummy_uid_2',
        firstName: 'Sarah',
        lastName: 'Johnson',
        displayName: 'Sarah Johnson',
        profileImage: '',
        email: 'sarah.johnson@example.com',
        contactNumber: '+1234567891',
        isOnline: 0,
      ),
      UserData(
        uid: 'dummy_uid_3',
        firstName: 'Michael',
        lastName: 'Brown',
        displayName: 'Michael Brown',
        profileImage: '',
        email: 'michael.brown@example.com',
        contactNumber: '+1234567892',
        isOnline: 1,
      ),
      UserData(
        uid: 'dummy_uid_4',
        firstName: 'Emily',
        lastName: 'Davis',
        displayName: 'Emily Davis',
        profileImage: '',
        email: 'emily.davis@example.com',
        contactNumber: '+1234567893',
        isOnline: 1,
      ),
      UserData(
        uid: 'dummy_uid_5',
        firstName: 'David',
        lastName: 'Wilson',
        displayName: 'David Wilson',
        profileImage: '',
        email: 'david.wilson@example.com',
        contactNumber: '+1234567894',
        isOnline: 0,
      ),
      UserData(
        uid: 'dummy_uid_6',
        firstName: 'Jessica',
        lastName: 'Martinez',
        displayName: 'Jessica Martinez',
        profileImage: '',
        email: 'jessica.martinez@example.com',
        contactNumber: '+1234567895',
        isOnline: 1,
      ),
      UserData(
        uid: 'dummy_uid_7',
        firstName: 'Robert',
        lastName: 'Taylor',
        displayName: 'Robert Taylor',
        profileImage: '',
        email: 'robert.taylor@example.com',
        contactNumber: '+1234567896',
        isOnline: 0,
      ),
      UserData(
        uid: 'dummy_uid_8',
        firstName: 'Amanda',
        lastName: 'Anderson',
        displayName: 'Amanda Anderson',
        profileImage: '',
        email: 'amanda.anderson@example.com',
        contactNumber: '+1234567897',
        isOnline: 1,
      ),
    ];
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.lblChat,
      child: Observer(builder: (context) {
        // Show dummy data if flag is enabled
        if (USE_DUMMY_DATA) {
          return _buildDummyDataList();
        }

        return SnapHelperWidget(
          future: Future.value(FirebaseAuth.instance.currentUser != null &&
              appStore.uid.isNotEmpty),
          onSuccess: (isLoggedIn) {
            if (!isLoggedIn) {
              return NoDataWidget(
                title: language.youAreNotConnectedWithChatServer,
                subTitle: language.NotConnectedWithChatServerMessage,
                onRetry: () async {
                  if (!appStore.isLoggedIn) {
                    const SignInScreen().launch(context);
                  } else {
                    appStore.setLoading(true);
                    await authService.verifyFirebaseUser().then((value) {
                      setState(() {});
                    }).catchError((e) {
                      toast(e.toString());
                    });
                    appStore.setLoading(false);
                  }
                },
                retryText: language.connect,
                imageWidget: const EmptyStateWidget(),
              ).paddingSymmetric(horizontal: 16);
            } else {
              return FirestorePagination(
                query: chatServices.fetchChatListQuery(userId: appStore.uid),
                physics: const AlwaysScrollableScrollPhysics(),
                isLive: true,
                shrinkWrap: true,
                itemBuilder: (context, snap, index) {
                  UserData contact = UserData.fromJson(
                      snap[index].data() as Map<String, dynamic>);
                  return UserItemWidget(userUid: contact.uid.validate());
                },
                initialLoader: LoaderWidget(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 10),
                padding:
                    const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8),
                limit: PER_PAGE_CHAT_LIST_COUNT,
                separatorBuilder: (_, i) =>
                    Divider(height: 0, indent: 0, color: context.dividerColor),
                viewType: ViewType.list,
                onEmpty: NoDataWidget(
                  title: language.noConversation,
                  subTitle: language.noConversationSubTitle,
                  imageWidget: const EmptyStateWidget(),
                ).paddingSymmetric(horizontal: 16),
              );
            }
          },
          loadingWidget: LoaderWidget(),
          errorBuilder: (p0) {
            return NoDataWidget(
              title: p0,
              imageWidget: const ErrorStateWidget(),
            );
          },
        );
      }),
    );
  }

  Widget _buildDummyDataList() {
    if (dummyUsers.isEmpty) {
      return NoDataWidget(
        title: language.noConversation,
        subTitle: language.noConversationSubTitle,
        imageWidget: const EmptyStateWidget(),
      ).paddingSymmetric(horizontal: 16);
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8),
      itemCount: dummyUsers.length,
      separatorBuilder: (_, i) => Divider(
        height: 0,
        indent: 0,
        color: context.dividerColor,
      ),
      itemBuilder: (context, index) {
        UserData user = dummyUsers[index];
        return _DummyUserItemWidget(userData: user, index: index);
      },
    );
  }
}

// Dummy widget that mimics UserItemWidget but without StreamBuilder dependencies
class _DummyUserItemWidget extends StatelessWidget {
  final UserData userData;
  final int index;

  const _DummyUserItemWidget({required this.userData, required this.index});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to chat screen with dummy user data
        UserChatScreen(receiverUser: userData).launch(
          context,
          pageRouteAnimation: PageRouteAnimation.Fade,
          duration: 300.milliseconds,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (userData.profileImage.validate().isEmpty)
              Container(
                height: 40,
                width: 40,
                padding: const EdgeInsets.all(6),
                color: context.primaryColor.withValues(alpha: 0.2),
                child: Text(
                  userData.displayName.validate()[0].validate().toUpperCase(),
                  style: boldTextStyle(color: context.primaryColor),
                ).center().fit(),
              ).cornerRadiusWithClipRRect(50)
            else
              CachedImageWidget(
                url: userData.profileImage.validate(),
                height: 40,
                circle: true,
                fit: BoxFit.cover,
              ),
            8.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      userData.firstName.validate() +
                          " " +
                          userData.lastName.validate(),
                      style: boldTextStyle(),
                      maxLines: 1,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Dummy unread count badge (random for demo)
                    if (index % 3 == 0)
                      Container(
                        height: 18,
                        width: 18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: primaryColor,
                        ),
                        child: Text(
                          '${(index % 5) + 1}',
                          style: secondaryTextStyle(color: white),
                          textAlign: TextAlign.center,
                        ).center(),
                      ),
                  ],
                ),
                // Dummy last message
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getDummyLastMessage(index),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: primaryTextStyle(size: 14),
                    ).expand(),
                    16.width,
                    Text(
                      _getDummyTime(index),
                      style: primaryTextStyle(size: 10),
                    ),
                  ],
                ).paddingTop(2),
              ],
            ).expand()
          ],
        ),
      ),
    );
  }

  String _getDummyLastMessage(int index) {
    List<String> messages = [
      'Hello! How are you?',
      'Thanks for your help!',
      'Can we schedule a meeting?',
      'I\'ll be there in 10 minutes',
      'See you soon!',
      'Great work!',
      'Let me know when you\'re available',
      'Perfect, thank you!',
    ];
    return messages[index % messages.length];
  }

  String _getDummyTime(int index) {
    List<String> times = [
      'Just now',
      'Yesterday',
      'June 6, 2025',
      'June 5, 2025',
      'June 4, 2025',
      'June 3, 2025',
      'June 2, 2025',
      'June 1, 2025',
    ];
    return times[index % times.length];
  }
}
