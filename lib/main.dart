import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:yemis/services/common/notification_service.dart';
import 'package:yemis/models/business/business_listing_model.dart';
import 'package:yemis/models/volunteer/volunteer_listing.dart';
import 'package:yemis/services/food/i_food_service.dart';
import 'package:yemis/viewmodels/business/business_profile_viewmodel.dart';
import 'package:yemis/viewmodels/food/food_home_viewmodel.dart';
import 'package:yemis/viewmodels/food/food_profile_viewmodel.dart';
import 'package:yemis/viewmodels/food/food_orders_history_viewmodel.dart';
import 'package:yemis/viewmodels/volunteer/volunteer_add_listing_viewmodel.dart';
import 'package:yemis/viewmodels/volunteer/volunteer_profile_viewmodel.dart';
import 'package:yemis/viewmodels/food/food_favorites_viewmodel.dart';
import 'package:yemis/viewmodels/business/business_listings_viewmodel.dart';
import 'package:yemis/views/auth/change_password_view.dart';
import 'package:yemis/views/volunteer/volunteer_add_address_view.dart';
import 'package:yemis/services/food/api_food_service.dart';
import 'package:yemis/services/food/mock_food_service.dart';
import 'package:yemis/services/auth/api_auth_service.dart';
import 'package:yemis/services/auth/i_auth_service.dart';
import 'package:yemis/services/auth/user_session.dart';
import 'package:yemis/services/location/api_location_data_service.dart';
import 'package:yemis/services/location/i_location_data_service.dart';
import 'package:yemis/services/business/i_business_service.dart';
import 'package:yemis/services/business/api_business_service.dart';
import 'package:yemis/services/volunteer/i_volunteer_service.dart';
import 'package:yemis/services/volunteer/api_volunteer_service.dart';
import 'package:yemis/services/common/assistant_service.dart';
import 'package:yemis/services/notifications/api_notification_service.dart';
import 'package:yemis/models/auth/address_model.dart';
import 'package:yemis/models/auth/saved_card_model.dart';
import 'package:yemis/models/app_module_type.dart';
import 'package:yemis/models/food/food_listing.dart';
import 'package:yemis/utils/routes/app_routes.dart';
import 'package:yemis/utils/theme/app_theme.dart';
import 'package:yemis/viewmodels/auth/forgot_password_viewmodel.dart';
import 'package:yemis/viewmodels/auth/login_viewmodel.dart';
import 'package:yemis/viewmodels/auth/register_viewmodel.dart';
import 'package:yemis/viewmodels/auth/verification_viewmodel.dart';
import 'package:yemis/viewmodels/auth/cards_viewmodel.dart';
import 'package:yemis/views/auth/forgot_password_view.dart';
import 'package:yemis/views/auth/login_view.dart';
import 'package:yemis/views/auth/register_view.dart';
import 'package:yemis/views/auth/verification_view.dart';
import 'package:yemis/views/auth/reset_password_view.dart';
import 'package:yemis/viewmodels/auth/reset_password_viewmodel.dart';
import 'package:yemis/views/business/business_home_view.dart';
import 'views/food/food_detail_view.dart';
import 'views/food/food_favorites_view.dart';
import 'views/food/food_home_view.dart';
import 'views/food/food_profile_edit_view.dart';
import 'views/food/food_profile_view.dart';
import 'views/food/food_orders_history_view.dart';
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
import 'views/volunteer/volunteer_edit_listing_view.dart';
import 'views/volunteer/volunteer_listing_detail_view.dart';
import 'views/auth/addresses_view.dart';
import 'views/auth/cards_view.dart';
import 'views/auth/food_add_address_view.dart';
import 'views/common/language_select_view.dart';
import 'views/business/business_profile_view.dart';
import 'views/business/business_profile_edit_view.dart';
import 'views/business/business_add_order_view.dart';
import 'views/business/business_approvals_view.dart';
import 'views/business/business_listings_view.dart';
import 'views/business/business_edit_order_view.dart';
import 'views/business/business_listing_detail_view.dart';
import 'views/business/business_reports_view.dart';
import 'viewmodels/business/business_reports_viewmodel.dart';
import 'views/common/notification_view.dart';
import 'views/common/yemo_assistant_view.dart';
import 'views/common/onboarding_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  try {
    await Firebase.initializeApp();
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  final authService = ApiAuthService();
  final userSession = UserSession();
  final locationDataService = ApiLocationDataService();

  final businessService = ApiBusinessService();

  final foodService = ApiFoodService();
  final volunteerService = ApiVolunteerService();
  final assistantService = ApiAssistantService();
  final notificationService = ApiNotificationService();

  // Kayıtlı oturumu yükle
  await userSession.loadSession();

  if (userSession.isLoggedIn) {
    final token = userSession.token!;
    authService.setToken(token);
    businessService.setToken(token);
    foodService.setToken(token);
    volunteerService.setToken(token);
    assistantService.setToken(token);
    notificationService.setToken(token);

    // Proactively sync/self-heal local location coordinates cache with DB default/active address
    Future.microtask(() async {
      try {
        final addresses = await authService.getAddresses();
        if (addresses.isNotEmpty) {
          final activeAddr = addresses.firstWhere(
            (a) => a.addressLine == userSession.currentAddress,
            orElse: () => addresses.firstWhere(
              (a) => a.isDefault,
              orElse: () => addresses.first,
            ),
          );
          if (userSession.currentLat != activeAddr.latitude ||
              userSession.currentLng != activeAddr.longitude ||
              userSession.currentAddress != activeAddr.addressLine) {
            userSession.updateLocation(
              activeAddr.addressLine,
              lat: activeAddr.latitude,
              lng: activeAddr.longitude,
            );
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('current_location_address', activeAddr.addressLine);
            await prefs.setDouble('current_lat', activeAddr.latitude);
            await prefs.setDouble('current_lng', activeAddr.longitude);
            debugPrint('Self-healed local location cache with database: ${activeAddr.addressLine} (${activeAddr.latitude}, ${activeAddr.longitude})');
          }
        }
      } catch (e) {
        debugPrint('Error self-healing/syncing location cache with DB: $e');
      }
    });

    // Uygulama açılışını FCM'e bağlama; servis geçici olarak kapalıysa
    // ekranların yüklenmesini etkilemesin.
    Future<void>.delayed(const Duration(seconds: 10), () async {
      final fcmToken = await NotificationService().getToken();
      if (fcmToken != null) {
        final platform = kIsWeb
            ? 'web'
            : (defaultTargetPlatform == TargetPlatform.android
                  ? 'android'
                  : 'ios');
        await notificationService.registerDeviceToken(fcmToken, platform);
      }
    });
  }

  // Onboarding ve Giriş Kontrolü
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingSeen = prefs.getBool('onboarding_seen') ?? false;

  String initialRoute;
  if (userSession.isLoggedIn) {
    initialRoute = AppRoutes.home;
  } else if (!onboardingSeen) {
    initialRoute = AppRoutes.onboarding;
  } else {
    initialRoute = AppRoutes.login;
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
        businessService: businessService,
        foodService: foodService,
        volunteerService: volunteerService,
        assistantService: assistantService,
        notificationService: notificationService,
        initialRoute: initialRoute,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ApiAuthService authService;
  final UserSession userSession;
  final ApiLocationDataService locationDataService;
  final ApiBusinessService businessService;
  final ApiFoodService foodService;
  final ApiVolunteerService volunteerService;
  final IAssistantService assistantService;
  final ApiNotificationService notificationService;
  final String initialRoute;

  MyApp({
    super.key,
    required this.authService,
    required this.userSession,
    required this.locationDataService,
    required this.businessService,
    required this.foodService,
    required this.volunteerService,
    required this.assistantService,
    required this.notificationService,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userSession),
        Provider<IAuthService>.value(value: authService),
        Provider<ILocationDataService>.value(value: locationDataService),
        Provider<IBusinessService>.value(value: businessService),
        Provider<IFoodService>.value(value: foodService),
        Provider<ApiFoodService>.value(value: foodService),
        Provider<IVolunteerService>.value(value: volunteerService),
        Provider<ApiVolunteerService>.value(value: volunteerService),
        Provider<IAssistantService>.value(value: assistantService),
        Provider<ApiNotificationService>.value(value: notificationService),
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(
            authService,
            businessService,
            foodService,
            volunteerService,
            notificationService,
            assistantService,
            userSession,
          ),
        ),
        ChangeNotifierProvider(create: (_) => RegisterViewModel(authService)),
        ChangeNotifierProvider(
          create: (_) => ForgotPasswordViewModel(authService),
        ),
        ChangeNotifierProvider(
          create: (_) => FoodProfileViewModel(authService, userSession),
        ),
        ChangeNotifierProvider(
          create: (ctx) => FoodOrdersHistoryViewModel(ctx.read<IFoodService>()),
        ),
        ChangeNotifierProvider(
          create: (_) => VolunteerProfileViewModel(authService, userSession),
        ),
        ChangeNotifierProvider(
          create: (_) => BusinessProfileViewModel(authService, userSession),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              FoodHomeViewModel(service: foodService, userSession: userSession),
        ),
        ChangeNotifierProvider(
          create: (_) => FoodFavoritesViewModel(foodService),
        ),
        // VerificationViewModel route-level'da inject edilir (email argümanı gerektirir)
      ],
      child: MaterialApp(
        title: 'yemis',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // easy_localization entegrasyonu
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        initialRoute: initialRoute,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.onboarding:
              return MaterialPageRoute(
                builder: (_) => const OnboardingView(),
                settings: settings,
              );
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
                    businessService,
                    foodService,
                    volunteerService,
                    assistantService,
                    userSession,
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
              final code = args['otp'] as String? ?? '';
              return MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => ResetPasswordViewModel(
                    authService,
                    email: email,
                    code: code,
                  ),
                  child: const ResetPasswordView(),
                ),
                settings: settings,
              );
            case AppRoutes.location:
              final args = settings.arguments as Map<String, dynamic>? ?? {};
              final returnToSender = args['returnToSender'] as bool? ?? false;
              final moduleType =
                  args['moduleType'] as AppModuleType? ?? AppModuleType.food;
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
                builder: (ctx) => const FoodProfileView(),
                settings: settings,
              );
            case AppRoutes.foodOrdersHistory:
              return MaterialPageRoute(
                builder: (_) => const FoodOrdersHistoryView(),
                settings: settings,
              );
            case AppRoutes.foodAllListings:
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) {
                  final view = FoodAllListingsView(
                    title: args['title'] as String,
                    listings: args['listings'] as List<FoodListing>,
                  );
                  if (args.containsKey('vm')) {
                    return ChangeNotifierProvider.value(
                      value: args['vm'] as FoodHomeViewModel,
                      child: view,
                    );
                  }
                  return view;
                },
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
                  Widget view = const FoodProfileEditView();

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
                builder: (ctx) => const VolunteerProfileView(),
                settings: settings,
              );
            case AppRoutes.volunteerAddListing:
              return MaterialPageRoute(
                builder: (ctx) => Theme(
                  data: AppTheme.themeFor(AppSection.volunteer),
                  child: ChangeNotifierProvider(
                    create: (ctx) => VolunteerAddListingViewModel(
                      ctx.read<IAuthService>(),
                      ctx.read<IVolunteerService>(),
                    ),
                    child: const VolunteerAddListingView(),
                  ),
                ),
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
            case AppRoutes.volunteerListingDetail:
              final volunteerListing = settings.arguments as VolunteerListing;
              return MaterialPageRoute(
                builder: (_) => VolunteerListingDetailView(
                  listing: volunteerListing,
                  isEditable: true,
                ),
                settings: settings,
              );
            case AppRoutes.volunteerEditListing:
              final listing = settings.arguments as VolunteerListing;
              return MaterialPageRoute(
                builder: (_) => VolunteerEditListingView(listing: listing),
                settings: settings,
              );
            case AppRoutes.businessHome:
              return MaterialPageRoute(
                builder: (_) => const BusinessHomeView(),
                settings: settings,
              );
            case AppRoutes.businessProfile:
              return MaterialPageRoute(
                builder: (ctx) => const BusinessProfileView(),
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
            case AppRoutes.businessProfileEdit:
              return MaterialPageRoute(
                builder: (_) => const BusinessProfileEditView(),
                settings: settings,
              );
            case AppRoutes.addresses:
              final moduleType =
                  settings.arguments as AppModuleType? ?? AppModuleType.food;
              return MaterialPageRoute(
                builder: (_) => AddressesView(moduleType: moduleType),
                settings: settings,
              );
            case AppRoutes.cards:
              return MaterialPageRoute(
                builder: (_) => const CardsView(),
                settings: settings,
              );
            case AppRoutes.addCard:
              final viewModel = settings.arguments as CardsViewModel;
              return MaterialPageRoute(
                builder: (_) => AddCardView(viewModel: viewModel),
                settings: settings,
              );
            case AppRoutes.cardDetail:
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => CardDetailView(
                  card: args['card'] as SavedCardModel,
                  viewModel: args['viewModel'] as CardsViewModel,
                ),
                settings: settings,
              );
            case AppRoutes.foodAddAddress:
              final args = settings.arguments as Map<String, dynamic>?;
              final address = args?['address'] as AddressModel?;
              final moduleType =
                  args?['moduleType'] as AppModuleType? ?? AppModuleType.food;

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
            case AppRoutes.businessListings:
              final type =
                  settings.arguments as ListingType? ?? ListingType.all;
              return MaterialPageRoute(
                builder: (_) => BusinessListingsView(type: type),
                settings: settings,
              );
            case AppRoutes.businessEditOrder:
              final listing = settings.arguments as BusinessListingModel;
              return MaterialPageRoute(
                builder: (_) => BusinessEditOrderView(listing: listing),
                settings: settings,
              );
            case AppRoutes.businessListingDetail:
              final listing = settings.arguments as BusinessListingModel;
              return MaterialPageRoute(
                builder: (_) => BusinessListingDetailView(listing: listing),
                settings: settings,
              );
            case AppRoutes.changePassword:
              final moduleType =
                  settings.arguments as AppModuleType? ?? AppModuleType.food;
              return MaterialPageRoute(
                builder: (_) => ChangePasswordView(moduleType: moduleType),
                settings: settings,
              );
            case AppRoutes.notification:
              final moduleType =
                  settings.arguments as AppModuleType? ?? AppModuleType.food;
              return MaterialPageRoute(
                builder: (ctx) => NotificationView(moduleType: moduleType),
                settings: settings,
              );
            case AppRoutes.yemoAssistant:
              final moduleType =
                  settings.arguments as AppModuleType? ?? AppModuleType.food;
              return MaterialPageRoute(
                builder: (_) => YemoAssistantView(moduleType: moduleType),
                settings: settings,
              );
            case AppRoutes.businessReports:
              return MaterialPageRoute(
                builder: (ctx) => ChangeNotifierProvider(
                  create: (_) => BusinessReportsViewModel(ctx.read<IBusinessService>()),
                  child: const BusinessReportsView(),
                ),
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
