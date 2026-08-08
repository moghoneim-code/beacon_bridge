## 0.1.0

Initial release.

- Attaches to a `flutter run` you started yourself — it never spawns or wraps
  `flutter run`, so it works with whatever flavor, device or run configuration
  you already use.
- Discovers the Dart VM Service by watching the file `flutter run` writes with
  `--vmservice-out-file`, and reconnects automatically across hot restarts and
  app relaunches.
- Writes `.ref/sel-<id>.json` plus a cropped `.png` for every selection, and
  copies a compact, paste-ready `[ref] ...` line to your clipboard.
- `--format=multiline` for terminal agents that handle newlines; the default is
  single-line, since many chat inputs treat a newline as "send".
- Handles combined multi-widget selections from `beacon`'s selection stack.
- Housekeeping: prunes `.ref/sel-*` older than an hour, on startup and
  periodically while running; warns once if `.ref/` looks missing from your
  `.gitignore`.

Pairs with the [`beacon`](https://pub.dev/packages/beacon) Flutter package,
which provides the on-device half.
