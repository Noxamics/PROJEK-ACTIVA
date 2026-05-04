// ============================================================
// DUMMY SEED DATA — MongoDB (mongosh)
// Jalankan: mongosh <db_name> dummy_seed.js
// ============================================================

// ─────────────────────────────────────────────
// 1. USERS
// ─────────────────────────────────────────────
db.users.insertMany([
  {
    _id: ObjectId("6600000000000000000000a1"),
    name: "Andi Pratama",
    email: "andi.pratama@email.com",
    password_hash: "$2y$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ123456",
    gender: "male",
    tgl_lahir: new Date("2000-03-15"),
    age: 25,
    region: "Jawa Timur",
    education_level: "S1",
    daily_role: "Student",
    income_level: "Low",
    last_login: new Date("2026-04-03T08:30:00Z"),
    created_at: new Date("2026-01-10T07:00:00Z"),
    updated_at: new Date("2026-04-03T08:30:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000a2"),
    name: "Siti Rahayu",
    email: "siti.rahayu@email.com",
    password_hash: "$2y$10$zyxwvutsrqponmlkjihgfedcZYXWVUTSRQPONMLKJIHGFEDCBA654321",
    gender: "female",
    tgl_lahir: new Date("1998-07-22"),
    age: 27,
    region: "DKI Jakarta",
    education_level: "S2",
    daily_role: "Employee",
    income_level: "Medium",
    last_login: new Date("2026-04-04T09:15:00Z"),
    created_at: new Date("2026-01-15T10:00:00Z"),
    updated_at: new Date("2026-04-04T09:15:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000a3"),
    name: "Budi Santoso",
    email: "budi.santoso@email.com",
    password_hash: "$2y$10$mnopqrstuvwxyzABCDEFGHabcdefghijklmnopqrstuvwxyz7890ab",
    gender: "male",
    tgl_lahir: new Date("1995-11-05"),
    age: 30,
    region: "Jawa Barat",
    education_level: "SMA",
    daily_role: "Freelancer",
    income_level: "High",
    last_login: new Date("2026-04-02T14:45:00Z"),
    created_at: new Date("2026-02-01T08:00:00Z"),
    updated_at: new Date("2026-04-02T14:45:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000a4"),
    name: "Dewi Lestari",
    email: "dewi.lestari@email.com",
    password_hash: "$2y$10$QRSTUVWXYZabcdefghijklmnopqrstuvwxyzABCDEFGH1234567890",
    gender: "female",
    tgl_lahir: new Date("2002-05-30"),
    age: 23,
    region: "Bali",
    education_level: "D3",
    daily_role: "Student",
    income_level: "Low",
    last_login: new Date("2026-04-04T11:00:00Z"),
    created_at: new Date("2026-02-20T09:30:00Z"),
    updated_at: new Date("2026-04-04T11:00:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000a5"),
    name: "Reza Firmansyah",
    email: "reza.firmansyah@email.com",
    password_hash: "$2y$10$lkjhgfdsapoiuytrewqzxcvbnm1234567890ABCDEFGHIJKLMNOPQRS",
    gender: "male",
    tgl_lahir: new Date("1993-01-18"),
    age: 33,
    region: "Sumatera Utara",
    education_level: "S1",
    daily_role: "Employee",
    income_level: "High",
    last_login: new Date("2026-04-03T16:20:00Z"),
    created_at: new Date("2026-03-05T07:45:00Z"),
    updated_at: new Date("2026-04-03T16:20:00Z")
  }
]);

