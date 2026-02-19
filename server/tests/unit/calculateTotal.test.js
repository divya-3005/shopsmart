const calculateTotal = require("../../src/utils/calculateTotal");

describe("calculateTotal", () => {
  it("should multiply correctly", () => {
    expect(calculateTotal(100, 3)).toBe(300);
  });
});
