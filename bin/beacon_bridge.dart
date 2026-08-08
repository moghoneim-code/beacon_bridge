// The CLI: attaches to a flutter run you started yourself. On every
// `beacon.selected` event it writes `.ref/sel-<id>.json`+`.png`, copies a
// paste-ready reference to the clipboard, and prints a one-line
// confirmation (PLAN.md §5). On `beacon.selectedMany` — a broadcast
// selection stack (PLAN.md §6) — it writes each item the same way, then
// copies one combined reference listing all of them.
import 'dart:async';
import 'dart:io';

import 'package:beacon_bridge/beacon_bridge.dart';

Future<void> main(List<String> arguments) async {
  final String vmServiceOutFilePath = _argValue(arguments, '--vmservice-out-file') ?? '.ref/vm.json';
  final bool multiline = _argValue(arguments, '--format') == 'multiline';

  final File vmServiceOutFile = File(vmServiceOutFilePath);
  final Directory refDir = vmServiceOutFile.absolute.parent;
  final Directory projectRoot = refDir.parent;

  print('beacon_bridge — attaches to a flutter run you started yourself.');
  print('Start (or restart) your app with:');
  print('  flutter run --vmservice-out-file=$vmServiceOutFilePath');
  print('');

  pruneOldSelections(refDir);
  schedulePeriodicPruning(refDir);
  final String? gitignoreWarning = checkGitignore(projectRoot);
  if (gitignoreWarning != null) print('[beacon_bridge] $gitignoreWarning');

  final VmClient client = VmClient(
    vmServiceOutFile: vmServiceOutFile,
    onStatus: (String message) => print('[beacon_bridge] $message'),
    onSelected: (String kind, Map<String, Object?> payload) {
      switch (kind) {
        case 'beacon.selected':
          unawaited(_handleSelected(payload, refDir: refDir, multiline: multiline));
        case 'beacon.selectedMany':
          unawaited(_handleSelectedMany(payload, refDir: refDir));
      }
    },
  );
  await client.start();

  // The tool has no other work to do — it just reacts to events until the
  // developer kills it.
  await Completer<void>().future;
}

Future<void> _handleSelected(Map<String, Object?> payload, {required Directory refDir, required bool multiline}) async {
  final WrittenSelection written = writeSelection(payload, refDir: refDir);
  final String pasteString = formatSelection(written.payload, jsonPath: written.jsonPath, multiline: multiline);

  await copyToClipboard(pasteString, onStatus: (String message) => print('[beacon_bridge] $message'));

  final Map<String, Object?>? target = written.payload['target'] as Map<String, Object?>?;
  print('[ref] ${target?['widget']} @ ${target?['file']}:${target?['line']}');
}

Future<void> _handleSelectedMany(Map<String, Object?> payload, {required Directory refDir}) async {
  final List<Object?> items = payload['items'] as List<Object?>? ?? const <Object?>[];
  final List<({Map<String, Object?> payload, String jsonPath})> written =
      <({Map<String, Object?> payload, String jsonPath})>[];
  for (final Object? item in items) {
    if (item is! Map<String, Object?>) continue;
    final WrittenSelection selection = writeSelection(item, refDir: refDir);
    written.add((payload: selection.payload, jsonPath: selection.jsonPath));
  }
  if (written.isEmpty) return;

  final String pasteString = formatMultiSelection(written);
  await copyToClipboard(pasteString, onStatus: (String message) => print('[beacon_bridge] $message'));
  print('[ref] ${written.length} selections combined');
}

String? _argValue(List<String> arguments, String flag) {
  final String prefix = '$flag=';
  for (final String arg in arguments) {
    if (arg.startsWith(prefix)) return arg.substring(prefix.length);
  }
  return null;
}
