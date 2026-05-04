require("dotenv").config();
const express = require("express");

const { getMLResult } = require("./services/mlService");
const { getAIResponse } = require("./services/aiService");
const { analyze } = require("./utils/analyzer");
const { buildPrompt } = require("./utils/promptBuilder");
const { mapToTag } = require("./utils/tagMapper");

const app = express();
app.use(express.json());

/**
 * POST /chatbot
 *
 * Mode 1 — pakai user_id dari dataset Excel:
 *   { "user_id": 3 }
 *
 * Mode 2 — input manual (tetap bisa):
 *   {
 *     "device_hours_per_day": 9,
 *     "social_media_mins": 180,
 *     "sleep_hours": 5,
 *     "notifications_per_day": 120,
 *     "stress_level": 8,
 *     "depression_score": 7.5,
 *     "physical_activity_days": 1
 *   }
 */
app.post("/chatbot", async (req, res) => {
  try {
    const { score, category, penyebab, data } = req.body;
    console.log("PAYLOAD DARI FLASK:", { score, category, penyebab });

    const prompt = buildPrompt({ score, category, penyebab, data });
    const aiResponse = await getAIResponse(prompt);
    console.log("AI RESPONSE:", aiResponse);

    let aiResult;
    try {
      const cleaned = aiResponse.replace(/```json|```/g, "").trim();
      aiResult = JSON.parse(cleaned);
    } catch (e) {
      console.warn("JSON parse gagal, fallback plain text");
      // Fallback: buat array rekomendasi manual
      aiResult = {
        penyebab: penyebab,
        rekomendasi: penyebab.map((tag) => ({
          tag: tag,
          isi: aiResponse,
        })),
      };
    }

    res.json({ ai: aiResult });
  } catch (err) {
    console.error("ERROR:", err);
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server jalan di port ${PORT}`));
