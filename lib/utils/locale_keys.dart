// Bu dosya çeviri key'lerini sabit olarak tutar.
// JSON yapısındaki key hiyerarşisi burada yansıtılır.
// Kullanım: LocaleKeys.auth_login_title.tr()
abstract class LocaleKeys {
  // auth.login
  static const auth_login_title = 'auth.login.title';
  static const auth_login_rememberMe = 'auth.login.rememberMe';
  static const auth_login_forgotPassword = 'auth.login.forgotPassword';
  static const auth_login_noAccount = 'auth.login.noAccount';
  static const auth_login_register = 'auth.login.register';
  static const auth_login_button = 'auth.login.button';

  // auth.register
  static const auth_register_title = 'auth.register.title';
  static const auth_register_kvkk = 'auth.register.kvkk';
  static const auth_register_hasAccount = 'auth.register.hasAccount';
  static const auth_register_login = 'auth.register.login';
  static const auth_register_button = 'auth.register.button';

  // auth.forgotPassword
  static const auth_forgotPassword_title = 'auth.forgotPassword.title';
  static const auth_forgotPassword_description = 'auth.forgotPassword.description';
  static const auth_forgotPassword_button = 'auth.forgotPassword.button';

  // auth.verification
  static const auth_verification_title = 'auth.verification.title';
  static const auth_verification_description = 'auth.verification.description';
  static const auth_verification_codeSent = 'auth.verification.codeSent';
  static const auth_verification_resend = 'auth.verification.resend';
  static const auth_verification_button = 'auth.verification.button';

  // auth.fields
  static const auth_fields_email = 'auth.fields.email';
  static const auth_fields_password = 'auth.fields.password';
  static const auth_fields_name = 'auth.fields.name';

  // auth.validation
  static const auth_validation_emailEmpty = 'auth.validation.emailEmpty';
  static const auth_validation_emailInvalid = 'auth.validation.emailInvalid';
  static const auth_validation_passwordEmpty = 'auth.validation.passwordEmpty';
  static const auth_validation_passwordMinLength = 'auth.validation.passwordMinLength';
  static const auth_validation_nameEmpty = 'auth.validation.nameEmpty';
  static const auth_validation_kvkkRequired = 'auth.validation.kvkkRequired';
  static const auth_validation_codeIncomplete = 'auth.validation.codeIncomplete';

  // auth.errors
  static const auth_errors_invalidCredentials = 'auth.errors.invalidCredentials';
  static const auth_errors_emailAlreadyRegistered = 'auth.errors.emailAlreadyRegistered';
  static const auth_errors_general = 'auth.errors.general';
  static const auth_errors_emailSendFailed = 'auth.errors.emailSendFailed';
  static const auth_errors_codeSendFailed = 'auth.errors.codeSendFailed';
  static const auth_errors_codeInvalid = 'auth.errors.codeInvalid';
  static const auth_errors_registerSuccess = 'auth.errors.registerSuccess';
  static const auth_errors_loginSuccess = 'auth.errors.loginSuccess';

  // location
  static const location_title = 'location.title';
  static const location_shareTitle = 'location.shareTitle';
  static const location_shareDescription = 'location.shareDescription';
  static const location_buttonShare = 'location.buttonShare';
  static const location_buttonPick = 'location.buttonPick';
  static const location_permissionDenied = 'location.permissionDenied';
  static const location_fetchError = 'location.fetchError';

  // mapPicker
  static const mapPicker_searchHint = 'mapPicker.searchHint';
  static const mapPicker_confirmButton = 'mapPicker.confirmButton';
  static const mapPicker_locating = 'mapPicker.locating';

  // foodDetail
  static const foodDetail_tabOrder = 'foodDetail.tabOrder';
  static const foodDetail_tabReview = 'foodDetail.tabReview';
  static const foodDetail_goToLocation = 'foodDetail.goToLocation';
  static const foodDetail_moreDetail = 'foodDetail.moreDetail';
  static const foodDetail_ingredients = 'foodDetail.ingredients';
  static const foodDetail_reserveButton = 'foodDetail.reserveButton';
  static const foodDetail_shareLabel = 'foodDetail.shareLabel';

  // home
  static const home_nearbyPlaces = 'home.nearbyPlaces';
  static const home_seeAll = 'home.seeAll';
  static const home_surpriseBox = 'home.surpriseBox';
  static const home_buyNow = 'home.buyNow';
  static const home_todayPopular = 'home.todayPopular';
  static const home_locationLoading = 'home.locationLoading';
}

