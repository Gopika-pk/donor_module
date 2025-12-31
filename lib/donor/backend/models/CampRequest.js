const mongoose = require("mongoose");

const CampRequestSchema = new mongoose.Schema({
  campId: { type: String, required: true },
  itemName: { type: String, required: true },
  requiredQuantity: { type: Number, required: true },
  remainingQuantity: { type: Number, required: true },
  unit: { type: String, required: true },
  status: { type: String, default: "open" }, // open | fulfilled
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model("CampRequest", CampRequestSchema);
