// services/mlService.js
const XLSX = require("xlsx");
const path = require("path");

// Load workbook sekali saja saat startup
const workbook = XLSX.readFile(path.join(__dirname, "../data/Data.xlsx"));
const sheet = workbook.Sheets[workbook.SheetNames[0]];
const allRows = XLSX.utils.sheet_to_json(sheet);

/**
 * Cari baris dari Excel berdasarkan id user.
 * Kalau tidak ada id, gunakan data dari req.body langsung
 * tapi hitung score dari digital_dependence_score di Excel
 * sebagai referensi distribusi.
 */
async function getMLResult(data) {
  // Kalau ada user_id, cari langsung dari dataset
  if (data.user_id) {
    const row = allRows.find((r) => r.id === Number(data.user_id));
    if (row) {
      return buildResult(row);
    }
  }

  // Fallback: hitung score dari input manual (mirip rumus di dataset)
  const score = computeScore(data);
  const category = scoreToCategory(score);

  return { score, category };
}

function buildResult(row) {
  const score = row.digital_dependence_score ?? computeScore(row);
  const category = scoreToCategory(score);

  return {
    score: parseFloat(score.toFixed(2)),
    category,
    // data tambahan dari Excel yang akan dipakai promptBuilder
    depression_score: row.depression_score ?? null,
    anxiety_score: row.anxiety_score ?? null,
    happiness_score: row.happiness_score ?? null,
    focus_score: row.focus_score ?? null,
    high_risk_flag: row.high_risk_flag ?? 0,
    // expose raw data supaya analyzer & promptBuilder bisa pakai
    raw: row,
  };
}

function computeScore(data) {
  // Estimasi sederhana kalau tidak ada user_id
  let score = 0;
  const hours = data.device_hours_per_day ?? 0;
  const socmed = data.social_media_mins ?? 0;
  const sleep = data.sleep_hours ?? 8;
  const notif = data.notifications_per_day ?? 0;

  score += Math.min(hours * 5, 40); // max 40
  score += Math.min(socmed / 15, 20); // max 20
  score += Math.max(0, (8 - sleep) * 3); // max ~24 kalau tidur 0
  score += Math.min(notif / 20, 15); // max 15
  return Math.min(Math.round(score), 100);
}

function scoreToCategory(score) {
  if (score <= 40) return "Rendah";
  if (score <= 70) return "Sedang";
  return "Tinggi";
}

module.exports = { getMLResult };
