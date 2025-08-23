import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_no.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('no'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'BISO'**
  String get appName;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome to BISO'**
  String get welcomeToBiso;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Email field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmail;

  /// Email domain validation error
  ///
  /// In en, this message translates to:
  /// **'Email must be from @bi.no or @biso.no domain'**
  String get emailMustBeBiDomain;

  /// Continue button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Login button
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// OTP verification screen title
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verifyOtp;

  /// OTP sent message
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a 6-digit code to {email}'**
  String otpSentTo(String email);

  /// OTP input hint
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit code'**
  String get enterOtpCode;

  /// Invalid OTP error message
  ///
  /// In en, this message translates to:
  /// **'Invalid code. Please try again.'**
  String get invalidOtpCode;

  /// Resend OTP button
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// Button to open default mail app
  ///
  /// In en, this message translates to:
  /// **'Open Mail App'**
  String get openMailApp;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Explore tab label
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// Chat tab label
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Profile tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Events category
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// Marketplace category
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplace;

  /// Jobs category
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get jobs;

  /// Volunteer opportunities
  ///
  /// In en, this message translates to:
  /// **'Volunteer'**
  String get volunteer;

  /// Expense reimbursements
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// Student organizations
  ///
  /// In en, this message translates to:
  /// **'Clubs & Units'**
  String get clubsAndUnits;

  /// BISO Shop
  ///
  /// In en, this message translates to:
  /// **'BISO Shop'**
  String get bisoShop;

  /// Campus
  ///
  /// In en, this message translates to:
  /// **'Campus'**
  String get campus;

  /// Oslo campus
  ///
  /// In en, this message translates to:
  /// **'Oslo'**
  String get oslo;

  /// Bergen campus
  ///
  /// In en, this message translates to:
  /// **'Bergen'**
  String get bergen;

  /// Trondheim campus
  ///
  /// In en, this message translates to:
  /// **'Trondheim'**
  String get trondheim;

  /// Stavanger campus
  ///
  /// In en, this message translates to:
  /// **'Stavanger'**
  String get stavanger;

  /// Campus selection prompt
  ///
  /// In en, this message translates to:
  /// **'Select your campus'**
  String get selectCampus;

  /// Personal info section
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// Name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Phone field
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Address field
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// City field
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// ZIP code field
  ///
  /// In en, this message translates to:
  /// **'ZIP Code'**
  String get zipCode;

  /// Settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Norwegian language
  ///
  /// In en, this message translates to:
  /// **'Norwegian'**
  String get norwegian;

  /// Error
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Success
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Loading state
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No internet error
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Student benefits section title
  ///
  /// In en, this message translates to:
  /// **'For Students'**
  String get forStudents;

  /// Business benefits section title
  ///
  /// In en, this message translates to:
  /// **'For Business'**
  String get forBusiness;

  /// Career advantages section title
  ///
  /// In en, this message translates to:
  /// **'Career Advantages'**
  String get careerAdvantages;

  /// Students count label
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get students;

  /// Products category
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// Clubs category
  ///
  /// In en, this message translates to:
  /// **'Clubs'**
  String get clubs;

  /// Campus leadership section title
  ///
  /// In en, this message translates to:
  /// **'Campus Leadership'**
  String get campusLeadership;

  /// Contact information section title
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// Close button
  String get close;

  /// Enable button
  String get enable;

  /// Details label
  String get details;

  /// Buy membership button
  String get buyMembership;

  /// Renew membership button
  String get renewMembership;

  /// Verification code copied message
  String get verificationCodeCopied;

  /// Keep private button
  String get keepPrivate;

  /// Make public button
  String get makePublic;

  /// Failed to load campuses message
  String get failedToLoadCampuses;

  /// Message copied snackbar
  String get messageCopied;

  /// Payment information title
  String get paymentInformation;

  /// Payment info saved
  String get paymentInfoSaved;

  /// Payment info save failed
  String paymentInfoSaveFailed(String error);

  /// Save payment info button
  String get savePaymentInformation;

  /// Chat notifications title
  String get chatNotifications;

  /// Checking permissions text
  String get checkingPermissions;

  /// Receive notifications description
  String get receiveMessageNotifications;

  /// Loading notification settings
  String get loadingNotificationSettings;

  /// Error loading notification settings
  String get errorLoadingNotificationSettings;

  /// Vibration setting
  String get vibration;

  /// Vibration description
  String get vibrationDescription;

  /// Sound setting
  String get sound;

  /// Sound description
  String get soundDescription;

  /// Read receipts setting
  String get readReceipts;

  /// Typing indicators setting
  String get typingIndicators;

  /// Last seen setting
  String get lastSeen;

  /// Last seen description
  String get lastSeenDescription;

  /// Auto-delete messages setting
  String get autoDeleteMessages;

  /// Auto-delete messages description
  String get autoDeleteMessagesDescription;

  /// Never option
  String get never;

  /// Auto-delete options coming soon
  String get autoDeleteOptionsComingSoon;

  /// Auto-download media setting
  String get autoDownloadMedia;

  /// Wi-Fi only option
  String get wifiOnly;

  /// Auto-download options coming soon
  String get autoDownloadOptionsComingSoon;

  /// Loading your profile
  String get loadingYourProfile;

  /// Complete Profile button
  String get completeProfile;

  /// Sign Out button
  String get signOut;

  /// Sign out confirmation
  String get areYouSureSignOut;

  /// Student verification title
  String get studentVerification;

  /// Register student ID first
  String get pleaseRegisterStudentId;

  /// Remove student ID title
  String get removeStudentId;

  /// Remove button
  String get remove;

  /// Try again button
  String get tryAgain;

  /// Connect BI account button
  String get connectBiAccount;

  /// Refresh button
  String get refresh;

  /// Purchase membership button
  String get purchaseMembership;

  /// Refresh status button
  String get refreshStatus;

  /// Dark mode setting
  String get darkMode;

  /// Dark mode description
  String get darkModeDescription;

  /// Clear cache setting
  String get clearCache;

  /// Clear cache description
  String get clearCacheDescription;

  /// Offline data setting
  String get offlineData;

  /// Offline data description
  String get offlineDataDescription;

  /// Offline coming soon
  String get offlineComingSoon;

  /// App Version
  String get appVersion;

  /// Privacy Policy
  String get privacyPolicy;

  /// Terms of Service
  String get termsOfService;

  /// Cache cleared successfully
  String get cacheClearedSuccessfully;

  /// Clear button
  String get clear;

  /// Events notifications
  String get eventsNotifications;

  /// Marketplace notifications
  String get marketplaceNotifications;

  /// Job opportunities
  String get jobOpportunities;

  /// Job opportunities description
  String get jobOpportunitiesDescription;

  /// Expenses notifications
  String get expensesNotifications;

  /// Expenses notifications description
  String get expensesNotificationsDescription;

  /// Chat messages notifications
  String get chatMessagesNotifications;

  /// Chat messages description
  String get chatMessagesDescription;

  /// Quiet hours
  String get quietHours;

  /// Quiet hours coming soon
  String get quietHoursComingSoon;

  /// Date format
  String get dateFormat;

  /// Date format value
  String get dateFormatValue;

  /// Date format options coming soon
  String get dateFormatOptionsComingSoon;

  /// Currency
  String get currency;

  /// Currency value
  String get currencyValue;

  /// Sell item
  String get sellItem;

  /// Publish
  String get publish;

  /// Price negotiable
  String get priceNegotiable;

  /// Discard changes title
  String get discardChanges;

  /// Keep editing
  String get keepEditing;

  /// Discard button
  String get discard;

  /// Please add at least one photo
  String get pleaseAddAtLeastOnePhoto;

  /// Item now live
  String get itemNowLive;

  /// Failed to publish with error
  String failedToPublish(String error);

  /// Units & Departments
  String get unitsAndDepartments;

  /// Generic failed to load with error
  String failedToLoad(String error);

  /// Notifications enabled
  String get notificationsEnabled;

  /// Error enabling notifications with error
  String errorEnablingNotifications(String error);

  /// Purchase failed with error
  String purchaseFailed(String error);

  /// Failed to load membership options with error
  String failedToLoadMembershipOptions(String error);

  // Tabs and sections
  String get general;
  String get privacy;
  String get appLanguage;
  String get account;
  String get dataAndStorage;
  String get about;

  // Settings/general
  String get currentCampus;
  String get useCampusSwitcherHint;
  String get validatorMode;
  String get openValidatorMode;
  String get scanStudentQRCodes;

  // Notifications tab
  String get pushNotifications;
  String get marketplaceNewItemsDeals;
  String get notificationSchedule;
  String get muteNotificationsDuringSpecificHours;
  String get vibrationSettingsComingSoon;

  // Privacy tab
  String get privacyInformation;
  String get publicProfile;
  String get othersCanFindAndMessageYou;
  String get privateProfile;
  String get othersCannotFindYouInSearch;
  String get youCanStillMessageOthers;
  String get onlyYouCanStartNewConversations;
  String get existingConversationsRemainActive;

  // Language tab
  String get languageChangeRestartNotice;
  String get regionalSettings;
  String get currencyAutoNokHint;

  // Profile screen
  String get signInToViewProfile;
  String get editProfile;
  String get studentId;
  String get profileInformation;
  String get campusAndInterests;
  String get interests;
  String get expenseHistory;
  String get notificationPreferences;
  String get languageSettings;
  String get unknownUser;

  // Sell product
  String get pleaseSignInToSellItems;
  String get titleLabel;
  String get exampleMacbook;
  String get titleIsRequired;
  String get descriptionLabel;
  String get pleaseAddMoreDetail;
  String get priceNok;
  String get requiredField;
  String get enterValidAmount;
  String get categoryLabel;
  String get conditionLabel;
  String get preferredContactOptional;
  String get contactInfoOptional;
  String get photos;
  String get none;
  String get inAppMessage;

  // Category and condition labels
  String get categoryBooks;
  String get categoryElectronics;
  String get categoryFurniture;
  String get categoryClothes;
  String get categorySports;
  String get categoryOther;

  String get conditionBrandNew;
  String get conditionLikeNew;
  String get conditionGood;
  String get conditionFair;
  String get conditionPoor;

  // Dialog text
  String get unsavedChangesWarning;

  // Membership UI
  String get bisoMembership;
  String get membershipBenefitsBlurb;
  String get membershipExpired;
  String membershipExpiredOn(String name, String date);
  String membershipExpiredNoDate(String name);
  String get validUntil;
  String get noExpiry;
  String get memberSince;
  String get unknown;
  String get memberBenefitsActive;
  String get memberBenefitsBullets;
  String idLabel(String code);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'no'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'no':
      return AppLocalizationsNo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
