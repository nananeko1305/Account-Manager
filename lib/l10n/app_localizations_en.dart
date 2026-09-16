// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTagline => 'Your cozy vault for accounts';

  @override
  String get setupTitle => 'Welcome! 👋';

  @override
  String get setupSubtitle =>
      'Set a master password to unlock the app.\nRemember it well — without it your data cannot be read.';

  @override
  String get masterPassword => 'Master password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get minChars4 => 'At least 4 characters';

  @override
  String get passwordsNoMatch => 'Passwords do not match';

  @override
  String get saving => 'Saving...';

  @override
  String get saveAndEnter => 'Save and enter';

  @override
  String get unlockTitle => 'Welcome back';

  @override
  String get unlockSubtitle =>
      'Enter your master password to unlock the vault.';

  @override
  String get wrongPassword => 'Wrong password';

  @override
  String get checking => 'Checking...';

  @override
  String get enter => 'Enter';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get registerTitle => 'Create account';

  @override
  String get loginSubtitle => 'Sign in to see your vault on all devices.';

  @override
  String get registerSubtitle =>
      'Register so your vault is available everywhere.';

  @override
  String get email => 'Email';

  @override
  String get accountPassword => 'Account password';

  @override
  String get minChars6 => 'At least 6 characters';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get wait => 'Please wait...';

  @override
  String get signIn => 'Sign in';

  @override
  String get register => 'Register';

  @override
  String get toRegister => 'No account? Register';

  @override
  String get toLogin => 'Already have an account? Sign in';

  @override
  String get errInvalidEmail => 'The email is not valid.';

  @override
  String get errEmailInUse => 'An account with this email already exists.';

  @override
  String get errWeakPassword => 'Password is too weak (min. 6 characters).';

  @override
  String get errWrongCredentials => 'Wrong email or password.';

  @override
  String get errNoNetwork => 'No internet connection.';

  @override
  String get errGeneric => 'Something went wrong. Please try again.';

  @override
  String errWithCode(String code) {
    return 'Error: $code';
  }

  @override
  String get myAccounts => 'My accounts';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get lock => 'Lock';

  @override
  String get logout => 'Sign out';

  @override
  String get newAccount => 'New account';

  @override
  String get searchHint => 'Search accounts...';

  @override
  String get clearSearch => 'Clear search';

  @override
  String noResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get emptyTitle => 'No accounts yet';

  @override
  String get emptySubtitle =>
      'Add your first one with the \"New account\" button';

  @override
  String get deleteTitle => 'Delete account?';

  @override
  String deleteMessage(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get passwordCopied => 'Password copied ✓';

  @override
  String get chooseColor => 'Choose app color';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get editAccount => 'Edit account';

  @override
  String get accountName => 'Account name';

  @override
  String get accountNameHint => 'e.g. Gmail, Instagram, Steam...';

  @override
  String get required => 'Required field';

  @override
  String get usingEmail => 'Using email';

  @override
  String get usingUsername => 'Using username';

  @override
  String get switchToUsername => 'Switch to username';

  @override
  String get switchToEmail => 'Switch to email';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get showHide => 'Show/hide';

  @override
  String get copyPassword => 'Copy password';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get addAccount => 'Add account';

  @override
  String get paletteTopla => 'Warm';

  @override
  String get palettePlava => 'Blue';

  @override
  String get paletteCrvena => 'Red';

  @override
  String get paletteZelena => 'Green';

  @override
  String get paletteZuta => 'Yellow';

  @override
  String get paletteLjubicasta => 'Purple';

  @override
  String get syncing => 'Syncing...';

  @override
  String get synced => 'Synced ✓';

  @override
  String get syncNow => 'Sync now';

  @override
  String get deleteWarning => 'This action can\'t be undone.';

  @override
  String get appearance => 'Appearance';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get website => 'Website (optional)';

  @override
  String get websiteHint => 'e.g. instagram.com';
}
