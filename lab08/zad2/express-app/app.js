const express = require("express");
const redis = require("redis");

const PORT = 3000;
const REDIS_HOST = "redis";
const REDIS_PORT = 6379;

const app = express();

app.use(express.json());

const client = redis.createClient({
  socket: {
    host: REDIS_HOST,
    port: REDIS_PORT,
  },
});

client.on("error", (err) => console.log("Redis Client Error", err));

const startServer = async () => {
  await client.connect();

  // Route to add a message
  app.post("/messages", async (req, res) => {
    const { id, message } = req.body;
    if (!id || !message) {
      return res.status(400).json({ error: "ID and message are required" });
    }

    try {
      await client.set(id, message);
      res.status(200).json({ success: true, message: "Message saved" });
    } catch (err) {
      res.status(500).json({ error: "Failed to save message" });
    }
  });

  // Route to get a message by ID
  app.get("/messages/:id", async (req, res) => {
    const { id } = req.params;

    try {
      const message = await client.get(id);
      if (!message) {
        return res.status(404).json({ error: "Message not found" });
      }
      res.status(200).json({ id, message });
    } catch (err) {
      res.status(500).json({ error: "Failed to retrieve message" });
    }
  });

  app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
  });
};

startServer().catch((err) => console.error("Failed to start server:", err));
