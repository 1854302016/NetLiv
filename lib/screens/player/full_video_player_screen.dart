import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../models/episode.dart';
import '../../models/media_item.dart';
import '../../services/download_service.dart';
import '../../state/app_state.dart';

/// Full-screen production-ready OTT video player supporting movies, series episodes,
/// double-tap seek gestures, playback speed, screen locking, audio/subtitles, and next episode.
class FullVideoPlayerScreen extends StatefulWidget {
  final MediaItem item;
  final String? videoUrl;
  final String? title;
  final String? subtitle;
  final int? episodeIndex;
  final List<Episode>? episodes;

  const FullVideoPlayerScreen({
    super.key,
    required this.item,
    this.videoUrl,
    this.title,
    this.subtitle,
    this.episodeIndex,
    this.episodes,
  });

  static Future<void> show(
    BuildContext context,
    MediaItem item, {
    String? videoUrl,
    String? title,
    String? subtitle,
    int? episodeIndex,
    List<Episode>? episodes,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullVideoPlayerScreen(
          item: item,
          videoUrl: videoUrl,
          title: title,
          subtitle: subtitle,
          episodeIndex: episodeIndex,
          episodes: episodes,
        ),
      ),
    );
  }

  @override
  State<FullVideoPlayerScreen> createState() => _FullVideoPlayerScreenState();
}

