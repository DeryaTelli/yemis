import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../auth/user_session.dart';
import '../../utils/routes/navigation_service.dart';
import '../../utils/routes/app_routes.dart';

/// Herhangi bir istekte 401 Unauthorized dönmesi durumunda otomatik olarak
/// kullanıcının oturumunu temizleyen ve giriş sayfasına yönlendiren özel http.Client.
class InterceptedClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _inner.send(request);
    if (response.statusCode == 401) {
      final session = UserSession.instance;
      if (session != null && session.isLoggedIn) {
        debugPrint('⚠️ [InterceptedClient] 401 Unauthorized hatası alındı, oturum sonlandırılıyor.');
        
        // Build aşamasında notifyListeners çağrısı veya navigasyon hatası almamak için 
        // mikro-görev (microtask) kuyruğuna atıyoruz.
        Future.microtask(() {
          if (session.isLoggedIn) {
            session.clear();
            NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            );
          }
        });
      }
    }
    return response;
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
