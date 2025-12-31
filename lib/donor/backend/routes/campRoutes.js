const express = require("express");
const CampRequest = require("../models/campRequest");
const router = express.Router();

// Create inventory request
router.post("/request", async (req, res) => {
  try {
    const { campId, itemName, quantity, unit } = req.body;

    const request = new CampRequest({
      campId,
      itemName,
      requiredQuantity: quantity,
      remainingQuantity: quantity,
      unit
    });

    await request.save();
    res.json({ message: "Inventory request created" });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// View all open requests (donor dashboard)
router.get("/requests", async (req, res) => {
  const requests = await CampRequest.find({ status: "open" });
  res.json(requests);
});

module.exports = router;
