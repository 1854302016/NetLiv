import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class CastDevicePickerModal extends StatefulWidget {
  const CastDevicePickerModal({super.key});

  static void show(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const CastDevicePickerModal(),
    );
  }

  @override
  State<CastDevicePickerModal> createState() => _CastDevicePickerModalState();
}

class _CastDevicePickerModalState extends State<CastDevicePickerModal> {
  bool _isScanning = true;
  String? _connectedDevice;

  final List<Map<String, dynamic>> _devices = [
    {
      'id': 'living_room_tv',
      'name': 'Living Room TV (Chromecast 4K)',
      'type': 'Google Cast / Android TV',
      'icon': Icons.tv_rounded,
      'isAvailable': true,
    },
    {
      'id': 'bed_room_tv',
      'name': 'Bedroom Smart TV (Samsung Tizen)',
      'type': 'Smart View / AirPlay',
      'icon': Icons.smart_display_rounded,
      'isAvailable': true,
    },
    {
      'id': 'fire_tv',
      'name': 'Fire TV Stick 4K Max',
      'type': 'Amazon Cast',
      'icon': Icons.cast_connected_rounded,
      'isAvailable': true,
    },
    {
      'id': 'nest_hub',
      'name': 'Kitchen Display (Nest Hub)',
      'type': 'Google Cast',
      'icon': Icons.tablet_mac_rounded,
      'isAvailable': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    });
  }

  void _connectToDevice(Map<String, dynamic> device) {
    HapticFeedback.mediumImpact();
    final isAlreadyConnected = _connectedDevice == device['id'];

    if (isAlreadyConnected) {
      setState(() => _connectedDevice = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceElevated,
          content: Text('Disconnected from ${device['name']}'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      setState(() => _connectedDevice = device['id'] as String);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceElevated,
          content: Row(
            children: [
              const Icon(Icons.cast_connected_rounded, color: AppColors.accentEmerald, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Connected to ${device['name']}. Ready to cast!',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF161616),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Modal Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.netflixRed.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cast_rounded, color: AppColors.netflixRed, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cast to Device',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Play movies & shows on your TV',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_isScanning)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.netflixRed,
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Color(0xFFAAAAAA), size: 20),
                    onPressed: () {
                      setState(() => _isScanning = true);
                      Future.delayed(const Duration(milliseconds: 1000), () {
                        if (mounted) setState(() => _isScanning = false);
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFF262626)),
            const SizedBox(height: 10),

            // Devices List
            ..._devices.map((device) {
              final isConnected = _connectedDevice == device['id'];

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isConnected
                      ? AppColors.netflixRed.withOpacity(0.12)
                      : const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isConnected
                        ? AppColors.netflixRed.withOpacity(0.5)
                        : const Color(0xFF2D2D2D),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isConnected
                          ? AppColors.netflixRed
                          : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      device['icon'] as IconData,
                      color: isConnected ? Colors.white : const Color(0xFFCCCCCC),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    device['name'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isConnected ? FontWeight.w700 : FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    isConnected ? 'Connected • Ready to cast' : device['type'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isConnected ? AppColors.accentEmerald : const Color(0xFF888888),
                      fontWeight: isConnected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: isConnected
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentEmerald.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.accentEmerald.withOpacity(0.4)),
                          ),
                          child: Text(
                            'Active',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentEmerald,
                            ),
                          ),
                        )
                      : const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF666666), size: 14),
                  onTap: () => _connectToDevice(device),
                ),
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
