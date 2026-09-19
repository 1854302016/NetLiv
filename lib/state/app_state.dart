import 'dart:async';
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/billing_record.dart';
import '../models/home_feed.dart';
import '../models/media_item.dart';
import '../models/notification_item.dart';
import '../models/short_video.dart';
import '../models/subscription_plan.dart';
import '../models/upcoming_item.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../services/download_service.dart';
import '../services/preferences_service.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _restorePreferences();
  }

  void _restorePreferences() {
    // Auth restore
    _authToken = PreferencesService.getAuthToken();
    _phoneNumber = PreferencesService.getPhoneNumber();

    // Preferences restore
    _autoplayPreviews = PreferencesService.getAutoplayPreviews();
    _smartDownloads = PreferencesService.getSmartDownloads();
    _notificationsEnabled = PreferencesService.getNotificationsEnabled();
    _wifiOnly = PreferencesService.getWifiOnly();
    _videoQuality = PreferencesService.getVideoQuality();

    // PINs & Parental controls restore
    _appLockEnabled = PreferencesService.getAppLockEnabled();
    _appLockPin = PreferencesService.getAppLockPin();
    _parentalControlsEnabled = PreferencesService.getParentalControlsEnabled();
    _parentalPin = PreferencesService.getParentalPin();
    _maturityLimit = PreferencesService.getMaturityLimit();

    // Languages restore
    _preferredLanguages.clear();
    _preferredLanguages.addAll(PreferencesService.getPreferredLanguages());

    // Ratings & Notifications restore
    _readNotificationIds.addAll(PreferencesService.getReadNotificationIds());
    _userRatings.addAll(PreferencesService.getUserRatings());
    _reminders.addAll(PreferencesService.getReminderIds());

    // Active Profile initialization
    _activeProfile = MockData.profiles.first;

    // Initial My List and Downloads
    _myList.addAll([
      MockData.heroBanners[0],
      MockData.heroBanners[1],
      MockData.topTenToday[1],
    ]);
    _downloads.addAll([
      MockData.heroBanners[0],
      MockData.topTenToday[0],
    ]);

    // Populate initial continue watching
    _rebuildContinueWatchingFromLocal();

    // Load offline downloaded videos
    unawaited(loadDownloadedItems());

    // If logged in, fetch live profiles & continue watching in background
    if (_authToken != null) {
      unawaited(loadProfiles());
      unawaited(_refreshDeviceCount());
      unawaited(loadContinueWatching());
      unawaited(loadNotifications());
      unawaited(refreshSubscriptionStatus());
    }
  }

  // Auth
  String? _authToken;
  String? _phoneNumber;
  String? _userName;
  String? _userGender;
  int? _userAge;
  bool get isLoggedIn => _authToken != null;
  String? get phoneNumber => _phoneNumber;
  String? get userName => _userName;
  String? get userGender => _userGender;
  int? get userAge => _userAge;

  // Subscription & Expiry state
  bool _hasActiveSubscription = false;
  bool _isSubscriptionExpiringSoon = false;
  int _subscriptionDaysLeft = 0;
  String? _activePlanName;
  String? _subscriptionExpiresAt;

  bool get hasActiveSubscription => _hasActiveSubscription;
  bool get isSubscriptionExpiringSoon => _isSubscriptionExpiringSoon;
  int get subscriptionDaysLeft => _subscriptionDaysLeft;
  String? get activePlanName => _activePlanName;
  String? get subscriptionExpiresAt => _subscriptionExpiresAt;

  Future<void> refreshSubscriptionStatus() async {
    if (_authToken == null) {
      _hasActiveSubscription = false;
      _isSubscriptionExpiringSoon = false;
      _subscriptionDaysLeft = 0;
      _activePlanName = null;
      _subscriptionExpiresAt = null;
      notifyListeners();
      return;
    }
    try {
      final me = await ApiService.fetchMe(_authToken!);
      final sub = me['subscription'] as Map<String, dynamic>?;
      if (sub != null) {
        _hasActiveSubscription = sub['hasActiveSubscription'] as bool? ?? false;
        _isSubscriptionExpiringSoon = sub['isExpiringSoon'] as bool? ?? false;
        _subscriptionDaysLeft = sub['daysLeft'] as int? ?? 0;
        _activePlanName = sub['planName'] as String?;
        _subscriptionExpiresAt = sub['expiresAt'] as String?;
      }
      notifyListeners();
    } catch (_) {}
  }

  /// Requests an OTP for [phone]. Returns the OTP itself for on-screen testing
  /// until a real SMS gateway is wired up on the backend (never populated in prod).
  Future<String?> requestOtp(String phone) async {
    _phoneNumber = phone;
    await PreferencesService.setPhoneNumber(phone);
    return ApiService.requestOtp(phone);
  }

  int _deviceCount = 1;
  int get deviceCount => _deviceCount;

  /// Verifies [otp] and returns onboarding status.
  Future<Map<String, dynamic>> verifyOtp(String otp) async {
    if (_phoneNumber == null) {
      throw ApiException('No phone number to verify.');
    }
    final result = await ApiService.verifyOtp(_phoneNumber!, otp);
    _authToken = result['token'] as String;
    final isNewUser = result['isNewUser'] as bool;
    final isProfileComplete = result['isProfileComplete'] as bool;
    final userData = result['user'] as Map<String, dynamic>?;
    if (userData != null) {
      _userName = userData['name'] as String?;
      _userGender = userData['gender'] as String?;
      _userAge = userData['age'] as int?;
    }

    // Persist session
    await PreferencesService.setAuthToken(_authToken);
    await PreferencesService.setPhoneNumber(_phoneNumber);

    await loadProfiles();
    unawaited(_refreshDeviceCount());
    unawaited(loadContinueWatching());
    unawaited(loadNotifications());
    unawaited(refreshSubscriptionStatus());
    notifyListeners();
    return {
      'isNewUser': isNewUser,
      'isProfileComplete': isProfileComplete,
    };
  }

  /// Updates user profile details (Name, Gender, Age).
  Future<void> updateUserBasicDetails({
    required String name,
    required String gender,
    required int age,
  }) async {
    if (_authToken == null) {
      throw ApiException('Please sign in to update profile.');
    }
    final res = await ApiService.updateUserBasicDetails(
      _authToken!,
      name: name,
      gender: gender,
      age: age,
    );
    final userData = res['user'] as Map<String, dynamic>?;
    if (userData != null) {
      _userName = userData['name'] as String?;
      _userGender = userData['gender'] as String?;
      _userAge = userData['age'] as int?;
    }
    await loadProfiles();
    notifyListeners();
  }

  /// Marks onboarding as finished so it never shows again for this account.
  Future<void> completeOnboarding() async {
    if (_authToken == null) return;
    try {
      await ApiService.completeOnboarding(_authToken!);
    } catch (_) {
      // Non-critical: worst case onboarding shows once more on the next login.
    }
  }

  Future<void> _refreshDeviceCount() async {
    if (_authToken == null) return;
    try {
      _deviceCount = await ApiService.fetchDeviceCount(_authToken!);
      notifyListeners();
    } catch (_) {
      // Non-critical display value; keep the previous count on failure.
    }
  }

  Future<void> logout() async {
    if (_authToken != null) {
      try {
        await ApiService.logout(_authToken!);
      } catch (_) {}
    }
    _authToken = null;
    _phoneNumber = null;
    _userName = null;
    _userGender = null;
    _userAge = null;
    _deviceCount = 1;
    _billingHistory = [];
    _paymentMethod = null;
    _billingLoaded = false;
    await PreferencesService.clearAuthSession();
    _rebuildContinueWatchingFromLocal();
    notifyListeners();
  }

  /// Starts a Razorpay checkout for [planId]. Requires the user to be logged in.
  Future<Map<String, dynamic>> startCheckout(String planId) {
    if (_authToken == null) {
      throw ApiException('Please sign in to subscribe to a plan.');
    }
    return ApiService.checkout(_authToken!, planId);
  }

  /// Verifies a completed Razorpay payment and activates the subscription.
  Future<void> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    if (_authToken == null) {
      throw ApiException('Please sign in to subscribe to a plan.');
    }
    await ApiService.verifyPayment(
      _authToken!,
      orderId: orderId,
      paymentId: paymentId,
      signature: signature,
    );
    await refreshSubscriptionStatus();
  }

  List<BillingRecord> _billingHistory = [];
  List<BillingRecord> get billingHistory => List.unmodifiable(_billingHistory);
  PaymentMethodSummary? _paymentMethod;
  PaymentMethodSummary? get paymentMethod => _paymentMethod;
  bool _billingLoaded = false;
  bool get billingLoaded => _billingLoaded;

  /// Loads the signed-in user's real billing history and payment method.
  Future<void> loadBilling() async {
    if (_authToken == null) return;
    try {
      final data = await ApiService.fetchBilling(_authToken!);
      final history = data['history'] as List<dynamic>? ?? [];
      _billingHistory = history
          .map((json) => BillingRecord.fromJson(json as Map<String, dynamic>))
          .toList();
      final method = data['paymentMethod'] as Map<String, dynamic>?;
      _paymentMethod = method != null ? PaymentMethodSummary.fromJson(method) : null;
    } catch (_) {
    } finally {
      _billingLoaded = true;
      notifyListeners();
    }
  }

  // Content Catalog
  HomeFeed? _homeFeed;
  HomeFeed? get homeFeed => _homeFeed;

  List<MediaItem> _catalog = [];
  List<MediaItem> get catalog => List.unmodifiable(_catalog);

  List<UpcomingItem> _upcomingItems = [];
  List<UpcomingItem> get upcomingItems => List.unmodifiable(_upcomingItems);

  List<String> _genreNames = [];
  List<String> get genreNames => List.unmodifiable(_genreNames);

  List<ShortVideo> _shorts = [];
  List<ShortVideo> get shorts => List.unmodifiable(_shorts);

  List<SubscriptionPlan> _plans = [];
  List<SubscriptionPlan> get plans => List.unmodifiable(_plans);

  bool _isContentLoading = false;
  bool get isContentLoading => _isContentLoading;
  bool _contentLoaded = false;
  bool get isContentLoaded => _contentLoaded;
  String? contentError;

  /// Dynamic trending keywords generated from genres and catalog
  List<String> get trendingKeywords {
    final List<String> keywords = [];
    if (_genreNames.isNotEmpty) {
      keywords.addAll(_genreNames.take(4));
    }
    if (_catalog.isNotEmpty) {
      final trendingTitles = _catalog.where((m) => m.isTrending).map((m) => m.title).take(4);
      keywords.addAll(trendingTitles);
    }
    if (keywords.isEmpty) {
      return MockData.trendingKeywords;
    }
    return keywords.toSet().toList();
  }

  /// Finds catalog items sharing a genre with [seed].
  List<MediaItem> recommendationsFor(
    MediaItem seed, {
    List<String> exclude = const [],
    int count = 10,
  }) {
    final excludedIds = {seed.id, ...exclude};
    final matches = _catalog.where((item) {
      if (excludedIds.contains(item.id)) return false;
      return item.genres.any((g) => seed.genres.contains(g));
    }).toList();
    matches.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return matches.take(count).toList();
  }

  Future<void> loadContent({bool force = false}) async {
    if (_contentLoaded && !force) return;
    _isContentLoading = true;
    contentError = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        ApiService.fetchHome(),
        ApiService.fetchMedia(),
        ApiService.fetchGenres(),
        ApiService.fetchUpcoming(),
        ApiService.fetchShorts(),
        ApiService.fetchSubscriptionPlans(),
      ]);
      _homeFeed = HomeFeed.fromJson(results[0] as Map<String, dynamic>);
      _catalog = (results[1] as List<dynamic>)
          .map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
          .toList();
      _genreNames = (results[2] as List<dynamic>)
          .map((e) => (e as Map<String, dynamic>)['name'] as String)
          .toList();
      _upcomingItems = (results[3] as List<dynamic>)
          .map((e) => UpcomingItem.fromJson(e as Map<String, dynamic>))
          .toList();
      _shorts = (results[4] as List<dynamic>)
          .map((e) => ShortVideo.fromJson(e as Map<String, dynamic>))
          .toList();
      final planJson = results[5] as List<dynamic>;
      _plans = List.generate(planJson.length, (i) {
        final isPopular = planJson.length >= 3 && i == planJson.length ~/ 2;
        return SubscriptionPlan.fromJson(planJson[i] as Map<String, dynamic>, isPopular: isPopular);
      });
      _contentLoaded = true;

      // Re-evaluate continue watching against the freshly loaded catalog
      _rebuildContinueWatchingFromLocal();
      if (_authToken != null) {
        unawaited(loadContinueWatching());
      }
    } catch (e) {
      contentError = e is ApiException ? e.message : "Couldn't load content. Check your connection.";
    } finally {
      _isContentLoading = false;
      notifyListeners();
    }
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
    if (_preferredLanguages.isEmpty) {
      _preferredLanguages.add('English');
    }
    PreferencesService.setPreferredLanguages(_preferredLanguages);
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

  // User Profiles
  late final List<UserProfile> _profiles = List<UserProfile>.from(MockData.profiles);
  List<UserProfile> get profiles => List.unmodifiable(_profiles);

  late UserProfile _activeProfile;
  UserProfile get activeProfile => _activeProfile;
  bool get isKidsModeActive => _activeProfile.isKids;

  Future<void> loadProfiles() async {
    if (_authToken == null) return;
    try {
      final json = await ApiService.fetchProfiles(_authToken!);
      if (json.isEmpty) return;
      _profiles
        ..clear()
        ..addAll(json.map((e) => UserProfile.fromJson(e as Map<String, dynamic>)));
      _activeProfile = _profiles.first;
      notifyListeners();
    } catch (_) {}
  }

  void setActiveProfile(UserProfile profile) {
    _activeProfile = profile;
    unawaited(loadContinueWatching());
    notifyListeners();
  }

  Future<void> addProfile(UserProfile profile) async {
    if (_authToken != null) {
      final json = await ApiService.createProfile(
        _authToken!,
        name: profile.name,
        avatarUrl: profile.avatarUrl,
        isKids: profile.isKids,
      );
      _profiles.add(UserProfile.fromJson(json['data'] as Map<String, dynamic>));
    } else {
      _profiles.add(profile);
    }
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile updated) async {
    final index = _profiles.indexWhere((p) => p.id == updated.id);
    if (index < 0) return;

    if (_authToken != null) {
      final json = await ApiService.updateProfile(
        _authToken!,
        updated.id,
        name: updated.name,
        avatarUrl: updated.avatarUrl,
        isKids: updated.isKids,
      );
      updated = UserProfile.fromJson(json['data'] as Map<String, dynamic>);
    }

    _profiles[index] = updated;
    if (_activeProfile.id == updated.id) {
      _activeProfile = updated;
    }
    notifyListeners();
  }

  Future<bool> removeProfile(String id) async {
    if (_profiles.length <= 1) return false;

    if (_authToken != null) {
      await ApiService.deleteProfile(_authToken!, id);
    }

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
    PreferencesService.setParentalPin(pin);
    PreferencesService.setParentalControlsEnabled(true);
    notifyListeners();
  }

  bool verifyParentalPin(String pin) => _parentalPin == pin;

  void toggleParentalControls(bool value) {
    _parentalControlsEnabled = value;
    PreferencesService.setParentalControlsEnabled(value);
    notifyListeners();
  }

  void setMaturityLimit(String level) {
    _maturityLimit = level;
    PreferencesService.setMaturityLimit(level);
    notifyListeners();
  }

  void clearParentalPin() {
    _parentalPin = null;
    _parentalControlsEnabled = false;
    PreferencesService.setParentalPin(null);
    PreferencesService.setParentalControlsEnabled(false);
    notifyListeners();
  }

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

  // Continue Watching
  List<MediaItem> _continueWatching = [];
  List<MediaItem> get continueWatching => List.unmodifiable(_continueWatching);

  void _rebuildContinueWatchingFromLocal() {
    final progressMap = PreferencesService.getWatchProgressMap();
    if (progressMap.isEmpty) {
      _continueWatching = List<MediaItem>.from(MockData.continueWatching);
      return;
    }

    final pool = _catalog.isNotEmpty ? _catalog : MockData.allItems;
    final List<MediaItem> list = [];
    for (final entry in progressMap.entries) {
      final found = pool.where((m) => m.id == entry.key).firstOrNull;
      if (found != null) {
        list.add(MediaItem(
          id: found.id,
          title: found.title,
          description: found.description,
          posterUrl: found.posterUrl,
          backdropUrl: found.backdropUrl,
          genres: found.genres,
          releaseYear: found.releaseYear,
          ageRating: found.ageRating,
          durationOrSeasons: found.durationOrSeasons,
          matchScore: found.matchScore,
          type: found.type,
          isOriginal: found.isOriginal,
          isTrending: found.isTrending,
          topTenRank: found.topTenRank,
          watchProgress: entry.value,
          cast: found.cast,
          creators: found.creators,
          episodes: found.episodes,
          tags: found.tags,
          videoUrl: found.videoUrl,
        ));
      }
    }
    _continueWatching = list.isNotEmpty ? list : List<MediaItem>.from(MockData.continueWatching);
  }

  Future<void> loadContinueWatching() async {
    if (_authToken == null) {
      _rebuildContinueWatchingFromLocal();
      notifyListeners();
      return;
    }
    try {
      final rawList = await ApiService.fetchContinueWatching(_authToken!, profileId: _activeProfile.id);
      if (rawList.isNotEmpty) {
        final pool = _catalog.isNotEmpty ? _catalog : MockData.allItems;
        final List<MediaItem> list = [];
        for (final json in rawList) {
          final mediaId = json['media_id']?.toString() ?? json['id']?.toString() ?? '';
          final progressRatio = (json['progress_percentage'] as num?)?.toDouble() ??
              (((json['position_seconds'] as num?)?.toDouble() ?? 0) /
                  ((json['duration_seconds'] as num?)?.toDouble() ?? 1));
          
          final found = pool.where((m) => m.id == mediaId).firstOrNull;
          if (found != null) {
            list.add(MediaItem(
              id: found.id,
              title: found.title,
              description: found.description,
              posterUrl: found.posterUrl,
              backdropUrl: found.backdropUrl,
              genres: found.genres,
              releaseYear: found.releaseYear,
              ageRating: found.ageRating,
              durationOrSeasons: found.durationOrSeasons,
              matchScore: found.matchScore,
              type: found.type,
              isOriginal: found.isOriginal,
              isTrending: found.isTrending,
              topTenRank: found.topTenRank,
              watchProgress: progressRatio.clamp(0.0, 1.0),
              cast: found.cast,
              creators: found.creators,
              episodes: found.episodes,
              tags: found.tags,
              videoUrl: found.videoUrl,
            ));
          }
        }
        if (list.isNotEmpty) {
          _continueWatching = list;
          notifyListeners();
          return;
        }
      }
    } catch (_) {}
    _rebuildContinueWatchingFromLocal();
    notifyListeners();
  }

  Future<void> updateWatchProgress(MediaItem item, double positionSeconds, double durationSeconds) async {
    if (durationSeconds <= 0) return;
    final progress = (positionSeconds / durationSeconds).clamp(0.0, 1.0);

    // Save to local storage
    await PreferencesService.saveWatchProgress(item.id, progress);

    // Update state list
    final existingIndex = _continueWatching.indexWhere((m) => m.id == item.id);
    final updatedItem = MediaItem(
      id: item.id,
      title: item.title,
      description: item.description,
      posterUrl: item.posterUrl,
      backdropUrl: item.backdropUrl,
      genres: item.genres,
      releaseYear: item.releaseYear,
      ageRating: item.ageRating,
      durationOrSeasons: item.durationOrSeasons,
      matchScore: item.matchScore,
      type: item.type,
      isOriginal: item.isOriginal,
      isTrending: item.isTrending,
      topTenRank: item.topTenRank,
      watchProgress: progress,
      cast: item.cast,
      creators: item.creators,
      episodes: item.episodes,
      tags: item.tags,
      videoUrl: item.videoUrl,
    );

    if (progress >= 0.95) {
      _continueWatching.removeWhere((m) => m.id == item.id);
    } else if (existingIndex >= 0) {
      _continueWatching[existingIndex] = updatedItem;
    } else {
      _continueWatching.insert(0, updatedItem);
    }
    notifyListeners();

    // Sync to backend if authenticated
    if (_authToken != null) {
      try {
        await ApiService.updateWatchProgress(
          _authToken!,
          mediaId: item.id,
          profileId: _activeProfile.id,
          progressSeconds: positionSeconds,
          durationSeconds: durationSeconds,
        );
      } catch (_) {}
    }
  }

  Future<void> removeContinueWatching(String mediaId) async {
    await PreferencesService.saveWatchProgress(mediaId, 0.0);
    _continueWatching.removeWhere((m) => m.id == mediaId);
    notifyListeners();

    if (_authToken != null) {
      try {
        await ApiService.removeWatchProgress(_authToken!, mediaId, profileId: _activeProfile.id);
      } catch (_) {}
    }
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
    PreferencesService.setMyListIds(_myList.map((m) => m.id).toList());
    notifyListeners();
  }

  void removeFromMyList(String id) {
    _myList.removeWhere((item) => item.id == id);
    PreferencesService.setMyListIds(_myList.map((m) => m.id).toList());
    notifyListeners();
  }

  // Downloads & Offline Storage
  final List<MediaItem> _downloads = [];
  List<MediaItem> get downloads => _offlineDownloads.isNotEmpty
      ? _offlineDownloads.map((d) => d.mediaItem).toList()
      : List.unmodifiable(_downloads);

  List<DownloadedItem> _offlineDownloads = [];
  List<DownloadedItem> get offlineDownloads => List.unmodifiable(_offlineDownloads);

  Future<void> loadDownloadedItems() async {
    _offlineDownloads = await DownloadService.getDownloadedItems();
    notifyListeners();
  }

  bool isDownloaded(String id) {
    return _offlineDownloads.any((item) => item.mediaItem.id == id) ||
        _downloads.any((item) => item.id == id);
  }

  Future<void> downloadMediaItem(
    MediaItem item, {
    Function(double progress)? onProgress,
  }) async {
    await DownloadService.downloadItem(item, onProgress: onProgress);
    await loadDownloadedItems();
  }

  Future<void> removeDownload(String id) async {
    await DownloadService.deleteDownload(id);
    _downloads.removeWhere((item) => item.id == id);
    PreferencesService.setDownloadIds(_downloads.map((m) => m.id).toList());
    await loadDownloadedItems();
  }

  void toggleDownload(MediaItem item) {
    if (isDownloaded(item.id)) {
      unawaited(removeDownload(item.id));
    } else {
      unawaited(downloadMediaItem(item));
    }
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
    PreferencesService.setReminderIds(_reminders);
    notifyListeners();
  }

  // App Settings Toggles
  bool _autoplayPreviews = true;
  bool get autoplayPreviews => _autoplayPreviews;
  void toggleAutoplayPreviews(bool value) {
    _autoplayPreviews = value;
    PreferencesService.setAutoplayPreviews(value);
    notifyListeners();
  }

  bool _smartDownloads = true;
  bool get smartDownloads => _smartDownloads;
  void toggleSmartDownloads(bool value) {
    _smartDownloads = value;
    PreferencesService.setSmartDownloads(value);
    notifyListeners();
  }

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;
  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    PreferencesService.setNotificationsEnabled(value);
    notifyListeners();
  }

  bool _wifiOnly = true;
  bool get wifiOnly => _wifiOnly;
  void toggleWifiOnly(bool value) {
    _wifiOnly = value;
    PreferencesService.setWifiOnly(value);
    notifyListeners();
  }

  String _videoQuality = 'Ultra HD (4K)';
  String get videoQuality => _videoQuality;
  void setVideoQuality(String quality) {
    _videoQuality = quality;
    PreferencesService.setVideoQuality(quality);
    notifyListeners();
  }

  // Subscription Plan
  String? _selectedPlanId;
  String? get selectedPlanId => _selectedPlanId;
  void setSelectedPlan(String planId) {
    _selectedPlanId = planId;
    notifyListeners();
  }

  // Notifications Center
  final List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications =>
      _notifications.isNotEmpty ? List.unmodifiable(_notifications) : MockData.notifications;

  final Set<String> _readNotificationIds = {};
  bool isNotificationRead(String id) => _readNotificationIds.contains(id);

  int get unreadNotificationCount =>
      notifications.where((n) => !_readNotificationIds.contains(n.id)).length;

  Future<void> loadNotifications() async {
    if (_authToken == null) return;
    try {
      final list = await ApiService.fetchNotifications(_authToken!);
      if (list.isNotEmpty) {
        _notifications.clear();
        _notifications.addAll(list.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)));
        notifyListeners();
      }
    } catch (_) {}
  }

  void markNotificationRead(String id) {
    if (_readNotificationIds.add(id)) {
      PreferencesService.setReadNotificationIds(_readNotificationIds);
      if (_authToken != null) {
        try {
          ApiService.markNotificationRead(_authToken!, id);
        } catch (_) {}
      }
      notifyListeners();
    }
  }

  void markAllNotificationsRead() {
    _readNotificationIds.addAll(notifications.map((n) => n.id));
    PreferencesService.setReadNotificationIds(_readNotificationIds);
    notifyListeners();
  }

  // Ratings & Reviews
  final Map<String, int> _userRatings = {};
  int? getUserRating(String itemId) => _userRatings[itemId];

  void setUserRating(String itemId, int stars) {
    _userRatings[itemId] = stars;
    PreferencesService.saveUserRating(itemId, stars);
    notifyListeners();
  }

  // App Lock
  bool _appLockEnabled = false;
  bool get appLockEnabled => _appLockEnabled;

  String? _appLockPin;
  bool get hasAppLockPin => _appLockPin != null;

  void setAppLockPin(String pin) {
    _appLockPin = pin;
    _appLockEnabled = true;
    PreferencesService.setAppLockPin(pin);
    PreferencesService.setAppLockEnabled(true);
    notifyListeners();
  }

  bool verifyAppLockPin(String pin) => _appLockPin == pin;

  void toggleAppLock(bool value) {
    _appLockEnabled = value;
    PreferencesService.setAppLockEnabled(value);
    notifyListeners();
  }

  void clearAppLockPin() {
    _appLockPin = null;
    _appLockEnabled = false;
    PreferencesService.setAppLockPin(null);
    PreferencesService.setAppLockEnabled(false);
    notifyListeners();
  }
}
