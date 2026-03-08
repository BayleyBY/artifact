# Artifact

A shadow box art installation featuring six graphics cards spanning 2003–2013. Each card is paired with an NFC tag that opens a mobile page telling its story — and comparing it to the visitor's own phone.

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

Over this decade: **56× more transistors · 16× more memory · 90× more compute.**

---

## NFC Tag URLs

Program one tag per card using [NFC Tools](https://www.wakdev.com/en/apps/nfc-tools.html) (iOS/Android). NTAG213 stickers work well.

| Card | URL |
|------|-----|
| GeForce FX 5600 | `https://bayleyby.github.io/artifact/fx5600.html` |
| Radeon 9550 | `https://bayleyby.github.io/artifact/radeon9550.html` |
| GeForce 7800 GS | `https://bayleyby.github.io/artifact/7800gs.html` |
| Radeon HD 2900 XT | `https://bayleyby.github.io/artifact/hd2900xt.html` |
| Radeon HD 5750 | `https://bayleyby.github.io/artifact/hd5750.html` |
| GeForce GTX 760 FTW | `https://bayleyby.github.io/artifact/gtx760.html` |

---

## What each card page includes

- **The story** — narrative context for the card's place in GPU history
- **Games of the era** — 3 games played on this card, each linking to its YouTube trailer
- **Your device comparison** — detects the visitor's phone and compares its GPU performance to the card
- **Specs** — transistors, memory, interface, DirectX, performance
- **The big picture** — link to a conclusion page comparing the visitor's phone to all 6 cards combined

---

## Device Detection

When a visitor taps the NFC tag, `device.js` identifies their phone using User-Agent and screen resolution, then looks up its GPU performance.

- **iPhone:** screen resolution + iOS version → chip (A9 through A18 Pro)
- **Android:** model string from User-Agent → chipset database (Snapdragon, Tensor, Exynos)
- **Desktop:** generic comparison message

All detection is client-side. No server, no analytics, no tracking.

---

## Print Labels

`labels.html` generates a print-ready sheet of six 6"×3" labels — one per card. Each label includes the card name, year, era, specs, and a TAP circle where the NFC sticker is placed.

Open `https://bayleyby.github.io/artifact/labels.html` in a browser and print at **100% scale, no page scaling**.

---

## File Structure

```
artifact/
├── index.html          Collection overview
├── fx5600.html
├── radeon9550.html
├── 7800gs.html
├── hd2900xt.html
├── hd5750.html
├── gtx760.html
├── conclusion.html     Combined comparison + closing essay
├── labels.html         Print-ready label sheet
├── css/
│   └── style.css
└── js/
    ├── device.js       Device detection + GPU database
    └── card.js         Card page rendering + animations
```