// ─────────────────────────────────────────────
// 2. QUESTIONNAIRES
// ─────────────────────────────────────────────
db.questionnaires.insertMany([
  {
    _id: ObjectId("6600000000000000000000b1"),
    user_id: "6600000000000000000000a1",
    device_hours_per_day: 8.5,
    phone_unlocks_per_day: 72,
    notifications_per_day: 150,
    social_media_minutes: 210,
    study_minutes: 120,
    physical_activity_days: 2,
    sleep_hours: 5.5,
    sleep_quality: 2.5,
    anxiety_score: 7.2,
    depression_score: 5.8,
    stress_level: 6.5,
    happiness_score: 4.0,
    device_type: "android",
    created_at: new Date("2026-04-01T08:00:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000b2"),
    user_id: "6600000000000000000000a2",
    device_hours_per_day: 5.0,
    phone_unlocks_per_day: 45,
    notifications_per_day: 80,
    social_media_minutes: 90,
    study_minutes: 60,
    physical_activity_days: 4,
    sleep_hours: 7.0,
    sleep_quality: 4.0,
    anxiety_score: 4.1,
    depression_score: 3.2,
    stress_level: 4.0,
    happiness_score: 6.5,
    device_type: "ios",
    created_at: new Date("2026-04-01T09:30:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000b3"),
    user_id: "6600000000000000000000a3",
    device_hours_per_day: 11.0,
    phone_unlocks_per_day: 100,
    notifications_per_day: 220,
    social_media_minutes: 300,
    study_minutes: 30,
    physical_activity_days: 1,
    sleep_hours: 4.5,
    sleep_quality: 1.5,
    anxiety_score: 8.5,
    depression_score: 7.0,
    stress_level: 8.0,
    happiness_score: 2.5,
    device_type: "android",
    created_at: new Date("2026-04-02T07:00:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000b4"),
    user_id: "6600000000000000000000a4",
    device_hours_per_day: 6.0,
    phone_unlocks_per_day: 55,
    notifications_per_day: 100,
    social_media_minutes: 150,
    study_minutes: 180,
    physical_activity_days: 3,
    sleep_hours: 7.5,
    sleep_quality: 3.5,
    anxiety_score: 5.0,
    depression_score: 4.0,
    stress_level: 5.0,
    happiness_score: 5.5,
    device_type: "android",
    created_at: new Date("2026-04-02T10:00:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000b5"),
    user_id: "6600000000000000000000a5",
    device_hours_per_day: 3.5,
    phone_unlocks_per_day: 30,
    notifications_per_day: 50,
    social_media_minutes: 60,
    study_minutes: 90,
    physical_activity_days: 5,
    sleep_hours: 8.0,
    sleep_quality: 4.5,
    anxiety_score: 2.5,
    depression_score: 2.0,
    stress_level: 3.0,
    happiness_score: 8.0,
    device_type: "ios",
    created_at: new Date("2026-04-03T08:00:00Z")
  }
]);

// ─────────────────────────────────────────────
// 3. ML_RESULTS
// ─────────────────────────────────────────────
db.ml_results.insertMany([
  {
    _id: ObjectId("6600000000000000000000c1"),
    user_id: "6600000000000000000000a1",
    questionnaire_id: "6600000000000000000000b1",
    ml_result: {
      digital_dependence_score: 78.4,
      category: "tinggi",
      confidence: 0.87
    },
    ai_analysis: {
      penyebab: ["screen_time_tinggi", "tidur_kurang", "aktivitas_fisik_rendah"],
      rekomendasi: [
        { tag: "sleep", isi: "Coba tidur lebih awal, targetkan minimal 7 jam per malam untuk memulihkan energi." },
        { tag: "social_media", isi: "Batasi penggunaan media sosial maksimal 60 menit per hari dengan app timer." },
        { tag: "exercise", isi: "Lakukan olahraga ringan seperti jalan kaki 30 menit setiap hari." }
      ],
      summary: "Tingkat ketergantungan digital Anda sangat tinggi. Pola tidur yang buruk dan screen time berlebih menjadi faktor utama. Disarankan untuk segera membatasi penggunaan perangkat dan memperbaiki pola tidur.",
      model: "gemini-pro",
      generated_at: new Date("2026-04-01T08:05:00Z")
    },
    week_group: "2026-W14",
    created_at: new Date("2026-04-01T08:05:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000c2"),
    user_id: "6600000000000000000000a2",
    questionnaire_id: "6600000000000000000000b2",
    ml_result: {
      digital_dependence_score: 42.1,
      category: "sedang",
      confidence: 0.82
    },
    ai_analysis: {
      penyebab: ["notifikasi_sering", "stress_moderat"],
      rekomendasi: [
        { tag: "notification", isi: "Nonaktifkan notifikasi yang tidak penting agar fokus tidak terganggu." },
        { tag: "mindfulness", isi: "Coba meditasi 10 menit setiap pagi untuk mengurangi stres." }
      ],
      summary: "Ketergantungan digital Anda berada di level sedang. Pola hidup Anda cukup seimbang, namun perlu sedikit perhatian pada manajemen notifikasi dan stres.",
      model: "gemini-pro",
      generated_at: new Date("2026-04-01T09:35:00Z")
    },
    week_group: "2026-W14",
    created_at: new Date("2026-04-01T09:35:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000c3"),
    user_id: "6600000000000000000000a3",
    questionnaire_id: "6600000000000000000000b3",
    ml_result: {
      digital_dependence_score: 91.7,
      category: "tinggi",
      confidence: 0.95
    },
    ai_analysis: {
      penyebab: ["screen_time_ekstrem", "tidur_sangat_kurang", "social_media_berlebih", "aktivitas_fisik_sangat_rendah"],
      rekomendasi: [
        { tag: "sleep", isi: "Tidur Anda sangat kurang. Segera buat jadwal tidur rutin dan hindari gadget 1 jam sebelum tidur." },
        { tag: "social_media", isi: "Kurangi penggunaan media sosial secara drastis, mulai dengan batas 30 menit per hari." },
        { tag: "digital_detox", isi: "Pertimbangkan digital detox setiap akhir pekan untuk menyeimbangkan kehidupan." },
        { tag: "exercise", isi: "Mulai berolahraga minimal 3x seminggu untuk memperbaiki kesehatan fisik dan mental." }
      ],
      summary: "Tingkat ketergantungan digital Anda sangat kritis. Hampir semua indikator menunjukkan ketidakseimbangan serius. Diperlukan perubahan gaya hidup yang signifikan segera.",
      model: "gemini-pro",
      generated_at: new Date("2026-04-02T07:05:00Z")
    },
    week_group: "2026-W14",
    created_at: new Date("2026-04-02T07:05:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000c4"),
    user_id: "6600000000000000000000a4",
    questionnaire_id: "6600000000000000000000b4",
    ml_result: {
      digital_dependence_score: 55.3,
      category: "sedang",
      confidence: 0.79
    },
    ai_analysis: {
      penyebab: ["social_media_moderat", "stress_moderat"],
      rekomendasi: [
        { tag: "social_media", isi: "Batasi scrolling media sosial dengan menjadwalkan waktu khusus, misalnya 30 menit setelah makan." },
        { tag: "study", isi: "Pertahankan keseimbangan waktu belajar yang sudah baik." }
      ],
      summary: "Ketergantungan digital Anda sedang. Waktu belajar yang baik adalah nilai positif, namun penggunaan media sosial masih perlu dikontrol lebih ketat.",
      model: "gemini-pro",
      generated_at: new Date("2026-04-02T10:05:00Z")
    },
    week_group: "2026-W14",
    created_at: new Date("2026-04-02T10:05:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000c5"),
    user_id: "6600000000000000000000a5",
    questionnaire_id: "6600000000000000000000b5",
    ml_result: {
      digital_dependence_score: 18.2,
      category: "rendah",
      confidence: 0.93
    },
    ai_analysis: {
      penyebab: [],
      rekomendasi: [
        { tag: "maintain", isi: "Pertahankan kebiasaan digital yang sehat seperti yang sudah Anda lakukan." }
      ],
      summary: "Selamat! Ketergantungan digital Anda sangat rendah. Pola hidup Anda sangat seimbang antara penggunaan teknologi, olahraga, dan istirahat yang cukup.",
      model: "gemini-pro",
      generated_at: new Date("2026-04-03T08:05:00Z")
    },
    week_group: "2026-W14",
    created_at: new Date("2026-04-03T08:05:00Z")
  }
]);

