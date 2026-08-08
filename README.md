# beacon_bridge

The desktop companion for the [`beacon_widget`](https://pub.dev/packages/beacon_widget) Flutter package.

`beacon_widget` lets you tap a widget in your running app. `beacon_bridge` receives that selection on
your development machine, saves it, and copies a paste-ready reference to your clipboard:

```
[ref] ElevatedButton @ lib/features/pos/widgets/checkout_bar.dart:142 · 180×48 · bg=colorScheme.primary · radius=8 · parent Row:130 · details: .ref/sel-a3f2.json
```

Paste that into Cursor, Claude Code, Codex CLI, or any other coding agent.

## Install

```bash
dart pub global activate beacon_bridge
```

## Usage

Add `beacon_widget` to your Flutter app first — see
[its documentation](https://pub.dev/packages/beacon_widget) for the one-line setup.

Then, from your project root, run your app with the VM service address written to a file:

```bash
flutter run --vmservice-out-file=.ref/vm.json
```

And in a second terminal, from the same directory:

```bash
beacon_bridge --vmservice-out-file=.ref/vm.json
```

Leave it running. It reconnects on its own across hot restarts and app relaunches.

`beacon_bridge` attaches to a `flutter run` you started yourself rather than launching one, so
it works with whatever flavor, device or run configuration you already use.

## Options

| Flag | Default | Description |
|---|---|---|
| `--vmservice-out-file=<path>` | `.ref/vm.json` | The file to watch for your app's VM service address. Must match the path passed to `flutter run`. |
| `--format=multiline` | single-line | Splits the reference across several lines. |

Single-line is the default because many chat inputs send the message on a newline. For terminal
agents that handle newlines, `--format=multiline` is easier to read:

```
[ref] ElevatedButton · lib/features/pos/widgets/checkout_bar.dart:142
180×48 · bg=colorScheme.primary · radius=8 · parent Row:130
→ .ref/sel-a3f2.json
```

Selecting several widgets in the app and sending them together copies one combined reference
listing each of them, one per line, in both formats.

## Output

Every selection writes two files into `.ref/`:

- `sel-<id>.json` — the full payload: source location, resolved theme properties, geometry,
  constraints, enclosing route and state, and the ancestor chain.
- `sel-<id>.png` — a screenshot of the widget, cropped from the live frame.

The clipboard line links to the JSON file, so an agent can read the full detail when the summary
isn't enough.

Add `.ref/` to your `.gitignore`. `beacon_bridge` prints a warning at startup if it looks
missing.

## Housekeeping

- **Your clipboard is overwritten on every selection**, with no undo. Each copy prints a
  confirmation so it's never silent.
- Files in `.ref/` older than an hour are deleted at startup and every ten minutes while running.

## Requirements

Dart SDK 3.10.8 or newer.

Runs on macOS, Linux and Windows. Clipboard access shells out to `pbcopy`, `xclip` and `clip`
respectively — there's no clipboard dependency, Accessibility grant or permission prompt
involved. On Linux, install `xclip` if you don't already have it.

## Troubleshooting

**It sits on "Watching .ref/vm.json for the VM service address…" and never connects**

The file it's watching is never being written, which means `--vmservice-out-file` isn't reaching
`flutter run`. If you launch from an IDE, add it to your run configuration:

- **Android Studio / IntelliJ** — *Run* → *Edit Configurations…* → select your Flutter
  configuration → **Additional run args** → add `--vmservice-out-file=.ref/vm.json`.

  (**Additional run args** and *Attach args* are different fields; the latter only applies to
  Flutter Attach.)

- **VS Code** — in `.vscode/launch.json`:

  ```json
  {
    "name": "Flutter (with beacon)",
    "type": "dart",
    "request": "launch",
    "args": ["--vmservice-out-file=.ref/vm.json"]
  }
  ```

Use the same path in both places.

**"Could not copy to clipboard"**

The relevant system utility isn't available. On Linux, install `xclip`.

## Developing locally

Running from a checkout rather than pub.dev:

```bash
dart pub global activate --source path /path/to/beacon_bridge
dart pub global run beacon_bridge --vmservice-out-file=.ref/vm.json
```

A path activation doesn't put a `beacon_bridge` command on your `PATH`, so `dart pub global run`
is required. It re-resolves against the source each time, picking up local edits without
re-activating.

## License

MIT
