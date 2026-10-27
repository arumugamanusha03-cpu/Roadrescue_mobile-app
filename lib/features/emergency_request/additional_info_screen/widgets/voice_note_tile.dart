import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../request_draft.dart';
import '../voice_note_service.dart';

/// Optional voice description: tap to record, then play back or delete.
/// Stored locally only (path in the request draft).
class VoiceNoteTile extends ConsumerStatefulWidget {
  const VoiceNoteTile({super.key});

  /// Recordings stop automatically at this length.
  static const maxDuration = Duration(minutes: 2);

  @override
  ConsumerState<VoiceNoteTile> createState() => _VoiceNoteTileState();
}

enum _Mode { idle, recording, recorded }

class _VoiceNoteTileState extends ConsumerState<VoiceNoteTile> {
  late final VoiceNoteService _service = ref.read(voiceNoteServiceProvider);
  Timer? _ticker;
  Duration _elapsed = Duration.zero;
  bool _recording = false;
  bool _playing = false;
  bool _busy = false;
  StreamSubscription<void>? _completeSub;

  @override
  void initState() {
    super.initState();
    _completeSub = _service.onPlaybackComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    unawaited(_completeSub?.cancel());
    if (_recording) unawaited(_service.cancelRecording());
    if (_playing) unawaited(_service.stopPlayback());
    super.dispose();
  }

  void _snack(String text, {SnackBarAction? action}) =>
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(text), action: action));

  Future<void> _start() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final access = await _service.requestPermission();
      if (!mounted) return;
      switch (access) {
        case MicAccess.denied:
          _snack('Microphone access is needed to record a voice note.');
          return;
        case MicAccess.permanentlyDenied:
          _snack(
            'Microphone access is turned off for RoadRescue.',
            action: SnackBarAction(
              label: 'Settings',
              onPressed: _service.openSettings,
            ),
          );
          return;
        case MicAccess.granted:
      }
      await _service.startRecording();
      if (!mounted) return;
      setState(() {
        _recording = true;
        _elapsed = Duration.zero;
      });
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsed += const Duration(seconds: 1));
        if (_elapsed >= VoiceNoteTile.maxDuration) unawaited(_stop());
      });
    } catch (_) {
      if (mounted) _snack('Couldn’t start recording. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _stop() async {
    _ticker?.cancel();
    try {
      final path = await _service.stopRecording();
      if (!mounted) return;
      setState(() => _recording = false);
      if (path == null || _elapsed < const Duration(seconds: 1)) {
        if (path != null) await _service.deleteRecording(path);
        _snack('That was too short. Hold on a little longer.');
        return;
      }
      ref
          .read(requestDraftProvider.notifier)
          .setVoiceNote(VoiceNote(path: path, duration: _elapsed));
    } catch (_) {
      if (mounted) {
        setState(() => _recording = false);
        _snack('Couldn’t save the recording. Please try again.');
      }
    }
  }

  Future<void> _cancel() async {
    _ticker?.cancel();
    await _service.cancelRecording();
    if (mounted) setState(() => _recording = false);
  }

  Future<void> _togglePlay(VoiceNote note) async {
    try {
      if (_playing) {
        await _service.stopPlayback();
        if (mounted) setState(() => _playing = false);
      } else {
        setState(() => _playing = true);
        await _service.play(note.path);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _playing = false);
        _snack('Couldn’t play the recording.');
      }
    }
  }

  Future<void> _delete(VoiceNote note) async {
    if (_playing) await _service.stopPlayback();
    await _service.deleteRecording(note.path);
    ref.read(requestDraftProvider.notifier).clearVoiceNote();
    if (mounted) setState(() => _playing = false);
  }

  static String _clock(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final note = ref.watch(requestDraftProvider.select((d) => d.voiceNote));
    final mode = _recording
        ? _Mode.recording
        : note != null
        ? _Mode.recorded
        : _Mode.idle;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: mode == _Mode.recording
              ? AppColors.error.withValues(alpha: 0.6)
              : AppColors.textPrimary.withValues(alpha: 0.1),
        ),
      ),
      child: switch (mode) {
        _Mode.idle => Semantics(
          button: true,
          label: 'Record a voice description',
          excludeSemantics: true,
          child: InkWell(
            onTap: _busy ? null : _start,
            borderRadius: AppRadius.mdAll,
            child: _Row(
              leading: const _RoundIcon(icon: Icons.mic, gradient: true),
              title: 'Tap to record',
              trailing: _busy
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.arrow_forward, color: AppColors.textSecondary),
            ),
          ),
        ),
        _Mode.recording => Semantics(
          liveRegion: true,
          label: 'Recording, ${_clock(_elapsed)}',
          child: _Row(
            leading: const _RecordingDot(),
            title: 'Recording…  ${_clock(_elapsed)}',
            subtitle: 'Up to ${VoiceNoteTile.maxDuration.inMinutes} minutes',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(onPressed: _cancel, child: const Text('Cancel')),
                IconButton.filled(
                  onPressed: _stop,
                  tooltip: 'Stop recording',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.stop_rounded),
                ),
              ],
            ),
          ),
        ),
        _Mode.recorded => _Row(
          leading: Semantics(
            button: true,
            label: _playing ? 'Stop playback' : 'Play voice note',
            excludeSemantics: true,
            child: InkWell(
              onTap: () => _togglePlay(note!),
              customBorder: const CircleBorder(),
              child: _RoundIcon(
                icon: _playing ? Icons.stop_rounded : Icons.play_arrow_rounded,
                gradient: true,
              ),
            ),
          ),
          title: _playing ? 'Playing…' : 'Voice note',
          subtitle: '${_clock(note!.duration)} • saved on this phone',
          trailing: IconButton(
            onPressed: () => _delete(note),
            tooltip: 'Delete voice note',
            icon: Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ),
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.leading,
    required this.title,
    required this.trailing,
    this.subtitle,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s12),
      child: Row(
        children: [
          leading,
          Gap.h16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Text(subtitle!, style: AppTypography.caption),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, this.gradient = false});

  final IconData icon;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient
            ? LinearGradient(
                colors: [
                  AppColors.authGradientStart,
                  AppColors.authGradientEnd,
                ],
              )
            : null,
      ),
      child: Icon(icon, color: AppColors.onAuthGradient),
    );
  }
}

/// Pulsing red dot while recording (static when motion is reduced).
class _RecordingDot extends StatefulWidget {
  const _RecordingDot();

  @override
  State<_RecordingDot> createState() => _RecordingDotState();
}

class _RecordingDotState extends State<_RecordingDot>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.errorFill,
      ),
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.error,
        ),
      ),
    );
    if (MediaQuery.disableAnimationsOf(context)) return dot;
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1).animate(_pulse),
      child: dot,
    );
  }
}
