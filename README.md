# Artifact

A shadow box art installation featuring eight graphics cards spanning 2003–2018. Each card is mounted in an 11×14 shadow box and paired with an NFC tag that opens a mobile page telling its story — and comparing it to the visitor's own phone.

**Live site:** https://bayleyby.github.io/artifact/

---

## The Collection

| Year | Card | Manufacturer | Era |
|------|------|-------------|-----|
| 2003 | GeForce FX 5600 | NVIDIA | Act I — The DirectX 9 Wars |
| 2004 | Radeon 9550 | ATI | Act I — The DirectX 9 Wars |
| 2006 | GeForce 7800 GS | NVIDIA | Act II — AGP's Last Stand |
| 2007 | Radeon HD 2900 XT | AMD / ATI | Act III — A New Slot, A New War |
| 2009 | Radeon HD 5750 | AMD | Act IV — The New World |
| 2013 | GeForce GTX 760 FTW | NVIDIA | Act V — The Compute Era |
| 2017 | GeForce GTX 1080 Ti | NVIDIA | Act VI — Pascal's Peak |
| 2018 | GeForce RTX 2080 | NVIDIA | Act VII — Light Learns to Bounce |

Over this era: **216× more transistors · 31× more memory · 400× more compute.**

### Wall layout

Cards are arranged in a 3×2 grid, reading left-to-right, top-to-bottom in chronological order:

```
Left Top:    FX 5600 (2003)       │  Middle Top:    7800 GS (2006)      │  Right Top:    HD 5750 (2009)
Left Bottom: Radeon 9550 (2004)   │  Middle Bottom: HD 2900 XT (2007)   │  Right Bottom: GTX 760 FTW (2013)
```

---

## NFC Tags

Tags used: **SwitchBot NTAG216**, 30mm diameter, 888 bytes.  
Program with [NFC Tools](https://www.wakdev.com/en/apps/nfc-tools.html) (iOS/Android) — Write → Add record → URL.

| Card | URL |
|------|-----|
| GeForce FX 5600 | `https://bayleyby.github.io/artifact/fx5600.html` |
| Radeon 9550 | `https://bayleyby.github.io/artifact/radeon9550.html` |
| GeForce 7800 GS | `https://bayleyby.github.io/artifact/7800gs.html` |
| Radeon HD 2900 XT | `https://bayleyby.github.io/artifact/hd2900xt.html` |
| Radeon HD 5750 | `https://bayleyby.github.io/artifact/hd5750.html` |
| GeForce GTX 760 FTW | `https://bayleyby.github.io/artifact/gtx760.html` |
| GeForce GTX 1080 Ti | `https://bayleyby.github.io/artifact/gtx1080ti.html` |
| GeForce RTX 2080 | `https://bayleyby.github.io/artifact/rtx2080.html` |

---

## What each card page includes

- **Photo** — picture of the actual card
- **The story** — narrative history, including physical/visual observations about the card itself
- **Games of the era** — 3 games played on this card, each linking to its YouTube trailer
- **Your device comparison** — detects the visitor's phone and compares its GPU to the card with an animated multiplier
- **Specs** — transistors, memory, interface, DirectX, performance
- **The big picture** — conclusion page comparing the visitor's phone to all 6 cards combined

---

## Device Detection

When a visitor taps the NFC tag, `device.js` identifies their phone using User-Agent and screen resolution, then looks up its GPU performance.

- **iPhone:** screen resolution + iOS version → chip (A9 through A18 Pro)
- **Android:** model string from User-Agent → chipset database (Snapdragon, Tensor, Exynos)
- **Desktop:** generic fallback message

All detection is client-side. No server, no analytics, no tracking.

---

## Physical Build

- **Shadow boxes:** Frametory 11×14, 2" interior depth, front-opening
- **NFC tags:** SwitchBot NTAG216, 30mm, programmed with NFC Tools
- **Labels:** 5"×3" printed cards with card name, year, era, specs, and NFC tap indicator
- **Label holders:** 3D printed at 35° wall angle — see `label-holder.scad`

### Print labels

Open `https://bayleyby.github.io/artifact/labels.html` and print at **100% scale, no page scaling**. Two labels per page, three pages total.

### Label holder (3D print)

`label-holder.scad` — wall-mounted holder, 35° angle, with a slot for the 5"×3" label and a 31mm recess for the NFC chip. Print in PLA or PETG, 20% infill, back face flat on the bed, no supports needed.

---

## File Structure

```
artifact/
├── index.html           Collection overview
├── fx5600.html
├── radeon9550.html
├── 7800gs.html
├── hd2900xt.html
├── hd5750.html
├── gtx760.html
├── conclusion.html      Combined phone comparison + closing essay
├── labels.html          Print-ready label sheet (5"×3", 2 per page)
├── label-holder.scad    OpenSCAD file for 3D printed label stand
├── images/
│   ├── fx5600.jpg
│   ├── radeon9550.jpg
│   ├── 7800gs.jpg
│   ├── hd2900xt.jpg
│   ├── hd5750.jpg
│   └── gtx760.jpg
├── css/
│   └── style.css
└── js/
    ├── device.js        Device detection + GPU database
    └── card.js          Card page rendering + animations
```
