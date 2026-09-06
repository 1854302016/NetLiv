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

  // Navigation tab
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }

  // Active User Profile
  late UserProfile _activeProfile;
  UserProfile get activeProfile => _activeProfile;

  void setActiveProfile(UserProfile profile) {
    _activeProfile = profile;
    notifyListeners();
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
}
