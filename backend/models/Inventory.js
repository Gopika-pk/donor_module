const mongoose = require("mongoose");

const inventorySchema = new mongoose.Schema({
  campId: String,
  itemName: String,
  quantity: Number,
  lastUpdated: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.models.Inventory || mongoose.model("Inventory", inventorySchema);
