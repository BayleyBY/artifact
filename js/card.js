/**
 * card.js — GPU Wall card page logic
 * Runs on each individual card page.
 * Expects window.CARD_DATA to be defined by the page.
 */

document.addEventListener('DOMContentLoaded', () => {
  const card = window.CARD_DATA;
  if (!card) return;

  // ── Render specs ──────────────────────────────────────────────────────────
  const specsEl = document.getElementById('specs-rows');
  if (specsEl) {
    specsEl.innerHTML = card.specs
      .map(s => `
        <div class="spec-row">
          <span class="spec-label">${s.label}</span>
          <span class="spec-value">${s.value}</span>
        </div>`).join('');
  }

  // ── Render story ──────────────────────────────────────────────────────────
  const storyEl = document.getElementById('story-text');
  if (storyEl) {
    storyEl.innerHTML = card.story
      .map(p => `<p>${p}</p>`).join('');
  }

  // ── Render games ─────────────────────────────────────────────────────────
  const gamesEl = document.getElementById('games-list');
  if (gamesEl && card.games) {
    gamesEl.innerHTML = card.games.map(g => `
      <div class="game-row">
        <span class="game-name">${g.name}</span>
        <span class="game-year">${g.year}</span>
        <span class="game-note">${g.note}</span>
      </div>`).join('');
  }

  // ── Device detection & comparison ─────────────────────────────────────────
  const compEl = document.getElementById('comparison-content');
  if (!compEl) return;

  const device = detectDevice();

  if (!device) {
    // Desktop visitor
    compEl.innerHTML = `
      <p class="comparison-desktop">
        Tap this tag with your phone to see how your device compares to this card.<br><br>
        <strong>Quick stat:</strong> A current flagship phone's GPU delivers roughly
        ${formatTflops(4.0)} TFLOPS of compute. This card managed
        ${formatTflops(card.tflops)} TFLOPS.
      </p>`;
    return;
  }

  const multiplier = Math.round(device.tflops / card.tflops);
  const approxNote = device.approximate
    ? ' <span style="font-size:11px;color:var(--text-dim)">(estimated)</span>' : '';

  // Bar fill: cap at 98% for huge multipliers, min 2%
  const barPct = Math.min(98, Math.max(2, (card.tflops / device.tflops) * 100));

  // Power comparison sentence
  const powerLine = card.powerWatts
    ? `<strong>${card.name}</strong> drew ${card.powerWatts}W from the wall. 
       Your phone's entire chip uses under 5W at peak.`
    : '';

  // What year phone roughly matched this card
  const matchYear = estimateMatchYear(card.tflops);

  compEl.innerHTML = `
    <div class="comparison-label">Your device</div>
    <div class="comparison-device">
      ${device.model}${approxNote}
      <span class="chip-name">${device.chipName} · ~${formatTflops(device.tflops)}</span>
    </div>

    <div class="multiplier-row">
      <div class="multiplier-number" id="multiplier-num">—</div>
      <div class="multiplier-label">× more<br>GPU power</div>
    </div>

    <div class="comparison-bar">
      <div class="comparison-bar-fill" id="bar-fill"></div>
    </div>

    <div class="comparison-detail">
      This card delivered <strong>${formatTflops(card.tflops)}</strong>.
      Your ${device.model.replace('approximate ', '')} delivers
      <strong>${formatTflops(device.tflops)}</strong>.
      ${matchYear ? `A phone reached this card's performance level around <strong>${matchYear}</strong>.` : ''}
      ${powerLine ? `<br><br>${powerLine}` : ''}
    </div>`;

  // Animate multiplier count-up
  animateCounter('multiplier-num', multiplier, 900);

  // Animate bar (this card's share of the device's power)
  setTimeout(() => {
    const bar = document.getElementById('bar-fill');
    if (bar) bar.style.width = barPct + '%';
  }, 200);
});

// ── Helpers ───────────────────────────────────────────────────────────────────

function formatTflops(t) {
  if (t < 0.1)  return (t * 1000).toFixed(0) + ' GFLOPS';
  if (t < 1.0)  return t.toFixed(2) + ' TFLOPS';
  return t.toFixed(1) + ' TFLOPS';
}

function estimateMatchYear(cardTflops) {
  // Rough table: when did a mainstream phone hit this TFLOPS level?
  const timeline = [
    { tflops: 4.0, year: 2024 }, { tflops: 2.7, year: 2023 },
    { tflops: 2.2, year: 2022 }, { tflops: 2.0, year: 2021 },
    { tflops: 1.6, year: 2020 }, { tflops: 1.0, year: 2019 },
    { tflops: 0.69, year: 2018 }, { tflops: 0.43, year: 2017 },
    { tflops: 0.25, year: 2016 }, { tflops: 0.17, year: 2015 },
  ];
  for (const entry of timeline) {
    if (cardTflops <= entry.tflops) return entry.year;
  }
  return null;
}

function animateCounter(id, target, durationMs) {
  const el = document.getElementById(id);
  if (!el) return;
  const start = performance.now();
  function step(now) {
    const t = Math.min(1, (now - start) / durationMs);
    const ease = 1 - Math.pow(1 - t, 3); // ease-out cubic
    el.textContent = Math.round(ease * target) + '×';
    if (t < 1) requestAnimationFrame(step);
  }
  requestAnimationFrame(step);
}
