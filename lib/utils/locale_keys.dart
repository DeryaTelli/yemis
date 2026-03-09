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
  static const auth_forgotPassword_description =
      'auth.forgotPassword.description';
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
  static const auth_validation_passwordMinLength =
      'auth.validation.passwordMinLength';
  static const auth_validation_nameEmpty = 'auth.validation.nameEmpty';
  static const auth_validation_kvkkRequired = 'auth.validation.kvkkRequired';
  static const auth_validation_codeIncomplete =
      'auth.validation.codeIncomplete';

  // auth.errors
  static const auth_errors_invalidCredentials =
      'auth.errors.invalidCredentials';
  static const auth_errors_emailAlreadyRegistered =
      'auth.errors.emailAlreadyRegistered';
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

  // volunteer
  static const volunteer_becomeButton = 'volunteer.becomeButton';
  static const volunteer_free = 'volunteer.free';

  // volunteerAddListing
  static const volunteerAddListing_title = 'volunteerAddListing.title';
  static const volunteerAddListing_photoLabel = 'volunteerAddListing.photoLabel';
  static const volunteerAddListing_endTimeLabel = 'volunteerAddListing.endTimeLabel';
  static const volunteerAddListing_locationLabel = 'volunteerAddListing.locationLabel';
  static const volunteerAddListing_locationButton = 'volunteerAddListing.locationButton';
  static const volunteerAddListing_priceLabel = 'volunteerAddListing.priceLabel';
  static const volunteerAddListing_priceFree = 'volunteerAddListing.priceFree';
  static const volunteerAddListing_shareButton = 'volunteerAddListing.shareButton';
  static const volunteerAddListing_successMessage = 'volunteerAddListing.successMessage';
  static const volunteerAddListing_errorNoLocation = 'volunteerAddListing.errorNoLocation';
  static const volunteerAddListing_photoSelected = 'volunteerAddListing.photoSelected';
  static const volunteerAddListing_pickFromCamera = 'volunteerAddListing.pickFromCamera';
  static const volunteerAddListing_pickFromGallery = 'volunteerAddListing.pickFromGallery';

  // volunteerDetail
  static const volunteerDetail_tabOrder = 'volunteerDetail.tabOrder';
  static const volunteerDetail_tabReview = 'volunteerDetail.tabReview';
  static const volunteerDetail_becomeButton = 'volunteerDetail.becomeButton';
  static const volunteerDetail_freeLabel = 'volunteerDetail.freeLabel';
  static const volunteerDetail_goToLocation = 'volunteerDetail.goToLocation';
  static const volunteerDetail_goToShelter = 'volunteerDetail.goToShelter';
  static const volunteerDetail_nearestShelter = 'volunteerDetail.nearestShelter';
  static const volunteerDetail_noLocation = 'volunteerDetail.noLocation';
  static const volunteerDetail_noShelterLocation = 'volunteerDetail.noShelterLocation';
  static const volunteerDetail_moreDetail = 'volunteerDetail.moreDetail';
  static const volunteerDetail_ingredients = 'volunteerDetail.ingredients';
  static const volunteerDetail_packaging = 'volunteerDetail.packaging';
  static const volunteerDetail_shareLabel = 'volunteerDetail.shareLabel';
  static const volunteerDetail_listingLocation = 'volunteerDetail.listingLocation';
  static const volunteerDetail_volunteerSuccess = 'volunteerDetail.volunteerSuccess';

  // volunteerHome
  static const volunteerHome_nearbyPlaces = 'volunteerHome.nearbyPlaces';
  static const volunteerHome_todayPopular = 'volunteerHome.todayPopular';
  static const volunteerHome_seeAll = 'volunteerHome.seeAll';
  static const volunteerHome_searchHint = 'volunteerHome.searchHint';

  // volunteerSearch
  static const volunteerSearch_title = 'volunteerSearch.title';
  static const volunteerSearch_comingSoon = 'volunteerSearch.comingSoon';

  // volunteerProfile
  static const volunteerProfile_title = 'volunteerProfile.title';
  static const volunteerProfile_comingSoon = 'volunteerProfile.comingSoon';
  static const volunteerProfile_notifications = 'volunteerProfile.notifications';
  static const volunteerProfile_pastListings = 'volunteerProfile.pastListings';
  static const volunteerProfile_attendedListings = 'volunteerProfile.attendedListings';
  static const volunteerProfile_activeListings = 'volunteerProfile.activeListings';
  static const volunteerProfile_savedAddresses = 'volunteerProfile.savedAddresses';
  static const volunteerProfile_savedCards = 'volunteerProfile.savedCards';
  static const volunteerProfile_changeLanguage = 'volunteerProfile.changeLanguage';
  static const volunteerProfile_deleteAccount = 'volunteerProfile.deleteAccount';

  // volunteerListings
  static const volunteerListings_activeTitle = 'volunteerListings.activeTitle';
  static const volunteerListings_pastTitle = 'volunteerListings.pastTitle';
  static const volunteerListings_attendedTitle = 'volunteerListings.attendedTitle';
  static const volunteerListings_emptyMessage = 'volunteerListings.emptyMessage';
}
