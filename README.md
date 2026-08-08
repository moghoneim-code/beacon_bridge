The desktop half of [`beacon`](https://pub.dev/packages/beacon): attaches to a `flutter run` you
started yourself, and on every tap writes `.ref/sel-<id>.json` + `.png`, copies a paste-ready
reference to your clipboard, and prints a one-line confirmation.

Works on macOS, Linux and Windows — it shells out to `pbcopy`, `xclip` or `clip` respectively,
so there's no clipboard package, no Accessibility grant and no TCC prompt.

## Install

**Once this is published to pub.dev:**

```bash
dart pub global activate beacon_bridge
```

That creates a `beacon_bridge` command directly on your `PATH`.

**Before then — installing from a local checkout (e.g. this repo, or a sibling
`packages/beacon_bridge` directory) — the command is different:**

```bash
dart pub global activate --source path /path/to/packages/beacon_bridge
```

This registers the package but, unlike a pub.dev activation, deliberately does **not** create
a `beacon_bridge` shim on your `PATH` — a path-based activation is meant for a package whose
source can change at any time, so there's no static command to point at. Run it with:

```bash
dart pub global run beacon_bridge --vmservice-out-file=.ref/vm.json
```

`dart pub global run` re-resolves against the live source every time, so it always reflects
your latest local edits without needing to re-activate. This is the form to use for as long as
you're installing from a local path rather than pub.dev — the rest of this README uses the
short `beacon_bridge ...` form for readability, but substitute `dart pub global run
beacon_bridge ...` for it if that's how you installed.

## Usage

`beacon_bridge` finds your app's Dart VM Service by watching a file `flutter run` writes to —
it never spawns `flutter run` itself, so it works with whatever flavor/run-config you already
use.

```bash
flutter run --vmservice-out-file=.ref/vm.json
```

```bash
beacon_bridge --vmservice-out-file=.ref/vm.json
# or, if installed from a local path: dart pub global run beacon_bridge --vmservice-out-file=.ref/vm.json
```

Run both from your Flutter project's root, in separate terminals. `beacon_bridge` reconnects
automatically across hot restarts and app relaunches — leave it running.

### IDE setup (Android Studio / VS Code)

**The `--vmservice-out-file` flag has to actually reach `flutter run`.** Clicking your IDE's
Run/Debug button launches `flutter run` the same way the terminal does — same VM Service, same
USB tunnel — but *without* that flag by default. If `beacon_bridge` never seems to connect (it
just sits on "Watching .ref/vm.json for the VM service address..." forever), this is almost
always why: the file it's watching for is never getting written, because nothing told
`flutter run` to write it.

Fix it once, per run configuration:

- **Android Studio / IntelliJ:** *Run* → *Edit Configurations…* → select your Flutter app's
  configuration → **Additional run args** → add `--vmservice-out-file=.ref/vm.json`.
- **VS Code:** in `.vscode/launch.json`, add an `args` array to the configuration you use to
  launch the app:

  ```json
  {
    "name": "Flutter (with beacon)",
    "type": "dart",
    "request": "launch",
    "args": ["--vmservice-out-file=.ref/vm.json"]
  }
  ```

Either way, use the *same* path you pass to `beacon_bridge --vmservice-out-file=...` — they're
just two ends of the same handshake.

### Paste format

Default is single-line (some chat inputs treat a newline as "send"):

```
[ref] ElevatedButton @ lib/features/pos/widgets/checkout_bar.dart:142 · 180×48 · bg=colorScheme.primary · radius=8 · parent Row:130 · details: .ref/sel-a3f2.json
```

Pass `--format=multiline` for terminal agents that handle it fine:

```
[ref] ElevatedButton · lib/features/pos/widgets/checkout_bar.dart:142
180×48 · bg=colorScheme.primary · radius=8 · parent Row:130
→ .ref/sel-a3f2.json
```

Tapping several widgets and broadcasting them together (`beacon`'s selection stack) copies one
combined reference listing every selection, one per line, regardless of this flag.

### Housekeeping

- `beacon_bridge` overwrites your clipboard on every tap — there's no undo. It prints what it
  did (`Copied to clipboard (replaced whatever was there before).`) so this is never silent.
- `.ref/sel-*` older than an hour are pruned on startup, and again every 10 minutes for as long
  as `beacon_bridge` keeps running — a long session tapping through the app doesn't just build
  up `.ref/` until you next restart it.
- Add `.ref/` to your `.gitignore` — `beacon_bridge` warns once at startup if it looks missing.
