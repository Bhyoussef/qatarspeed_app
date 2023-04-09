import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/models/conversation.dart';
import 'package:qatar_speed/models/message.dart';
import 'package:qatar_speed/tools/services/chat.dart';

import 'home_controller.dart';

class ChatController extends GetxController {
  List<ConversationModel> conversations = [];
  List<ConversationModel> requests = [];
  List<ConversationModel>? searchConversations;
  bool isRequests = false;
  ScrollController scrollController = ScrollController();
  final recordStatus = ''.obs;
  late bool isFetching;
  bool isSelectingMessages = false;
  bool canLoadMore = true;
  bool isLoadingMore = false;
  int page = 0;
  bool isFetchingConversations = false;

  Future<void> getConversations({bool refresh = false}) async {
    if (refresh) {
      isFetchingConversations = true;
      update(['conversations']);
    }
    conversations.clear();
    requests.clear();
    searchConversations?.clear();
    final map = await ChatWebService().getConversations();
    conversations.addAll(map['conversations']!);
    requests.addAll(map['requests']!);
    isFetchingConversations = false;
    update(['conversations']);
  }

  markMessageAsRead(ConversationModel conversation) {
    conversation.unread = 0;
    Get.find<HomeController>().countMessages();
    conversation.message = {
      'text': conversation.messages?.last.text ?? 'Attachement'
    };
    conversations.sort((conv, other) {
      if ((conv.messages?.isEmpty ?? true) ||
          (other.messages?.isEmpty ?? true)) {
        return 0;
      }
      return conv.messages?.last.createdAt
              ?.compareTo(other.messages?.last.createdAt ?? DateTime(0)) ??
          0;
    });
    update(['conversations']);
  }

  getMessages(ConversationModel conversation) async {
    if (!canLoadMore || isLoadingMore) {
      return;
    }
    final messages = (isRequests ? requests : conversations)
            .firstWhere((element) => element == conversation)
            .messages ??
        [];
    canLoadMore = (messages.length) == 20;
    if (page == 0) {
      messages.clear();
    } else {
      isLoadingMore = true;
      update(['messages']);
    }

    try {
      messages.insertAll(
          0, await ChatWebService().getMessages(conversation, page: page));
      if (page == 0 && (messages.isNotEmpty)) {
        scrollDown(jump: true);
      }
      page++;
    } on DioError catch (e) {
      debugPrint(e.requestOptions.uri.toString());
    } finally {
      isFetching = false;
      isLoadingMore = false;
      debugPrint('is fetching  controller?    $isFetching');
      update(['messages']);
    }
  }

  sendMessage({
    required MessageModel message,
    required ConversationModel conversation,
  }) async {
    message.status = SentStatus.sending;
    message.createdAt = DateTime.now();
    conversation.messages?.add(message);
    update(['messages']);
    scrollDown();
    final file = message.media;
    try {
      (await ChatWebService()
              .sendMessage(message: message, toId: conversation.user.id))
          .copyTo(message);
      message.status = SentStatus.sent;
      debugPrint('message status from controller   ${message.status}');
    } catch (e) {
      message.status = SentStatus.failed;
      debugPrint('error isss  ${(e as DioError).response?.data}');
    } finally {
      update(['messages']);
      scrollDown();
      if (file != null) {
        File(file).delete();
      }
    }
  }

  void setRecordMessage(String message) {
    recordStatus.value = message;
    update(['recording']);
  }

  void deleteMessage({required MessageModel message}) {
    message.status = SentStatus.deleted;
    unawaited(ChatWebService().deleteMessage(message));
    update(['messages']);
  }

  void selecteMessage(
      {required MessageModel message,
      required ConversationModel conversation}) {
    message.selected = !message.selected;
    isSelectingMessages = conversation.messages
            ?.where((element) => element.selected == true)
            .isNotEmpty ??
        false;
    update(['messages']);
  }

  void clearSelection(ConversationModel conversation) {
    conversation.messages?.forEach((element) {
      element.selected = false;
    });
    isSelectingMessages = false;
    update(['messages']);
  }

  Future<void> getMessageById(int id, ConversationModel conversation) async {
    debugPrint('called');
    conversation.messages?.add(await ChatWebService().getMessage(id));
    update(['messages']);
    scrollDown();
  }

  Future<void> scrollDown({bool jump = false}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (scrollController.positions.isNotEmpty) {
      if (jump) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
        return;
      }
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void deleteSelected(ConversationModel conversation) {
    List<MessageModel?> messagesToDelete = [];
    isSelectingMessages = false;
    messagesToDelete.addAll(
        (conversation.messages?.where((element) => element.selected) ?? [])
            .toList());
    for (var element in messagesToDelete) {
      element?.status = SentStatus.deleted;
      unawaited(ChatWebService().deleteMessage(element!));
    }
    clearSelection(conversation);
    update(['messages']);
  }

  Future<void> deleteConversation(ConversationModel conversation,
      {bool immediately = false}) async {
    conversation.delete = true;
    conversations.remove(conversation);
    searchConversations?.remove(conversation);
    await Future.delayed(Duration(
        seconds: immediately ? 0 : 3, milliseconds: immediately ? 0 : 500));
    if (conversation.delete) {
      ChatWebService().deleteConversation(conversation.id);
    }
  }

  void insertConversation(ConversationModel conversation, int index) {
    (searchConversations ?? conversations).insert(index, conversation);
    update(['conversations']);
  }

  void filter(String query) {
    searchConversations = [];
    if (query.isEmpty) {
      searchConversations = null;
      update(['conversations']);
      return;
    }

    searchConversations?.addAll(conversations.where((element) =>
        (element.user.name?.toLowerCase() ?? '')
            .contains(query.toLowerCase())));
    update(['conversations']);
  }

  void addConversation(ConversationModel conversation) {
    conversations.insert(0, conversation);
    update(['conversations']);
  }

  switchView({bool requests = false}) {
    isRequests = requests;
    update(['conversations', 'messages']);
  }

  acceptConversation(ConversationModel conversation) async {
    await ChatWebService().accept(conversation.id);
    isRequests = false;
    update(['conversations', 'messages']);
  }

  void seenMessage(int id, ConversationModel conversation) {
    try {
      conversation.messages
          ?.firstWhere((element) => element.id == id)
          .seen = true;
      update(['conversations', 'messages']);
    } catch(_) {}
  }
}
