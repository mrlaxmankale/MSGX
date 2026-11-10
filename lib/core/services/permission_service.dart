import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import '../utils/error_handler.dart';

/// Service responsible for managing Android and iOS media permissions for MSGX.
class PermissionService {
  /// Check whether media permissions are currently granted.
  static Future<bool> hasMediaPermission() async {
    try {
      if (Platform.isAndroid) {
        // Check Android 13+ READ_MEDIA_AUDIO
        final audioStatus = await Permission.audio.status;
        if (audioStatus.isGranted) return true;

        // Check fallback READ_EXTERNAL_STORAGE
        final storageStatus = await Permission.storage.status;
        return storageStatus.isGranted;
      } else if (Platform.isIOS) {
        final status = await Permission.mediaLibrary.status;
        return status.isGranted;
      }
      return true;
    } catch (e, stack) {
      ErrorHandler.logError('PermissionService.hasMediaPermission', e, stack);
      return false;
    }
  }

  /// Request media permissions with appropriate platform strategy.
  static Future<PermissionStatus> requestMediaPermission() async {
    try {
      if (Platform.isAndroid) {
        // Attempt audio permission first (Android 13+)
        PermissionStatus audioStatus = await Permission.audio.request();
        if (audioStatus.isGranted) {
          return audioStatus;
        }

        // Fallback to general storage permission for Android 12 and below
        PermissionStatus storageStatus = await Permission.storage.request();
        return storageStatus;
      } else if (Platform.isIOS) {
        return await Permission.mediaLibrary.request();
      }
      return PermissionStatus.granted;
    } catch (e, stack) {
      ErrorHandler.logError(
          'PermissionService.requestMediaPermission', e, stack);
      return PermissionStatus.denied;
    }
  }

  /// Check if media permissions have been permanently denied (requires opening OS settings).
  static Future<bool> isPermissionPermanentlyDenied() async {
    try {
      if (Platform.isAndroid) {
        final audioDenied = await Permission.audio.isPermanentlyDenied;
        final storageDenied = await Permission.storage.isPermanentlyDenied;
        return audioDenied || storageDenied;
      } else if (Platform.isIOS) {
        return await Permission.mediaLibrary.isPermanentlyDenied;
      }
      return false;
    } catch (e, stack) {
      ErrorHandler.logError(
          'PermissionService.isPermissionPermanentlyDenied', e, stack);
      return false;
    }
  }

  /// Open device app settings page
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
