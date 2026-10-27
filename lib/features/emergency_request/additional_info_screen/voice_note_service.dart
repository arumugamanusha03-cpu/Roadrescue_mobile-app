import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

enum MicAccess { granted, denied, permanentlyDenied }

/// Records and plays the optional voice description. Files stay on the
/// device; nothing is uploaded.
abstract class VoiceNoteService {
  Future<MicAccess> requestPermission();
  Future<void> openSettings();

  Future<void> startRecording();

  /// Stops and returns the recording's path (or blob URL on web).
  Future<String?> stopRecording();
  Future<void> cancelRecording();

  Future<void> play(String path);
  Future<void> stopPlayback();

  /// Fires when playback reaches the end.
  Stream<void> get onPlaybackComplete;

  Future<void> deleteRecording(String path);

  void dispose();
}

class DeviceVoiceNoteService implements VoiceNoteService {
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();

  @override
  Future<MicAccess> requestPermission() async {
    // permission_handler has no web implementation; the recorder asks the
    // browser itself.
    if (kIsWeb) {
      return await _recorder.hasPermission()
          ? MicAccess.granted
          : MicAccess.denied;
    }
    final status = await Permission.microphone.request();
    if (status.isGranted || status.isLimited) return MicAccess.granted;
    if (status.isPermanentlyDenied || status.isRestricted) {
      return MicAccess.permanentlyDenied;
    }
    return MicAccess.denied;
  }

  @override
  Future<void> openSettings() => openAppSettings();

  @override
  Future<void> startRecording() async {
    if (kIsWeb) {
      // The browser keeps the audio in memory; stop() returns a blob URL.
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path: '',
      );
      return;
    }
    final dir = Directory(
      '${(await getApplicationDocumentsDirectory()).path}/voice_notes',
    );
    await dir.create(recursive: true);
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(), path: path);
  }

  @override
  Future<String?> stopRecording() => _recorder.stop();

  @override
  Future<void> cancelRecording() => _recorder.cancel();

  @override
  Future<void> play(String path) => _player.play(
    kIsWeb || path.startsWith('blob:')
        ? UrlSource(path)
        : DeviceFileSource(path),
  );

  @override
  Future<void> stopPlayback() => _player.stop();

  @override
  Stream<void> get onPlaybackComplete => _player.onPlayerComplete;

  @override
  Future<void> deleteRecording(String path) async {
    if (kIsWeb || path.isEmpty) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  @override
  void dispose() {
    unawaited(_recorder.dispose());
    unawaited(_player.dispose());
  }
}

final voiceNoteServiceProvider = Provider<VoiceNoteService>((ref) {
  final service = DeviceVoiceNoteService();
  ref.onDispose(service.dispose);
  return service;
});