class _FullVideoPlayerScreenState extends State<FullVideoPlayerScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;
  bool _isLocked = false;
  double _playbackSpeed = 1.0;
  Timer? _hideControlsTimer;
  Timer? _syncTimer;

  // Double tap feedback
  bool _showLeftSeekRipple = false;
  bool _showRightSeekRipple = false;
  Timer? _seekFeedbackTimer;

  // Subtitle / Audio state
  String _selectedAudio = 'English [Original]';
  String _selectedSubtitle = 'English (CC)';
  bool _subtitlesEnabled = true;

  // Quality & PiP & Skip Intro
  static const MethodChannel _pipChannel = MethodChannel('com.example.netliv/pip');
  String _selectedQuality = 'Auto';
  bool _canSkipIntro = false;

  late int _currentEpisodeIndex;
  late List<Episode> _episodeList;

  @override
  void initState() {
    super.initState();
    // Prefer landscape or vertical auto-rotation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _episodeList = widget.episodes ?? widget.item.episodes ?? [];
    _currentEpisodeIndex = widget.episodeIndex ?? 0;

    _startInit();
  }

  void _startInit() async {
    final localPath = await DownloadService.getLocalPath(widget.item.id);
    if (localPath != null && await File(localPath).exists()) {
      _initPlayerForUrl(localPath);
    } else {
      _initPlayerForUrl(_activeVideoUrl);
    }
  }

  String get _activeVideoUrl {
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      return widget.videoUrl!;
    }
    if (_episodeList.isNotEmpty && _currentEpisodeIndex < _episodeList.length) {
      final epUrl = _episodeList[_currentEpisodeIndex].videoUrl;
      if (epUrl != null && epUrl.isNotEmpty) return epUrl;
    }
    return widget.item.videoUrl ?? '';
  }

  String get _displayTitle {
    if (widget.title != null && widget.title!.isNotEmpty) {
      return widget.title!;
    }
    return widget.item.title;
  }

  String? get _displaySubtitle {
    if (widget.subtitle != null && widget.subtitle!.isNotEmpty) {
      return widget.subtitle;
    }
    if (_episodeList.isNotEmpty && _currentEpisodeIndex < _episodeList.length) {
      final ep = _episodeList[_currentEpisodeIndex];
      return 'S${ep.seasonNumber}:E${ep.episodeNumber} • ${ep.title}';
    }
    return null;
  }

  void _initPlayerForUrl(String url) {
    if (url.isEmpty) {
      setState(() => _hasError = true);
      return;
    }

    _syncProgress();
    _controller?.removeListener(_onTick);
    _controller?.dispose();

    setState(() {
      _isInitialized = false;
      _hasError = false;
    });

    final VideoPlayerController controller;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      controller = VideoPlayerController.networkUrl(Uri.parse(url));
    } else {
      final file = File(url);
      controller = file.existsSync()
          ? VideoPlayerController.file(file)
          : VideoPlayerController.networkUrl(Uri.parse(url));
    }
    _controller = controller;

    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() => _isInitialized = true);

      // Seek to resume position if continuing watch for main item
      if (widget.episodeIndex == null &&
          widget.item.watchProgress != null &&
          widget.item.watchProgress! > 0.02) {
        final resumeMs =
            (controller.value.duration.inMilliseconds * widget.item.watchProgress!).toInt();
        controller.seekTo(Duration(milliseconds: resumeMs));
      }

      controller.setPlaybackSpeed(_playbackSpeed);
      controller.play();
      controller.addListener(_onTick);
      _scheduleHideControls();
      _startSyncTimer();
    }).catchError((_) {
      if (mounted) setState(() => _hasError = true);
    });
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 5), (_) => _syncProgress());
  }

  void _syncProgress() {
    final controller = _controller;
    if (controller == null || !_isInitialized || !mounted) return;
    final pos = controller.value.position.inSeconds.toDouble();
    final dur = controller.value.duration.inSeconds.toDouble();
    if (dur > 0) {
      context.read<AppState>().updateWatchProgress(widget.item, pos, dur);
    }
  }

  void _onTick() {
    if (!mounted) return;
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      final posSec = controller.value.position.inSeconds;
      final shouldShowIntro = posSec >= 4 && posSec <= 90;
      if (_canSkipIntro != shouldShowIntro) {
        _canSkipIntro = shouldShowIntro;
      }
      // Auto-next episode if series finished
      if (controller.value.position >= controller.value.duration &&
          controller.value.duration > Duration.zero) {
        if (_hasNextEpisode) {
          _playNextEpisode();
          return;
        }
      }
    }
    setState(() {});
  }

  bool get _hasNextEpisode =>
      _episodeList.isNotEmpty && _currentEpisodeIndex + 1 < _episodeList.length;

  void _playNextEpisode() {
    if (!_hasNextEpisode) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _currentEpisodeIndex++;
    });
    final nextEp = _episodeList[_currentEpisodeIndex];
    final nextUrl = nextEp.videoUrl?.isNotEmpty == true
        ? nextEp.videoUrl!
        : (widget.item.videoUrl ?? '');
    _initPlayerForUrl(nextUrl);
  }

  void _scheduleHideControls() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && (_controller?.value.isPlaying ?? false)) {
        setState(() => _showControls = false);
      }
    });
  }

  void _togglePlayPause() {
    final controller = _controller;
    if (controller == null || !_isInitialized) return;
    HapticFeedback.lightImpact();
    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
        _showControls = true;
        _hideControlsTimer?.cancel();
        _syncProgress();
      } else {
        controller.play();
        _scheduleHideControls();
      }
    });
  }

  void _seekRelative(int seconds) {
    final controller = _controller;
    if (controller == null || !_isInitialized) return;
    HapticFeedback.selectionClick();
    final current = controller.value.position;
    final total = controller.value.duration;
    final target = current + Duration(seconds: seconds);
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > total ? total : target);
    controller.seekTo(clamped);
    _scheduleHideControls();
  }

  void _handleDoubleTapSeek(bool isRightSide) {
    if (_isLocked) return;
    _seekRelative(isRightSide ? 10 : -10);
    _seekFeedbackTimer?.cancel();
    setState(() {
      if (isRightSide) {
        _showRightSeekRipple = true;
        _showLeftSeekRipple = false;
      } else {
        _showLeftSeekRipple = true;
        _showRightSeekRipple = false;
      }
    });
    _seekFeedbackTimer = Timer(const Duration(milliseconds: 650), () {
      if (mounted) {
        setState(() {
          _showLeftSeekRipple = false;
          _showRightSeekRipple = false;
        });
      }
    });
  }

  void _toggleControls() {
    if (_isLocked) {
      setState(() => _showControls = !_showControls);
      if (_showControls) {
        _scheduleHideControls();
      }
      return;
    }
    setState(() => _showControls = !_showControls);
    if (_showControls) _scheduleHideControls();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = d.inHours;
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  void _showSpeedDialog() {
    _hideControlsTimer?.cancel();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Playback Speed', style: AppTypography.titleMedium),
                const SizedBox(height: 12),
                ...speeds.map((speed) {
                  final isSelected = _playbackSpeed == speed;
                  return ListTile(
                    title: Text(
                      '${speed}x ${speed == 1.0 ? "(Normal)" : ""}',
                      style: TextStyle(
                        color: isSelected ? AppColors.netflixRed : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_rounded, color: AppColors.netflixRed)
                        : null,
                    onTap: () {
                      setState(() {
                        _playbackSpeed = speed;
                        _controller?.setPlaybackSpeed(speed);
                      });
                      Navigator.pop(context);
                      _scheduleHideControls();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _enterPipMode() async {
    try {
      await _pipChannel.invokeMethod('enterPipMode');
    } catch (_) {}
  }

  void _showQualityDialog() {
    _hideControlsTimer?.cancel();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final qualities = [
          {'label': 'Auto (Recommended)', 'badge': 'Auto'},
          {'label': '1080p Full HD (High Quality)', 'badge': '1080p'},
          {'label': '720p HD (Balanced)', 'badge': '720p'},
          {'label': '480p SD (Data Saver)', 'badge': '480p'},
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Video Streaming Quality', style: AppTypography.titleMedium),
                const SizedBox(height: 12),
                ...qualities.map((q) {
                  final badge = q['badge']!;
                  final isSelected = _selectedQuality == badge;
                  return ListTile(
                    title: Text(
                      q['label']!,
                      style: TextStyle(
                        color: isSelected ? AppColors.netflixRed : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_rounded, color: AppColors.netflixRed)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedQuality = badge;
                      });
                      Navigator.pop(context);
                      _scheduleHideControls();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAudioSubtitleDialog() {
    _hideControlsTimer?.cancel();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final audios = ['English [Original]', 'Hindi (हिन्दी)', 'Tamil (தமிழ்)', 'Telugu (తెలుగు)'];
        final subtitles = ['Off', 'English (CC)', 'Hindi [CC]', 'Tamil', 'Telugu'];

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Audio & Subtitles', style: AppTypography.titleLarge),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white70),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('AUDIO', style: AppTypography.chip.copyWith(color: AppColors.textMuted)),
                      const SizedBox(height: 6),
                      ...audios.map((aud) {
                        final isSel = _selectedAudio == aud;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(aud, style: TextStyle(color: isSel ? AppColors.netflixRed : Colors.white)),
                          trailing: isSel ? const Icon(Icons.check_rounded, color: AppColors.netflixRed) : null,
                          onTap: () {
                            setState(() => _selectedAudio = aud);
                            setModalState(() {});
                          },
                        );
                      }),
                      const Divider(color: AppColors.border, height: 24),
                      Text('SUBTITLES', style: AppTypography.chip.copyWith(color: AppColors.textMuted)),
                      const SizedBox(height: 6),
                      ...subtitles.map((sub) {
                        final isSel = sub == 'Off' ? !_subtitlesEnabled : (_subtitlesEnabled && _selectedSubtitle == sub);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(sub, style: TextStyle(color: isSel ? AppColors.netflixRed : Colors.white)),
                          trailing: isSel ? const Icon(Icons.check_rounded, color: AppColors.netflixRed) : null,
                          onTap: () {
                            setState(() {
                              if (sub == 'Off') {
                                _subtitlesEnabled = false;
                              } else {
                                _subtitlesEnabled = true;
                                _selectedSubtitle = sub;
                              }
                            });
                            setModalState(() {});
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEpisodesListDialog() {
    _hideControlsTimer?.cancel();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Episodes', style: AppTypography.titleLarge),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _episodeList.length,
                    separatorBuilder: (context, index) => const Divider(color: AppColors.border),
                    itemBuilder: (context, index) {
                      final ep = _episodeList[index];
                      final isCurrent = index == _currentEpisodeIndex;
                      return ListTile(
                        leading: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isCurrent ? AppColors.netflixRed : AppColors.surfaceHighlight,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${ep.episodeNumber}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        title: Text(
                          ep.title,
                          style: TextStyle(
                            color: isCurrent ? AppColors.netflixRed : Colors.white,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(ep.duration, style: const TextStyle(color: Colors.white54)),
                        trailing: isCurrent
                            ? const Icon(Icons.equalizer_rounded, color: AppColors.netflixRed)
                            : const Icon(Icons.play_circle_outline_rounded, color: Colors.white70),
                        onTap: () {
                          Navigator.pop(context);
                          if (!isCurrent) {
                            setState(() => _currentEpisodeIndex = index);
                            final targetUrl = ep.videoUrl?.isNotEmpty == true
                                ? ep.videoUrl!
                                : (widget.item.videoUrl ?? '');
                            _initPlayerForUrl(targetUrl);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _syncProgress();
    _syncTimer?.cancel();
    _hideControlsTimer?.cancel();
    _seekFeedbackTimer?.cancel();
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Display
            if (_hasError)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.netflixRed, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      "Couldn't load video stream.",
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _initPlayerForUrl(_activeVideoUrl),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.netflixRed),
                      child: const Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              )
            else if (_isInitialized && controller != null)
              Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              )
            else
              const Center(child: CircularProgressIndicator(color: AppColors.netflixRed)),

            // Double Tap Touch Detection Layer (Left = -10s, Right = +10s)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _toggleControls,
                    onDoubleTap: () => _handleDoubleTapSeek(false),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _toggleControls,
                    onDoubleTap: () => _handleDoubleTapSeek(true),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),

            // Left Seek Ripple Overlay (-10s)
            if (_showLeftSeekRipple)
              Positioned(
                left: 40,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.replay_10_rounded, color: Colors.white, size: 30),
                        SizedBox(width: 8),
                        Text(
                          '-10 sec',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Right Seek Ripple Overlay (+10s)
            if (_showRightSeekRipple)
              Positioned(
                right: 40,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '+10 sec',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.forward_10_rounded, color: Colors.white, size: 30),
                      ],
                    ),
                  ),
                ),
              ),

            // Screen Locked Overlay
            if (_isLocked && _showControls)
              Center(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() => _isLocked = false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.netflixRed, width: 1.5),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_open_rounded, color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text('Tap to Unlock Screen',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),

            // Skip Intro Button Overlay (shown during opening 4s to 90s)
            if (_canSkipIntro && !_isLocked)
              Positioned(
                right: 20,
                bottom: 80,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    _seekRelative(85);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Skip Intro',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 0.4,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.fast_forward_rounded, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ),

            // Full Player UI Controls (when not locked)
            if (!_isLocked && (_showControls || !_isInitialized)) ...[
              // Gradient Shade
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.22, 0.6, 1.0],
                  ),
                ),
              ),

              // Top Bar
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _displayTitle,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_displaySubtitle != null)
                            Text(
                              _displaySubtitle!,
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    // PiP Button
                    IconButton(
                      icon: const Icon(Icons.picture_in_picture_alt_rounded, color: Colors.white70),
                      tooltip: 'Picture-in-Picture',
                      onPressed: _enterPipMode,
                    ),
                    // Quality Selector
                    TextButton(
                      onPressed: _showQualityDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.netflixRed.withOpacity(0.7)),
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.black38,
                        ),
                        child: Text(
                          _selectedQuality,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // Lock Screen Button
                    IconButton(
                      icon: const Icon(Icons.lock_outline_rounded, color: Colors.white70),
                      tooltip: 'Lock Screen',
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _isLocked = true;
                          _showControls = true;
                        });
                        _scheduleHideControls();
                      },
                    ),
                    // Audio & Subtitles
                    IconButton(
                      icon: const Icon(Icons.subtitles_rounded, color: Colors.white70),
                      tooltip: 'Audio & Subtitles',
                      onPressed: _showAudioSubtitleDialog,
                    ),
                    // Playback Speed
                    TextButton(
                      onPressed: _showSpeedDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white54),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_playbackSpeed}x',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Center Action Row (-10s, Play/Pause, +10s)
              if (_isInitialized && controller != null)
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // -10s Rewind
                      IconButton(
                        iconSize: 42,
                        icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
                        onPressed: () => _seekRelative(-10),
                      ),
                      const SizedBox(width: 32),
                      // Play / Pause Circle
                      GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white38, width: 2),
                          ),
                          child: Icon(
                            controller.value.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      // +10s Forward
                      IconButton(
                        iconSize: 42,
                        icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
                        onPressed: () => _seekRelative(10),
                      ),
                    ],
                  ),
                ),

              // Bottom Control Bar
              if (_isInitialized && controller != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 12,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Video Progress Slider
                      VideoProgressIndicator(
                        controller,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        colors: const VideoProgressColors(
                          playedColor: AppColors.netflixRed,
                          bufferedColor: Colors.white38,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(controller.value.position),
                            style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                          ),
                          Row(
                            children: [
                              // Episodes selector if series
                              if (_episodeList.isNotEmpty)
                                TextButton.icon(
                                  onPressed: _showEpisodesListDialog,
                                  icon: const Icon(Icons.video_library_rounded, color: Colors.white, size: 16),
                                  label: const Text('Episodes', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                              // Next Episode Button
                              if (_hasNextEpisode)
                                TextButton.icon(
                                  onPressed: _playNextEpisode,
                                  icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 18),
                                  label: const Text('Next Ep', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                            ],
                          ),
                          Text(
                            _formatDuration(controller.value.duration),
                            style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
