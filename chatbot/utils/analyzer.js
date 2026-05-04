// utils/analyzer.js

function analyze(data) {
  let factors = [];

  const hours = data.device_hours_per_day ?? data.raw?.device_hours_per_day;
  const sleep = data.sleep_hours ?? data.raw?.sleep_hours;
  const depress = data.depression_score ?? data.raw?.depression_score;
  const socmed = data.social_media_mins ?? data.raw?.social_media_mins;
  const focus = data.focus_score ?? data.raw?.focus_score;

  if (hours > 7) {
    factors.push("Penggunaan HP terlalu lama");
  }

  if (sleep < 6) {
    factors.push("Waktu tidur kurang");
  }

  if (depress !== null && depress !== undefined && depress > 6) {
    factors.push("Tingkat depresi tinggi");
  }

  if (socmed > 300) {
    factors.push("Penggunaan media sosial berlebihan");
  }

  if (focus !== null && focus !== undefined && focus < 30) {
    factors.push("Fokus rendah");
  }

  return factors;
}

module.exports = { analyze };