// ─────────────────────────────────────────────
// 4. ADMIN_USERS
// ─────────────────────────────────────────────
db.admin_users.insertMany([
  {
    _id: ObjectId("6600000000000000000000d1"),
    name: "Super Admin",
    email: "superadmin@digitalhealth.id",
    role: "superadmin",
    is_active: true,
    created_at: new Date("2026-01-01T00:00:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000d2"),
    name: "Admin Operasional",
    email: "admin.ops@digitalhealth.id",
    role: "admin",
    is_active: true,
    created_at: new Date("2026-01-05T08:00:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000d3"),
    name: "Admin Riset",
    email: "admin.riset@digitalhealth.id",
    role: "admin",
    is_active: false,
    created_at: new Date("2026-02-10T09:00:00Z")
  }
]);

// ─────────────────────────────────────────────
// 5. PASSWORD_RESETS
// ─────────────────────────────────────────────
db.password_resets.insertMany([
  {
    _id: ObjectId("6600000000000000000000e1"),
    email: "andi.pratama@email.com",
    otp_code: "482910",
    expired_at: new Date("2026-04-04T09:00:00Z"),
    verified: false
  },
  {
    _id: ObjectId("6600000000000000000000e2"),
    email: "dewi.lestari@email.com",
    otp_code: "731045",
    expired_at: new Date("2026-04-04T12:00:00Z"),
    verified: true
  },
  {
    _id: ObjectId("6600000000000000000000e3"),
    email: "budi.santoso@email.com",
    otp_code: "295837",
    expired_at: new Date("2026-04-03T15:00:00Z"),
    verified: false
  }
]);

// ─────────────────────────────────────────────
// 6. ANALYTICS_LOGS
// ─────────────────────────────────────────────
db.analytics_logs.insertMany([
  {
    _id: ObjectId("6600000000000000000000f1"),
    user_id: "6600000000000000000000a1",
    avg_dependence_7_days: 75.2,
    dependence_change_percentage: 5.3,
    created_at: new Date("2026-04-04T00:00:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000f2"),
    user_id: "6600000000000000000000a2",
    avg_dependence_7_days: 40.8,
    dependence_change_percentage: -3.1,
    created_at: new Date("2026-04-04T00:00:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000f3"),
    user_id: "6600000000000000000000a3",
    avg_dependence_7_days: 89.4,
    dependence_change_percentage: 8.7,
    created_at: new Date("2026-04-04T00:00:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000f4"),
    user_id: "6600000000000000000000a4",
    avg_dependence_7_days: 53.0,
    dependence_change_percentage: -1.8,
    created_at: new Date("2026-04-04T00:00:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000f5"),
    user_id: "6600000000000000000000a5",
    avg_dependence_7_days: 19.5,
    dependence_change_percentage: -6.2,
    created_at: new Date("2026-04-04T00:00:00Z")
  }
]);

