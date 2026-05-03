// utils/promptBuilder.js

const TAG_DESCRIPTIONS = {
  screen_time_high: "terlalu lama menatap layar HP/gadget",
  notification_overload: "terlalu banyak notifikasi yang mengganggu fokus",
  sleep_low: "kurang tidur",
  sleep_bad_quality: "kualitas tidur yang buruk",
  anxiety_high: "tingkat kecemasan yang tinggi",
  depression_high: "tanda-tanda depresi yang perlu diperhatikan",
  stress_high: "tingkat stres yang tinggi",
  happiness_low: "tingkat kebahagiaan yang rendah",
  general: "gaya hidup digital yang perlu diseimbangkan",
};

function buildPrompt({ score, category, penyebab, data }) {
  const penyebabKalimat = penyebab
    .map((tag) => `- ${tag}: ${TAG_DESCRIPTIONS[tag] || tag}`)
    .join("\n");

  const contohOutput = penyebab
    .map(
      (tag) =>
        `    { "tag": "${tag}", "isi": "saran santai spesifik untuk ${TAG_DESCRIPTIONS[tag] || tag}" }`,
    )
    .join(",\n");

  return `
Kamu adalah asisten kesehatan digital yang ramah, santai, dan supportif — seperti teman yang peduli.

User punya skor ketergantungan digital: ${score} (kategori: ${category}).

Penyebab yang terdeteksi:
${penyebabKalimat}

Data kondisi user:
- Pakai HP: ${data.device_hours_per_day ?? "-"} jam/hari
- Media sosial: ${data.social_media_mins ?? "-"} menit/hari
- Tidur: ${data.sleep_hours ?? "-"} jam/hari
- Kualitas tidur: ${data.sleep_quality ?? "-"} dari 5
- Notifikasi: ${data.notifications_per_day ?? "-"} per hari
- Stres: ${data.stress_level ?? "-"} dari 10
- Kecemasan: ${data.anxiety_score ?? "-"}
- Depresi: ${data.depression_score ?? "-"}
- Kebahagiaan: ${data.happiness_score ?? "-"} dari 10

Tugasmu:
- Tulis "pembukaan": 2-3 kalimat santai yang menjelaskan hasil skor ketergantungan digital user dan menyebutkan semua penyebab yang terdeteksi — seperti teman yang lagi ngasih tau kondisi kamu
- Tulis "rekomendasi": array berisi saran TERPISAH untuk SETIAP penyebab, spesifik ke penyebabnya masing-masing, 1-2 kalimat santai per penyebab
- Kalau ada tanda depresi/kecemasan, singgung dengan lembut
- Jangan diagnosis medis, jangan menggurui

Output HARUS dalam format JSON (tanpa teks apapun di luar JSON):
{
  "penyebab": ${JSON.stringify(penyebab)},
  "pembukaan": "2-3 kalimat santai tentang hasil skor dan ringkasan semua penyebab",
  "rekomendasi": [
${contohOutput}
  ]
}
`.trim();
}

module.exports = { buildPrompt };
