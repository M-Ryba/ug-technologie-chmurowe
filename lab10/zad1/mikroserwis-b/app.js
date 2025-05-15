const express = require("express");
const app = express();
const PORT = 3001;

app.get("/info", (req, res) => {
  res.json({
    service: "mikroserwis_b",
    version: "1.0.0",
    time: new Date().toISOString(),
    message: "Odpowiedź z mikroserwis_b",
  });
});

app.listen(PORT, () => {
  console.log(`mikroserwis_b działa na porcie ${PORT}`);
});