// ─────────────────────────────────────────────
// 7. RECOMMENDATION_RULES
// ─────────────────────────────────────────────
db.recommendation_rules.insertMany([
  {
    _id: ObjectId("6600000000000000000000g1"),
    name: "High Dependence - High Social Media",
    conditions: {
      category: "tinggi",
      social_media_minutes: { min: 180 },
      sleep_hours: { max: 6 }
    },
    recommendation: "Kurangi screen time media sosial dan perbaiki pola tidur Anda segera. Gunakan fitur screen time di ponsel Anda untuk membatasi penggunaan.",
    priority: 1,
    is_active: true,
    created_at: new Date("2026-04-09T00:00:00Z"),
    updated_at: new Date("2026-04-09T00:00:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000g2"),
    name: "High Dependence - Low Physical Activity",
    conditions: {
      category: "tinggi",
      physical_activity_days: { max: 2 }
    },
    recommendation: "Tingkatkan aktivitas fisik Anda minimal 3 hari per minggu. Olahraga terbukti mengurangi ketergantungan digital dan memperbaiki kesehatan mental.",
    priority: 2,
    is_active: true,
    created_at: new Date("2026-04-09T00:00:00Z"),
    updated_at: new Date("2026-04-09T00:00:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000g3"),
    name: "Medium Dependence - Notification Overload",
    conditions: {
      category: "sedang",
      notifications_per_day: { min: 100 }
    },
    recommendation: "Nonaktifkan notifikasi yang tidak penting. Cek pesan dan media sosial pada waktu tertentu saja, misalnya 3x sehari.",
    priority: 3,
    is_active: true,
    created_at: new Date("2026-04-09T00:00:00Z"),
    updated_at: new Date("2026-04-09T00:00:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000g4"),
    name: "Medium Dependence - Poor Sleep Quality",
    conditions: {
      category: "sedang",
      sleep_quality: { max: 3.0 }
    },
    recommendation: "Kualitas tidur Anda kurang optimal. Hindari layar gadget minimal 1 jam sebelum tidur dan ciptakan rutinitas tidur yang konsisten.",
    priority: 4,
    is_active: true,
    created_at: new Date("2026-04-09T00:00:00Z"),
    updated_at: new Date("2026-04-09T00:00:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000g5"),
    name: "Low Dependence - Maintain Habit",
    conditions: {
      category: "rendah"
    },
    recommendation: "Hebat! Pertahankan kebiasaan digital sehat Anda. Tetap jaga keseimbangan antara teknologi, olahraga, dan waktu istirahat.",
    priority: 5,
    is_active: true,
    created_at: new Date("2026-04-09T00:00:00Z"),
    updated_at: new Date("2026-04-09T00:00:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000g6"),
    name: "High Anxiety Score",
    conditions: {
      anxiety_score: { min: 7.0 }
    },
    recommendation: "Skor kecemasan Anda tinggi. Pertimbangkan untuk berbicara dengan konselor atau psikolog. Teknik pernapasan dan meditasi dapat membantu.",
    priority: 1,
    is_active: true,
    created_at: new Date("2026-04-09T00:00:00Z"),
    updated_at: new Date("2026-04-09T00:00:00Z")
  },
  {
    _id: ObjectId("6600000000000000000000g7"),
    name: "Extreme Phone Unlocks",
    conditions: {
      phone_unlocks_per_day: { min: 80 }
    },
    recommendation: "Anda membuka ponsel terlalu sering. Coba atur 'Do Not Disturb' mode di jam-jam produktif dan letakkan ponsel di tempat yang tidak mudah dijangkau.",
    priority: 2,
    is_active: false,
    created_at: new Date("2026-04-09T00:00:00Z"),
    updated_at: new Date("2026-04-09T00:00:00Z")
  }
]);

// ─────────────────────────────────────────────
// VERIFIKASI (opsional)
// ─────────────────────────────────────────────
print("=== SEED SUMMARY ===");
print("users            :", db.users.countDocuments());
print("questionnaires   :", db.questionnaires.countDocuments());
print("ml_results       :", db.ml_results.countDocuments());
print("admin_users      :", db.admin_users.countDocuments());
print("password_resets  :", db.password_resets.countDocuments());
print("analytics_logs   :", db.analytics_logs.countDocuments());
print("recommendation_rules:", db.recommendation_rules.countDocuments());
