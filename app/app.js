const express = require("express");
const client = require("prom-client");

const app = express();

client.collectDefaultMetrics();

const requestDuration = new client.Histogram({
  name: "http_request_duration_seconds",
  help: "Duration of HTTP requests in seconds",
  labelNames: ["method", "route"],
  buckets: [0.1, 0.5, 1, 2, 5]
});

app.use((req, res, next) => {
  const end = requestDuration.startTimer();

  res.on("finish", () => {
    end({
      method: req.method,
      route: req.route?.path || req.path
    });
  });

  next();
});

app.get("/", (req, res) => {
  res.status(200).send("DevOps Demo Application");
});

app.get("/health", (req, res) => {
  res.status(200).json({
    status: "healthy"
  });
});

app.get("/metrics", async (req, res) => {
  res.set("Content-Type", client.register.contentType);
  res.end(await client.register.metrics());
});

module.exports = app;