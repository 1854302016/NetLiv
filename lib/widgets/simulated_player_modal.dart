import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../models/media_item.dart';
import 'shimmer_image.dart';

class SimulatedPlayerModal extends StatefulWidget {
  final MediaItem item;

  const SimulatedPlayerModal({
    super.key,
    required this.item,
  });

  static Future<void> show(BuildContext context, MediaItem item) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) =>
            SimulatedPlayerModal(item: item),
      ),
    );
  }

  @override
  State<SimulatedPlayerModal> createState() => _SimulatedPlayerModalState();
}

class _SimulatedPlayerModalState extends State<SimulatedPlayerModal> {
  bool _isPlaying = true;
  bool _showControls = true;
  double _currentPosition = 345.0; // 5m 45s in seconds
  final double _totalDuration = 7200.0; // 2 hours in seconds
  double _playbackSpeed = 1.0;
  Timer? _progressTimer;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    // Enable simulated video progress
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying && mounted) {
        setState(() {
          _currentPosition = (_currentPosition + _playbackSpeed)
              .clamp(0.0, _totalDuration);
        });
      }
    });
    _resetHideControlsTimer();
  }

  void _resetHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(double seconds) {
    final int totalSec = seconds.toInt();
    final int hours = totalSec ~/ 3600;
    final int mins = (totalSec % 3600) ~/ 60;
    final int secs = totalSec % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
          if (_showControls) _resetHideControlsTimer();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Simulation Backdrop
            Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ShimmerImage(
                      imageUrl: widget.item.backdropUrl,
                      fit: BoxFit.cover,
                    ),
                    // Ambient pulse simulation
                    Container(
                      color: Colors.black.withOpacity(_isPlaying ? 0.05 : 0.4),
                    ),
                    if (!_isPlaying)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.netflixRed, width: 2),
                          ),
                          child: const Icon(Icons.pause_rounded,
                              size: 48, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Controls Overlay
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: Container(
                  color: Colors.black54,
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top Bar: Back button, Title, Settings
                        _buildTopBar(),

                        // Center Controls: Skip -10s, Play/Pause, Skip +10s
                        _buildCenterControls(),

                        // Bottom Controls: Scrub bar, Time, Quality, Subtitles
                        _buildBottomControls(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.item.title,
                  style: AppTypography.titleMedium.copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Ultra HD 4K  •  Dolby Atmos  •  ${widget.item.ageRating}',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.primaryLight),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.cast_rounded, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Connected to Living Room TV'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Skip -10s
        IconButton(
          iconSize: 42,
          icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() {
              _currentPosition = (_currentPosition - 10).clamp(0.0, _totalDuration);
            });
            _resetHideControlsTimer();
          },
        ),
        const SizedBox(width: 32),

        // Play / Pause
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            setState(() {
              _isPlaying = !_isPlaying;
            });
            _resetHideControlsTimer();
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.netflixRed,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(width: 32),

        // Skip +10s
        IconButton(
          iconSize: 42,
          icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() {
              _currentPosition = (_currentPosition + 10).clamp(0.0, _totalDuration);
            });
            _resetHideControlsTimer();
          },
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Scrub Slider
          Row(
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: AppTypography.bodySmall.copyWith(color: Colors.white),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3.5,
                    activeTrackColor: AppColors.netflixRed,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: AppColors.netflixRed,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayColor: AppColors.netflixRed.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _currentPosition,
                    min: 0.0,
                    max: _totalDuration,
                    onChanged: (val) {
                      setState(() {
                        _currentPosition = val;
                      });
                      _resetHideControlsTimer();
                    },
                  ),
                ),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),

          // Bottom Quick Bar: Speed, Audio & Subtitles, Lock
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Speed
              TextButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (_playbackSpeed == 1.0) {
                      _playbackSpeed = 1.25;
                    } else if (_playbackSpeed == 1.25) {
                      _playbackSpeed = 1.5;
                    } else {
                      _playbackSpeed = 1.0;
                    }
                  });
                },
                child: Text(
                  'Speed (${_playbackSpeed}x)',
                  style: AppTypography.chip.copyWith(color: Colors.white),
                ),
              ),

              // Audio & Subtitles
              TextButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Audio: English 5.1 | Subtitles: English [CC]'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.subtitles_rounded, color: Colors.white, size: 18),
                label: Text(
                  'Audio & Subtitles',
                  style: AppTypography.chip.copyWith(color: Colors.white),
                ),
              ),

              // Next Episode button
              if (widget.item.type == MediaType.series)
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _currentPosition = 0;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Playing Next Episode...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 20),
                  label: Text('Next Ep', style: AppTypography.chip.copyWith(color: Colors.white)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
