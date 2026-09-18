import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../models/media_item.dart';
import '../state/app_state.dart';
import 'shimmer_image.dart';

class SimulatedPlayerModal extends StatefulWidget {
  final MediaItem item;
  final bool isWatchParty;
  final List<String> partyAvatars;

  const SimulatedPlayerModal({
    super.key,
    required this.item,
    this.isWatchParty = false,
    this.partyAvatars = const [],
  });

  static Future<void> show(
    BuildContext context,
    MediaItem item, {
    bool isWatchParty = false,
    List<String> partyAvatars = const [],
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) => SimulatedPlayerModal(
          item: item,
          isWatchParty: isWatchParty,
          partyAvatars: partyAvatars,
        ),
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
  bool _isLocked = false;
  bool _isCCOn = true;
  String _selectedAudio = 'English';
  String _selectedSubtitle = 'English';
  static const List<String> _languageOptions = [
    'English',
    'हिन्दी (Hindi)',
    'தமிழ் (Tamil)',
    'తెలుగు (Telugu)',
    'മലയാളം (Malayalam)',
    'ಕನ್ನಡ (Kannada)',
    'ਪੰਜਾਬੀ (Punjabi)',
    'भोजपुरी (Bhojpuri)',
  ];
  Timer? _progressTimer;
  Timer? _hideControlsTimer;

  static const double _introStart = 20.0;
  static const double _introEnd = 65.0;
  static const double _upNextWindow = 20.0;
  bool _upNextDismissed = false;

  MediaItem? get _nextEpisodeItem {
    if (widget.item.type != MediaType.series) return null;
    final related = context.read<AppState>().recommendationsFor(widget.item, count: 1);
    return related.isNotEmpty ? related.first : null;
  }

  bool get _showSkipIntro =>
      widget.item.type == MediaType.series &&
      _currentPosition >= _introStart &&
      _currentPosition < _introEnd;

  bool get _showUpNext =>
      widget.item.type == MediaType.series &&
      !_upNextDismissed &&
      (_totalDuration - _currentPosition) <= _upNextWindow &&
      _currentPosition < _totalDuration;

  @override
  void initState() {
    super.initState();
    if (widget.item.watchProgress != null && widget.item.watchProgress! > 0.02) {
      _currentPosition = widget.item.watchProgress! * _totalDuration;
    }
    // Enable simulated video progress
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying && mounted) {
        setState(() {
          _currentPosition = (_currentPosition + _playbackSpeed)
              .clamp(0.0, _totalDuration);
        });
        if (_currentPosition >= _totalDuration) {
          _handleAutoAdvance();
        }
      }
    });
    _resetHideControlsTimer();
  }

  void _handleAutoAdvance() {
    final appState = context.read<AppState>();
    if (widget.item.type == MediaType.series &&
        !_upNextDismissed &&
        appState.autoplayPreviews) {
      _playNextEpisode();
    }
  }

  void _playNextEpisode() {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentPosition = 0;
      _upNextDismissed = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Playing Next Episode...')),
    );
  }

  void _skipIntro() {
    HapticFeedback.mediumImpact();
    setState(() => _currentPosition = _introEnd + 1);
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
          if (_isLocked) {
             setState(() {
               _showControls = !_showControls;
             });
             if (_showControls) _resetHideControlsTimer();
          } else {
             setState(() {
               _showControls = !_showControls;
             });
             if (_showControls) _resetHideControlsTimer();
          }
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
                    child: _isLocked
                      ? _buildLockedControls()
                      : Column(
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

            // Skip Intro (visible independent of the controls overlay)
            if (_showSkipIntro && !_isLocked)
              Positioned(
                right: 16,
                bottom: 130,
                child: SafeArea(
                  child: OutlinedButton(
                    onPressed: _skipIntro,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Text('Skip Intro', style: AppTypography.button.copyWith(fontSize: 13)),
                  ),
                ),
              ),

            // Up Next / Auto-advance Overlay
            if (_showUpNext && !_isLocked)
              Positioned(
                right: 16,
                left: 16,
                bottom: 130,
                child: SafeArea(
                  child: _buildUpNextCard(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpNextCard() {
    final next = _nextEpisodeItem;
    final secondsLeft = (_totalDuration - _currentPosition).ceil().clamp(0, _upNextWindow.toInt());

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF181818),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('Up Next', style: AppTypography.chip.copyWith(color: AppColors.textSecondary)),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _upNextDismissed = true),
                  child: const Icon(Icons.close_rounded, color: Colors.white54, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: ShimmerImage(
                    imageUrl: (next ?? widget.item).backdropUrl,
                    width: 90,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    next?.title ?? 'Next Episode',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: _playNextEpisode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.netflixRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Text(
                  'Play Now ($secondsLeft s)',
                  style: AppTypography.button.copyWith(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAudioSubtitlePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181818),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Audio & Subtitles', style: AppTypography.titleMedium.copyWith(color: Colors.white)),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildLanguageColumn(
                            title: 'Audio',
                            options: _languageOptions,
                            selected: _selectedAudio,
                            onSelect: (val) {
                              setState(() => _selectedAudio = val);
                              setSheetState(() {});
                            },
                          ),
                        ),
                        Container(width: 1, height: 220, color: Colors.white12),
                        Expanded(
                          child: _buildLanguageColumn(
                            title: 'Subtitles',
                            options: ['Off', ..._languageOptions],
                            selected: _selectedSubtitle,
                            onSelect: (val) {
                              setState(() {
                                _selectedSubtitle = val;
                                _isCCOn = val != 'Off';
                              });
                              setSheetState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageColumn({
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(title, style: AppTypography.chip.copyWith(color: AppColors.textMuted)),
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220),
          child: SingleChildScrollView(
            child: Column(
              children: options.map((option) {
                final isSelected = option == selected;
                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelect(option);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: AppTypography.bodyMedium.copyWith(
                              color: isSelected ? Colors.white : const Color(0xFFB3B3B3),
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_rounded, color: AppColors.netflixRed, size: 18),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLockedControls() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            iconSize: 48,
            icon: const Icon(Icons.lock_open_rounded, color: Colors.white),
            onPressed: () {
              HapticFeedback.heavyImpact();
              setState(() {
                _isLocked = false;
              });
              _resetHideControlsTimer();
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Screen Locked\nTap to Unlock',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
          ),
        ],
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
          if (widget.isWatchParty) _buildWatchPartyIndicator(),
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

  Widget _buildWatchPartyIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: AppColors.netflixRed.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.netflixRed.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18.0 + (widget.partyAvatars.length.clamp(0, 3) * 12.0),
            height: 22,
            child: Stack(
              children: [
                for (int i = 0; i < widget.partyAvatars.length.clamp(0, 3); i++)
                  Positioned(
                    left: i * 12.0,
                    child: ClipOval(
                      child: ShimmerImage(
                        imageUrl: widget.partyAvatars[i],
                        width: 22,
                        height: 22,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Watch Party',
            style: AppTypography.chip.copyWith(color: AppColors.netflixRed, fontSize: 10),
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

          // Bottom Quick Bar: Episodes, Lock, CC, Speed, Fullscreen, etc.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                // Lock Button
                _buildBottomAction(
                  icon: Icons.lock_outline_rounded,
                  label: 'Lock',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _isLocked = true;
                    });
                  },
                ),
                const SizedBox(width: 16),
                
                // Episodes (if series)
                if (widget.item.type == MediaType.series) ...[
                  _buildBottomAction(
                    icon: Icons.format_list_bulleted_rounded,
                    label: 'Episodes',
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening Episodes List...')),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                ],

                // Audio & Subtitles
                _buildBottomAction(
                  icon: Icons.subtitles_rounded,
                  label: 'Audio & Subtitles',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _showAudioSubtitlePicker();
                  },
                ),
                const SizedBox(width: 16),

                // CC Toggle
                _buildBottomAction(
                  icon: _isCCOn ? Icons.closed_caption_rounded : Icons.closed_caption_disabled_rounded,
                  label: _isCCOn ? 'CC On' : 'CC Off',
                  iconColor: _isCCOn ? Colors.white : Colors.white54,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _isCCOn = !_isCCOn;
                      _selectedSubtitle = _isCCOn ? 'English' : 'Off';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_isCCOn ? 'Subtitles Enabled' : 'Subtitles Disabled')),
                    );
                  },
                ),
                const SizedBox(width: 16),
                
                // Speed
                _buildBottomAction(
                  icon: Icons.speed_rounded,
                  label: 'Speed (${_playbackSpeed}x)',
                  onTap: () {
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
                ),
                const SizedBox(width: 16),
                
                // Next Episode
                if (widget.item.type == MediaType.series) ...[
                  _buildBottomAction(
                    icon: Icons.skip_next_rounded,
                    label: 'Next Ep',
                    onTap: _playNextEpisode,
                  ),
                  const SizedBox(width: 16),
                ],

                // Fullscreen / Rotate
                _buildBottomAction(
                  icon: Icons.fullscreen_rounded,
                  label: 'Fullscreen',
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rotating to Landscape Fullscreen...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.chip.copyWith(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
