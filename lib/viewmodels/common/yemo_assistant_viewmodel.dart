import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:yemis/utils/locale_keys.dart';
import '../../services/common/assistant_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<AssistantActionModel> actions;
  final String? topic;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.actions = const [],
    this.topic,
  }) : timestamp = timestamp ?? DateTime.now();
}

class YemoAssistantViewModel extends ChangeNotifier {
  final IAssistantService _service;

  YemoAssistantViewModel({required IAssistantService service})
    : _service = service;

  bool _isDisposed = false;
  final List<ChatMessage> _messages = [];
  final TextEditingController messageController = TextEditingController();

  List<ChatMessage> get messages => _messages;

  bool _isChatStarted = false;
  bool get isChatStarted => _isChatStarted;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _isChatStarted = true;
    _messages.add(ChatMessage(text: trimmed, isUser: true));
    messageController.clear();
    _isLoading = true;
    notifyListeners();

    try {
      final reply = await _service.askQuestion(trimmed);
      if (_isDisposed) return;

      if (reply != null && reply.response.trim().isNotEmpty) {
        _messages.add(
          ChatMessage(
            text: reply.response.trim(),
            isUser: false,
            actions: reply.actions,
            topic: reply.intent,
          ),
        );
      } else {
        _messages.add(
          ChatMessage(
            text: LocaleKeys.yemoAssistant_errorBusy.tr(),
            isUser: false,
          ),
        );
      }
    } catch (_) {
      _messages.add(
        ChatMessage(
          text: LocaleKeys.yemoAssistant_errorNetwork.tr(),
          isUser: false,
        ),
      );
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> startGuidance(String topic) async {
    String message;
    switch (topic) {
      case 'find_food':
        message = 'Yakınımda nasıl yemek bulabilirim?';
        break;
      case 'reserve':
        message = 'Nasıl rezerve edebilirim?';
        break;
      case 'ai_suggestions':
        message = 'Bana özel yemek önerilerin neler?';
        break;
      case 'sales':
        message = 'Satışlarımı nasıl takip edebilirim?';
        break;
      case 'add_order':
        message = 'Yeni bir ilan nasıl eklerim?';
        break;
      case 'co2':
        message = 'CO2 etkimi nasıl görebilirim?';
        break;
      case 'volunteer_listings':
        message = 'Gönüllü ilanlarını nasıl görebilirim?';
        break;
      case 'become_volunteer':
        message = 'Nasıl gönüllü olabilirim?';
        break;
      case 'select_region':
        message = 'Bölgemi nasıl seçebilirim?';
        break;
      default:
        message = topic;
    }
    await sendMessage(message);
  }

  @override
  void dispose() {
    _isDisposed = true;
    messageController.dispose();
    super.dispose();
  }
}
