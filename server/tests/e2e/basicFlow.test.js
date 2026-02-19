const request = require("supertest");
const app = require("../../src/app");

describe("E2E Flow", () => {
  it("should simulate full request flow", async () => {
    const res = await request(app).get("/api/health")
;

    expect(res.statusCode).toBe(200);
  });
});
