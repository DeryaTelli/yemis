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
  static const auth_forgotPassword_success = 'auth.forgotPassword.success';

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
  static const auth_fields_newPassword = 'auth.fields.newPassword';
  static const auth_fields_confirmPassword = 'auth.fields.confirmPassword';
  static const auth_fields_phone = 'auth.fields.phone';

  // auth.validation
  static const auth_validation_emailEmpty = 'auth.validation.emailEmpty';
  static const auth_validation_emailInvalid = 'auth.validation.emailInvalid';
  static const auth_validation_passwordEmpty = 'auth.validation.passwordEmpty';
  static const auth_validation_passwordMinLength =
      'auth.validation.passwordMinLength';
  static const auth_validation_nameEmpty = 'auth.validation.nameEmpty';
  static const auth_validation_kvkkRequired = 'auth.validation.kvkkRequired';
  static const auth_validation_phoneEmpty = 'auth.validation.phoneEmpty';
  static const auth_validation_phoneInvalid = 'auth.validation.phoneInvalid';
  static const auth_validation_codeIncomplete =
      'auth.validation.codeIncomplete';
  static const auth_validation_passwordsNotMatch =
      'auth.validation.passwordsNotMatch';

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
  static const foodDetail_noReviews = 'foodDetail.noReviews';
  static const foodDetail_noLocation = 'foodDetail.noLocation';

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
  static const volunteerAddListing_photoLabel =
      'volunteerAddListing.photoLabel';
  static const volunteerAddListing_endTimeLabel =
      'volunteerAddListing.endTimeLabel';
  static const volunteerAddListing_locationLabel =
      'volunteerAddListing.locationLabel';
  static const volunteerAddListing_locationButton =
      'volunteerAddListing.locationButton';
  static const volunteerAddListing_priceLabel =
      'volunteerAddListing.priceLabel';
  static const volunteerAddListing_priceFree = 'volunteerAddListing.priceFree';
  static const volunteerAddListing_shareButton =
      'volunteerAddListing.shareButton';
  static const volunteerAddListing_successMessage =
      'volunteerAddListing.successMessage';
  static const volunteerAddListing_errorNoLocation =
      'volunteerAddListing.errorNoLocation';
  static const volunteerAddListing_photoSelected =
      'volunteerAddListing.photoSelected';
  static const volunteerAddListing_pickFromCamera =
      'volunteerAddListing.pickFromCamera';
  static const volunteerAddListing_pickFromGallery =
      'volunteerAddListing.pickFromGallery';

  // volunteerDetail
  static const volunteerDetail_tabOrder = 'volunteerDetail.tabOrder';
  static const volunteerDetail_tabReview = 'volunteerDetail.tabReview';
  static const volunteerDetail_becomeButton = 'volunteerDetail.becomeButton';
  static const volunteerDetail_freeLabel = 'volunteerDetail.freeLabel';
  static const volunteerDetail_goToLocation = 'volunteerDetail.goToLocation';
  static const volunteerDetail_goToShelter = 'volunteerDetail.goToShelter';
  static const volunteerDetail_nearestShelter =
      'volunteerDetail.nearestShelter';
  static const volunteerDetail_noLocation = 'volunteerDetail.noLocation';
  static const volunteerDetail_noShelterLocation =
      'volunteerDetail.noShelterLocation';
  static const volunteerDetail_moreDetail = 'volunteerDetail.moreDetail';
  static const volunteerDetail_ingredients = 'volunteerDetail.ingredients';
  static const volunteerDetail_packaging = 'volunteerDetail.packaging';
  static const volunteerDetail_shareLabel = 'volunteerDetail.shareLabel';
  static const volunteerDetail_listingLocation =
      'volunteerDetail.listingLocation';
  static const volunteerDetail_volunteerSuccess =
      'volunteerDetail.volunteerSuccess';
  static const volunteerDetail_noReviews = 'volunteerDetail.noReviews';

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
  static const volunteerProfile_notifications =
      'volunteerProfile.notifications';
  static const volunteerProfile_pastListings = 'volunteerProfile.pastListings';
  static const volunteerProfile_attendedListings =
      'volunteerProfile.attendedListings';
  static const volunteerProfile_activeListings =
      'volunteerProfile.activeListings';
  static const volunteerProfile_savedAddresses =
      'volunteerProfile.savedAddresses';
  static const volunteerProfile_savedCards = 'volunteerProfile.savedCards';
  static const volunteerProfile_changeLanguage =
      'volunteerProfile.changeLanguage';
  static const volunteerProfile_deleteAccount =
      'volunteerProfile.deleteAccount';

  // volunteerListings
  static const volunteerListings_activeTitle = 'volunteerListings.activeTitle';
  static const volunteerListings_pastTitle = 'volunteerListings.pastTitle';
  static const volunteerListings_attendedTitle =
      'volunteerListings.attendedTitle';
  static const volunteerListings_emptyMessage =
      'volunteerListings.emptyMessage';

  // languageSelect
  static const languageSelect_title = 'languageSelect.title';
  static const languageSelect_description = 'languageSelect.description';
  static const languageSelect_turkish = 'languageSelect.turkish';
  static const languageSelect_english = 'languageSelect.english';
  static const languageSelect_confirmButton = 'languageSelect.confirmButton';

  // businessHome
  static const businessHome_weeklySalesTitle = 'businessHome.weeklySalesTitle';
  static const businessHome_addedOrders = 'businessHome.addedOrders';
  static const businessHome_soldOrders = 'businessHome.soldOrders';
  static const businessHome_reportsTitle = 'businessHome.reportsTitle';
  static const businessHome_reportsDescription =
      'businessHome.reportsDescription';
  static const businessHome_co2Title = 'businessHome.co2Title';
  static const businessHome_co2Description = 'businessHome.co2Description';
  static const businessHome_addOrderButton = 'businessHome.addOrderButton';

  // businessProfile
  static const businessProfile_title = 'businessProfile.title';
  static const businessProfile_dailyLabel = 'businessProfile.dailyLabel';
  static const businessProfile_soldCountLabel =
      'businessProfile.soldCountLabel';
  static const businessProfile_earningsLabel = 'businessProfile.earningsLabel';
  static const businessProfile_notifications = 'businessProfile.notifications';
  static const businessProfile_reports = 'businessProfile.reports';
  static const businessProfile_pastListings = 'businessProfile.pastListings';
  static const businessProfile_soldListings = 'businessProfile.soldListings';
  static const businessProfile_unsoldListings =
      'businessProfile.unsoldListings';
  static const businessProfile_savedCards = 'businessProfile.savedCards';
  static const businessProfile_updateProfile = 'businessProfile.updateProfile';
  static const businessProfile_changePassword =
      'businessProfile.changePassword';
  static const businessProfile_changeLanguage =
      'businessProfile.changeLanguage';
  static const businessProfile_deleteAccount = 'businessProfile.deleteAccount';

  // businessAddOrder
  static const businessAddOrder_title = 'businessAddOrder.title';
  static const businessAddOrder_photoLabel = 'businessAddOrder.photoLabel';
  static const businessAddOrder_endTimeLabel = 'businessAddOrder.endTimeLabel';
  static const businessAddOrder_locationLabel =
      'businessAddOrder.locationLabel';
  static const businessAddOrder_locationButton =
      'businessAddOrder.locationButton';
  static const businessAddOrder_quantityLabel =
      'businessAddOrder.quantityLabel';
  static const businessAddOrder_priceLabel = 'businessAddOrder.priceLabel';
  static const businessAddOrder_discountPriceLabel =
      'businessAddOrder.discountPriceLabel';
  static const businessAddOrder_shareButton = 'businessAddOrder.shareButton';
  static const businessAddOrder_successMessage =
      'businessAddOrder.successMessage';
  static const businessAddOrder_errorNoLocation =
      'businessAddOrder.errorNoLocation';
  static const businessAddOrder_titleLabel = 'businessAddOrder.titleLabel';
  static const businessAddOrder_descriptionLabel =
      'businessAddOrder.descriptionLabel';
  static const businessAddOrder_allergensLabel =
      'businessAddOrder.allergensLabel';
  static const businessAddOrder_pickFromCamera =
      'businessAddOrder.pickFromCamera';
  static const businessAddOrder_pickFromGallery =
      'businessAddOrder.pickFromGallery';

  // businessApprovals
  static const businessApprovals_title = 'businessApprovals.title';
  static const businessApprovals_noPending = 'businessApprovals.noPending';
  static const businessApprovals_reservedBy = 'businessApprovals.reservedBy';
  static const businessApprovals_todayPickup = 'businessApprovals.todayPickup';
  static const businessApprovals_approveButton =
      'businessApprovals.approveButton';
  static const businessApprovals_rejectButton =
      'businessApprovals.rejectButton';
  static const businessApprovals_approved = 'businessApprovals.approved';
  static const businessApprovals_rejected = 'businessApprovals.rejected';

  // foodReserve
  static const foodReserve_title = 'foodReserve.title';
  static const foodReserve_paymentMethod = 'foodReserve.paymentMethod';
  static const foodReserve_selectPayment = 'foodReserve.selectPayment';
  static const foodReserve_quantity = 'foodReserve.quantity';
  static const foodReserve_price = 'foodReserve.price';
  static const foodReserve_reserveButton = 'foodReserve.reserveButton';
  static const foodReserve_successMessage = 'foodReserve.successMessage';
  static const foodReserve_googlePay = 'foodReserve.googlePay';
  static const foodReserve_applePay = 'foodReserve.applePay';

  // addresses
  static const addresses_title = 'addresses.title';
  static const addresses_addAddress = 'addresses.addAddress';
}
