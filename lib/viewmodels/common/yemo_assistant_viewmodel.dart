import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:yemis/utils/locale_keys.dart';
import '../../services/common/assistant_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class YemoAssistantViewModel extends ChangeNotifier {
  final IAssistantService _service;

  YemoAssistantViewModel({required IAssistantService service}) : _service = service;

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  bool _isChatStarted = false;
  bool get isChatStarted => _isChatStarted;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final TextEditingController messageController = TextEditingController();

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _isChatStarted = true;

    // Add user message
    _messages.add(ChatMessage(text: text, isUser: true));
    messageController.clear();
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _service.askQuestion(text);
      if (response != null) {
        _messages.add(ChatMessage(text: response, isUser: false));
      } else {
        _messages.add(ChatMessage(
          text: LocaleKeys.yemoAssistant_errorBusy.tr(),
          isUser: false,
        ));
      }
    } catch (e) {
      _messages.add(ChatMessage(
        text: LocaleKeys.yemoAssistant_errorNetwork.tr(),
        isUser: false,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startGuidance(String topic) {
    String message = '';
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
        message = 'Yeni bir sipariş nasıl eklerim?';
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
    sendMessage(message);
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}
