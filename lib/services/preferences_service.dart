import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized local persistent storage for user preferences, settings, PINs,
/// and offline cache.
class PreferencesService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    if (_prefs == null) {
      throw StateError('PreferencesService.init() must be called before accessing preferences.');
    }
    return _prefs!;
  }

  // Auth
  static const String _keyAuthToken = 'auth_token';
  static const String _keyPhoneNumber = 'phone_number';

  static String? getAuthToken() => _instance.getString(_keyAuthToken);
  static Future<void> setAuthToken(String? token) async {
    if (token == null) {
      await _instance.remove(_keyAuthToken);
    } else {
      await _instance.setString(_keyAuthToken, token);
    }
  }

  static String? getPhoneNumber() => _instance.getString(_keyPhoneNumber);
  static Future<void> setPhoneNumber(String? phone) async {
    if (phone == null) {
      await _instance.remove(_keyPhoneNumber);
    } else {
      await _instance.setString(_keyPhoneNumber, phone);
    }
  }

  // Playback & Download Settings
  static const String _keyAutoplayNext = 'autoplay_next';
  static const String _keyAutoplayPreviews = 'autoplay_previews';
  static const String _keySmartDownloads = 'smart_downloads';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyWifiOnly = 'wifi_only';
  static const String _keyVideoQuality = 'video_quality';

  static bool getAutoplayNext() => _instance.getBool(_keyAutoplayNext) ?? true;
  static Future<void> setAutoplayNext(bool value) => _instance.setBool(_keyAutoplayNext, value);

  static bool getAutoplayPreviews() => _instance.getBool(_keyAutoplayPreviews) ?? true;
  static Future<void> setAutoplayPreviews(bool value) => _instance.setBool(_keyAutoplayPreviews, value);

  static bool getSmartDownloads() => _instance.getBool(_keySmartDownloads) ?? true;
  static Future<void> setSmartDownloads(bool value) => _instance.setBool(_keySmartDownloads, value);

  static bool getNotificationsEnabled() => _instance.getBool(_keyNotifications) ?? true;
  static Future<void> setNotificationsEnabled(bool value) => _instance.setBool(_keyNotifications, value);

  static bool getWifiOnly() => _instance.getBool(_keyWifiOnly) ?? true;
  static Future<void> setWifiOnly(bool value) => _instance.setBool(_keyWifiOnly, value);

  static String getVideoQuality() => _instance.getString(_keyVideoQuality) ?? 'Ultra HD (4K)';
  static Future<void> setVideoQuality(String value) => _instance.setString(_keyVideoQuality, value);

  // App Lock
  static const String _keyAppLockEnabled = 'app_lock_enabled';
  static const String _keyAppLockPin = 'app_lock_pin';

  static bool getAppLockEnabled() => _instance.getBool(_keyAppLockEnabled) ?? false;
  static Future<void> setAppLockEnabled(bool value) => _instance.setBool(_keyAppLockEnabled, value);

  static String? getAppLockPin() => _instance.getString(_keyAppLockPin);
  static Future<void> setAppLockPin(String? pin) async {
    if (pin == null) {
      await _instance.remove(_keyAppLockPin);
    } else {
      await _instance.setString(_keyAppLockPin, pin);
    }
  }

  // Parental Controls
  static const String _keyParentalControlsEnabled = 'parental_controls_enabled';
  static const String _keyParentalPin = 'parental_pin';
  static const String _keyMaturityLimit = 'maturity_limit';

  static bool getParentalControlsEnabled() => _instance.getBool(_keyParentalControlsEnabled) ?? false;
  static Future<void> setParentalControlsEnabled(bool value) => _instance.setBool(_keyParentalControlsEnabled, value);

  static String? getParentalPin() => _instance.getString(_keyParentalPin);
  static Future<void> setParentalPin(String? pin) async {
    if (pin == null) {
      await _instance.remove(_keyParentalPin);
    } else {
      await _instance.setString(_keyParentalPin, pin);
    }
  }

  static String getMaturityLimit() => _instance.getString(_keyMaturityLimit) ?? 'All Maturity Levels';
  static Future<void> setMaturityLimit(String value) => _instance.setString(_keyMaturityLimit, value);

  // Preferred Languages
  static const String _keyPreferredLanguages = 'preferred_languages';
  static Set<String> getPreferredLanguages() {
    final list = _instance.getStringList(_keyPreferredLanguages);
    return list != null && list.isNotEmpty ? list.toSet() : {'English'};
  }
  static Future<void> setPreferredLanguages(Set<String> languages) =>
      _instance.setStringList(_keyPreferredLanguages, languages.toList());

  // Watch Progress (per media ID -> progress ratio 0.0 to 1.0 or seconds)
  static const String _keyWatchProgress = 'watch_progress_map';
  static Map<String, double> getWatchProgressMap() {
    final raw = _instance.getString(_keyWatchProgress);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } catch (_) {
      return {};
    }
  }
  static Future<void> saveWatchProgress(String mediaId, double progress) async {
    final map = getWatchProgressMap();
    if (progress <= 0.02) {
      map.remove(mediaId);
    } else {
      map[mediaId] = progress;
    }
    await _instance.setString(_keyWatchProgress, jsonEncode(map));
  }

  // User Ratings (media ID -> stars)
  static const String _keyUserRatings = 'user_ratings_map';
  static Map<String, int> getUserRatings() {
    final raw = _instance.getString(_keyUserRatings);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as int));
    } catch (_) {
      return {};
    }
  }
  static Future<void> saveUserRating(String mediaId, int stars) async {
    final map = getUserRatings();
    map[mediaId] = stars;
    await _instance.setString(_keyUserRatings, jsonEncode(map));
  }

  // Read Notifications
  static const String _keyReadNotifications = 'read_notifications';
  static Set<String> getReadNotificationIds() {
    final list = _instance.getStringList(_keyReadNotifications);
    return list != null ? list.toSet() : {};
  }
  static Future<void> setReadNotificationIds(Set<String> ids) =>
      _instance.setStringList(_keyReadNotifications, ids.toList());

  // Lists: My List, Downloads, Reminders
  static const String _keyMyList = 'my_list_ids';
  static const String _keyDownloads = 'download_ids';
  static const String _keyReminders = 'reminder_ids';

  static List<String> getMyListIds() => _instance.getStringList(_keyMyList) ?? [];
  static Future<void> setMyListIds(List<String> ids) => _instance.setStringList(_keyMyList, ids);

  static List<String> getDownloadIds() => _instance.getStringList(_keyDownloads) ?? [];
  static Future<void> setDownloadIds(List<String> ids) => _instance.setStringList(_keyDownloads, ids);

  static Set<String> getReminderIds() => (_instance.getStringList(_keyReminders) ?? []).toSet();
  static Future<void> setReminderIds(Set<String> ids) => _instance.setStringList(_keyReminders, ids.toList());

  // Clear on logout
  static Future<void> clearAuthSession() async {
    await _instance.remove(_keyAuthToken);
    await _instance.remove(_keyPhoneNumber);
  }
}
