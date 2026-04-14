import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Indica si ya se mostró el modal de bienvenida al trial esta sesión.
final trialWelcomeShownProvider = StateProvider<bool>((ref) => false);
