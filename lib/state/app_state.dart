import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/media_item.dart';
import '../models/user_profile.dart';

class AppState extends ChangeNotifier {
  AppState() {
    // Initialize default active profile and initial My List items
    _activeProfile = MockData.profiles.first;
    _myList.addAll([
      MockData.heroBanners[0],
      MockData.heroBanners[1],
      MockData.topTenToday[1],
    ]);
    _downloads.addAll([
      MockData.heroBanners[0],
      MockData.topTenToday[0],
    ]);
    _reminders.add('up-1');
  }

  // Content Languages
  final Set<String> _preferredLanguages = {'English'};
  Set<String> get preferredLanguages => Set.unmodifiable(_preferredLanguages);

  void togglePreferredLanguage(String language) {
    if (_preferredLanguages.contains(language)) {
      _preferredLanguages.remove(language);
    } else {
      _preferredLanguages.add(language);
    }
    // Ensure at least one language is selected
    if (_preferredLanguages.isEmpty) {
      _preferredLanguages.add('English');
    }
    notifyListeners();
  }

  // Navigation tab
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }

  // User Profiles (Multi-Profile / Kids Profile support)
  late final List<UserProfile> _profiles = List<UserProfile>.from(MockData.profiles);
  List<UserProfile> get profiles => List.unmodifiable(_profiles);

  late UserProfile _activeProfile;
  UserProfile get activeProfile => _activeProfile;
  bool get isKidsModeActive => _activeProfile.isKids;

  void setActiveProfile(UserProfile profile) {
    _activeProfile = profile;
    notifyListeners();
  }

  void addProfile(UserProfile profile) {
    _profiles.add(profile);
    notifyListeners();
  }

  void updateProfile(UserProfile updated) {
    final index = _profiles.indexWhere((p) => p.id == updated.id);
    if (index >= 0) {
      _profiles[index] = updated;
      if (_activeProfile.id == updated.id) {
        _activeProfile = updated;
      }
      notifyListeners();
    }
  }

  bool removeProfile(String id) {
    if (_profiles.length <= 1) return false;
    _profiles.removeWhere((p) => p.id == id);
    if (_activeProfile.id == id) {
      _activeProfile = _profiles.first;
    }
    notifyListeners();
    return true;
  }

  // Parental Controls
  bool _parentalControlsEnabled = false;
  bool get parentalControlsEnabled => _parentalControlsEnabled;

  String? _parentalPin;
  bool get hasParentalPin => _parentalPin != null;

  String _maturityLimit = 'All Maturity Levels';
  String get maturityLimit => _maturityLimit;

  void setParentalPin(String pin) {
    _parentalPin = pin;
    _parentalControlsEnabled = true;
    notifyListeners();
  }

  bool verifyParentalPin(String pin) => _parentalPin == pin;

  void toggleParentalControls(bool value) {
    _parentalControlsEnabled = value;
    notifyListeners();
  }

  void setMaturityLimit(String level) {
    _maturityLimit = level;
    notifyListeners();
  }

  void clearParentalPin() {
    _parentalPin = null;
    _parentalControlsEnabled = false;
    notifyListeners();
  }

  /// Whether content with the given [ageRating] ('13+', '16+', '18+') may be
  /// shown to the currently active profile, honoring Kids profiles and the
  /// configured maturity limit.
  bool isContentAllowed(String ageRating) {
    final effectiveLimit = isKidsModeActive ? 'Kids (13+) only' : _maturityLimit;
    switch (effectiveLimit) {
      case 'Kids (13+) only':
        return ageRating == '13+';
      case 'Teen (16+) and under':
        return ageRating != '18+';
      default:
        return true;
    }
  }

  // Home Screen Filter (All, TV Shows, Movies, Originals)
  String _selectedHomeCategory = 'All';
  String get selectedHomeCategory => _selectedHomeCategory;

  void setSelectedHomeCategory(String category) {
    _selectedHomeCategory = category;
    notifyListeners();
  }

  // My List
  final List<MediaItem> _myList = [];
  List<MediaItem> get myList => List.unmodifiable(_myList);

  bool isInMyList(String id) {
    return _myList.any((item) => item.id == id);
  }

  void toggleMyList(MediaItem item) {
    final index = _myList.indexWhere((element) => element.id == item.id);
    if (index >= 0) {
      _myList.removeAt(index);
    } else {
      _myList.insert(0, item);
    }
    notifyListeners();
  }

  void removeFromMyList(String id) {
    _myList.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // Downloads
  final List<MediaItem> _downloads = [];
  List<MediaItem> get downloads => List.unmodifiable(_downloads);

  bool isDownloaded(String id) {
    return _downloads.any((item) => item.id == id);
  }

  void toggleDownload(MediaItem item) {
    final index = _downloads.indexWhere((element) => element.id == item.id);
    if (index >= 0) {
      _downloads.removeAt(index);
    } else {
      _downloads.insert(0, item);
    }
    notifyListeners();
  }

  void removeDownload(String id) {
    _downloads.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // Reminders for Upcoming Content
  final Set<String> _reminders = {};
  Set<String> get reminders => Set.unmodifiable(_reminders);

  bool hasReminder(String id) => _reminders.contains(id);

  void toggleReminder(String id) {
    if (_reminders.contains(id)) {
      _reminders.remove(id);
    } else {
      _reminders.add(id);
    }
    notifyListeners();
  }

  // App Settings Toggles
  bool _autoplayPreviews = true;
  bool get autoplayPreviews => _autoplayPreviews;
  void toggleAutoplayPreviews(bool value) {
    _autoplayPreviews = value;
    notifyListeners();
  }

  bool _smartDownloads = true;
  bool get smartDownloads => _smartDownloads;
  void toggleSmartDownloads(bool value) {
    _smartDownloads = value;
    notifyListeners();
  }

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;
  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  bool _wifiOnly = true;
  bool get wifiOnly => _wifiOnly;
  void toggleWifiOnly(bool value) {
    _wifiOnly = value;
    notifyListeners();
  }

  String _videoQuality = 'Ultra HD (4K)';
  String get videoQuality => _videoQuality;
  void setVideoQuality(String quality) {
    _videoQuality = quality;
    notifyListeners();
  }

  // Subscription Plan
  String? _selectedPlanId;
  String? get selectedPlanId => _selectedPlanId;
  void setSelectedPlan(String planId) {
    _selectedPlanId = planId;
    notifyListeners();
  }

  // Notifications Center (read-state tracking)
  final Set<String> _readNotificationIds = {};
  bool isNotificationRead(String id) => _readNotificationIds.contains(id);

  int get unreadNotificationCount =>
      MockData.notifications.where((n) => !_readNotificationIds.contains(n.id)).length;

  void markNotificationRead(String id) {
    if (_readNotificationIds.add(id)) {
      notifyListeners();
    }
  }

  void markAllNotificationsRead() {
    _readNotificationIds.addAll(MockData.notifications.map((n) => n.id));
    notifyListeners();
  }

  // Ratings & Reviews
  final Map<String, int> _userRatings = {};
  int? getUserRating(String itemId) => _userRatings[itemId];

  void setUserRating(String itemId, int stars) {
    _userRatings[itemId] = stars;
    notifyListeners();
  }

  // App Lock (separate from Parental Controls / Kids gate)
  bool _appLockEnabled = false;
  bool get appLockEnabled => _appLockEnabled;

  String? _appLockPin;
  bool get hasAppLockPin => _appLockPin != null;

  void setAppLockPin(String pin) {
    _appLockPin = pin;
    _appLockEnabled = true;
    notifyListeners();
  }

  bool verifyAppLockPin(String pin) => _appLockPin == pin;

  void toggleAppLock(bool value) {
    _appLockEnabled = value;
    notifyListeners();
  }

  void clearAppLockPin() {
    _appLockPin = null;
    _appLockEnabled = false;
    notifyListeners();
  }
}
