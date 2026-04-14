/**
 * device.js — GPU Wall device detection
 * Identifies the visitor's phone and looks up its GPU performance
 * so we can compare it to the vintage card on the wall.
 */

// ─── GPU Performance Database ───────────────────────────────────────────────
// All TFLOPS values are approximate (FP32, rasterization-class workloads).
// Sources: Geekbench Metal scores, manufacturer benchmarks, community analysis.
// These are estimates for storytelling purposes, not precision specs.

const CHIP_DB = {
  // Apple A-series
  'A9':    { name: 'Apple A9',         tflops: 0.17, year: 2015 },
  'A10':   { name: 'Apple A10 Fusion', tflops: 0.25, year: 2016 },
  'A11':   { name: 'Apple A11 Bionic', tflops: 0.43, year: 2017 },
  'A12':   { name: 'Apple A12 Bionic', tflops: 0.69, year: 2018 },
  'A13':   { name: 'Apple A13 Bionic', tflops: 1.0,  year: 2019 },
  'A14':   { name: 'Apple A14 Bionic', tflops: 1.6,  year: 2020 },
  'A15':   { name: 'Apple A15 Bionic', tflops: 2.0,  year: 2021 },
  'A16':   { name: 'Apple A16 Bionic', tflops: 2.2,  year: 2022 },
  'A17':   { name: 'Apple A17 Pro',    tflops: 2.7,  year: 2023 },
  'A18':   { name: 'Apple A18',        tflops: 3.6,  year: 2024 },
  'A18P':  { name: 'Apple A18 Pro',    tflops: 4.3,  year: 2024 },

  // Snapdragon (Qualcomm)
  'SD_865':  { name: 'Snapdragon 865 (Adreno 650)',   tflops: 1.4, year: 2020 },
  'SD_888':  { name: 'Snapdragon 888 (Adreno 660)',   tflops: 1.8, year: 2021 },
  'SD_8G1':  { name: 'Snapdragon 8 Gen 1 (Adreno 730)', tflops: 2.4, year: 2022 },
  'SD_8G2':  { name: 'Snapdragon 8 Gen 2 (Adreno 740)', tflops: 3.8, year: 2023 },
  'SD_8G3':  { name: 'Snapdragon 8 Gen 3 (Adreno 750)', tflops: 4.8, year: 2024 },
  'SD_7G3':  { name: 'Snapdragon 7 Gen 3 (Adreno 720)', tflops: 2.0, year: 2024 },

  // Samsung Exynos
  'EX_2200': { name: 'Samsung Exynos 2200 GPU', tflops: 3.6, year: 2022 },
  'EX_2400': { name: 'Samsung Exynos 2400 GPU', tflops: 4.2, year: 2024 },

  // Google Tensor
  'TG2':  { name: 'Google Tensor G2 GPU', tflops: 1.5, year: 2022 },
  'TG3':  { name: 'Google Tensor G3 GPU', tflops: 2.0, year: 2023 },
  'TG4':  { name: 'Google Tensor G4 GPU', tflops: 2.5, year: 2024 },
};

// ─── iPhone Model → Chip ─────────────────────────────────────────────────────
// Detection: screen logical resolution (portrait) + iOS version
// Each entry: { w, h, iosMin, iosMax, model, chip }
// iosMin/iosMax are optional; if omitted, matches any iOS version.

