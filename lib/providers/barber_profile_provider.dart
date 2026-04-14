import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/barber.dart';
import '../services/api/barber_service.dart';
import '../services/storage/barber_profile_cache.dart';

/// Lectura rápida de la URL en caché (header).
final barberCachedImageUrlProvider = FutureProvider.autoDispose<String?>((ref) async {
  return BarberProfileCache.getImageUrl();
});

/// Perfil del barbero (dueño). Invalidar tras actualizar foto.
final barberProfileProvider = FutureProvider.autoDispose<BarberDto>((ref) async {
  final dynamic service = ref.watch(barberServiceProvider);
  final BarberDto profile = await service.getProfile();
  await BarberProfileCache.saveImageUrl(profile.profileImageUrl);
  return profile;
});
