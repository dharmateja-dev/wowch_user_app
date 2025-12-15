import 'dart:async';
import 'dart:io';

import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/chat_message_model.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/screens/chat/widget/chat_item_widget.dart';
import 'package:booking_system_flutter/services/notification_services.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/cached_image_widget.dart';
import '../../services/chat_services.dart';
import '../../utils/configs.dart';
import '../../utils/getImage.dart';
import '../../utils/images.dart';
import '../../utils/string_extensions.dart';
import 'send_file_screen.dart';

// Set this to true to show dummy data for UI testing
const bool USE_DUMMY_DATA = true;

class UserChatScreen extends StatefulWidget {
  final UserData receiverUser;
  final bool isChattingAllow;

  UserChatScreen({required this.receiverUser, this.isChattingAllow = false});

  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen>
    with WidgetsBindingObserver {
  TextEditingController messageCont = TextEditingController();

  FocusNode messageFocus = FocusNode();

  UserData senderUser = UserData();

  StreamSubscription? _streamSubscription;

  int isReceiverOnline = 0;

  bool get isReceiverUserOnline => isReceiverOnline == 1;

  List<ChatMessageModel> dummyMessages = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    WidgetsBinding.instance.addObserver(this);

    //OneSignal.shared.disablePush(true);

    if (USE_DUMMY_DATA) {
      _generateDummyMessages();
      appStore.setLoading(false);
      setState(() {});
      return;
    }

    if (widget.receiverUser.uid.validate().isEmpty) {
      await userService
          .getUser(email: widget.receiverUser.email.validate())
          .then((value) {
        widget.receiverUser.uid = value.uid;
      }).catchError((e) {
        log(e.toString());
      });
    }

    senderUser =
        await userService.getUser(email: appStore.userEmail.validate());
    appStore.setLoading(false);
    setState(() {});

    if (await userService.isReceiverInContacts(
        senderUserId: appStore.uid.validate(),
        receiverUserId: widget.receiverUser.uid.validate())) {
      await chatServices
          .setUnReadStatusToTrue(
              senderId: appStore.uid.validate(),
              receiverId: widget.receiverUser.uid.validate())
          .catchError((e) {
        toast(e.toString());
      });

      log("receiver ID ${widget.receiverUser.uid}");
      chatServices.setOnlineCount(
          senderId: widget.receiverUser.uid.validate(),
          receiverId: appStore.uid.validate(),
          status: 1);
      //
      _streamSubscription = chatServices
          .isReceiverOnline(
              senderId: appStore.uid.validate(),
              receiverUserId: widget.receiverUser.uid.validate())
          .listen((event) {
        isReceiverOnline = event.isOnline.validate();
        log("=======*=======*=======*=======*=======* User $isReceiverOnline =======*=======*=======*=======*=======");
      });
    }
  }

