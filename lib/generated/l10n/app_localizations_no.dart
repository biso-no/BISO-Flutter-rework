// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian (`no`).
class AppLocalizationsNo extends AppLocalizations {
  AppLocalizationsNo([String locale = 'no']) : super(locale);

  @override
  String get appName => 'BISO';

  @override
  String get welcomeToBiso => 'Velkommen til BISO';

  @override
  String get email => 'E-post';

  @override
  String get enterEmail => 'Skriv inn e-postadressen din';

  @override
  String get enterValidEmail => 'Vennligst skriv inn en gyldig e-postadresse';

  @override
  String get emailMustBeBiDomain =>
      'E-post må være fra @bi.no eller @biso.no domene';

  @override
  String get continueButton => 'Fortsett';

  @override
  String get back => 'Tilbake';

  @override
  String get cancel => 'Avbryt';

  @override
  String get save => 'Lagre';

  @override
  String get login => 'Logg inn';

  @override
  String get logout => 'Logg ut';

  @override
  String get verifyOtp => 'Bekreft kode';

  @override
  String otpSentTo(String email) {
    return 'Vi har sendt en 6-sifret kode til $email';
  }

  @override
  String get enterOtpCode => 'Skriv inn 6-sifret kode';

  @override
  String get invalidOtpCode => 'Ugyldig kode. Vennligst prøv igjen.';

  @override
  String get resendCode => 'Send kode på nytt';

  @override
  String get openMailApp => 'Åpne e-post app';

  @override
  String get home => 'Hjem';

  @override
  String get explore => 'Utforsk';

  @override
  String get chat => 'Chat';

  @override
  String get profile => 'Profil';

  @override
  String get events => 'Arrangementer';

  @override
  String get marketplace => 'Markedsplass';

  @override
  String get jobs => 'Jobber';

  @override
  String get volunteer => 'Frivillig';

  @override
  String get expenses => 'Utgifter';

  @override
  String get clubsAndUnits => 'Klubber og enheter';

  @override
  String get bisoShop => 'BISO Butikk';

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
  String get selectCampus => 'Velg campus';

  @override
  String get personalInfo => 'Personlig informasjon';

  @override
  String get name => 'Navn';

  @override
  String get phone => 'Telefon';

  @override
  String get address => 'Adresse';

  @override
  String get city => 'By';

  @override
  String get zipCode => 'Postnummer';

  @override
  String get settings => 'Innstillinger';

  @override
  String get notifications => 'Varsler';

  @override
  String get language => 'Språk';

  @override
  String get english => 'Engelsk';

  @override
  String get norwegian => 'Norsk';

  @override
  String get error => 'Feil';

  @override
  String get success => 'Suksess';

  @override
  String get loading => 'Laster...';

  @override
  String get retry => 'Prøv igjen';

  @override
  String get noInternetConnection => 'Ingen internettforbindelse';

  @override
  String get somethingWentWrong => 'Noe gikk galt';
}
