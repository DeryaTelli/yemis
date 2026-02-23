import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth/mock_auth_service.dart';
import 'services/auth/user_session.dart';
import 'models/food/food_listing.dart';
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
import 'views/business/business_home_view.dart';
import 'views/food/food_detail_view.dart';
import 'views/food/food_home_view.dart';
import 'views/home_view.dart';
import 'views/location_view.dart';
import 'views/map_picker_view.dart';
import 'views/volunteer/volunteer_home_view.dart';

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
    final userSession = UserSession();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userSession),
        ChangeNotifierProvider(
            create: (_) => LoginViewModel(authService, userSession)),
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
            case AppRoutes.location:
              return MaterialPageRoute(
                builder: (_) => const LocationView(),
                settings: settings,
              );
            case AppRoutes.mapPicker:
              return MaterialPageRoute(
                builder: (_) => const MapPickerView(),
                settings: settings,
              );
            case AppRoutes.home:
              return MaterialPageRoute(
                builder: (_) => const HomeView(),
                settings: settings,
              );
            case AppRoutes.foodHome:
              return MaterialPageRoute(
                builder: (_) => const FoodHomeView(),
                settings: settings,
              );
            case AppRoutes.foodDetail:
              final listing = settings.arguments as FoodListing;
              return MaterialPageRoute(
                builder: (_) => FoodDetailView(listing: listing),
                settings: settings,
              );
            case AppRoutes.volunteerHome:
              return MaterialPageRoute(
                builder: (_) => const VolunteerHomeView(),
                settings: settings,
              );
            case AppRoutes.businessHome:
              return MaterialPageRoute(
                builder: (_) => const BusinessHomeView(),
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
