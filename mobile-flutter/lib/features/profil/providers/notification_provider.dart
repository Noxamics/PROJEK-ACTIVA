import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/services/notification_service.dart';

class NotificationNotifier extends StateNotifier<bool> {
  final LocalStorage _storage;

  NotificationNotifier(this._storage) : super(false) {
    _init();
  }

  Future<void> _init() async {
    final enabled = await _storage.getNotificationSetting();
    state = enabled;
    
    if (enabled) {
      // Pastikan terjadwal saat app terbuka
      await NotificationService.scheduleDailyReminder();
    }
  }

  Future<void> toggle(bool value) async {
    state = value;
    await _storage.saveNotificationSetting(value);
    
    if (value) {
      await NotificationService.requestPermissions();
      await NotificationService.scheduleDailyReminder();
    } else {
      await NotificationService.cancelAll();
    }
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, bool>((ref) {
  final storage = ref.watch(localStorageProvider);
  return NotificationNotifier(storage);
});
