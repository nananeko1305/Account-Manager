import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:encrypt/encrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/account.dart';
import 'legacy_local_store.dart';

/// Vault ÃÂuva ÃÂ¡ifrovan sef u oblaku (Firestore). Svaki nalog je zaseban
/// dokument (vaults/{uid}/accounts/{id}) Ã¢ÂÂ tako Firestore sam sinhronizuje
/// izmene izmeÃÂu ureÃÂaja i radi offline. U oblak ide samo ÃÂ¡ifrovan tekst;
/// master lozinka nikad ne napuÃÂ¡ta ureÃÂaj (zero-knowledge).
class Vault {
  Vault._();
  static final Vault instance = Vault._();

  Key? _sessionKey;
  bool get isUnlocked => _sessionKey != null;

  /// Meta dokument korisnika (ÃÂuva salt + verifier master lozinke).
  DocumentReference<Map<String, dynamic>> get _metaDoc {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('Nisi prijavljen.');
    return FirebaseFirestore.instance.collection('vaults').doc(uid);
  }

  /// Kolekcija naloga ovog korisnika.
  CollectionReference<Map<String, dynamic>> get _accountsCol =>
      _metaDoc.collection('accounts');

  Future<bool> isInitialized() async {
    final snap = await _metaDoc.get();
    return snap.exists && snap.data()?['verifier'] != null;
  }

  /// Prvi put: postavlja master lozinku, pa pokuÃÂ¡ava migraciju starih podataka.
  Future<void> setup(String masterPassword) async {
    final salt = _randomBytes(16);
    final key = _deriveKey(masterPassword, salt);
    _sessionKey = key;

    await _metaDoc.set({
      'salt': base64Encode(salt),
      'verifier': _verifier(key, salt),
      'createdAt': FieldValue.serverTimestamp(),
    });
    await LegacyLocalStore.migrateInto(masterPassword, upsertAccount);
  }

  /// OtkljuÃÂava app; ako lozinka odgovara, pokuÃÂ¡ava i migraciju starih podataka.
  Future<bool> unlock(String masterPassword) async {
    final data = (await _metaDoc.get()).data();
    if (data == null) return false;

    final saltStr = data['salt'] as String?;
    final storedVerifier = data['verifier'] as String?;
    if (saltStr == null || storedVerifier == null) return false;

    final salt = base64Decode(saltStr);
    final key = _deriveKey(masterPassword, salt);
    if (_verifier(key, salt) != storedVerifier) return false;

    _sessionKey = key;
    await _migrateCloudBlobIfPresent(data);
    await LegacyLocalStore.migrateInto(masterPassword, upsertAccount);
    return true;
  }

  void lock() => _sessionKey = null;

  /// ÃÂ½ivi tok naloga iz oblaka (Firestore keÃÂ¡ omoguÃÂava rad i bez neta).
  Stream<List<Account>> watchAccounts() {
    if (_sessionKey == null) throw StateError('Sef je zakljuÃÂan.');
    return _accountsCol.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => _decryptAccount(d.data()))
          .whereType<Account>()
          .toList();
      list.sort((a, b) {
        final c = a.order.compareTo(b.order);
        return c != 0 ? c : a.id.compareTo(b.id);
      });
      return list;
    });
  }

  /// Dodaje ili menja nalog (isti [Account.id] = izmena, novi = dodavanje).
  Future<void> upsertAccount(Account account) async {
    final key = _sessionKey;
    if (key == null) throw StateError('Sef je zakljuÃÂan.');

    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final data = encrypter.encrypt(jsonEncode(account.toJson()), iv: iv);

    await _accountsCol.doc(account.id).set({
      'iv': iv.base64,
      'data': data.base64,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAccount(String id) => _accountsCol.doc(id).delete();

  /// Ručna sinhronizacija: pošalji čekanje za neposlato pa povuci sveže sa servera.
  Future<void> forceSync() async {
    await FirebaseFirestore.instance.waitForPendingWrites();
    await _accountsCol.get(const GetOptions(source: Source.server));
  }

  /// Snima novi redosled: postavi order = pozicija za naloge kojima se promenio.
  Future<void> saveOrder(List<Account> ordered) async {
    for (var i = 0; i < ordered.length; i++) {
      if (ordered[i].order != i.toDouble()) {
        await upsertAccount(ordered[i].copyWith(order: i.toDouble()));
      }
    }
  }

  Account? _decryptAccount(Map<String, dynamic> data) {
    try {
      final ivStr = data['iv'] as String?;
      final dataStr = data['data'] as String?;
      if (ivStr == null || dataStr == null) return null;
      final encrypter = Encrypter(AES(_sessionKey!, mode: AESMode.cbc));
      final plain = encrypter.decrypt(
        Encrypted.fromBase64(dataStr),
        iv: IV.fromBase64(ivStr),
      );
      return Account.fromJson(jsonDecode(plain) as Map<String, dynamic>);
    } catch (_) {
      return null; // preskoÃÂi neÃÂitljiv/oÃÂ¡teÃÂen zapis
    }
  }

  /// Prebacuje stari "jedan blok" format (ako postoji na meta dokumentu) u
  /// zasebne dokumente naloga â jednokratno.
  Future<void> _migrateCloudBlobIfPresent(Map<String, dynamic> meta) async {
    final dataStr = meta['data'] as String?;
    final ivStr = meta['iv'] as String?;
    if (dataStr == null || ivStr == null) return;
    try {
      final encrypter = Encrypter(AES(_sessionKey!, mode: AESMode.cbc));
      final plain = encrypter.decrypt(
        Encrypted.fromBase64(dataStr),
        iv: IV.fromBase64(ivStr),
      );
      for (final e in jsonDecode(plain) as List<dynamic>) {
        await upsertAccount(Account.fromJson(e as Map<String, dynamic>));
      }
    } catch (_) {
      // ignorisi necitljiv stari blok
    }
    await _metaDoc.update({
      'data': FieldValue.delete(),
      'iv': FieldValue.delete(),
    });
  }

  Key _deriveKey(String password, List<int> salt) {
    final bytes = <int>[...utf8.encode(password), ...salt];
    return Key(Uint8List.fromList(crypto.sha256.convert(bytes).bytes));
  }

  String _verifier(Key key, List<int> salt) {
    final bytes = <int>[...key.bytes, ...salt];
    return crypto.sha256.convert(bytes).toString();
  }

  List<int> _randomBytes(int length) {
    final rnd = Random.secure();
    return List<int>.generate(length, (_) => rnd.nextInt(256));
  }
}
