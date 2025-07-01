// Performance monitoring setup
const express = require("express")
const prometheus = require("prom-client")
const responseTime = require("response-time")

const app = express()

// Create metrics
const httpRequestDuration = new prometheus.Histogram({
  name: "http_request_duration_seconds",
  help: "Duration of HTTP requests in seconds",
  labelNames: ["method", "route", "status_code"],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10],
})

const httpRequestTotal = new prometheus.Counter({
  name: "http_requests_total",
  help: "Total number of HTTP requests",
  labelNames: ["method", "route", "status_code"],
})

// Middleware to collect metrics
app.use(
  responseTime((req, res, time) => {
    const route = req.route ? req.route.path : req.path
    const labels = {
      method: req.method,
      route: route,
      status_code: res.statusCode,
    }

    httpRequestDuration.observe(labels, time / 1000)
    httpRequestTotal.inc(labels)
  }),
)

// Metrics endpoint
app.get("/metrics", (req, res) => {
  res.set("Content-Type", prometheus.register.contentType)
  res.end(prometheus.register.metrics())
})

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({
    status: "healthy",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  })
})

module.exports = app
