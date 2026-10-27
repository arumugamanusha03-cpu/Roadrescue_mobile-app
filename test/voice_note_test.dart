import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_rescue/core/theme/theme.dart';
import 'package:road_rescue/features/emergency_request/additional_info_screen/voice_note_service.dart';
import 'package:road_rescue/features/emergency_request/additional_info_screen/widgets/voice_note_tile.dart';
import 'package:road_rescue/features/emergency_request/request_draft.dart';

class _FakeVoiceService implements VoiceNoteService {
  MicAccess access = MicAccess.granted;
  bool recording = false;
  String? playing;
  final deleted = <String>[];
  final _complete = StreamController<void>.broadcast();

  @override
  Future<MicAccess> requestPermission() async => access;
  @override
  Future<void> openSettings() async {}
  @override
  Future<void> startRecording() async => recording = true;
  @override
  Future<String?> stopRecording() async {
    recording = false;
    return '/local/voice_1.m4a';
  }

  @override
  Future<void> cancelRecording() async => recording = false;
  @override
  Future<void> play(String path) async => playing = path;
  @override
  Future<void> stopPlayback() async => playing = null;
  @override
  Stream<void> get onPlaybackComplete => _complete.stream;
  void finishPlayback() => _complete.add(null);
  @override
  Future<void> deleteRecording(String path) async => deleted.add(path);
  @override
  void dispose() {}
}

Future<(ProviderContainer, _FakeVoiceService)> _pump(
  WidgetTester tester, {
  MicAccess access = MicAccess.granted,
}) async {
  final fake = _FakeVoiceService()..access = access;
  final c = ProviderContainer(
    overrides: [voiceNoteServiceProvider.overrideWithValue(fake)],
  );
  addTearDown(c.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        theme: AppTheme.current,
        home: const Scaffold(
          body: Padding(padding: EdgeInsets.all(16), child: VoiceNoteTile()),
        ),
      ),
    ),
  );
  return (c, fake);
}

void main() {
  testWidgets('record, play back and delete a voice note', (tester) async {
    final (c, fake) = await _pump(tester);
    expect(find.text('Tap to record'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Record a voice description'));
    await tester.pump();
    expect(fake.recording, isTrue);
    await tester.pump(const Duration(seconds: 3));
    expect(find.textContaining('0:03'), findsOneWidget);

    await tester.tap(find.byTooltip('Stop recording'));
    await tester.pump();
    final note = c.read(requestDraftProvider).voiceNote;
    expect(note?.path, '/local/voice_1.m4a');
    expect(note?.duration, const Duration(seconds: 3));
    expect(find.text('Voice note'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Play voice note'));
    await tester.pump();
    expect(fake.playing, '/local/voice_1.m4a');
    fake.finishPlayback();
    await tester.pump();
    expect(find.bySemanticsLabel('Play voice note'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete voice note'));
    await tester.pump();
    expect(fake.deleted, ['/local/voice_1.m4a']);
    expect(c.read(requestDraftProvider).voiceNote, isNull);
    expect(find.text('Tap to record'), findsOneWidget);
  });

  testWidgets('cancel discards the recording', (tester) async {
    final (c, fake) = await _pump(tester);
    await tester.tap(find.bySemanticsLabel('Record a voice description'));
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(fake.recording, isFalse);
    expect(c.read(requestDraftProvider).voiceNote, isNull);
  });

  testWidgets('recording stops automatically at the limit', (tester) async {
    final (c, _) = await _pump(tester);
    await tester.tap(find.bySemanticsLabel('Record a voice description'));
    await tester.pump();
    for (var i = 0; i < VoiceNoteTile.maxDuration.inSeconds; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pump();
    expect(
      c.read(requestDraftProvider).voiceNote?.duration,
      VoiceNoteTile.maxDuration,
    );
  });

  testWidgets('denied microphone explains why nothing recorded', (
    tester,
  ) async {
    final (_, fake) = await _pump(tester, access: MicAccess.denied);
    await tester.tap(find.bySemanticsLabel('Record a voice description'));
    await tester.pump();
    expect(fake.recording, isFalse);
    expect(
      find.text('Microphone access is needed to record a voice note.'),
      findsOneWidget,
    );
  });

  testWidgets('blocked microphone offers Settings', (tester) async {
    await _pump(tester, access: MicAccess.permanentlyDenied);
    await tester.tap(find.bySemanticsLabel('Record a voice description'));
    await tester.pump();
    expect(find.text('Settings'), findsOneWidget);
  });
}