const IPHONE_MAP = [
  // Unambiguous unique resolutions
  { w: 440, h: 956,  model: 'iPhone 16 Pro Max', chip: 'A18P' },
  { w: 402, h: 874,  model: 'iPhone 16 Pro',     chip: 'A18P' },

  // 430×932 — disambiguate by iOS version
  { w: 430, h: 932, iosMin: 18, model: 'iPhone 16 Plus',    chip: 'A18'  },
  { w: 430, h: 932, iosMin: 17, iosMax: 17, model: 'iPhone 15 Pro Max', chip: 'A17' },
  { w: 430, h: 932, iosMin: 16, iosMax: 16, model: 'iPhone 14 Pro Max', chip: 'A16' },
  { w: 430, h: 932, iosMin: 0,  iosMax: 15, model: 'iPhone 13 Pro Max', chip: 'A15' },

  // 393×852
  { w: 393, h: 852, iosMin: 18, model: 'iPhone 16',     chip: 'A18' },
  { w: 393, h: 852, iosMin: 17, iosMax: 17, model: 'iPhone 15 Pro', chip: 'A17' },
  { w: 393, h: 852, iosMin: 0,  iosMax: 16, model: 'iPhone 14 Pro', chip: 'A16' },

  // 428×926
  { w: 428, h: 926, iosMin: 16, model: 'iPhone 14 Plus',    chip: 'A15' },
  { w: 428, h: 926, iosMin: 15, iosMax: 15, model: 'iPhone 13 Pro Max', chip: 'A15' },
  { w: 428, h: 926, iosMin: 0,  iosMax: 14, model: 'iPhone 12 Pro Max', chip: 'A14' },

  // 390×844
  { w: 390, h: 844, iosMin: 16, model: 'iPhone 14',  chip: 'A15' },
  { w: 390, h: 844, iosMin: 15, iosMax: 15, model: 'iPhone 13', chip: 'A15' },
  { w: 390, h: 844, iosMin: 0,  iosMax: 14, model: 'iPhone 12', chip: 'A14' },

  // 375×812
  { w: 375, h: 812, iosMin: 15, model: 'iPhone 13 mini', chip: 'A15' },
  { w: 375, h: 812, iosMin: 14, iosMax: 14, model: 'iPhone 12 mini', chip: 'A14' },
  { w: 375, h: 812, iosMin: 13, iosMax: 13, model: 'iPhone 11 Pro', chip: 'A13' },
  { w: 375, h: 812, iosMin: 0,  iosMax: 12, model: 'iPhone X/XS',  chip: 'A11' },

  // 414×896 dpr=2 → XR/11
  { w: 414, h: 896, dpr: 2, iosMin: 13, model: 'iPhone 11', chip: 'A13' },
  { w: 414, h: 896, dpr: 2, iosMin: 0,  iosMax: 12, model: 'iPhone XR', chip: 'A12' },

  // 414×896 dpr=3 → 11 Pro Max / XS Max
  { w: 414, h: 896, dpr: 3, iosMin: 13, model: 'iPhone 11 Pro Max', chip: 'A13' },
  { w: 414, h: 896, dpr: 3, iosMin: 0,  iosMax: 12, model: 'iPhone XS Max', chip: 'A12' },

  // 414×736 → Plus models
  { w: 414, h: 736, iosMin: 11, model: 'iPhone 8 Plus', chip: 'A11' },
  { w: 414, h: 736, iosMin: 0,  iosMax: 10, model: 'iPhone 7 Plus', chip: 'A10' },

  // 375×667 → SE / 8 / 7 / 6s
  { w: 375, h: 667, iosMin: 15, model: 'iPhone SE (3rd gen)', chip: 'A15' },
  { w: 375, h: 667, iosMin: 13, iosMax: 14, model: 'iPhone SE (2nd gen)', chip: 'A13' },
  { w: 375, h: 667, iosMin: 11, iosMax: 12, model: 'iPhone 8', chip: 'A11' },
  { w: 375, h: 667, iosMin: 0,  iosMax: 10, model: 'iPhone 7/6s', chip: 'A10' },

  // 320×568 → SE 1st gen
  { w: 320, h: 568, model: 'iPhone SE (1st gen)', chip: 'A9' },
];

// ─── Android device model → chip ─────────────────────────────────────────────
// Keyed by partial model string (case-insensitive match against UA)

