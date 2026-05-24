import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/constants/api_constants.dart';

class AssistantActionModel {
  final String label;
  final String? route;
  final String? topic;

  const AssistantActionModel({
    required this.label,
    this.route,
    this.topic,
  });

  factory AssistantActionModel.fromJson(Map<String, dynamic> json) {
    return AssistantActionModel(
      label: json['label']?.toString() ?? '',
      route: json['route']?.toString(),
      topic: json['topic']?.toString(),
    );
  }
}

class AssistantReplyModel {
  final String response;
  final String source;
  final String? intent;
  final List<AssistantActionModel> actions;

  const AssistantReplyModel({
    required this.response,
    required this.source,
    this.intent,
    this.actions = const [],
  });

  factory AssistantReplyModel.fromJson(Map<String, dynamic> json) {
    final rawActions = json['actions'];
    return AssistantReplyModel(
      response:
          json['response']?.toString() ?? json['message']?.toString() ?? '',
      source: json['source']?.toString() ?? 'unknown',
      intent: json['intent']?.toString(),
      actions: rawActions is List
          ? rawActions
                .whereType<Map>()
                .map(
                  (e) => AssistantActionModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .where((e) => e.label.trim().isNotEmpty)
                .toList()
          : const [],
    );
  }
}

abstract class IAssistantService {
  Future<AssistantReplyModel?> askQuestion(String message);
}

class ApiAssistantService implements IAssistantService {
  String? _authToken;

  void setToken(String? token) => _authToken = token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  @override
  Future<AssistantReplyModel?> askQuestion(String message) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.assistantAsk}');

    print('--- AI ASSISTANT REQUEST ---');
    print('URL: $url');
    print('Message: $message');

    try {
      final response = await http
          .post(
            url,
            headers: _headers,
            body: jsonEncode({'message': message}),
          )
          .timeout(ApiConstants.requestTimeout);

      print('--- AI ASSISTANT RESPONSE ---');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return AssistantReplyModel.fromJson(data);
        }
        if (data is Map) {
          return AssistantReplyModel.fromJson(Map<String, dynamic>.from(data));
        }
      }
    } catch (e) {
      print('AI Assistant Error: $e');
    }
    return null;
  }
}
