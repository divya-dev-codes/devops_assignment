const express = require("express");
const client = require("prom-client");

const app = express();
const PORT = process.env.PORT || 3000;

// 1. Create Prometheus registry
const register = new client.Registry();

// 2. Collect default Node.js metrics
client.collectDefaultMetrics({
  register,
});

// 3. HTTP request counter
const httpRequests = new client.Counter({
  name: "http_requests_total",
  help: "Total number of HTTP requests",
  labelNames: ["method", "route", "status"],
  registers: [register],
});

// 4. HTTP response time histogram
const httpDuration = new client.Histogram({
  name: "http_request_duration_seconds",
  help: "HTTP request duration in seconds",
  labelNames: ["method", "route"],
  buckets: [0.1, 0.3, 0.5, 1, 2, 5],
  registers: [register],
});

// 5. Middleware to collect application metrics
app.use((req, res, next) => {
  // Do not count Prometheus scraping requests
  if (req.path === "/metrics") {
    return next();
  }

  const start = process.hrtime.bigint();

  res.on("finish", () => {
    const duration =
      Number(process.hrtime.bigint() - start) / 1e9;

    // Use route patterns instead of dynamic URLs
    const route = req.route
      ? `${req.baseUrl}${req.route.path}`
      : "unmatched";

    httpRequests.inc({
      method: req.method,
      route,
      status: String(res.statusCode),
    });

    httpDuration.observe(
      {
        method: req.method,
        route,
      },
      duration
    );
  });

  next();
});

// 6. Application home route
app.get("/", (req, res) => {
  res.send(
    "👋 Hello, 8Byte! Excited to have you here. Everything is running smoothly! 🚀"
  );
});

// 7. Health check endpoint for AWS ALB
app.get("/health", (req, res) => {
  res.status(200).json({
    status: "healthy",
    application: "DevOps Assignment",
  });
});

// 8. Prometheus metrics endpoint
app.get("/metrics", async (req, res) => {
  res.set("Content-Type", register.contentType);
  res.end(await register.metrics());
});

// 9. Start server and listen on all network interfaces
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on port ${PORT}`);
});