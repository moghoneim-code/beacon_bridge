# Example

A full session, from a clean project to a reference on your clipboard.

## Setup

Add [`beacon_widget`](https://pub.dev/packages/beacon_widget) to the Flutter app you want to
inspect, and wrap it once:

```dart
import 'package:beacon_widget/beacon_widget.dart';

MaterialApp(
  builder: (context, child) => Beacon.attach(child!),
  home: const MyHomePage(),
)
```

Install this CLI:

```bash
dart pub global activate beacon_bridge
```

## Running

Two terminals, both in your Flutter project's root.

**Terminal 1** — your app, with the VM service address written to a file:

```bash
flutter run --vmservice-out-file=.ref/vm.json
```

**Terminal 2** — the bridge, watching that same file:

```bash
beacon_bridge --vmservice-out-file=.ref/vm.json
```

It prints its startup banner and waits:

```
beacon_bridge — attaches to a flutter run you started yourself.
Start (or restart) your app with:
  flutter run --vmservice-out-file=.ref/vm.json

[beacon_bridge] Watching .ref/vm.json for the VM service address...
[beacon_bridge] Connected to ws://127.0.0.1:54321/abc123=/ws
```

## Selecting a widget

In the app, tap the beacon button to enter select mode, then tap a widget. The bridge prints:

```
[beacon_bridge] Copied to clipboard (replaced whatever was there before).
[ref] ElevatedButton @ lib/features/pos/widgets/checkout_bar.dart:142
```

Your clipboard now holds:

```
[ref] ElevatedButton @ lib/features/pos/widgets/checkout_bar.dart:142 · 180×48 · bg=colorScheme.primary · radius=8 · parent Row:130 · details: .ref/sel-a3f2.json
```

Paste that into your coding agent:

> Make this button full-width on tablets.
> [ref] ElevatedButton @ lib/features/pos/widgets/checkout_bar.dart:142 · 180×48 · …

The agent gets the file, the line, and the resolved theme token — no guessing which button you
meant.

## Selecting several at once

Tap several widgets, then tap the **Tap to send N** pill above the beacon button:

```
[beacon_bridge] Copied to clipboard (replaced whatever was there before).
[ref] 3 selections combined
```

The clipboard holds one reference per line, useful for "these three should share a style".

## Multi-line output

For terminal agents that handle newlines:

```bash
beacon_bridge --vmservice-out-file=.ref/vm.json --format=multiline
```

```
[ref] ElevatedButton · lib/features/pos/widgets/checkout_bar.dart:142
180×48 · bg=colorScheme.primary · radius=8 · parent Row:130
→ .ref/sel-a3f2.json
```

## What's left on disk

```
.ref/
├── vm.json           # written by flutter run
├── sel-a3f2.json     # the full payload for one selection
└── sel-a3f2.png      # a cropped screenshot of that widget
```

Add `.ref/` to your `.gitignore`. Selections older than an hour are pruned automatically.
