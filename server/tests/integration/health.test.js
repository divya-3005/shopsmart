const request = require("supertest");
const app = require("../../src/app");

describe("GET /api/health", () => {
  it("should return backend status", async () => {
    const res = await request(app).get("/api/health");

    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe("ok");
    expect(res.body.message).toBe("ShopSmart Backend is running");
  });
});
