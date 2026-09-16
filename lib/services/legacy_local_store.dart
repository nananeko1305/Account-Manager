import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/account.dart';

/// Čita podatke iz STARIJE (lokalne, bez oblaka) verzije aplikacije i, ako
/// master lozinka odgovara, prebacuje ih u oblak — jednom.
///
/// Stara verzija je čuvala sve naloge kao jedan šifrovan blok u
/// shared_preferences (ključevi ispod). Ovde ih dešifrujemo i predajemo
/// [upsert] funkciji koja ih upisuje u oblak.
class LegacyLocalStore {
  static const _saltKey = 'vault_salt';
  static const _verifierKey = 'vault_verifier';
  static const _dataKey = 'vault_data';
  static const _ivKey = 'vault_iv';
  static const _migratedKey = 'migrated_to_cloud';

  /// Vraća koliko je naloga migrirano (0 ako nema šta ili lozinka ne odgovara).
  static Future<int> migrateInto(
    String masterPassword,
    Future<void> Function(Account account) upsert,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migratedKey) == true) return 0;

    final saltStr = prefs.getString(_saltKey);
    final verifier = prefs.getString(_verifierKey);
    final dataStr = prefs.getString(_dataKey);
    final ivStr = prefs.getString(_ivKey);

    // Nema starih podataka -> obeleži da je "migracija" gotova i izađi.
    if (saltStr == null || verifier == null || dataStr == null || ivStr == null) {
      await prefs.setBool(_migratedKey, true);
      return 0;
    }

    final salt = base64Decode(saltStr);
    final key = _deriveKey(masterPassword, salt);

    // Master lozinka ne odgovara starim podacima -> probaj neki drugi put.
    if (_verifier(key, salt) != verifier) return 0;

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final plain = encrypter.decrypt(
      Encrypted.fromBase64(dataStr),
      iv: IV.fromBase64(ivStr),
    );
    final list = (jsonDecode(plain) as List<dynamic>)
        .map((e) => Account.fromJson(e as Map<String, dynamic>))
        .toList();

    for (final account in list) {
      await upsert(account);
    }
    await prefs.setBool(_migratedKey, true);
    return list.length;
  }

  static Key _deriveKey(String password, List<int> salt) {
    final bytes = <int>[...utf8.encode(password), ...salt];
    return Key(Uint8List.fromList(crypto.sha256.convert(bytes).bytes));
  }

  static String _verifier(Key key, List<int> salt) {
    final bytes = <int>[...key.bytes, ...salt];
    return crypto.sha256.convert(bytes).toString();
  }
}
