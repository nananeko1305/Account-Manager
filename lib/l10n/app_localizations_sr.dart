// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Serbian (`sr`).
class AppLocalizationsSr extends AppLocalizations {
  AppLocalizationsSr([String locale = 'sr']) : super(locale);

  @override
  String get appTagline => 'Tvoj topli sef za naloge';

  @override
  String get setupTitle => 'Dobrodošao! 👋';

  @override
  String get setupSubtitle =>
      'Postavi master lozinku kojom ćeš otključavati sef.\nZapamti je dobro — bez nje se podaci ne mogu pročitati.';

  @override
  String get masterPassword => 'Master lozinka';

  @override
  String get confirmPassword => 'Potvrdi lozinku';

  @override
  String get minChars4 => 'Najmanje 4 znaka';

  @override
  String get passwordsNoMatch => 'Lozinke se ne poklapaju';

  @override
  String get saving => 'Čuvam...';

  @override
  String get saveAndEnter => 'Sačuvaj i uđi';

  @override
  String get unlockTitle => 'Dobrodošao nazad';

  @override
  String get unlockSubtitle => 'Unesi master lozinku da otključaš sef.';

  @override
  String get wrongPassword => 'Pogrešna lozinka';

  @override
  String get checking => 'Proveravam...';

  @override
  String get enter => 'Uđi';

  @override
  String get loginTitle => 'Prijava';

  @override
  String get registerTitle => 'Napravi nalog';

  @override
  String get loginSubtitle => 'Prijavi se da vidiš svoj sef na svim uređajima.';

  @override
  String get registerSubtitle => 'Registruj se da bi sef bio dostupan svuda.';

  @override
  String get email => 'Email';

  @override
  String get accountPassword => 'Lozinka naloga';

  @override
  String get minChars6 => 'Najmanje 6 znakova';

  @override
  String get invalidEmail => 'Unesi ispravan email';

  @override
  String get wait => 'Sačekaj...';

  @override
  String get signIn => 'Prijavi se';

  @override
  String get register => 'Registruj se';

  @override
  String get toRegister => 'Nemaš nalog? Registruj se';

  @override
  String get toLogin => 'Već imaš nalog? Prijavi se';

  @override
  String get errInvalidEmail => 'Email nije ispravan.';

  @override
  String get errEmailInUse => 'Nalog sa ovim email-om već postoji.';

  @override
  String get errWeakPassword => 'Lozinka je preslaba (min. 6 znakova).';

  @override
  String get errWrongCredentials => 'Pogrešan email ili lozinka.';

  @override
  String get errNoNetwork => 'Nema veze sa internetom.';

  @override
  String get errGeneric => 'Nešto nije u redu. Pokušaj ponovo.';

  @override
  String errWithCode(String code) {
    return 'Greška: $code';
  }

  @override
  String get myAccounts => 'Moji nalozi';

  @override
  String get theme => 'Tema';

  @override
  String get language => 'Jezik';

  @override
  String get lock => 'Zaključaj';

  @override
  String get logout => 'Odjavi se';

  @override
  String get newAccount => 'Novi nalog';

  @override
  String get searchHint => 'Pretraži naloge...';

  @override
  String get clearSearch => 'Obriši pretragu';

  @override
  String noResults(String query) {
    return 'Nema rezultata za „$query”';
  }

  @override
  String get emptyTitle => 'Još nemaš nijedan nalog';

  @override
  String get emptySubtitle => 'Dodaj prvi dugmetom „Novi nalog”';

  @override
  String get deleteTitle => 'Obriši nalog?';

  @override
  String deleteMessage(String name) {
    return 'Sigurno želiš da obrišeš „$name”?';
  }

  @override
  String get cancel => 'Otkaži';

  @override
  String get delete => 'Obriši';

  @override
  String get passwordCopied => 'Lozinka kopirana ✓';

  @override
  String get chooseColor => 'Izaberi boju aplikacije';

  @override
  String get chooseLanguage => 'Izaberi jezik';

  @override
  String get editAccount => 'Izmeni nalog';

  @override
  String get accountName => 'Naziv naloga';

  @override
  String get accountNameHint => 'npr. Gmail, Instagram, Steam...';

  @override
  String get required => 'Obavezno polje';

  @override
  String get usingEmail => 'Koristim email';

  @override
  String get usingUsername => 'Koristim korisničko ime';

  @override
  String get switchToUsername => 'Prebaci za korisničko ime';

  @override
  String get switchToEmail => 'Prebaci za email';

  @override
  String get username => 'Korisničko ime';

  @override
  String get password => 'Lozinka';

  @override
  String get showHide => 'Prikaži/sakrij';

  @override
  String get copyPassword => 'Kopiraj lozinku';

  @override
  String get saveChanges => 'Sačuvaj izmene';

  @override
  String get addAccount => 'Dodaj nalog';

  @override
  String get paletteTopla => 'Topla';

  @override
  String get palettePlava => 'Plava';

  @override
  String get paletteCrvena => 'Crvena';

  @override
  String get paletteZelena => 'Zelena';

  @override
  String get paletteZuta => 'Žuta';

  @override
  String get paletteLjubicasta => 'Ljubičasta';

  @override
  String get syncing => 'Sinhronizujem...';

  @override
  String get synced => 'Sinhronizovano ✓';

  @override
  String get syncNow => 'Sinhronizuj sada';

  @override
  String get deleteWarning => 'Ova radnja ne može da se poništi.';

  @override
  String get appearance => 'Izgled';

  @override
  String get light => 'Svetla';

  @override
  String get dark => 'Tamna';

  @override
  String get website => 'Sajt (opciono)';

  @override
  String get websiteHint => 'npr. instagram.com';
}
