const test = require("node:test");
const assert = require("node:assert/strict");
const app = require("../app");

test("application and metrics endpoints work together", async (t) => {
  const server = app.listen(0);

  t.after(() => {
    server.close();
  });

  await new Promise((resolve) => {
    server.once("listening", resolve);
  });

  const address = server.address();
  const baseUrl = `http://127.0.0.1:${address.port}`;

  const appResponse = await fetch(`${baseUrl}/`);
  const appBody = await appResponse.text();

  assert.equal(appResponse.status, 200);
  assert.equal(appBody, "DevOps Demo Application");

  const metricsResponse = await fetch(`${baseUrl}/metrics`);
  const metricsBody = await metricsResponse.text();

  assert.equal(metricsResponse.status, 200);
  assert.match(
    metricsResponse.headers.get("content-type"),
    /text\/plain/
  );
  assert.match(metricsBody, /http_request_duration_seconds/);
});