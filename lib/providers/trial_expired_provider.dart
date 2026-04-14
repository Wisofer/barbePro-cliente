import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier global: true cuando la API devolvió 403 con code TRIAL_EXPIRED.
class TrialExpiredNotifier extends StateNotifier<bool> {
  TrialExpiredNotifier() : super(false);

  void markExpired() {
    state = true;
  }

  void clear() {
    state = false;
  }
}

final trialExpiredNotifierProvider =
    StateNotifierProvider<TrialExpiredNotifier, bool>((ref) {
  return TrialExpiredNotifier();
});
