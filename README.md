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

This puts a `beacon_bridge` executable in `~/.pub-cache/bin`, which needs to be on your `PATH`.
If your shell reports `command not found: beacon_bridge`, add it:

```bash
# ~/.zshrc or ~/.bashrc
export PATH="$PATH":"$HOME/.pub-cache/bin"
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

## IDE setup

If you launch your app from the IDE's Run or Debug button rather than the terminal, there are
two things to set up: making the IDE pass `--vmservice-out-file`, and running the bridge
alongside it.

### Android Studio / IntelliJ

**1. Pass the flag to your app.** *Run* → *Edit Configurations…* → select your Flutter
configuration → put this in **Additional run args**:

```
--vmservice-out-file=.ref/vm.json
```

Make sure it's **Additional run args** and not *Attach args* — they're separate fields, and the
latter only applies to Flutter Attach. A flag in the wrong box silently does nothing, which
looks exactly like the bridge failing to connect.

**2. Run the bridge.** The quickest way is the built-in terminal: *View* → *Tool Windows* →
*Terminal*, then:

```bash
beacon_bridge --vmservice-out-file=.ref/vm.json
```

To get a Run button for it instead, add a run configuration: *Run* → *Edit Configurations…* →
**+** → **Shell Script** → set *Execution* to *Script text*, with:

```
beacon_bridge --vmservice-out-file=.ref/vm.json
```

Set the working directory to your project root. You can then start it from the configuration
dropdown and leave it running across app restarts.

### VS Code

**1. Pass the flag to your app,** in `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (with beacon)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": ["--vmservice-out-file=.ref/vm.json"]
    }
  ]
}
```

**2. Run the bridge** from the integrated terminal, or define it as a task in
`.vscode/tasks.json` so it starts with the project:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "beacon_bridge",
      "type": "shell",
      "command": "beacon_bridge --vmservice-out-file=.ref/vm.json",
      "isBackground": true,
      "problemMatcher": [],
      "runOptions": { "runOn": "folderOpen" },
      "presentation": { "panel": "dedicated", "reveal": "silent" }
    }
  ]
}
```

`runOn: folderOpen` starts the bridge when you open the project, independently of debugging.
Prefer it over `preLaunchTask`: the bridge runs indefinitely and never signals completion, so
VS Code would wait on it forever before launching your app.

Either way, use the same path in both places — the flag and the bridge are two ends of one
handshake.

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
`flutter run`. Launching from an IDE's Run button won't pass it unless you've added it to the
run configuration — see [IDE setup](#ide-setup).

To confirm that's the cause, run your app from the terminal instead:

```bash
flutter run --vmservice-out-file=.ref/vm.json
```

If the bridge connects that way, the flag isn't reaching `flutter run` from your IDE.

**`command not found: beacon_bridge`**

`~/.pub-cache/bin` isn't on your `PATH` — see [Install](#install).

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
