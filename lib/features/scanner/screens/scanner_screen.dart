import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../library/providers/library_provider.dart';
import '../providers/scanner_provider.dart';

/// Screen responsible for device audio scanning and local folder imports.
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  int _minDurationSeconds = 30;

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scannerStateProvider);
    final scannerNotifier = ref.read(scannerStateProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Music Scanner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.darkPrimarySurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.darkDivider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        scanState.isScanning
                            ? Icons.radar_rounded
                            : (scanState.error != null
                                ? Icons.error_outline_rounded
                                : Icons.check_circle_outline_rounded),
                        color: scanState.isScanning
                            ? AppColors.primaryGreen
                            : (scanState.error != null
                                ? AppColors.error
                                : AppColors.primaryGreen),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          scanState.isScanning
                              ? 'Scanning local music...'
                              : (scanState.error != null
                                  ? 'Scan encountered an issue'
                                  : 'Library Ready'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (scanState.isScanning) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(
                      backgroundColor: Colors.white12,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metricColumn('Discovered', '${scanState.discovered}'),
                      _metricColumn('Valid Songs', '${scanState.valid}',
                          color: AppColors.primaryGreen),
                      _metricColumn('Skipped', '${scanState.skipped}'),
                    ],
                  ),
                  if (scanState.error != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      scanState.error!,
                      style:
                          const TextStyle(color: AppColors.error, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Scan Filters
            const Text(
              'SCAN CONFIGURATION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkPrimarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Minimum Song Duration',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '$_minDurationSeconds seconds',
                        style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Files shorter than this are ignored to filter out system ringtones and notification clips.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.darkTextSecondary),
                  ),
                  Slider(
                    value: _minDurationSeconds.toDouble(),
                    min: 5.0,
                    max: 60.0,
                    divisions: 11,
                    activeColor: AppColors.primaryGreen,
                    inactiveColor: AppColors.darkDivider,
                    onChanged: scanState.isScanning
                        ? null
                        : (val) {
                            setState(() {
                              _minDurationSeconds = val.round();
                            });
                          },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Scan & Import Buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: Icon(
                    scanState.isScanning ? Icons.close : Icons.refresh_rounded),
                label: Text(
                  scanState.isScanning ? 'Cancel Scan' : 'Scan Device Music',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: scanState.isScanning
                      ? AppColors.darkSecondarySurface
                      : AppColors.primaryGreen,
                  foregroundColor:
                      scanState.isScanning ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () async {
                  if (scanState.isScanning) {
                    scannerNotifier.cancel();
                  } else {
                    await scannerNotifier.startScan(
                      minDurationMs: _minDurationSeconds * 1000,
                    );
                    ref.invalidate(allSongsProvider);
                    ref.invalidate(allAlbumsProvider);
                    ref.invalidate(allArtistsProvider);
                  }
                },
              ),
            ),

            const SizedBox(height: 14),

            // Import Folder Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon:
                    const Icon(Icons.folder_open_rounded, color: Colors.white),
                label: const Text(
                  'Import Custom Folder / Files',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.darkDivider),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: scanState.isScanning
                    ? null
                    : () async {
                        final scanner = ref.read(musicScannerProvider);
                        await scanner.importCustomFolder(
                          onProgress: (p) => ref
                              .read(scannerStateProvider.notifier)
                              .setProgress(p),
                        );
                        ref.invalidate(allSongsProvider);
                        ref.invalidate(allAlbumsProvider);
                        ref.invalidate(allArtistsProvider);
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricColumn(String label, String value,
      {Color color = Colors.white}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.darkTextSecondary,
          ),
        ),
      ],
    );
  }
}
