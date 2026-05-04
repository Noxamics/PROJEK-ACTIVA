require("dotenv").config();
const Groq = require("groq-sdk");

const client = new Groq({ apiKey: process.env.GROQ_API_KEY });

async function getAIResponse(prompt) {
  try {
    const response = await client.chat.completions.create({
      model: "llama-3.3-70b-versatile", // gratis, paling pintar di Groq
      messages: [
        {
          role: "system",
          content:
            "Kamu adalah asisten kesehatan digital yang ramah dan empatik. Selalu jawab HANYA dalam format JSON yang diminta, tanpa teks tambahan apapun di luar JSON.",
        },
        {
          role: "user",
          content: prompt,
        },
      ],
      max_tokens: 1024,
      temperature: 0.7,
    });

    return response.choices[0].message.content;
  } catch (err) {
    console.error("Groq Error:", err.message);
    return null;
  }
}

module.exports = { getAIResponse };
