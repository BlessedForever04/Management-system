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

  @override
  void initState() {
    super.initState();
    projectId = Get.arguments;
    _projectNameFuture = getProjectName();
    _initialLoad();
    _startPolling();
  }

  Future<String> getProjectName() async {
    final Task task = await _taskController.getTaskById(projectId);
    return task.title;
  }

  /// ✅ WhatsApp style date formatter
  String formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(messageDate).inDays;

    if (difference == 0) return "Today";
    if (difference == 1) return "Yesterday";

    return "${date.day}/${date.month}/${date.year}";
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
        iconTheme: const IconThemeData(color: Colors.black),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: _projectNameFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  return Text(
                    snapshot.data!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
              },
            ),
            const Text(
              "Team Messages",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            /// 💬 MESSAGE LIST
            Expanded(
              child: Obx(() {
                final remarks = _taskController.remarkList;

                if (remarks.isEmpty) {
                  return const Center(
                    child: Text(
                      "No messages yet 🚀",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: remarks.length,
                  itemBuilder: (context, index) {
                    final remark = remarks[index];

                    final date = DateTime.parse(remark.timestamp);

                    final isMe =
                        remark.senderId == _authController.currentUserId.value;

                    bool showDateHeader = false;

                    if (index == 0) {
                      showDateHeader = true;
                    } else {
                      final prevDate = DateTime.parse(
                        remarks[index - 1].timestamp,
                      );

                      showDateHeader =
                          date.day != prevDate.day ||
                          date.month != prevDate.month ||
                          date.year != prevDate.year;
                    }

                    return Column(
                      children: [
                        /// 📅 DATE HEADER
                        if (showDateHeader)
                          Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                formatDateHeader(date),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),

                        /// 💬 MESSAGE BUBBLE
                        Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                constraints: const BoxConstraints(
                                  maxWidth: 280,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? Colors.blueAccent
                                      : Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(isMe ? 16 : 0),
                                    bottomRight: Radius.circular(isMe ? 0 : 16),
                                  ),
                                  boxShadow: const [
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

                              /// 👤 NAME
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  remark.senderName ?? "Unknown",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),

            /// ✍️ INPUT BAR
            Container(
              margin: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: AppTextfield(
                      label: "Message",
                      controller: messageController,
                      hint: "Type a message...",
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blueAccent,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
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
