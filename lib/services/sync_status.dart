import 'package:flutter/foundation.dart';

/// Faza sinhronizacije koju prikazuje banner.
enum SyncPhase { idle, syncing, done }

/// Prati da li je snimanje u toku. `track` obavije neku akciju:
/// pre nje pokaže "sinhronizujem", posle uspeha "gotovo" pa se sam sakrije.
class SyncController extends ValueNotifier<SyncPhase> {
  SyncController() : super(SyncPhase.idle);

  int _seq = 0;

  Future<T> track<T>(Future<T> Function() action) async {
    final my = ++_seq;
    value = SyncPhase.syncing;
    try {
      final result = await action();
      if (my == _seq) {
        value = SyncPhase.done;
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (my == _seq && value == SyncPhase.done) value = SyncPhase.idle;
        });
      }
      return result;
    } catch (e) {
      if (my == _seq) value = SyncPhase.idle;
      rethrow;
    }
  }
}

final SyncController syncController = SyncController();
