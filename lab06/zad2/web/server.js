const express = require("express");
const mysql = require("mysql2/promise");
const app = express();
const port = 3000;

// Database connection configuration
const dbConfig = {
  host: "db",
  user: "root",
  password: "password",
  database: "testdb",
};

app.get("/", async (req, res) => {
  try {
    // Create a connection to the database
    const connection = await mysql.createConnection(dbConfig);

    // Query the users table
    const [rows] = await connection.execute("SELECT * FROM users");

    // Close the connection
    await connection.end();

    // Create HTML response
    let html = "<h1>Connection to MySQL database successful!</h1>";
    html += "<h2>Users in Database:</h2>";
    html += '<table border="1"><tr><th>ID</th><th>Name</th><th>Email</th></tr>';

    // Add each user to the table
    rows.forEach((user) => {
      html += `<tr><td>${user.id}</td><td>${user.name}</td><td>${user.email}</td></tr>`;
    });

    html += "</table>";
    html += "<p>Network configuration: web connects to db:3306</p>";

    res.send(html);
  } catch (error) {
    console.error("Database connection error:", error);
    res
      .status(500)
      .send(`<h1>Database Connection Error</h1><pre>${error.message}</pre>`);
  }
});

// Start the server
app.listen(port, () => {
  console.log(`Web service listening at http://localhost:${port}`);
});
