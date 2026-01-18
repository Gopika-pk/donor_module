const express = require("express");
const router = express.Router();
const Inventory = require("../models/Inventory");

// Get inventory for a specific camp
// Get detailed inventory for a specific camp
router.get("/:campId", async (req, res) => {
  try {
    const { campId } = req.params;
    const CampRequest = require("../models/CampRequest");
    const DonationRecord = require("../models/DonationRecord");

    // 1. Fetch all relevant data in parallel
    const [inventoryItems, requests, donations] = await Promise.all([
      Inventory.find({ campId }),
      CampRequest.find({ campId }),
      DonationRecord.find({ campId })
    ]);

    // 2. Create a map to aggregate data by itemName
    const itemMap = {};

    // Helper to ensure item exists in map
    const ensureItem = (name) => {
      if (!itemMap[name]) {
        itemMap[name] = {
          itemName: name,
          requested: 0,
          received: 0,
          currentStock: 0,
          donors: [] // List of strings or objects
        };
      }
    };

    // Process Requests (Requested Amount)
    requests.forEach(req => {
      ensureItem(req.itemName);
      itemMap[req.itemName].requested += req.requiredQty || 0;
    });

    // Process Donations (Received Amount & Donors)
    donations.forEach(don => {
      ensureItem(don.itemName);
      itemMap[don.itemName].received += don.quantity || 0;
      // Add donor info
      itemMap[don.itemName].donors.push({
        name: don.donorName || "Anonymous",
        quantity: don.quantity,
        unit: don.unit
      });
    });

    // Process Inventory (Current Stock)
    inventoryItems.forEach(inv => {
      ensureItem(inv.itemName);
      itemMap[inv.itemName].currentStock = inv.quantity || 0;
    });

    // Convert map to array
    const result = Object.values(itemMap);

    res.json(result);
  } catch (error) {
    console.error("Error fetching detailed inventory:", error);
    res.status(500).json({ message: "Error fetching inventory" });
  }
});

// Update inventory manually
router.put("/update", async (req, res) => {
  const { campId, itemName, quantity } = req.body;

  try {
    let item = await Inventory.findOne({ campId, itemName });

    if (item) {
      item.quantity = quantity;
      item.lastUpdated = new Date();
      await item.save();
    } else {
      item = await Inventory.create({
        campId,
        itemName,
        quantity,
      });
    }

    res.json({ message: "Inventory updated successfully" });
  } catch (error) {
    res.status(500).json({ message: "Inventory update failed" });
  }
});

module.exports = router;
