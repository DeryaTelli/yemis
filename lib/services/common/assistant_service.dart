import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/constants/api_constants.dart';

abstract class IAssistantService {
  Future<String?> askQuestion(String message);
}

class ApiAssistantService implements IAssistantService {
  String? _authToken;

  void setToken(String? token) => _authToken = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  @override
  Future<String?> askQuestion(String message) async {
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
        return data['response']?.toString() ?? data['message']?.toString();
      }
    } catch (e) {
      print('AI Assistant Error: $e');
    }
    return null;
  }
}
