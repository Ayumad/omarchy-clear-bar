<p align="center">
  <img src="preview.png" alt="Clear Bar logo" width="260">
</p>

<h1 align="center">Clear Bar</h1>

<p align="center">
  Adaptive transparency for the Omarchy status bar.
</p>

<p align="center">
  <a href="#install">Install</a> · <a href="#how-it-works">How it works</a> · <a href="#remove">Remove</a>
</p>

Clear Bar makes the stock Omarchy bar transparent whenever the active workspace is empty and restores its normal opaque appearance whenever windows are present. It listens directly to Hyprland's event socket and changes the live bar surface in memory—there is no polling, configuration rewrite, or shell reload in the hot path.

Clear Bar takes inspiration from [TranslucentTB](https://github.com/TranslucentTB/TranslucentTB), one of the most polished examples of adaptive taskbar transparency on Windows, reimagined for Omarchy and Hyprland.

## Highlights

- Transparent on an empty workspace; opaque when you are working.
- Preserves Omarchy's built-in bar, layout, icons, widgets, and interactions.
- Uses a self-contained Omarchy service plugin—no manual scripts or autostart configuration.
- Restores the normal opaque bar automatically when disabled or removed.

## Install

```bash
omarchy plugin add https://github.com/Ayumad/omarchy-clear-bar.git --enable
```

The plugin starts immediately. Open an empty workspace to see the transparent bar; opening a window restores the normal opaque bar.

## How it works

Hyprland publishes workspace and window changes through its event socket. Clear Bar listens to that stream, reads the active workspace's window count, and updates the already-running Omarchy bar directly:

| Active workspace | Bar appearance |
| --- | --- |
| Empty | Transparent |
| One or more windows | Opaque |

When transparent, the bar keeps your current theme's normal text color for reliable, immediate rendering. This intentionally avoids Omarchy's slower wallpaper-specific contrast probe.

## Requirements

- Omarchy Quattro with the stock `omarchy.bar` active.
- Hyprland, `hyprctl`, and `socat` (all present in a standard Omarchy session).

## Remove

```bash
omarchy plugin disable io.github.ayumad.clear-bar
omarchy plugin remove io.github.ayumad.clear-bar --yes
```

Disabling the plugin returns the bar to its normal opaque state.

## Privacy and security

Clear Bar makes no network requests, collects no data, and does not alter your Hyprland or Omarchy configuration. It reads Hyprland's local event socket and controls only the in-memory opacity of the running stock bar.

## Development

```bash
omarchy plugin validate .
```

## License

MIT. See [LICENSE](LICENSE).
