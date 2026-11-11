const test = require("node:test");
const assert = require("node:assert/strict");
const request = require("supertest");
const app = require("../app");

test("GET / returns the application response", async () => {
  const response = await request(app).get("/");

  assert.equal(response.statusCode, 200);
  assert.equal(response.text, "DevOps Demo Application");
});

test("GET /health returns healthy status", async () => {
  const response = await request(app).get("/health");

  assert.equal(response.statusCode, 200);
  assert.deepEqual(response.body, {
    status: "healthy"
  });
});