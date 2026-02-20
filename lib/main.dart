import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth/mock_auth_service.dart';
import 'utils/routes/app_routes.dart';
import 'utils/theme/app_theme.dart';
import 'viewmodels/auth/forgot_password_viewmodel.dart';
import 'viewmodels/auth/login_viewmodel.dart';
import 'viewmodels/auth/register_viewmodel.dart';
import 'viewmodels/auth/verification_viewmodel.dart';
import 'views/auth/forgot_password_view.dart';
import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart';
import 'views/auth/verification_view.dart';
import 'views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('tr'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Servis instance'ı — ileride ApiAuthService ile değiştir
    final authService = MockAuthService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel(authService)),
        ChangeNotifierProvider(create: (_) => RegisterViewModel(authService)),
        ChangeNotifierProvider(
            create: (_) => ForgotPasswordViewModel(authService)),
        // VerificationViewModel route-level'da inject edilir (email argümanı gerektirir)
      ],
      child: MaterialApp(
        title: 'Yemiş',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // easy_localization entegrasyonu
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        initialRoute: AppRoutes.login,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.login:
              return MaterialPageRoute(
                builder: (_) => const LoginView(),
                settings: settings,
              );
            case AppRoutes.register:
              return MaterialPageRoute(
                builder: (_) => const RegisterView(),
                settings: settings,
              );
            case AppRoutes.forgotPassword:
              return MaterialPageRoute(
                builder: (_) => const ForgotPasswordView(),
                settings: settings,
              );
            case AppRoutes.verification:
              final email = settings.arguments as String? ?? '';
              return MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) =>
                      VerificationViewModel(authService, email: email),
                  child: const VerificationView(),
                ),
                settings: settings,
              );
            case AppRoutes.home:
              return MaterialPageRoute(
                builder: (_) => const HomeView(),
                settings: settings,
              );
            default:
              return MaterialPageRoute(builder: (_) => const LoginView());
          }
        },
      ),
    );
  }
}
