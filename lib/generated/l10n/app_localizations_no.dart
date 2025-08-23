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

  @override
  String get forStudents => 'For Studenter';

  @override
  String get forBusiness => 'For Bedrifter';

  @override
  String get careerAdvantages => 'Karrierefordeler';

  @override
  String get students => 'Studenter';

  @override
  String get products => 'Produkter';

  @override
  String get clubs => 'Klubber';

  @override
  String get campusLeadership => 'Campus Ledelse';

  @override
  String get contactInformation => 'Kontaktinformasjon';

  @override
  String get close => 'Lukk';

  @override
  String get enable => 'Aktiver';

  @override
  String get details => 'Detaljer';

  @override
  String get buyMembership => 'Kjøp medlemskap';

  @override
  String get renewMembership => 'Forny medlemskap';

  @override
  String get verificationCodeCopied => 'Verifiseringskode kopiert';

  @override
  String get keepPrivate => 'Hold privat';

  @override
  String get makePublic => 'Gjør offentlig';

  @override
  String get failedToLoadCampuses => 'Kunne ikke laste campuser';

  @override
  String get messageCopied => 'Melding kopiert til utklippstavlen';

  @override
  String get paymentInformation => 'Betalingsinformasjon';

  @override
  String get paymentInfoSaved => 'Betalingsinformasjon lagret';

  @override
  String paymentInfoSaveFailed(String error) => 'Kunne ikke lagre betalingsinformasjon: $error';

  @override
  String get savePaymentInformation => 'Lagre betalingsinformasjon';

  @override
  String get chatNotifications => 'Chat-varsler';

  @override
  String get checkingPermissions => 'Sjekker tillatelser...';

  @override
  String get receiveMessageNotifications => 'Motta varsler for nye meldinger';

  @override
  String get loadingNotificationSettings => 'Laster varslingsinnstillinger...';

  @override
  String get errorLoadingNotificationSettings => 'Feil ved lasting av varslingsinnstillinger';

  @override
  String get vibration => 'Vibrasjon';

  @override
  String get vibrationDescription => 'Vibrer for nye meldinger';

  @override
  String get sound => 'Lyd';

  @override
  String get soundDescription => 'Spill av lyd for nye meldinger';

  @override
  String get readReceipts => 'Lese kvitteringer';

  @override
  String get typingIndicators => 'Skriveindikatorer';

  @override
  String get lastSeen => 'Sist sett';

  @override
  String get lastSeenDescription => 'Vis din sist sett-status';

  @override
  String get autoDeleteMessages => 'Auto-slett meldinger';

  @override
  String get autoDeleteMessagesDescription => 'Slett gamle meldinger automatisk';

  @override
  String get never => 'Aldri';

  @override
  String get autoDeleteOptionsComingSoon => 'Alternativer for auto-slett kommer snart';

  @override
  String get autoDownloadMedia => 'Auto-last ned media';

  @override
  String get wifiOnly => 'Kun Wi-Fi';

  @override
  String get autoDownloadOptionsComingSoon => 'Alternativer for auto-nedlasting kommer snart';

  @override
  String get loadingYourProfile => 'Laster profilen din...';

  @override
  String get completeProfile => 'Fullfør profil';

  @override
  String get signOut => 'Logg ut';

  @override
  String get areYouSureSignOut => 'Er du sikker på at du vil logge ut?';

  @override
  String get studentVerification => 'Studentverifisering';

  @override
  String get pleaseRegisterStudentId => 'Vennligst registrer student-ID først.';

  @override
  String get removeStudentId => 'Fjern student-ID';

  @override
  String get remove => 'Fjern';

  @override
  String get tryAgain => 'Prøv igjen';

  @override
  String get connectBiAccount => 'Koble til BI-konto';

  @override
  String get refresh => 'Oppdater';

  @override
  String get purchaseMembership => 'Kjøp medlemskap';

  @override
  String get refreshStatus => 'Oppdater status';

  @override
  String get darkMode => 'Mørk modus';

  @override
  String get darkModeDescription => 'Bruk mørkt tema i hele appen';

  @override
  String get clearCache => 'Tøm cache';

  @override
  String get clearCacheDescription => 'Frigjør lagringsplass';

  @override
  String get offlineData => 'Frakoblet data';

  @override
  String get offlineDataDescription => 'Administrer nedlastet innhold';

  @override
  String get offlineComingSoon => 'Administrasjon av frakoblet data kommer snart';

  @override
  String get appVersion => 'Appversjon';

  @override
  String get privacyPolicy => 'Personvernerklæring';

  @override
  String get termsOfService => 'Vilkår for bruk';

  @override
  String get cacheClearedSuccessfully => 'Cache tømt';

  @override
  String get clear => 'Tøm';

  @override
  String get eventsNotifications => 'Arrangementer';

  @override
  String get marketplaceNotifications => 'Markedsplass';

  @override
  String get jobOpportunities => 'Jobbmuligheter';

  @override
  String get jobOpportunitiesDescription => 'Frivillig- og jobbmuligheter';

  @override
  String get expensesNotifications => 'Utgifter';

  @override
  String get expensesNotificationsDescription => 'Oppdateringer om utgiftsrefusjoner';

  @override
  String get chatMessagesNotifications => 'Chatmeldinger';

  @override
  String get chatMessagesDescription => 'Nye meldinger i chattene dine';

  @override
  String get quietHours => 'Stilletid';

  @override
  String get quietHoursComingSoon => 'Stilletid-funksjon kommer snart';

  @override
  String get dateFormat => 'Datoformat';

  @override
  String get dateFormatValue => 'DD/MM/ÅÅÅÅ (Norsk)';

  @override
  String get dateFormatOptionsComingSoon => 'Alternativer for datoformat kommer snart';

  @override
  String get currency => 'Valuta';

  @override
  String get currencyValue => 'NOK (Norsk krone)';

  @override
  String get sellItem => 'Selg vare';

  @override
  String get publish => 'Publiser';

  @override
  String get priceNegotiable => 'Pris kan diskuteres';

  @override
  String get discardChanges => 'Forkaste endringer?';

  @override
  String get keepEditing => 'Fortsett å redigere';

  @override
  String get discard => 'Forkast';

  @override
  String get pleaseAddAtLeastOnePhoto => 'Vennligst legg til minst ett bilde';

  @override
  String get itemNowLive => 'Varen din er nå publisert!';

  @override
  String failedToPublish(String error) => 'Kunne ikke publisere: $error';

  @override
  String get unitsAndDepartments => 'Enheter og avdelinger';

  @override
  String failedToLoad(String error) => 'Kunne ikke laste: $error';

  @override
  String get notificationsEnabled => 'Varsler aktivert!';

  @override
  String errorEnablingNotifications(String error) => 'Feil ved aktivering av varsler: $error';

  @override
  String purchaseFailed(String error) => 'Kjøp mislyktes: $error';

  @override
  String failedToLoadMembershipOptions(String error) => 'Kunne ikke laste medlemskapsalternativer: $error';

  // Tabs and sections
  @override
  String get general => 'Generelt';
  @override
  String get privacy => 'Personvern';
  @override
  String get appLanguage => 'Appspråk';
  @override
  String get account => 'Konto';
  @override
  String get dataAndStorage => 'Data og lagring';
  @override
  String get about => 'Om';

  // Settings/general
  @override
  String get currentCampus => 'Nåværende campus';
  @override
  String get useCampusSwitcherHint => 'Bruk campusvelgeren på startsiden for å bytte campus';
  @override
  String get validatorMode => 'Kontrollørmodus';
  @override
  String get openValidatorMode => 'Åpne kontrollørmodus';
  @override
  String get scanStudentQRCodes => 'Skann student-QR-koder for å verifisere medlemskap';

  // Notifications tab
  @override
  String get pushNotifications => 'Push-varsler';
  @override
  String get marketplaceNewItemsDeals => 'Nye varer og tilbud i markedsplassen';
  @override
  String get notificationSchedule => 'Varslingstid';
  @override
  String get muteNotificationsDuringSpecificHours => 'Demp varsler i bestemte tidsrom';
  @override
  String get vibrationSettingsComingSoon => 'Vibrasjonsinnstillinger kommer snart';

  // Privacy tab
  @override
  String get privacyInformation => 'Personverninformasjon';
  @override
  String get publicProfile => 'Offentlig profil';
  @override
  String get othersCanFindAndMessageYou => 'Andre kan finne og sende meldinger til deg';
  @override
  String get privateProfile => 'Privat profil';
  @override
  String get othersCannotFindYouInSearch => 'Andre kan ikke finne deg i søk';
  @override
  String get youCanStillMessageOthers => 'Du kan fortsatt sende meldinger';
  @override
  String get onlyYouCanStartNewConversations => 'Bare du kan starte nye samtaler';
  @override
  String get existingConversationsRemainActive => 'Eksisterende samtaler fortsetter';

  // Language tab
  @override
  String get languageChangeRestartNotice => 'Språkendringer trer i kraft etter at appen startes på nytt.';
  @override
  String get regionalSettings => 'Regioninnstillinger';
  @override
  String get currencyAutoNokHint => 'Valuta settes automatisk til NOK for BI-studenter';

  // Profile screen
  @override
  String get signInToViewProfile => 'Logg inn for å se profilen din';
  @override
  String get editProfile => 'Rediger profil';
  @override
  String get studentId => 'Student-ID';
  @override
  String get profileInformation => 'Profilinformasjon';
  @override
  String get campusAndInterests => 'Campus og interesser';
  @override
  String get interests => 'Interesser';
  @override
  String get expenseHistory => 'Utgiftshistorikk';
  @override
  String get notificationPreferences => 'Varslingsinnstillinger';
  @override
  String get languageSettings => 'Språkinnstillinger';
  @override
  String get unknownUser => 'Ukjent bruker';

  // Sell product
  @override
  String get pleaseSignInToSellItems => 'Vennligst logg inn for å selge varer';
  @override
  String get titleLabel => 'Tittel';
  @override
  String get exampleMacbook => 'f.eks. MacBook Pro 13"';
  @override
  String get titleIsRequired => 'Tittel er påkrevd';
  @override
  String get descriptionLabel => 'Beskrivelse';
  @override
  String get pleaseAddMoreDetail => 'Vennligst legg til litt mer informasjon';
  @override
  String get priceNok => 'Pris (NOK)';
  @override
  String get requiredField => 'Påkrevd';
  @override
  String get enterValidAmount => 'Oppgi et gyldig beløp';
  @override
  String get categoryLabel => 'Kategori';
  @override
  String get conditionLabel => 'Tilstand';
  @override
  String get preferredContactOptional => 'Foretrukket kontakt (valgfritt)';
  @override
  String get contactInfoOptional => 'Kontaktinfo (valgfritt)';
  @override
  String get photos => 'Bilder';
  @override
  String get none => 'Ingen';
  @override
  String get inAppMessage => 'Melding i app';

  // Category and condition labels
  @override
  String get categoryBooks => 'Bøker';
  @override
  String get categoryElectronics => 'Elektronikk';
  @override
  String get categoryFurniture => 'Møbler';
  @override
  String get categoryClothes => 'Klær';
  @override
  String get categorySports => 'Sport';
  @override
  String get categoryOther => 'Annet';

  @override
  String get conditionBrandNew => 'Helt ny';
  @override
  String get conditionLikeNew => 'Som ny';
  @override
  String get conditionGood => 'God';
  @override
  String get conditionFair => 'Brukbar';
  @override
  String get conditionPoor => 'Dårlig';

  // Dialog text
  @override
  String get unsavedChangesWarning => 'Hvis du går ut nå, vil endringene dine ikke bli lagret.';

  // Membership UI
  @override
  String get bisoMembership => 'BISO-medlemskap';
  @override
  String get membershipBenefitsBlurb => 'Få tilgang til eksklusive arrangementer, rabatter og mer';
  @override
  String get membershipExpired => 'Medlemskapet er utløpt';
  @override
  String membershipExpiredOn(String name, String date) => 'Ditt $name-medlemskap utløp $date';
  @override
  String membershipExpiredNoDate(String name) => 'Ditt $name-medlemskap er utløpt';
  @override
  String get validUntil => 'Gyldig til';
  @override
  String get noExpiry => 'Ingen utløpsdato';
  @override
  String get memberSince => 'Medlem siden';
  @override
  String get unknown => 'Ukjent';
  @override
  String get memberBenefitsActive => 'Medlemsfordeler aktiv';
  @override
  String get memberBenefitsBullets => 'Tilgang til arrangementer • Utgiftsrefusjoner • Rabatter i markedsplassen • Prioritert støtte';
  @override
  String idLabel(String code) => 'ID: $code';
}
