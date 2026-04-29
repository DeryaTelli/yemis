import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:yemis/models/volunteer/volunteer_listing.dart';
import 'package:yemis/viewmodels/business/business_profile_viewmodel.dart';
import 'package:yemis/viewmodels/food/food_profile_viewmodel.dart';
import 'package:yemis/viewmodels/volunteer/volunteer_profile_viewmodel.dart';
import 'package:yemis/views/volunteer/volunteer_add_address_view.dart';
import 'services/food/mock_food_service.dart';
import 'services/auth/api_auth_service.dart';
import 'services/auth/i_auth_service.dart';
import 'services/auth/user_session.dart';
import 'services/location/api_location_data_service.dart';
import 'services/location/i_location_data_service.dart';
import 'models/auth/address_model.dart';
import 'models/app_module_type.dart';
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
import 'views/auth/reset_password_view.dart';
import 'viewmodels/auth/reset_password_viewmodel.dart';
import 'views/business/business_home_view.dart';
import 'views/food/food_detail_view.dart';
import 'views/food/food_favorites_view.dart';
import 'views/food/food_home_view.dart';
import 'views/food/food_profile_edit_view.dart';
import 'views/food/food_profile_view.dart';
import 'views/food/food_reserve_view.dart';
import 'views/food/food_search_view.dart';
import 'views/food/food_all_listings_view.dart';
import 'views/volunteer/volunteer_all_listings_view.dart';
import 'views/home_view.dart';
import 'views/location_view.dart';
import 'views/map_picker_view.dart';
import 'views/volunteer/volunteer_add_listing_view.dart';
import 'views/volunteer/volunteer_home_view.dart';
import 'views/volunteer/volunteer_listings_view.dart';
import 'views/volunteer/volunteer_profile_view.dart';
import 'views/volunteer/volunteer_search_view.dart';
import 'views/volunteer/volunteer_detail_view.dart';
import 'views/auth/addresses_view.dart';
import 'views/auth/food_add_address_view.dart';
import 'views/common/language_select_view.dart';
import 'views/business/business_profile_view.dart';
import 'views/business/business_add_order_view.dart';
import 'views/business/business_approvals_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final authService = ApiAuthService();
  final userSession = UserSession();
  final locationDataService = ApiLocationDataService();

  // Kayıtlı token'ı yükle
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  if (token != null) {
    authService.setToken(token);
    // UserSession için de gerekebilir (currentUser null ise bile token kalsın diye)
  }

  MockFoodService().setUserSession(userSession);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('tr'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr'),
      child: MyApp(
        authService: authService,
        userSession: userSession,
        locationDataService: locationDataService,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ApiAuthService authService;
  final UserSession userSession;
  final ApiLocationDataService locationDataService;

  const MyApp({
    super.key,
    required this.authService,
    required this.userSession,
    required this.locationDataService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userSession),
        Provider<IAuthService>.value(value: authService),
        Provider<ILocationDataService>.value(value: locationDataService),
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(authService, userSession),
        ),
        ChangeNotifierProvider(create: (_) => RegisterViewModel(authService)),
        ChangeNotifierProvider(
          create: (_) => ForgotPasswordViewModel(authService),
        ),
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
              final args = settings.arguments as Map<String, dynamic>? ?? {};
              final email = args['email'] as String? ?? '';
              final isPasswordReset = args['isPasswordReset'] as bool? ?? false;
              return MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => VerificationViewModel(
                    authService,
                    email: email,
                    isPasswordReset: isPasswordReset,
                  ),
                  child: const VerificationView(),
                ),
                settings: settings,
              );
            case AppRoutes.resetPassword:
              final args = settings.arguments as Map<String, dynamic>? ?? {};
              final email = args['email'] as String? ?? '';
              final otp = args['otp'] as String? ?? '';
              return MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => ResetPasswordViewModel(
                    authService,
                    email: email,
                    otp: otp,
                  ),
                  child: const ResetPasswordView(),
                ),
                settings: settings,
              );
            case AppRoutes.location:
              final args = settings.arguments as Map<String, dynamic>? ?? {};
              final returnToSender = args['returnToSender'] as bool? ?? false;
              final moduleType = args['moduleType'] as AppModuleType? ?? AppModuleType.food;
              return MaterialPageRoute(
                builder: (_) => LocationView(
                  returnToSender: returnToSender,
                  moduleType: moduleType,
                ),
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
                builder: (ctx) =>
                    FoodHomeView(userSession: ctx.read<UserSession>()),
                settings: settings,
              );
            case AppRoutes.foodSearch:
              return MaterialPageRoute(
                builder: (_) => const FoodSearchView(),
                settings: settings,
              );
            case AppRoutes.foodFavorites:
              return MaterialPageRoute(
                builder: (_) => const FoodFavoritesView(),
                settings: settings,
              );
            case AppRoutes.foodProfile:
              return MaterialPageRoute(
                builder: (ctx) => ChangeNotifierProvider(
                  create: (_) => FoodProfileViewModel(
                    ctx.read<IAuthService>(),
                    ctx.read<UserSession>(),
                  ),
                  child: const FoodProfileView(),
                ),
                settings: settings,
              );
            case AppRoutes.foodAllListings:
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => FoodAllListingsView(
                  title: args['title'] as String,
                  listings: args['listings'] as List<FoodListing>,
                ),
                settings: settings,
              );
            case AppRoutes.volunteerAllListings:
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => VolunteerAllListingsView(
                  title: args['title'] as String,
                  listings: args['listings'] as List<VolunteerListing>,
                ),
                settings: settings,
              );
            case AppRoutes.foodProfileEdit:
              final section =
                  settings.arguments as AppSection? ?? AppSection.food;
              return MaterialPageRoute(
                builder: (ctx) {
                  Widget view = ChangeNotifierProvider(
                    create: (_) => FoodProfileViewModel(
                      ctx.read<IAuthService>(),
                      ctx.read<UserSession>(),
                    ),
                    child: const FoodProfileEditView(),
                  );

                  if (section == AppSection.volunteer) {
                    view = Theme(
                      data: AppTheme.themeFor(AppSection.volunteer),
                      child: view,
                    );
                  }
                  return view;
                },
                settings: settings,
              );
            case AppRoutes.foodDetail:
              final listing = settings.arguments as FoodListing;
              return MaterialPageRoute(
                builder: (_) => FoodDetailView(listing: listing),
                settings: settings,
              );
            case AppRoutes.foodReserve:
              final reserveListing = settings.arguments as FoodListing;
              return MaterialPageRoute(
                builder: (_) => FoodReserveView(listing: reserveListing),
                settings: settings,
              );
            case AppRoutes.volunteerHome:
              return MaterialPageRoute(
                builder: (_) => const VolunteerHomeView(),
                settings: settings,
              );
            case AppRoutes.volunteerSearch:
              return MaterialPageRoute(
                builder: (_) => const VolunteerSearchView(),
                settings: settings,
              );
            case AppRoutes.volunteerAddAddress:
              return MaterialPageRoute(
                builder: (_) => const VolunteerAddAddressView(),
                settings: settings,
              );
            case AppRoutes.volunteerProfile:
              return MaterialPageRoute(
                builder: (ctx) => ChangeNotifierProvider(
                  create: (_) => VolunteerProfileViewModel(
                    ctx.read<IAuthService>(),
                    ctx.read<UserSession>(),
                  ),
                  child: const VolunteerProfileView(),
                ),
                settings: settings,
              );
            case AppRoutes.volunteerAddListing:
              return MaterialPageRoute(
                builder: (_) => const VolunteerAddListingView(),
                settings: settings,
              );
            case AppRoutes.volunteerListings:
              return MaterialPageRoute(
                builder: (_) => const VolunteerListingsView(),
                settings: settings,
              );
            case AppRoutes.volunteerDetail:
              final volunteerListing = settings.arguments as VolunteerListing;
              return MaterialPageRoute(
                builder: (_) => VolunteerDetailView(listing: volunteerListing),
                settings: settings,
              );
            case AppRoutes.businessHome:
              return MaterialPageRoute(
                builder: (_) => const BusinessHomeView(),
                settings: settings,
              );
            case AppRoutes.businessProfile:
              return MaterialPageRoute(
                builder: (ctx) => ChangeNotifierProvider(
                  create: (_) => BusinessProfileViewModel(
                    ctx.read<IAuthService>(),
                    ctx.read<UserSession>(),
                  ),
                  child: const BusinessProfileView(),
                ),
                settings: settings,
              );
            case AppRoutes.businessApprovals:
              return MaterialPageRoute(
                builder: (_) => const BusinessApprovalsView(),
                settings: settings,
              );
            case AppRoutes.businessAddOrder:
              return MaterialPageRoute(
                builder: (_) => const BusinessAddOrderView(),
                settings: settings,
              );
            case AppRoutes.addresses:
              final moduleType = settings.arguments as AppModuleType? ?? AppModuleType.food;
              return MaterialPageRoute(
                builder: (_) => AddressesView(moduleType: moduleType),
                settings: settings,
              );
            case AppRoutes.foodAddAddress:
              final args = settings.arguments as Map<String, dynamic>?;
              final address = args?['address'] as AddressModel?;
              final moduleType = args?['moduleType'] as AppModuleType? ?? AppModuleType.food;
              
              return MaterialPageRoute(
                builder: (_) => FoodAddAddressView(
                  address: address,
                  moduleType: moduleType,
                ),
                settings: settings,
              );
            case AppRoutes.languageSelect:
              final section = (settings.arguments is AppSection)
                  ? settings.arguments as AppSection
                  : AppSection.food;
              return MaterialPageRoute(
                builder: (_) => LanguageSelectView(section: section),
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

/// Henüz uygulanmamış sayfalar için geçici iskelet ekran
class _PlaceholderView extends StatelessWidget {
  final String title;
  final IconData icon;
  const _PlaceholderView({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFFE8800),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: const Color(0xFFFE8800)),
            const SizedBox(height: 16),
            Text(
              '$title yakında!',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
