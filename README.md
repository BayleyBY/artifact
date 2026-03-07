# GPU Wall

Six shadow-boxed graphics cards spanning 2003–2013, each paired with an NFC tag that opens a mobile page telling its story — and comparing it to the visitor's own phone.

## Pages

| Card | File | NFC URL |
|------|------|---------|
| NVIDIA GeForce FX 5600 (2003) | `fx5600.html` | `https://bayleyby.github.io/gpu-wall/fx5600.html` |
| ATI Radeon 9550 (2004) | `radeon9550.html` | `https://bayleyby.github.io/gpu-wall/radeon9550.html` |
| NVIDIA GeForce 7800 GS (2006) | `7800gs.html` | `https://bayleyby.github.io/gpu-wall/7800gs.html` |
| AMD Radeon HD 2900 XT (2007) | `hd2900xt.html` | `https://bayleyby.github.io/gpu-wall/hd2900xt.html` |
| AMD Radeon HD 5750 (2009) | `hd5750.html` | `https://bayleyby.github.io/gpu-wall/hd5750.html` |
| NVIDIA GeForce GTX 760 FTW (2013) | `gtx760.html` | `https://bayleyby.github.io/gpu-wall/gtx760.html` |

## Hosting on GitHub Pages

1. Create a new repo: `github.com/BayleyBY/gpu-wall`
2. Push this folder to the `main` branch
3. Go to Settings → Pages → Source: `main` branch, `/ (root)`
4. Site will be live at `https://bayleyby.github.io/gpu-wall/`

```bash
cd /Users/rhea/.openclaw/workspace/gpu-wall
git init
git add .
git commit -m "Initial GPU Wall site"
gh repo create BayleyBY/gpu-wall --public --source=. --push
```

Then enable GitHub Pages in the repo settings.

## NFC Tags

Program each tag with its card's URL. Any NFC-writeable tag works (NTAG213 is cheap and widely available). Recommended app: **NFC Tools** (iOS/Android).

## How device detection works

When a visitor taps the tag, `device.js` reads their browser's User-Agent string and screen resolution to identify their phone model and look up its GPU performance (approximate TFLOPS). It then calculates a multiplier and animates it on screen.

- iPhone detection: screen resolution + iOS version → chip (A9 through A18 Pro)
- Android detection: model string from User-Agent → chipset database
- Desktop visitors: see a generic comparison message

All detection runs client-side — no server, no analytics, no tracking.

## Structure

```
gpu-wall/
├── index.html          Overview / collection landing page
├── fx5600.html
├── radeon9550.html
├── 7800gs.html
├── hd2900xt.html
├── hd5750.html
├── gtx760.html
├── css/
│   └── style.css       Shared styles
└── js/
    ├── device.js       Device detection + GPU database
    └── card.js         Card page logic (comparison, animation)
```
