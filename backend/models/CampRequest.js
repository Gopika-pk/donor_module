const mongoose = require("mongoose");

const campRequestSchema = new mongoose.Schema(
  {
    campId: String,
    itemName: String,
    requiredQty: Number,
    remainingQty: Number,
    status: String,
    unit: String,
    category: String,
    priority: String,
  },
  { timestamps: true }
);

module.exports = mongoose.models.CampRequest || mongoose.model("CampRequest", campRequestSchema);
