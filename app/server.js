const express = require("express");
const client = require("prom-client");

const app = express();

// Create a Registry
const register = new client.Registry();

// Collect default Node.js metrics
client.collectDefaultMetrics({
  register,
});

app.get("/", (req, res) => {
  res.send("DevOps Assignment Success");
});

// Metrics endpoint
app.get("/metrics", async (req, res) => {
  res.set("Content-Type", register.contentType);
  res.end(await register.metrics());
});

app.listen(3000, () => {
  console.log("Server running on port 3000");
});