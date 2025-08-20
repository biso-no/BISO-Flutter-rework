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
}
