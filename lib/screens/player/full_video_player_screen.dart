import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../constants/app_colors.dart';
import '../../models/media_item.dart';
import '../../state/app_state.dart';

/// Full-screen vertical video player for a complete media item, using the
/// real video file uploaded via the admin panel (as opposed to the
/// simulated player, which is a UI-only mock for items without one).
class FullVideoPlayerScreen extends StatefulWidget {
  final MediaItem item;

  const FullVideoPlayerScreen({super.key, required this.item});

  static Future<void> show(BuildContext context, MediaItem item) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FullVideoPlayerScreen(item: item)),
    );
  }

  @override
  State<FullVideoPlayerScreen> createState() => _FullVideoPlayerScreenState();
}

class _FullVideoPlayerScreenState extends State<FullVideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() {
    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.item.videoUrl!));
    _controller = controller;
    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() => _isInitialized = true);

      // Seek to resume position if continuing watch
      if (widget.item.watchProgress != null && widget.item.watchProgress! > 0.02) {
        final resumeMs = (controller.value.duration.inMilliseconds * widget.item.watchProgress!).toInt();
        controller.seekTo(Duration(milliseconds: resumeMs));
      }

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
    if (mounted) setState(() {});
  }

  void _scheduleHideControls() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && (_controller?.value.isPlaying ?? false)) {
        setState(() => _showControls = false);
      }
    });
  }

  void _togglePlayPause() {
    final controller = _controller;
    if (controller == null || !_isInitialized) return;
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

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _scheduleHideControls();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = d.inHours;
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  void dispose() {
    _syncProgress();
    _syncTimer?.cancel();
    _hideControlsTimer?.cancel();
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
        child: GestureDetector(
          onTap: _toggleControls,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_hasError)
                Center(
                  child: Text(
                    "Couldn't play this video.",
                    style: GoogleFonts.inter(color: Colors.white70),
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

              if (_showControls || !_isInitialized)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.75),
                      ],
                      stops: const [0.0, 0.25, 0.6, 1.0],
                    ),
                  ),
                ),

              if (_showControls)
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
                      Expanded(
                        child: Text(
                          widget.item.title,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

              if (_isInitialized && controller != null && _showControls && !controller.value.isPlaying)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 64),
                  ),
                ),

              if (_isInitialized && controller != null && _showControls)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VideoProgressIndicator(
                        controller,
                        allowScrubbing: true,
                        padding: EdgeInsets.zero,
                        colors: const VideoProgressColors(
                          playedColor: AppColors.netflixRed,
                          bufferedColor: Colors.white38,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(controller.value.position),
                            style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                          ),
                          IconButton(
                            icon: Icon(
                              controller.value.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                            ),
                            onPressed: _togglePlayPause,
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
          ),
        ),
      ),
    );
  }
}
