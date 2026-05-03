// utils/tagMapper.js

function mapToTag(factor) {
  const map = {
    "Penggunaan HP terlalu lama": "screen_time_tinggi",
    "Waktu tidur kurang": "tidur_kurang",
    "Tingkat depresi tinggi": "depresi_tinggi", // ✅ baru
    "Penggunaan media sosial berlebihan": "socmed_berlebih", // ✅ baru
    "Fokus rendah": "fokus_rendah", // ✅ baru
  };

  return map[factor] || "general";
}

module.exports = { mapToTag };
