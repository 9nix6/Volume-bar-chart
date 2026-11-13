# Volume Bar Chart — MetaTrader 5 SDK (superseded)

> **This repository is no longer maintained.** Volume bar charts were merged into the
> **X Tick & Volume Bar Chart** indicator, and the SDK moved with them:
>
> **→ [9nix6/X-Tick-Chart](https://github.com/9nix6/X-Tick-Chart)**

## What to use instead

| You want | Go to |
|---|---|
| The SDK — headers, ported indicators and EAs for tick *and* volume bar charts | [X-Tick-Chart](https://github.com/9nix6/X-Tick-Chart) · [latest release](https://github.com/9nix6/X-Tick-Chart/releases/latest) |
| The indicator, az-invest.eu edition | [Tick Chart & Volume Chart for MetaTrader 5](https://www.az-invest.eu/tick-chart-and-volume-chart-for-mt5) |
| The indicator, MQL5 Market edition | X Tick Chart, on the MQL5 Market |

## Why the code was removed

The headers that used to live here were written for Volume Bar Chart 1.10 (2020). The indicator's
settings layout has changed since, and the SDK shares that layout with the indicator through a
binary settings file — an EA built against the old headers reads the current indicator's settings
incorrectly. Leaving them downloadable would only produce EAs that fail in ways that are hard to
diagnose.

The last version of those files remains available as the
[1.10 release](https://github.com/9nix6/Volume-bar-chart/releases/tag/1.10) and in this
repository's history, for anyone still running the 2020 indicator.

## License

Released under the [GNU General Public License v3](LICENSE).
