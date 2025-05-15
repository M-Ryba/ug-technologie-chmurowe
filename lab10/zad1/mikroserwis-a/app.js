const express = require("express");
const axios = require("axios");

const app = express();
const PORT = 3000;

// Adres serwisu B w klastrze Kubernetes
const MIKROSERVICE_B_URL = "http://mikroserwis-b-service:3001";

app.get("/", async (req, res) => {
  try {
    const response = await axios.get(`${MIKROSERVICE_B_URL}/info`);
    res.json({
      message: "Odpowiedź z mikroserwis_a",
      time: new Date().toISOString(),
      dataFromServiceB: response.data,
    });
  } catch (error) {
    console.error("Błąd podczas komunikacji z mikroserwis_b:", error.message);
    res.status(500).json({
      error: "Nie udało się połączyć z mikroserwis_b",
      details: error.message,
    });
  }
});

app.listen(PORT, () => {
  console.log(`Mikroserwis_a działa na porcie ${PORT}`);
});