const ANDROID_MODELS = [
  // Samsung Galaxy S25 series
  { match: /SM-S93[1-6]/i,  model: 'Samsung Galaxy S25',       chip: 'SD_8G4'  }, // future-proofing
  // Samsung Galaxy S24 series
  { match: /SM-S92[1-8]/i,  model: 'Samsung Galaxy S24 series', chip: 'SD_8G3' },
  { match: /SM-S928/i,      model: 'Samsung Galaxy S24 Ultra',  chip: 'SD_8G3' },
  // Samsung Galaxy S23 series
  { match: /SM-S91[1-8]/i,  model: 'Samsung Galaxy S23 series', chip: 'SD_8G2' },
  { match: /SM-S918/i,      model: 'Samsung Galaxy S23 Ultra',  chip: 'SD_8G2' },
  // Samsung Galaxy S22 series
  { match: /SM-S90[1-8]/i,  model: 'Samsung Galaxy S22 series', chip: 'SD_8G1' },
  // Samsung Galaxy S21 series
  { match: /SM-G99[0-8]/i,  model: 'Samsung Galaxy S21 series', chip: 'SD_888' },
  // Google Pixel 9 series
  { match: /Pixel 9 Pro/i,  model: 'Google Pixel 9 Pro',  chip: 'TG4' },
  { match: /Pixel 9/i,      model: 'Google Pixel 9',      chip: 'TG4' },
  // Google Pixel 8 series
  { match: /Pixel 8 Pro/i,  model: 'Google Pixel 8 Pro',  chip: 'TG3' },
  { match: /Pixel 8/i,      model: 'Google Pixel 8',      chip: 'TG3' },
  // Google Pixel 7 series
  { match: /Pixel 7 Pro/i,  model: 'Google Pixel 7 Pro',  chip: 'TG2' },
  { match: /Pixel 7/i,      model: 'Google Pixel 7',      chip: 'TG2' },
  // OnePlus
  { match: /OnePlus 12/i,   model: 'OnePlus 12',   chip: 'SD_8G3' },
  { match: /OnePlus 11/i,   model: 'OnePlus 11',   chip: 'SD_8G2' },
];

// ─── Detection Functions ──────────────────────────────────────────────────────

function _detectiPhone(ua) {
  const iosMatch = ua.match(/OS (\d+)[_\.]/);
  const ios = iosMatch ? parseInt(iosMatch[1]) : 0;

  const w = Math.min(screen.width, screen.height);
  const h = Math.max(screen.width, screen.height);
  const dpr = window.devicePixelRatio || 2;

  for (const entry of IPHONE_MAP) {
    if (entry.w !== w || entry.h !== h) continue;
    if (entry.dpr !== undefined && Math.round(dpr) !== entry.dpr) continue;
    const min = entry.iosMin !== undefined ? entry.iosMin : 0;
    const max = entry.iosMax !== undefined ? entry.iosMax : 99;
    if (ios < min || ios > max) continue;
    return { model: entry.model, chip: entry.chip, type: 'iphone' };
  }

  // Fallback: iOS version bucket
  const fallbackChip =
    ios >= 18 ? 'A18' : ios >= 17 ? 'A17' : ios >= 16 ? 'A16' :
    ios >= 15 ? 'A15' : ios >= 14 ? 'A14' : ios >= 13 ? 'A13' : 'A12';
  return { model: 'iPhone', chip: fallbackChip, type: 'iphone', approximate: true };
}

function _detectAndroid(ua) {
  for (const entry of ANDROID_MODELS) {
    if (entry.match.test(ua)) {
      const chip = CHIP_DB[entry.chip] ? entry.chip : null;
      return { model: entry.model, chip, type: 'android' };
    }
  }

  // Try to extract a readable model name from UA
  const modelMatch = ua.match(/\(Linux; Android [\d.]+; ([^)]+?)\s*(?:Build|;)/i);
  const modelName = modelMatch ? modelMatch[1].trim() : 'Android device';

  // Guess chip from Android version
  const androidMatch = ua.match(/Android ([\d.]+)/i);
  const androidVer = androidMatch ? parseFloat(androidMatch[1]) : 0;
  const fallbackChip =
    androidVer >= 14 ? 'SD_8G3' : androidVer >= 13 ? 'SD_8G2' :
    androidVer >= 12 ? 'SD_8G1' : 'SD_888';

  return { model: modelName, chip: fallbackChip, type: 'android', approximate: true };
}

// ─── Main Export ──────────────────────────────────────────────────────────────

/**
 * detectDevice()
 * Returns: { model, chip, tflops, chipName, type, approximate }
 * or null if not a mobile device.
 */
function detectDevice() {
  const ua = navigator.userAgent;

  let result = null;

  if (/iPhone/.test(ua)) {
    result = _detectiPhone(ua);
  } else if (/Android/.test(ua)) {
    result = _detectAndroid(ua);
  } else {
    return null; // Desktop or unknown
  }

  if (!result) return null;

  const chipData = CHIP_DB[result.chip];
  if (!chipData) return null;

  return {
    model: result.model,
    chip: result.chip,
    chipName: chipData.name,
    tflops: chipData.tflops,
    chipYear: chipData.year,
    type: result.type,
    approximate: result.approximate || false,
  };
}
