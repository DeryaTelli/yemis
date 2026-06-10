// Bu dosya Ã§eviri key'lerini sabit olarak tutar.
// JSON yapÄ±sÄ±ndaki key hiyerarÅŸisi burada yansÄ±tÄ±lÄ±r.
// KullanÄ±m: LocaleKeys.auth_login_title.tr()
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
  static const home_todayPopularAll = 'home.todayPopularAll';
  static const home_locationLoading = 'home.locationLoading';

  // foodProfile
  static const foodProfile_title = 'foodProfile.title';
  static const foodProfile_notifications = 'foodProfile.notifications';
  static const foodProfile_history = 'foodProfile.history';
  static const foodProfile_addresses = 'foodProfile.addresses';
  static const foodProfile_cards = 'foodProfile.cards';
  static const foodProfile_updateProfile = 'foodProfile.updateProfile';
  static const foodProfile_changePassword = 'foodProfile.changePassword';
  static const foodProfile_changeLanguage = 'foodProfile.changeLanguage';
  static const foodProfile_logout = 'foodProfile.logout';
  static const foodProfile_editTitle = 'foodProfile.editTitle';
  static const foodProfile_updateButton = 'foodProfile.updateButton';
  static const profileEdit_updateSuccess = 'profileEdit.updateSuccess';

  // yemoAssistant
  static const yemoAssistant_foodFindTitle = 'yemoAssistant.foodFindTitle';
  static const yemoAssistant_foodFindSubtitle =
      'yemoAssistant.foodFindSubtitle';
  static const yemoAssistant_foodReserveTitle =
      'yemoAssistant.foodReserveTitle';
  static const yemoAssistant_foodReserveSubtitle =
      'yemoAssistant.foodReserveSubtitle';
  static const yemoAssistant_foodAiTitle = 'yemoAssistant.foodAiTitle';
  static const yemoAssistant_foodAiSubtitle = 'yemoAssistant.foodAiSubtitle';
  static const yemoAssistant_businessSalesTitle =
      'yemoAssistant.businessSalesTitle';
  static const yemoAssistant_businessSalesSubtitle =
      'yemoAssistant.businessSalesSubtitle';
  static const yemoAssistant_businessAddOrderTitle =
      'yemoAssistant.businessAddOrderTitle';
  static const yemoAssistant_businessAddOrderSubtitle =
      'yemoAssistant.businessAddOrderSubtitle';
  static const yemoAssistant_businessCo2Title =
      'yemoAssistant.businessCo2Title';
  static const yemoAssistant_businessCo2Subtitle =
      'yemoAssistant.businessCo2Subtitle';
  static const yemoAssistant_volunteerListingsTitle =
      'yemoAssistant.volunteerListingsTitle';
  static const yemoAssistant_volunteerListingsSubtitle =
      'yemoAssistant.volunteerListingsSubtitle';
  static const yemoAssistant_volunteerBecomeTitle =
      'yemoAssistant.volunteerBecomeTitle';
  static const yemoAssistant_volunteerBecomeSubtitle =
      'yemoAssistant.volunteerBecomeSubtitle';
  static const yemoAssistant_volunteerRegionTitle =
      'yemoAssistant.volunteerRegionTitle';
  static const yemoAssistant_volunteerRegionSubtitle =
      'yemoAssistant.volunteerRegionSubtitle';
  static const yemoAssistant_commonQuestionsTitle =
      'yemoAssistant.commonQuestionsTitle';
  static const yemoAssistant_commonQuestionsSubtitle =
      'yemoAssistant.commonQuestionsSubtitle';
  static const yemoAssistant_hintText = 'yemoAssistant.hintText';
  static const yemoAssistant_errorBusy = 'yemoAssistant.errorBusy';
  static const yemoAssistant_errorNetwork = 'yemoAssistant.errorNetwork';

  // notifications
  static const notifications_markAllRead = 'notifications.markAllRead';
  static const notifications_title = 'notifications.title';
  static const notifications_preferences = 'notifications.preferences';
  static const notifications_emptyTitle = 'notifications.emptyTitle';
  static const notifications_emptySubtitle = 'notifications.emptySubtitle';
  static const notifications_channelPrefs = 'notifications.channelPrefs';
  static const notifications_typePrefs = 'notifications.typePrefs';
  static const notifications_prefsNote = 'notifications.prefsNote';
  static const notifications_pushTitle = 'notifications.pushTitle';
  static const notifications_pushSubtitle = 'notifications.pushSubtitle';
  static const notifications_emailTitle = 'notifications.emailTitle';
  static const notifications_emailSubtitle = 'notifications.emailSubtitle';
  static const notifications_orderTitle = 'notifications.orderTitle';
  static const notifications_orderSubtitle = 'notifications.orderSubtitle';
  static const notifications_promoTitle = 'notifications.promoTitle';
  static const notifications_promoSubtitle = 'notifications.promoSubtitle';
  static const notifications_volunteerTitle = 'notifications.volunteerTitle';
  static const notifications_volunteerSubtitle =
      'notifications.volunteerSubtitle';

  // changePassword
  static const changePassword_currentPassword =
      'changePassword.currentPassword';
  static const changePassword_newPassword = 'changePassword.newPassword';

  // register
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
  static const volunteerDetail_cancelButton = 'volunteerDetail.cancelButton';
  static const volunteerDetail_cancelSuccess = 'volunteerDetail.cancelSuccess';
  static const volunteerDetail_cancelError = 'volunteerDetail.cancelError';
  static const volunteerDetail_cannotVolunteerOwnListing =
      'volunteerDetail.cannotVolunteerOwnListing';
  static const volunteerDetail_cannotVolunteerTitle =
      'volunteerDetail.cannotVolunteerTitle';

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
  static const volunteerListings_emptyPastTitle =
      'volunteerListings.emptyPastTitle';
  static const volunteerListings_emptyPastDescription =
      'volunteerListings.emptyPastDescription';
  static const volunteerListings_emptyAttendedTitle =
      'volunteerListings.emptyAttendedTitle';
  static const volunteerListings_emptyAttendedDescription =
      'volunteerListings.emptyAttendedDescription';
  static const volunteerListings_emptyActiveTitle =
      'volunteerListings.emptyActiveTitle';
  static const volunteerListings_emptyActiveDescription =
      'volunteerListings.emptyActiveDescription';
  static const volunteerListings_deleteError = 'volunteerListings.deleteError';
  static const volunteerListings_deleteConfirm =
      'volunteerListings.deleteConfirm';
  static const volunteerListings_deleteTitle = 'volunteerListings.deleteTitle';

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
  static const businessAddOrder_categoryLabel =
      'businessAddOrder.categoryLabel';
  static const businessAddOrder_categoryPlaceholder =
      'businessAddOrder.categoryPlaceholder';
  static const businessAddOrder_errorNoAddress =
      'businessAddOrder.errorNoAddress';

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
  static const addresses_noAddressFound = 'addresses.noAddressFound';
  static const addresses_deleted = 'addresses.deleted';
  static const addresses_city = 'addresses.city';
  static const addresses_district = 'addresses.district';
  static const addresses_neighborhood = 'addresses.neighborhood';
  static const addresses_addressLine = 'addresses.addressLine';
  static const addresses_addressTitle = 'addresses.addressTitle';
  static const addresses_select = 'addresses.select';
  static const addresses_selectCityFirst = 'addresses.selectCityFirst';
  static const addresses_selectDistrictFirst = 'addresses.selectDistrictFirst';
  static const addresses_enterAddressInfo = 'addresses.enterAddressInfo';
  static const addresses_enterAddressTitle = 'addresses.enterAddressTitle';

  // common
  static const common_edit = 'common.edit';
  static const common_delete = 'common.delete';
  static const common_update = 'common.update';
  static const common_camera = 'common.camera';
  static const common_gallery = 'common.gallery';
  static const common_cancel = 'common.cancel';
  static const common_save = 'common.save';
  static const common_error = 'common.error';
  static const common_success = 'common.success';
  static const common_yes = 'common.yes';
  static const common_no = 'common.no';
  static const common_pickFromCamera = 'common.pickFromCamera';
  static const common_pickFromGallery = 'common.pickFromGallery';

  // volunteerEditListing
  static const volunteerEditListing_title = 'volunteerEditListing.title';

  // navigation
  static const navigation_permissionRequired = 'navigation.permissionRequired';
  static const navigation_openSettings = 'navigation.openSettings';
  static const navigation_goToLocation = 'navigation.goToLocation';
  static const navigation_navigate = 'navigation.navigate';
  static const navigation_getDirections = 'navigation.getDirections';
  static const navigation_openGoogleMaps = 'navigation.openGoogleMaps';
  static const navigation_openYandexMaps = 'navigation.openYandexMaps';
  static const navigation_openAppleMaps = 'navigation.openAppleMaps';
  static const navigation_selectTravelMode = 'navigation.selectTravelMode';
  static const navigation_driving = 'navigation.driving';
  static const navigation_walking = 'navigation.walking';
  static const navigation_calculatingRoute = 'navigation.calculatingRoute';
  static const common_searchHint = 'common.searchHint';
  static const common_list = 'common.list';
  static const common_map = 'common.map';
  static const common_warning = 'common.warning';
  static const common_profileNoChange = 'common.profileNoChange';
  static const common_invalidUserId = 'common.invalidUserId';
  static const common_fullName = 'common.fullName';

  static const auth_resetPassword_title = 'auth.resetPassword.title';
  static const auth_changePassword_title = 'auth.changePassword.title';
  static const auth_fields_fullNameHint = 'auth.fields.fullNameHint';
  static const auth_fields_emailHint = 'auth.fields.emailHint';
  static const auth_verification_successMessage =
      'auth.verification.successMessage';

  static const businessProfile_editTitle = 'businessProfile.editTitle';
  static const businessProfile_addedListings = 'businessProfile.addedListings';
  static const businessProfile_soldOrdersTitle =
      'businessProfile.soldOrdersTitle';
  static const businessProfile_expiredListings =
      'businessProfile.expiredListings';

  static const businessAddOrder_titleHint = 'businessAddOrder.titleHint';
  static const businessAddOrder_descriptionHint =
      'businessAddOrder.descriptionHint';
  static const businessAddOrder_allergensHint =
      'businessAddOrder.allergensHint';

  static const home_volunteerSubtitle = 'home.volunteerSubtitle';
  static const home_foodTitle = 'home.foodTitle';
  static const home_foodSubtitle = 'home.foodSubtitle';
  static const home_businessTitle = 'home.businessTitle';
  static const home_businessSubtitle = 'home.businessSubtitle';
  static const home_onboarding1Subtitle = 'home.onboarding1Subtitle';
  static const home_onboarding2Title = 'home.onboarding2Title';
  static const home_onboarding2Subtitle = 'home.onboarding2Subtitle';
  static const home_onboarding3Title = 'home.onboarding3Title';
  static const home_onboarding3Subtitle = 'home.onboarding3Subtitle';
  static const home_onboarding4Title = 'home.onboarding4Title';
  static const home_onboarding4Subtitle = 'home.onboarding4Subtitle';

  static const foodFavorites_title = 'foodFavorites.title';
  static const businessListings_deleteError = 'businessListings.deleteError';
  static const volunteerEditListing_successTitle =
      'volunteerEditListing.successTitle';
  static const volunteerEditListing_successMessage =
      'volunteerEditListing.successMessage';
  static const businessEditOrder_successTitle =
      'businessEditOrder.successTitle';
  static const businessEditOrder_successMessage =
      'businessEditOrder.successMessage';
  static const common_selectLocation = 'common.selectLocation';
  static const common_selectLocationFromMap = 'common.selectLocationFromMap';
  static const common_noResults = 'common.noResults';
  static const common_pickupToday = 'common.pickupToday';
  static const common_pickupTomorrow = 'common.pickupTomorrow';
  static const common_sorting = 'common.sorting';
  static const common_clear = 'common.clear';

  static const sorting_defaultSort = 'sorting.defaultSort';
  static const sorting_rating = 'sorting.rating';
  static const sorting_lowToHigh = 'sorting.lowToHigh';
  static const sorting_highToLow = 'sorting.highToLow';
  static const sorting_price = 'sorting.price';
  static const sorting_distance = 'sorting.distance';
  static const sorting_nearToFar = 'sorting.nearToFar';

  static const filters_all = 'filters.all';
  static const filters_food = 'filters.food';
  static const filters_breadPastry = 'filters.breadPastry';
  static const filters_market = 'filters.market';
  static const filters_buyNow = 'filters.buyNow';

  // onboarding
  static const onboarding_page1_title = 'onboarding.page1.title';
  static const onboarding_page1_subtitle = 'onboarding.page1.subtitle';
  static const onboarding_page1_description = 'onboarding.page1.description';
  static const onboarding_page2_title = 'onboarding.page2.title';
  static const onboarding_page2_subtitle = 'onboarding.page2.subtitle';
  static const onboarding_page2_description = 'onboarding.page2.description';
  static const onboarding_page3_title = 'onboarding.page3.title';
  static const onboarding_page3_subtitle = 'onboarding.page3.subtitle';
  static const onboarding_page3_description = 'onboarding.page3.description';
  static const onboarding_page4_title = 'onboarding.page4.title';
  static const onboarding_page4_subtitle = 'onboarding.page4.subtitle';
  static const onboarding_page4_description = 'onboarding.page4.description';
  static const onboarding_buttons_skip = 'onboarding.buttons.skip';
  static const onboarding_buttons_next = 'onboarding.buttons.next';
  static const onboarding_buttons_start = 'onboarding.buttons.start';

  // Additional Keys
  static const volunteerListingDetail_activeBadge =
      'volunteerListingDetail.activeBadge';
  static const volunteerListingDetail_freeLabel =
      'volunteerListingDetail.freeLabel';
  static const volunteerListingDetail_deliveryRange =
      'volunteerListingDetail.deliveryRange';
  static const volunteerListingDetail_locationSection =
      'volunteerListingDetail.locationSection';
  static const volunteerListingDetail_address =
      'volunteerListingDetail.address';
  static const volunteerListingDetail_descriptionSection =
      'volunteerListingDetail.descriptionSection';
  static const volunteerListingDetail_noContent =
      'volunteerListingDetail.noContent';
  static const volunteerListingDetail_volunteerSection =
      'volunteerListingDetail.volunteerSection';

  static const volunteerListingCard_freeLabel =
      'volunteerListingCard.freeLabel';

  static const volunteerOrderTab_detailTitle = 'volunteerOrderTab.detailTitle';
  static const volunteerOrderTab_detailSubtitle =
      'volunteerOrderTab.detailSubtitle';
  static const volunteerOrderTab_descriptionTitle =
      'volunteerOrderTab.descriptionTitle';
  static const volunteerOrderTab_descriptionText =
      'volunteerOrderTab.descriptionText';
  static const volunteerOrderTab_ingredientsText =
      'volunteerOrderTab.ingredientsText';
  static const volunteerOrderTab_packagingText =
      'volunteerOrderTab.packagingText';

  static const volunteerAddListingForm_titleLabel =
      'volunteerAddListingForm.titleLabel';
  static const volunteerAddListingForm_titleHint =
      'volunteerAddListingForm.titleHint';
  static const volunteerAddListingForm_descriptionLabel =
      'volunteerAddListingForm.descriptionLabel';
  static const volunteerAddListingForm_descriptionHint =
      'volunteerAddListingForm.descriptionHint';
  static const volunteerAddListingForm_photoLabel =
      'volunteerAddListingForm.photoLabel';
  static const volunteerAddListingForm_endTimeLabel =
      'volunteerAddListingForm.endTimeLabel';
  static const volunteerAddListingForm_locationLabel =
      'volunteerAddListingForm.locationLabel';
  static const volunteerAddListingForm_priceLabel =
      'volunteerAddListingForm.priceLabel';
  static const volunteerAddListingForm_addressPlaceholder =
      'volunteerAddListingForm.addressPlaceholder';
  static const volunteerAddListingForm_noSavedAddress =
      'volunteerAddListingForm.noSavedAddress';

  static const foodFavoritesPage_empty = 'foodFavoritesPage.empty';
  static const foodFavoritesPage_emptyHint = 'foodFavoritesPage.emptyHint';

  static const foodReservationConfirm_title = 'foodReservationConfirm.title';
  static const foodReservationConfirm_goToLocation =
      'foodReservationConfirm.goToLocation';
  static const foodReservationConfirm_cancel = 'foodReservationConfirm.cancel';
  static const foodReservationConfirm_months_jan =
      'foodReservationConfirm.months.jan';
  static const foodReservationConfirm_months_feb =
      'foodReservationConfirm.months.feb';
  static const foodReservationConfirm_months_mar =
      'foodReservationConfirm.months.mar';
  static const foodReservationConfirm_months_apr =
      'foodReservationConfirm.months.apr';
  static const foodReservationConfirm_months_may =
      'foodReservationConfirm.months.may';
  static const foodReservationConfirm_months_jun =
      'foodReservationConfirm.months.jun';
  static const foodReservationConfirm_months_jul =
      'foodReservationConfirm.months.jul';
  static const foodReservationConfirm_months_aug =
      'foodReservationConfirm.months.aug';
  static const foodReservationConfirm_months_sep =
      'foodReservationConfirm.months.sep';
  static const foodReservationConfirm_months_oct =
      'foodReservationConfirm.months.oct';
  static const foodReservationConfirm_months_nov =
      'foodReservationConfirm.months.nov';
  static const foodReservationConfirm_months_dec =
      'foodReservationConfirm.months.dec';
  static const foodReservationConfirm_sectionNearby =
      'foodReservationConfirm.sectionNearby';
  static const foodReservationConfirm_sectionBuyNow =
      'foodReservationConfirm.sectionBuyNow';
  static const foodReservationConfirm_sectionTodayPopular =
      'foodReservationConfirm.sectionTodayPopular';
  static const foodReservationConfirm_sectionTodayPopularAll =
      'foodReservationConfirm.sectionTodayPopularAll';

  static const foodOrderTab_categoryBreadPastry =
      'foodOrderTab.categoryBreadPastry';
  static const foodOrderTab_surpriseBoxDesc = 'foodOrderTab.surpriseBoxDesc';
  static const foodOrderTab_listingDetail = 'foodOrderTab.listingDetail';
  static const foodOrderTab_distanceText = 'foodOrderTab.distanceText';
  static const foodOrderTab_category = 'foodOrderTab.category';
  static const foodOrderTab_ingredientsAllergens =
      'foodOrderTab.ingredientsAllergens';
  static const foodOrderTab_surpriseIngredients =
      'foodOrderTab.surpriseIngredients';
  static const foodOrderTab_allergens = 'foodOrderTab.allergens';
  static const foodOrderTab_categoryDetail = 'foodOrderTab.categoryDetail';
  static const foodOrderTab_categoryDesc = 'foodOrderTab.categoryDesc';
  static const foodReviewItem_today = 'foodReviewItem.today';

  static const businessListingDetail_approvedBadge =
      'businessListingDetail.approvedBadge';
  static const businessListingDetail_businessNameFallback =
      'businessListingDetail.businessNameFallback';
  static const businessListingDetail_createdAt =
      'businessListingDetail.createdAt';
  static const businessListingDetail_lastPickupTime =
      'businessListingDetail.lastPickupTime';
  static const businessListingDetail_category =
      'businessListingDetail.category';
  static const businessListingDetail_breadPastry =
      'businessListingDetail.breadPastry';
  static const businessListingDetail_notSpecified =
      'businessListingDetail.notSpecified';
  static const businessListingDetail_locationSection =
      'businessListingDetail.locationSection';
  static const businessListingDetail_address = 'businessListingDetail.address';
  static const businessListingDetail_noAddress =
      'businessListingDetail.noAddress';
  static const businessListingDetail_contentSection =
      'businessListingDetail.contentSection';
  static const businessListingDetail_noContent =
      'businessListingDetail.noContent';
  static const businessListingDetail_allergensSection =
      'businessListingDetail.allergensSection';
  static const businessListingDetail_noAllergens =
      'businessListingDetail.noAllergens';
  static const businessListingDetail_stockStatus =
      'businessListingDetail.stockStatus';
  static const businessListingDetail_remaining =
      'businessListingDetail.remaining';

  static const businessListings_allTitle = 'businessListings.allTitle';
  static const businessListings_soldTitle = 'businessListings.soldTitle';
  static const businessListings_activeTitle = 'businessListings.activeTitle';
  static const businessListings_expiredTitle = 'businessListings.expiredTitle';
  static const businessListings_emptyAll = 'businessListings.emptyAll';
  static const businessListings_emptySold = 'businessListings.emptySold';
  static const businessListings_emptyActive = 'businessListings.emptyActive';
  static const businessListings_emptyExpired = 'businessListings.emptyExpired';
  static const businessListings_emptyAllDescription =
      'businessListings.emptyAllDescription';
  static const businessListings_emptySoldDescription =
      'businessListings.emptySoldDescription';
  static const businessListings_emptyActiveDescription =
      'businessListings.emptyActiveDescription';
  static const businessListings_emptyExpiredDescription =
      'businessListings.emptyExpiredDescription';
  static const businessListings_deleteDialogTitle =
      'businessListings.deleteDialogTitle';
  static const businessListings_deleteDialogMessage =
      'businessListings.deleteDialogMessage';
  static const businessListings_soldOut = 'businessListings.soldOut';
  static const businessListings_expired = 'businessListings.expired';
  static const businessListings_remaining = 'businessListings.remaining';
  static const businessListings_noLocation = 'businessListings.noLocation';

  static const businessProfileEdit_fullNameLabel =
      'businessProfileEdit.fullNameLabel';
  static const businessProfileEdit_fullNameHint =
      'businessProfileEdit.fullNameHint';
  static const businessProfileEdit_emailLabel =
      'businessProfileEdit.emailLabel';
  static const businessProfileEdit_emailHint = 'businessProfileEdit.emailHint';
  static const businessProfileEdit_phoneLabel =
      'businessProfileEdit.phoneLabel';
  static const businessProfileEdit_updateButton =
      'businessProfileEdit.updateButton';
  static const businessProfileEdit_deleteAccountButton =
      'businessProfileEdit.deleteAccountButton';
  static const businessProfileEdit_cameraOption =
      'businessProfileEdit.cameraOption';
  static const businessProfileEdit_galleryOption =
      'businessProfileEdit.galleryOption';

  static const businessCard_noLocation = 'businessCard.noLocation';
  static const businessLocationButton_placeholder =
      'businessLocationButton.placeholder';

  static const weeklySales_days_mon = 'weeklySales.days.mon';
  static const weeklySales_days_tue = 'weeklySales.days.tue';
  static const weeklySales_days_wed = 'weeklySales.days.wed';
  static const weeklySales_days_thu = 'weeklySales.days.thu';
  static const weeklySales_days_fri = 'weeklySales.days.fri';
  static const weeklySales_days_sat = 'weeklySales.days.sat';
  static const weeklySales_days_sun = 'weeklySales.days.sun';

  // addresses (missing)
  static const addresses_newAddress = 'addresses.newAddress';
  static const addresses_deleteTitle = 'addresses.deleteTitle';
  static const addresses_deleteConfirm = 'addresses.deleteConfirm';
  static const addresses_defaultLabel = 'addresses.defaultLabel';
  static const addresses_editLabel = 'addresses.editLabel';
  static const addresses_selectFromLocation = 'addresses.selectFromLocation';
  static const addresses_enterAddress = 'addresses.enterAddress';
  static const addresses_notFound = 'addresses.notFound';
  static const addresses_editTitle = 'addresses.editTitle';
  static const addresses_addTitle = 'addresses.addTitle';
  static const addresses_ilLabel = 'addresses.ilLabel';
  static const addresses_ilceLabel = 'addresses.ilceLabel';
  static const addresses_mahalleLabel = 'addresses.mahalleLabel';
  static const addresses_adresLabel = 'addresses.adresLabel';
  static const addresses_adresHint = 'addresses.adresHint';
  static const addresses_baslikLabel = 'addresses.baslikLabel';
  static const addresses_baslikHint = 'addresses.baslikHint';
  static const addresses_selectPlaceholder = 'addresses.selectPlaceholder';
  static const addresses_selectIlFirst = 'addresses.selectIlFirst';
  static const addresses_selectIlceFirst = 'addresses.selectIlceFirst';
  static const addresses_selectIlTitle = 'addresses.selectIlTitle';
  static const addresses_selectIlceTitle = 'addresses.selectIlceTitle';
  static const addresses_selectMahalleTitle = 'addresses.selectMahalleTitle';
  static const addresses_mapMarked = 'addresses.mapMarked';

  // taskTracking – messages
  static const taskTracking_completedOwner = 'taskTracking.completedOwner';
  static const taskTracking_completedVolunteer =
      'taskTracking.completedVolunteer';
  static const taskTracking_deliveredPendingReviewOwner =
      'taskTracking.deliveredPendingReviewOwner';
  static const taskTracking_deliveredPendingReviewVolunteer =
      'taskTracking.deliveredPendingReviewVolunteer';
  static const taskTracking_goingToShelterOwner =
      'taskTracking.goingToShelterOwner';
  static const taskTracking_goingToShelterVolunteer =
      'taskTracking.goingToShelterVolunteer';
  static const taskTracking_pickedUpOwner = 'taskTracking.pickedUpOwner';
  static const taskTracking_pickedUpVolunteer =
      'taskTracking.pickedUpVolunteer';
  static const taskTracking_ownerHandedOverOwner =
      'taskTracking.ownerHandedOverOwner';
  static const taskTracking_ownerHandedOverVolunteer =
      'taskTracking.ownerHandedOverVolunteer';
  static const taskTracking_goingToPickUpOwner =
      'taskTracking.goingToPickUpOwner';
  static const taskTracking_goingToPickUpVolunteer =
      'taskTracking.goingToPickUpVolunteer';
  static const taskTracking_acceptedOwner = 'taskTracking.acceptedOwner';
  static const taskTracking_acceptedVolunteer =
      'taskTracking.acceptedVolunteer';
  static const taskTracking_pendingOwner = 'taskTracking.pendingOwner';
  static const taskTracking_pendingVolunteer = 'taskTracking.pendingVolunteer';

  static const taskTracking_statusPendingOwner =
      'taskTracking.statusPendingOwner';
  static const taskTracking_statusPendingVolunteer =
      'taskTracking.statusPendingVolunteer';
  static const taskTracking_statusApprovedOwner =
      'taskTracking.statusApprovedOwner';
  static const taskTracking_statusApprovedVolunteer =
      'taskTracking.statusApprovedVolunteer';
  static const taskTracking_statusInProgressOwner =
      'taskTracking.statusInProgressOwner';
  static const taskTracking_statusInProgressVolunteer =
      'taskTracking.statusInProgressVolunteer';
  static const taskTracking_statusDeliveredOwner =
      'taskTracking.statusDeliveredOwner';
  static const taskTracking_statusDeliveredVolunteer =
      'taskTracking.statusDeliveredVolunteer';
  static const taskTracking_statusCompletedOwner =
      'taskTracking.statusCompletedOwner';
  static const taskTracking_statusCompletedVolunteer =
      'taskTracking.statusCompletedVolunteer';
  static const taskTracking_statusCancelledOwner =
      'taskTracking.statusCancelledOwner';
  static const taskTracking_statusCancelledVolunteer =
      'taskTracking.statusCancelledVolunteer';
  static const taskTracking_buttonReject = 'taskTracking.buttonReject';
  static const taskTracking_buttonApprove = 'taskTracking.buttonApprove';
  static const taskTracking_buttonCancel = 'taskTracking.buttonCancel';
  static const taskTracking_buttonHandover = 'taskTracking.buttonHandover';
  static const taskTracking_buttonConfirmDelivery =
      'taskTracking.buttonConfirmDelivery';
  static const taskTracking_volunteerComment = 'taskTracking.volunteerComment';
  static const taskTracking_assignedVolunteer =
      'taskTracking.assignedVolunteer';
  static const taskTracking_volunteer = 'taskTracking.volunteer';
  static const taskTracking_deliveredExclamation =
      'taskTracking.deliveredExclamation';
  static const taskTracking_waitingApproval = 'taskTracking.waitingApproval';
  static const taskTracking_stepApproved = 'taskTracking.stepApproved';
  static const taskTracking_given = 'taskTracking.given';
  static const taskTracking_delivering = 'taskTracking.delivering';
  static const taskTracking_stepCompleted = 'taskTracking.stepCompleted';
  static const taskTracking_stepReview = 'taskTracking.stepReview';
  static const taskTracking_stepApproval = 'taskTracking.stepApproval';
  static const taskTracking_stepPickup = 'taskTracking.stepPickup';
  static const taskTracking_stepDelivery = 'taskTracking.stepDelivery';
  static const taskTracking_stepResult = 'taskTracking.stepResult';

  // volunteerListingCard
  static const volunteerListingCard_volunteered =
      'volunteerListingCard.volunteered';
  static const volunteerListingCard_noReviewYet =
      'volunteerListingCard.noReviewYet';
  static const volunteerListingCard_noVolunteerYet =
      'volunteerListingCard.noVolunteerYet';

  // volunteerListing
  static const volunteerListing_volunteerFailed =
      'volunteerListing.volunteerFailed';

  // volunteerOrderTab
  static const volunteerOrderTab_noShelterNearby =
      'volunteerOrderTab.noShelterNearby';

  // volunteerCancelDialog
  static const volunteerCancelDialog_confirm = 'volunteerCancelDialog.confirm';

  // taskTracking – buttons
  static const taskTracking_btnLeaveReview = 'taskTracking.btnLeaveReview';
  static const taskTracking_btnReject = 'taskTracking.btnReject';
  static const taskTracking_btnApprove = 'taskTracking.btnApprove';
  static const taskTracking_btnHandover = 'taskTracking.btnHandover';
  static const taskTracking_btnGoPickup = 'taskTracking.btnGoPickup';
  static const taskTracking_btnPickedUp = 'taskTracking.btnPickedUp';
  static const taskTracking_btnGoShelter = 'taskTracking.btnGoShelter';
  static const taskTracking_btnComplete = 'taskTracking.btnComplete';
  static const taskTracking_btnCancel = 'taskTracking.btnCancel';

  // businessReports
  static const businessReports_title = 'businessReports.title';
  static const businessReports_totalRevenue = 'businessReports.totalRevenue';
  static const businessReports_mealsSaved = 'businessReports.mealsSaved';
  static const businessReports_sellThroughRate = 'businessReports.sellThroughRate';
  static const businessReports_co2Saved = 'businessReports.co2Saved';
  static const businessReports_wastePrevented = 'businessReports.wastePrevented';
  static const businessReports_rating = 'businessReports.rating';
  static const businessReports_activeListings = 'businessReports.activeListings';
  static const businessReports_soldOutListings = 'businessReports.soldOutListings';
  static const businessReports_unsoldListings = 'businessReports.unsoldListings';
  static const businessReports_totalOrders = 'businessReports.totalOrders';
  static const businessReports_environmentalImpact = 'businessReports.environmentalImpact';
  static const businessReports_performanceSummary = 'businessReports.performanceSummary';
  static const businessReports_noData = 'businessReports.noData';
  static const businessReports_emptyTitle = 'businessReports.emptyTitle';
  static const businessReports_emptyDescription =
      'businessReports.emptyDescription';
}
