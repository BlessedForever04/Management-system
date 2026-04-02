import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/app_textfield.dart';
import 'package:managementt/controller/auth_controller.dart';
import 'package:managementt/controller/task_controller.dart';
import 'package:managementt/model/task.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late final String projectId;
  final TextEditingController messageController = TextEditingController();
  final _taskController = Get.find<TaskController>();
  final _authController = Get.find<AuthController>();
  final ScrollController scrollController = ScrollController();

  Timer? _pollTimer;
  bool _isFetching = false;
  String? _latestRemarkId;
  late final Future<String> _projectNameFuture;

  Future<String> getProjectName() async {
    final Task task = await _taskController.getTaskById(projectId);
    return task.title;
  }

  @override
  void initState() {
    super.initState();
    projectId = Get.arguments;
    _projectNameFuture = getProjectName();
    _initialLoad();
    _startPolling();
  }

  Future<void> _initialLoad() async {
    await _fetchRemarksAndHandleNewMessage(isInitialLoad: true);
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await _fetchRemarksAndHandleNewMessage();
    });
  }

  Future<void> _fetchRemarksAndHandleNewMessage({
    bool isInitialLoad = false,
  }) async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      await _taskController.fetchRemarks(projectId);
      final remarks = _taskController.remarkList;
      final latestId = remarks.isNotEmpty ? remarks.last.id : null;
      final hasNewMessage =
          !isInitialLoad && latestId != null && latestId != _latestRemarkId;

      _latestRemarkId = latestId;

      if (isInitialLoad) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !scrollController.hasClients) return;
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        });
      }

      if (hasNewMessage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !scrollController.hasClients) return;
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        });
      }
    } finally {
      _isFetching = false;
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.scaffoldBackground,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: _projectNameFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(strokeWidth: 1, value: 0.0);
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  return Text(
                    snapshot.data!,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
              },
            ),
            Text(
              "Team Messages",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: false,
      ),

      body: SafeArea(
        child: Column(
          children: [
            /// 💬 MESSAGE LIST
            Expanded(
              child: Obx(() {
                final remarks = _taskController.remarkList;

                if (remarks.isEmpty) {
                  return Center(
                    child: Text(
                      "No messages yet 🚀",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.all(12),
                  itemCount: remarks.length,
                  itemBuilder: (context, index) {
                    final remark = remarks[index];

                    final isMe =
                        remark.senderId == _authController.currentUserId.value;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            padding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            constraints: BoxConstraints(maxWidth: 280),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blueAccent : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(isMe ? 16 : 0),
                                bottomRight: Radius.circular(isMe ? 0 : 16),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              remark.message,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "${remark.senderName}",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),

            /// ✍️ INPUT BAR (LIKE WHATSAPP)
            Container(
              margin: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: AppTextfield(
                      label: "Message",
                      controller: messageController,
                      hint: "Type a message...",
                    ),
                  ),

                  SizedBox(width: 8),

                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blueAccent,
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: () async {
                        if (messageController.text.trim().isEmpty) return;

                        await _taskController.addRemark(
                          _authController.currentUserId.value,
                          projectId,
                          messageController.text.trim(),
                        );

                        final remarks = _taskController.remarkList;
                        _latestRemarkId = remarks.isNotEmpty
                            ? remarks.last.id
                            : null;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted || !scrollController.hasClients) return;
                          scrollController.animateTo(
                            scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                          );
                        });
                        messageController.clear();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
