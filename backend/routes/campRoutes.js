const express = require("express");
const CampRequest = require("../models/CampRequest");
const router = express.Router();

// Create inventory request
router.post("/request", async (req, res) => {
  try {
    const { campId, itemName, quantity, unit, category, priority } = req.body;

    const request = new CampRequest({
      campId,
      itemName,
      requiredQty: quantity,
      remainingQty: quantity,
      unit,
      category,
      priority,
      status: "Pending"
    });

    await request.save();
    res.json({ message: "Inventory request created" });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// View all open requests (donor dashboard)
router.get("/requests", async (req, res) => {
  try {
    const requests = await CampRequest.find({ status: { $in: ["Pending", "open", "Open"] } });

    // Populate location from CampManager
    const CampManager = require("../models/CampManager");

    const enrichedRequests = await Promise.all(
      requests.map(async (req) => {
        const camp = await CampManager.findOne({ campId: req.campId });
        return {
          ...req.toObject(),
          location: camp?.location || "Unknown"
        };
      })
    );

    res.json(enrichedRequests);
  } catch (error) {
    console.error("Fetch requests error:", error);
    res.status(500).json({ message: "Failed to fetch requests" });
  }
});

// Get all valid camps for dropdown (donor dashboard)
router.get("/camps", async (req, res) => {
  try {
    const CampManager = require("../models/CampManager");
    const camps = await CampManager.find()
      .select("campId campName location")
      .sort({ campName: 1 });

    res.json(camps);
  } catch (error) {
    console.error("Fetch camps error:", error);
    res.status(500).json({ message: "Failed to fetch camps" });
  }
});

module.exports = router;
