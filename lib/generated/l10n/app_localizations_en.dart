// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'BISO';

  @override
  String get welcomeToBiso => 'Welcome to BISO';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterValidEmail => 'Please enter a valid email';

  @override
  String get emailMustBeBiDomain =>
      'Email must be from @bi.no or @biso.no domain';

  @override
  String get continueButton => 'Continue';

  @override
  String get back => 'Back';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get login => 'Log In';

  @override
  String get logout => 'Log Out';

  @override
  String get verifyOtp => 'Verify Code';

  @override
  String otpSentTo(String email) {
    return 'We\'ve sent a 6-digit code to $email';
  }

  @override
  String get enterOtpCode => 'Enter 6-digit code';

  @override
  String get invalidOtpCode => 'Invalid code. Please try again.';

  @override
  String get resendCode => 'Resend code';

  @override
  String get openMailApp => 'Open Mail App';

  @override
  String get home => 'Home';

  @override
  String get explore => 'Explore';

  @override
  String get chat => 'Chat';

  @override
  String get profile => 'Profile';

  @override
  String get events => 'Events';

  @override
  String get marketplace => 'Marketplace';

  @override
  String get jobs => 'Jobs';

  @override
  String get volunteer => 'Volunteer';

  @override
  String get expenses => 'Expenses';

  @override
  String get clubsAndUnits => 'Clubs & Units';

  @override
  String get bisoShop => 'BISO Shop';

  @override
  String get campus => 'Campus';

  @override
  String get oslo => 'Oslo';

  @override
  String get bergen => 'Bergen';

  @override
  String get trondheim => 'Trondheim';

  @override
  String get stavanger => 'Stavanger';

  @override
  String get selectCampus => 'Select your campus';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get address => 'Address';

  @override
  String get city => 'City';

  @override
  String get zipCode => 'ZIP Code';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get norwegian => 'Norwegian';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get forStudents => 'For Students';

  @override
  String get forBusiness => 'For Business';

  @override
  String get careerAdvantages => 'Career Advantages';

  @override
  String get students => 'Students';

  @override
  String get products => 'Products';

  @override
  String get clubs => 'Clubs';

  @override
  String get campusLeadership => 'Campus Leadership';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get close => 'Close';

  @override
  String get enable => 'Enable';

  @override
  String get details => 'Details';

  @override
  String get buyMembership => 'Buy Membership';

  @override
  String get renewMembership => 'Renew Membership';

  @override
  String get verificationCodeCopied => 'Verification code copied';

  @override
  String get keepPrivate => 'Keep Private';

  @override
  String get makePublic => 'Make Public';

  @override
  String get failedToLoadCampuses => 'Failed to load campuses';

  @override
  String get messageCopied => 'Message copied to clipboard';

  @override
  String get paymentInformation => 'Payment Information';

  @override
  String get paymentInfoSaved => 'Payment information saved successfully';

  @override
  String paymentInfoSaveFailed(String error) => 'Failed to save payment information: $error';

  @override
  String get savePaymentInformation => 'Save Payment Information';

  @override
  String get chatNotifications => 'Chat Notifications';

  @override
  String get checkingPermissions => 'Checking permissions...';

  @override
  String get receiveMessageNotifications => 'Receive notifications for new messages';

  @override
  String get loadingNotificationSettings => 'Loading notification settings...';

  @override
  String get errorLoadingNotificationSettings => 'Error loading notification settings';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrationDescription => 'Vibrate for new messages';

  @override
  String get sound => 'Sound';

  @override
  String get soundDescription => 'Play sound for new messages';

  @override
  String get readReceipts => 'Read Receipts';

  @override
  String get typingIndicators => 'Typing Indicators';

  @override
  String get lastSeen => 'Last Seen';

  @override
  String get lastSeenDescription => 'Show your last seen status';

  @override
  String get autoDeleteMessages => 'Auto-delete Messages';

  @override
  String get autoDeleteMessagesDescription => 'Automatically delete old messages';

  @override
  String get never => 'Never';

  @override
  String get autoDeleteOptionsComingSoon => 'Auto-delete options coming soon';

  @override
  String get autoDownloadMedia => 'Auto-download Media';

  @override
  String get wifiOnly => 'Wi-Fi only';

  @override
  String get autoDownloadOptionsComingSoon => 'Auto-download options coming soon';

  @override
  String get loadingYourProfile => 'Loading your profile...';

  @override
  String get completeProfile => 'Complete Profile';

  @override
  String get signOut => 'Sign Out';

  @override
  String get areYouSureSignOut => 'Are you sure you want to sign out?';

  @override
  String get studentVerification => 'Student Verification';

  @override
  String get pleaseRegisterStudentId => 'Please register your student ID first.';

  @override
  String get removeStudentId => 'Remove Student ID';

  @override
  String get remove => 'Remove';

  @override
  String get tryAgain => 'Try again';

  @override
  String get connectBiAccount => 'Connect BI Account';

  @override
  String get refresh => 'Refresh';

  @override
  String get purchaseMembership => 'Purchase Membership';

  @override
  String get refreshStatus => 'Refresh Status';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeDescription => 'Use dark theme throughout the app';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get clearCacheDescription => 'Free up storage space';

  @override
  String get offlineData => 'Offline Data';

  @override
  String get offlineDataDescription => 'Manage downloaded content';

  @override
  String get offlineComingSoon => 'Offline data management coming soon';

  @override
  String get appVersion => 'App Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get cacheClearedSuccessfully => 'Cache cleared successfully';

  @override
  String get clear => 'Clear';

  @override
  String get eventsNotifications => 'Events';

  @override
  String get marketplaceNotifications => 'Marketplace';

  @override
  String get jobOpportunities => 'Job Opportunities';

  @override
  String get jobOpportunitiesDescription => 'Volunteer and job opportunities';

  @override
  String get expensesNotifications => 'Expenses';

  @override
  String get expensesNotificationsDescription => 'Expense reimbursement status updates';

  @override
  String get chatMessagesNotifications => 'Chat Messages';

  @override
  String get chatMessagesDescription => 'New messages in your chats';

  @override
  String get quietHours => 'Quiet Hours';

  @override
  String get quietHoursComingSoon => 'Quiet hours feature coming soon';

  @override
  String get dateFormat => 'Date Format';

  @override
  String get dateFormatValue => 'DD/MM/YYYY (Norwegian)';

  @override
  String get dateFormatOptionsComingSoon => 'Date format options coming soon';

  @override
  String get currency => 'Currency';

  @override
  String get currencyValue => 'NOK (Norwegian Krone)';

  @override
  String get sellItem => 'Sell Item';

  @override
  String get publish => 'Publish';

  @override
  String get priceNegotiable => 'Price is negotiable';

  @override
  String get discardChanges => 'Discard changes?';

  @override
  String get keepEditing => 'Keep Editing';

  @override
  String get discard => 'Discard';

  @override
  String get pleaseAddAtLeastOnePhoto => 'Please add at least one photo';

  @override
  String get itemNowLive => 'Your item is now live!';

  @override
  String failedToPublish(String error) => 'Failed to publish: $error';

  @override
  String get unitsAndDepartments => 'Units & Departments';

  @override
  String failedToLoad(String error) => 'Failed to load: $error';

  @override
  String get notificationsEnabled => 'Notifications enabled successfully!';

  @override
  String errorEnablingNotifications(String error) => 'Error enabling notifications: $error';

  @override
  String purchaseFailed(String error) => 'Purchase failed: $error';

  @override
  String failedToLoadMembershipOptions(String error) => 'Failed to load membership options: $error';

  // Tabs and sections
  @override
  String get general => 'General';
  @override
  String get privacy => 'Privacy';
  @override
  String get appLanguage => 'App Language';
  @override
  String get account => 'Account';
  @override
  String get dataAndStorage => 'Data & Storage';
  @override
  String get about => 'About';

  // Settings/general
  @override
  String get currentCampus => 'Current Campus';
  @override
  String get useCampusSwitcherHint => 'Use the campus switcher on the home screen to change campus';
  @override
  String get validatorMode => 'Validator Mode';
  @override
  String get openValidatorMode => 'Open Validator Mode';
  @override
  String get scanStudentQRCodes => 'Scan student QR codes to verify membership';

  // Notifications tab
  @override
  String get pushNotifications => 'Push Notifications';
  @override
  String get marketplaceNewItemsDeals => 'New items and deals in the marketplace';
  @override
  String get notificationSchedule => 'Notification Schedule';
  @override
  String get muteNotificationsDuringSpecificHours => 'Mute notifications during specific hours';
  @override
  String get vibrationSettingsComingSoon => 'Vibration settings coming soon';

  // Privacy tab
  @override
  String get privacyInformation => 'Privacy Information';
  @override
  String get publicProfile => 'Public Profile';
  @override
  String get othersCanFindAndMessageYou => 'Others can find and message you';
  @override
  String get privateProfile => 'Private Profile';
  @override
  String get othersCannotFindYouInSearch => 'Others cannot find you in search';
  @override
  String get youCanStillMessageOthers => 'You can still message others';
  @override
  String get onlyYouCanStartNewConversations => 'Only you can start new conversations';
  @override
  String get existingConversationsRemainActive => 'Existing conversations remain active';

  // Language tab
  @override
  String get languageChangeRestartNotice => 'Language changes will take effect after restarting the app.';
  @override
  String get regionalSettings => 'Regional Settings';
  @override
  String get currencyAutoNokHint => 'Currency is automatically set to NOK for BI students';

  // Profile screen
  @override
  String get signInToViewProfile => 'Sign in to view your profile';
  @override
  String get editProfile => 'Edit Profile';
  @override
  String get studentId => 'Student ID';
  @override
  String get profileInformation => 'Profile Information';
  @override
  String get campusAndInterests => 'Campus & Interests';
  @override
  String get interests => 'Interests';
  @override
  String get expenseHistory => 'Expense History';
  @override
  String get notificationPreferences => 'Notification Preferences';
  @override
  String get languageSettings => 'Language Settings';
  @override
  String get unknownUser => 'Unknown User';

  // Sell product
  @override
  String get pleaseSignInToSellItems => 'Please sign in to sell items';
  @override
  String get titleLabel => 'Title';
  @override
  String get exampleMacbook => 'e.g., MacBook Pro 13"';
  @override
  String get titleIsRequired => 'Title is required';
  @override
  String get descriptionLabel => 'Description';
  @override
  String get pleaseAddMoreDetail => 'Please add a bit more detail';
  @override
  String get priceNok => 'Price (NOK)';
  @override
  String get requiredField => 'Required';
  @override
  String get enterValidAmount => 'Enter a valid amount';
  @override
  String get categoryLabel => 'Category';
  @override
  String get conditionLabel => 'Condition';
  @override
  String get preferredContactOptional => 'Preferred contact (optional)';
  @override
  String get contactInfoOptional => 'Contact info (optional)';
  @override
  String get photos => 'Photos';
  @override
  String get none => 'None';
  @override
  String get inAppMessage => 'In-app message';

  // Category and condition labels
  @override
  String get categoryBooks => 'Books';
  @override
  String get categoryElectronics => 'Electronics';
  @override
  String get categoryFurniture => 'Furniture';
  @override
  String get categoryClothes => 'Clothes';
  @override
  String get categorySports => 'Sports';
  @override
  String get categoryOther => 'Other';

  @override
  String get conditionBrandNew => 'Brand new';
  @override
  String get conditionLikeNew => 'Like new';
  @override
  String get conditionGood => 'Good';
  @override
  String get conditionFair => 'Fair';
  @override
  String get conditionPoor => 'Poor';

  // Dialog text
  @override
  String get unsavedChangesWarning => 'If you leave now, your changes will not be saved.';

  // Membership UI
  @override
  String get bisoMembership => 'BISO Membership';
  @override
  String get membershipBenefitsBlurb => 'Get access to exclusive events, discounts, and more';
  @override
  String get membershipExpired => 'Membership Expired';
  @override
  String membershipExpiredOn(String name, String date) => 'Your $name membership expired on $date';
  @override
  String membershipExpiredNoDate(String name) => 'Your $name membership expired';
  @override
  String get validUntil => 'Valid Until';
  @override
  String get noExpiry => 'No expiry';
  @override
  String get memberSince => 'Member Since';
  @override
  String get unknown => 'Unknown';
  @override
  String get memberBenefitsActive => 'Member Benefits Active';
  @override
  String get memberBenefitsBullets => 'Event access • Expense reimbursements • Marketplace discounts • Priority support';
  @override
  String idLabel(String code) => 'ID: $code';
}
