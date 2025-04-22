const express = require("express");
const redis = require("redis");
const { Pool } = require("pg");

const PORT = 3000;
const REDIS_HOST = "redis";
const REDIS_PORT = 6379;
const DB_USER = "admin";
const DB_PASSWORD = "secretpassword";
const DB_HOST = "postgres";
const DB_PORT = 5432;

const app = express();

app.use(express.json());

// Redis client
const client = redis.createClient({
  socket: {
    host: REDIS_HOST,
    port: REDIS_PORT,
  },
});

// PostgreSQL client
const pool = new Pool({
  user: DB_USER,
  password: DB_PASSWORD,
  host: DB_HOST,
  database: DB_HOST,
  port: DB_PORT,
});

client.on("error", (err) => console.log("Redis Client Error", err));

const startServer = async () => {
  await client.connect();

  // Initialize users table
  await pool.query(`
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      name VARCHAR(100) NOT NULL,
      email VARCHAR(100) UNIQUE NOT NULL
    );
  `);

  // Route to add a user
  app.post("/users", async (req, res) => {
    const { name, email } = req.body;
    if (!name || !email) {
      return res.status(400).json({ error: "Name and email are required" });
    }

    try {
      const result = await pool.query(
        "INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *",
        [name, email]
      );
      res.status(201).json({ success: true, user: result.rows[0] });
    } catch (err) {
      res
        .status(500)
        .json({ error: "Failed to create user", details: err.message });
    }
  });

  // Route to get a user by ID
  app.get("/users/:id", async (req, res) => {
    const { id } = req.params;

    try {
      const result = await pool.query("SELECT * FROM users WHERE id = $1", [
        id,
      ]);

      if (result.rows.length === 0) {
        return res.status(404).json({ error: "User not found" });
      }

      res.status(200).json({ user: result.rows[0] });
    } catch (err) {
      res
        .status(500)
        .json({ error: "Failed to retrieve user", details: err.message });
    }
  });

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