  //region Widget
  Widget _buildChatFieldWidget() {
    return Row(
      children: [
        AppTextField(
          textStyle: context.primaryTextStyle(),
          textFieldType: TextFieldType.OTHER,
          controller: messageCont,
          minLines: 1,
          onFieldSubmitted: (s) {
            sendMessages();
          },
          focus: messageFocus,
          cursorHeight: 20,
          maxLines: 5,
          cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          suffix: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Transform.rotate(
                    angle: -0.75,
                    child: const Icon(Icons.attach_file_outlined)),
                onPressed: () {
                  if (!appStore.isLoading) {
                    _handleDocumentClick();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined),
                onPressed: () {
                  if (!appStore.isLoading) {
                    _handleCameraClick();
                  }
                },
              ),
            ],
          ),
          decoration: inputDecoration(context).copyWith(
              hintText: language.message,
              hintStyle: context.primaryTextStyle()),
        ).expand(),
        8.width,
        IconButton(
          icon: ic_send_message.iconImage(
            context: context,
            size: 32,
          ),
          onPressed: () {
            sendMessages();
          },
        )
      ],
    );
  }

  //endregion

  //region Methods
  Future<void> sendMessages({
    bool isFile = false,
    List<String> attachmentFiles = const [],
  }) async {
    if (appStore.isLoading) return;
    // If Message TextField is Empty.
    if (messageCont.text.trim().isEmpty && !isFile) {
      messageFocus.requestFocus();
      return;
    } else if (isFile && attachmentFiles.isEmpty) {
      return;
    }

    // Making Request for sending data to firebase
    ChatMessageModel data = ChatMessageModel();

    data.receiverId = widget.receiverUser.uid;
    data.senderId = appStore.uid;
    data.message = messageCont.text;
    data.isMessageRead = isReceiverOnline == 1;
    data.createdAt = DateTime.now().millisecondsSinceEpoch;
    data.createdAtTime = Timestamp.now();
    data.updatedAtTime = Timestamp.now();
    data.messageType = isFile ? MessageType.Files.name : MessageType.TEXT.name;
    data.attachmentfiles = attachmentFiles;
    log('ChatMessageModel Data : ${data.toJson()}');
    messageCont.clear();

    if (!(await userService.isReceiverInContacts(
        senderUserId: appStore.uid.validate(),
        receiverUserId: widget.receiverUser.uid.validate()))) {
      log("========Adding To Contacts=========");
      await chatServices.addToContacts(
        senderId: data.senderId,
        receiverId: data.receiverId,
        receiverName: widget.receiverUser.displayName.validate(),
        senderName: senderUser.displayName.validate(),
      );
      _streamSubscription = chatServices
          .isReceiverOnline(
              senderId: appStore.uid.validate(),
              receiverUserId: widget.receiverUser.uid.validate())
          .listen((event) {
        isReceiverOnline = event.isOnline.validate();
        log("=======*=======*=======*=======*=======* User $isReceiverOnline =======*=======*=======*=======*=======");
      });
    }
    log('-------addMessage----');
    await chatServices.addMessage(data).then((value) async {
      log("--Message Successfully Added--");
      // todo : remove this
      isReceiverOnline = 0;
      if (isReceiverOnline != 1) {
        /// Send Notification
        NotificationService()
            .sendPushNotifications(
          appStore.userFullName,
          data.message.validate(),
          image: data.attachmentfiles == null || data.attachmentfiles!.isEmpty
              ? null
              : data.attachmentfiles!.first,
          receiverUser: widget.receiverUser,
          senderUserData: senderUser,
        )
            .catchError((e) {
          log("Notification Error ${e.toString()}");
        });
      }

      /// Save receiverId to Sender Doc.
      userService
          .saveToContacts(
              senderId: appStore.uid,
              receiverId: widget.receiverUser.uid.validate())
          .then((value) => log("---ReceiverId to Sender Doc.---"))
          .catchError((e) {
        log(e.toString());
      });

      /// Save senderId to Receiver Doc.
      userService
          .saveToContacts(
              senderId: widget.receiverUser.uid.validate(),
              receiverId: appStore.uid)
          .then((value) => log("---SenderId to Receiver Doc.---"))
          .catchError((e) {
        log(e.toString());
      });

      /// ENd
    }).catchError((e) {
      log(e.toString());
    });
  }

  //endregion

  void _generateDummyMessages() {
    DateTime now = DateTime.now();
    String currentUserId = appStore.uid.validate().isNotEmpty
        ? appStore.uid.validate()
        : 'current_user_123'; // Dummy current user ID
    String receiverUserId = widget.receiverUser.uid.validate().isNotEmpty
        ? widget.receiverUser.uid.validate()
        : 'receiver_user_456';

    dummyMessages = [
      // Recent messages (today)
      ChatMessageModel(
        uid: 'msg_1',
        senderId: currentUserId,
        receiverId: receiverUserId,
        message: 'Hello! How are you doing today?',
        messageType: MessageType.TEXT.name,
        isMessageRead: true,
        createdAt:
            now.subtract(const Duration(minutes: 5)).millisecondsSinceEpoch,
        createdAtTime:
            Timestamp.fromDate(now.subtract(const Duration(minutes: 5))),
        updatedAtTime:
            Timestamp.fromDate(now.subtract(const Duration(minutes: 5))),
      )..isMe = true,
      ChatMessageModel(
        uid: 'msg_2',
        senderId: receiverUserId,
        receiverId: currentUserId,
        message: 'Hi! I\'m doing great, thanks for asking. How about you?',
        messageType: MessageType.TEXT.name,
        isMessageRead: true,
        createdAt:
            now.subtract(const Duration(minutes: 4)).millisecondsSinceEpoch,
        createdAtTime:
            Timestamp.fromDate(now.subtract(const Duration(minutes: 4))),
        updatedAtTime:
            Timestamp.fromDate(now.subtract(const Duration(minutes: 4))),
      )..isMe = false,
      ChatMessageModel(
        uid: 'msg_3',
        senderId: currentUserId,
        receiverId: receiverUserId,
        message:
            'I\'m good too! Just wanted to check if you\'re available for a quick chat.',
        messageType: MessageType.TEXT.name,
        isMessageRead: true,
        createdAt:
            now.subtract(const Duration(minutes: 3)).millisecondsSinceEpoch,
        createdAtTime:
            Timestamp.fromDate(now.subtract(const Duration(minutes: 3))),
        updatedAtTime:
            Timestamp.fromDate(now.subtract(const Duration(minutes: 3))),
      )..isMe = true,
      ChatMessageModel(
        uid: 'msg_4',
        senderId: receiverUserId,
        receiverId: currentUserId,
        message: 'Sure! What would you like to discuss?',
        messageType: MessageType.TEXT.name,
        isMessageRead: true,
        createdAt:
            now.subtract(const Duration(minutes: 2)).millisecondsSinceEpoch,
        createdAtTime:
            Timestamp.fromDate(now.subtract(const Duration(minutes: 2))),
        updatedAtTime:
            Timestamp.fromDate(now.subtract(const Duration(minutes: 2))),
      )..isMe = false,
      ChatMessageModel(
        uid: 'msg_5',
        senderId: currentUserId,
        receiverId: receiverUserId,
        message:
            'I wanted to follow up on our previous conversation about the project timeline.',
        messageType: MessageType.TEXT.name,
        isMessageRead: false,
        createdAt:
            now.subtract(const Duration(minutes: 1)).millisecondsSinceEpoch,
        createdAtTime:
            Timestamp.fromDate(now.subtract(const Duration(minutes: 1))),
        updatedAtTime:
            Timestamp.fromDate(now.subtract(const Duration(minutes: 1))),
      )..isMe = true,
      // Yesterday's messages
      ChatMessageModel(
        uid: 'msg_6',
        senderId: receiverUserId,
        receiverId: currentUserId,
        message: 'Thanks for the update! I\'ll review it and get back to you.',
        messageType: MessageType.TEXT.name,
        isMessageRead: true,
        createdAt: now
            .subtract(const Duration(days: 1, hours: 2))
            .millisecondsSinceEpoch,
        createdAtTime:
            Timestamp.fromDate(now.subtract(const Duration(days: 1, hours: 2))),
        updatedAtTime:
            Timestamp.fromDate(now.subtract(const Duration(days: 1, hours: 2))),
      )..isMe = false,
      ChatMessageModel(
        uid: 'msg_7',
        senderId: currentUserId,
        receiverId: receiverUserId,
        message: 'Perfect! Let me know if you need any clarification.',
        messageType: MessageType.TEXT.name,
        isMessageRead: true,
        createdAt: now
            .subtract(const Duration(days: 1, hours: 1))
            .millisecondsSinceEpoch,
        createdAtTime:
            Timestamp.fromDate(now.subtract(const Duration(days: 1, hours: 1))),
        updatedAtTime:
            Timestamp.fromDate(now.subtract(const Duration(days: 1, hours: 1))),
      )..isMe = true,
      // Older messages
      ChatMessageModel(
        uid: 'msg_8',
        senderId: receiverUserId,
        receiverId: currentUserId,
        message: 'Will do! Have a great day! 😊',
        messageType: MessageType.TEXT.name,
        isMessageRead: true,
        createdAt: now.subtract(const Duration(days: 2)).millisecondsSinceEpoch,
        createdAtTime:
            Timestamp.fromDate(now.subtract(const Duration(days: 2))),
        updatedAtTime:
            Timestamp.fromDate(now.subtract(const Duration(days: 2))),
      )..isMe = false,
      ChatMessageModel(
        uid: 'msg_9',
        senderId: currentUserId,
        receiverId: receiverUserId,
        message: 'You too! Talk to you soon.',
        messageType: MessageType.TEXT.name,
        isMessageRead: true,
        createdAt: now
            .subtract(const Duration(days: 2, minutes: 30))
            .millisecondsSinceEpoch,
        createdAtTime: Timestamp.fromDate(
            now.subtract(const Duration(days: 2, minutes: 30))),
        updatedAtTime: Timestamp.fromDate(
            now.subtract(const Duration(days: 2, minutes: 30))),
      )..isMe = true,
      ChatMessageModel(
        uid: 'msg_10',
        senderId: receiverUserId,
        receiverId: currentUserId,
        message: 'Hey! Just wanted to check in and see how things are going.',
        messageType: MessageType.TEXT.name,
        isMessageRead: true,
        createdAt: now.subtract(const Duration(days: 3)).millisecondsSinceEpoch,
        createdAtTime:
            Timestamp.fromDate(now.subtract(const Duration(days: 3))),
        updatedAtTime:
            Timestamp.fromDate(now.subtract(const Duration(days: 3))),
      )..isMe = false,
      ChatMessageModel(
        uid: 'msg_11',
        senderId: currentUserId,
        receiverId: receiverUserId,
        message: 'Everything is going smoothly. Thanks for checking!',
        messageType: MessageType.TEXT.name,
        isMessageRead: true,
        createdAt: now
            .subtract(const Duration(days: 3, hours: 1))
            .millisecondsSinceEpoch,
        createdAtTime:
            Timestamp.fromDate(now.subtract(const Duration(days: 3, hours: 1))),
        updatedAtTime:
            Timestamp.fromDate(now.subtract(const Duration(days: 3, hours: 1))),
      )..isMe = true,
      // File message example
      ChatMessageModel(
        uid: 'msg_12',
        senderId: receiverUserId,
        receiverId: currentUserId,
        message: 'Here\'s the document you requested.',
        messageType: MessageType.Files.name,
        isMessageRead: true,
        attachmentfiles: ['https://example.com/document.pdf'],
        createdAt: now.subtract(const Duration(days: 4)).millisecondsSinceEpoch,
        createdAtTime:
            Timestamp.fromDate(now.subtract(const Duration(days: 4))),
        updatedAtTime:
            Timestamp.fromDate(now.subtract(const Duration(days: 4))),
      )..isMe = false,
      ChatMessageModel(
        uid: 'msg_13',
        senderId: currentUserId,
        receiverId: receiverUserId,
        message: 'Thank you! I\'ll take a look at it.',
        messageType: MessageType.TEXT.name,
        isMessageRead: true,
        createdAt: now
            .subtract(const Duration(days: 4, hours: 1))
            .millisecondsSinceEpoch,
        createdAtTime:
            Timestamp.fromDate(now.subtract(const Duration(days: 4, hours: 1))),
        updatedAtTime:
            Timestamp.fromDate(now.subtract(const Duration(days: 4, hours: 1))),
      )..isMe = true,
    ];

    // Reverse to show oldest first (like Firebase pagination reverse: true)
    dummyMessages = dummyMessages.reversed.toList();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.detached) {
      chatServices.setOnlineCount(
          senderId: widget.receiverUser.uid.validate(),
          receiverId: appStore.uid.validate(),
          status: 0);
    }

    if (state == AppLifecycleState.paused) {
      chatServices.setOnlineCount(
          senderId: widget.receiverUser.uid.validate(),
          receiverId: appStore.uid.validate(),
          status: 0);
    }
    if (state == AppLifecycleState.resumed) {
      chatServices.setOnlineCount(
          senderId: widget.receiverUser.uid.validate(),
          receiverId: appStore.uid.validate(),
          status: 1);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    chatServices.setOnlineCount(
        senderId: widget.receiverUser.uid.validate(),
        receiverId: appStore.uid.validate(),
        status: 0);

    _streamSubscription?.cancel();

    setStatusBarColor(transparentColor,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: context.primaryColor,
          leadingWidth: context.width(),
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: context.primaryColor,
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.light),
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              BackWidget(),
              CachedImageWidget(
                  url: widget.receiverUser.profileImage.validate(),
                  height: 36,
                  circle: true,
                  fit: BoxFit.cover),
              12.width,
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.receiverUser.firstName.validate() + " " + widget.receiverUser.lastName.validate()}",
                    style: context.boldTextStyle(
                        color: white, size: APP_BAR_TEXT_SIZE),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ).expand(),
              40.width,
            ],
          ),
          actions: [
            PopupMenuButton(
              onSelected: (index) {
                if (index == 0) {
                  showConfirmDialogCustom(
                    context,
                    height: 80,
                    width: 290,
                    positiveText: language.lblYes,
                    negativeText: language.lblNo,
                    primaryColor: primaryColor,
                    negativeTextColor: primaryColor,
                    title: language.clearChatMessage,
                    customCenterWidget: Image.asset(ic_warning,
                        height: 70, width: 70, fit: BoxFit.cover),
                    onAccept: (c) async {
                      if (USE_DUMMY_DATA) {
                        // Clear dummy messages
                        dummyMessages.clear();
                        hideKeyboard(context);
                        setState(() {});
                        toast(language.chatCleared);
                      } else {
                        appStore.setLoading(true);
                        await chatServices
                            .clearAllMessages(
                                senderId: appStore.uid,
                                receiverId: widget.receiverUser.uid.validate())
                            .then((value) {
                          toast(language.chatCleared);
                          hideKeyboard(context);
                        }).catchError((e) {
                          toast(e);
                        });
                        appStore.setLoading(false);
                      }
                    },
                  );
                }
              },
              color: context.cardColor,
              icon: const Icon(Icons.more_vert_sharp, color: Colors.white),
              itemBuilder: (context) {
                List<PopupMenuItem> list = [];
                list.add(
                  PopupMenuItem(
                    value: 0,
                    child: Text(language.clearChat,
                        style: context.primaryTextStyle()),
                  ),
                );
                return list;
              },
            )
          ],
        ),
        body: SafeArea(
          child: SizedBox(
            height: context.height(),
            width: context.width(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  margin:
                      EdgeInsets.only(bottom: widget.isChattingAllow ? 0 : 80),
                  child: USE_DUMMY_DATA
                      ? _buildDummyChatList()
                      : FirestorePagination(
                          reverse: true,
                          isLive: true,
                          padding: const EdgeInsets.only(
                              left: 8, top: 8, right: 8, bottom: 0),
                          physics: const BouncingScrollPhysics(),
                          query: chatServices.chatMessagesWithPagination(
                              senderId: appStore.uid.validate(),
                              receiverUserId:
                                  widget.receiverUser.uid.validate()),
                          initialLoader: LoaderWidget(),
                          limit: PER_PAGE_CHAT_LIST_COUNT,
                          onEmpty: NoDataWidget(
                            title: language.noConversation,
                            imageWidget: Image.asset(no_conversation,
                                height: 200, width: 200, fit: BoxFit.contain),
                          ),
                          shrinkWrap: true,
                          viewType: ViewType.list,
                          itemBuilder: (context, snap, index) {
                            ChatMessageModel data = ChatMessageModel.fromJson(
                                snap[index].data() as Map<String, dynamic>);
                            data.isMe = data.senderId == appStore.uid;
                            data.chatDocumentReference = snap[index].reference;

                            return ChatItemWidget(chatItemData: data);
                          },
                        ),
                ),
                if (!widget.isChattingAllow)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: _buildChatFieldWidget(),
                  ),
                Observer(
                    builder: (context) =>
                        LoaderWidget().visible(appStore.isLoading)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleDocumentClick() async {
    appStore.setLoading(true);
    await pickFiles(
      allowedExtensions: chatFilesAllowedExtensions,
      maxFileSizeMB: max_acceptable_file_size,
      type: FileType.custom,
    ).then((pickedfiles) async {
      await handleUploadAndSendFiles(pickedfiles);
    }).catchError((e) {
      toast(e);
      log('ChatServices().uploadFiles Err: ${e}');
      return;
    }).whenComplete(() => appStore.setLoading(false));
  }

  Future<void> _handleCameraClick() async {
    GetImage(ImageSource.camera, path: (path, name, xFile) async {
      log('Path camera : ${path.toString()} name $name');
      await handleUploadAndSendFiles([File(xFile.path)]);
      setState(() {});
    });
  }

  Future<void> handleUploadAndSendFiles(List<File> pickedfiles) async {
    if (pickedfiles.isEmpty) return;
    await SendFilePreviewScreen(pickedfiles: pickedfiles)
        .launch(context)
        .then((value) async {
      debugPrint('text: ${value}');
      debugPrint('text: ${value[MessageType.TEXT.name]}');
      debugPrint('files: ${value[MessageType.Files.name]}');
      debugPrint('files: ${value[MessageType.Files.name].runtimeType}');

      if (value[MessageType.Files.name] is List<File>) {
        pickedfiles = value[MessageType.Files.name];
      }

      if (value[MessageType.TEXT.name] is String) {
        messageCont.text = value[MessageType.TEXT.name];
      }

      if (messageCont.text.trim().isNotEmpty || pickedfiles.isNotEmpty) {
        appStore.setLoading(true);
        await ChatServices()
            .uploadFiles(pickedfiles)
            .then((attached_files) async {
          if (attached_files.isEmpty) return;
          log('ATTACHEDFILES: ${attached_files}');
          await sendMessages(isFile: true, attachmentFiles: attached_files)
              .whenComplete(() => appStore.setLoading(false));
        }).catchError((e) {
          toast(e);
          log('ChatServices().uploadFiles Err: ${e}');
          return;
        }).whenComplete(() => appStore.setLoading(false));
      }
    });
  }

  Widget _buildDummyChatList() {
    if (dummyMessages.isEmpty) {
      return NoDataWidget(
        title: language.noConversation,
        imageWidget: Image.asset(no_conversation,
            height: 300, width: 300, fit: BoxFit.contain),
      );
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
      physics: const BouncingScrollPhysics(),
      itemCount: dummyMessages.length,
      itemBuilder: (context, index) {
        ChatMessageModel data = dummyMessages[index];
        // Set isMe based on senderId compared with appStore.uid (same as real implementation)
        String currentUserId = appStore.uid.validate().isNotEmpty
            ? appStore.uid.validate()
            : 'current_user_123';
        data.isMe = data.senderId == currentUserId;
        return ChatItemWidget(chatItemData: data);
      },
    );
  }
}
