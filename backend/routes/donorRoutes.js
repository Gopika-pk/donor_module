const express = require("express");
const CampRequest = require("../models/CampRequest");
const MoneyDonation = require("../models/MoneyDonation");
const router = express.Router();

// Donate items
router.post("/donate-item", async (req, res) => {
  try {
    const { requestId, donateQty } = req.body;

    const request = await CampRequest.findById(requestId);
    if (!request || request.remainingQty <= 0) {
      return res.status(400).json({ message: "Invalid or fulfilled request" });
    }

    // 1. Deduct from Request
    request.remainingQty -= donateQty;

    if (request.remainingQty <= 0) {
      request.remainingQty = 0;
      request.status = "fulfilled";
    }

    await request.save();

    // 2. Add to Camp Inventory
    // We assume the campId, itemName, and unit come from the request
    const Inventory = require("../models/Inventory");

    let inventoryItem = await Inventory.findOne({
      campId: request.campId,
      itemName: request.itemName
    });

    if (inventoryItem) {
      inventoryItem.quantity += donateQty;
      inventoryItem.lastUpdated = new Date();
      await inventoryItem.save();
    } else {
      await Inventory.create({
        campId: request.campId,
        itemName: request.itemName,
        quantity: donateQty,
        lastUpdated: new Date()
      });
    }

    // 3. Create Donation Record
    const DonationRecord = require("../models/DonationRecord");

    await DonationRecord.create({
      campId: request.campId,
      donorName: "Ananya", // Hardcoded for demo, or pass from req.body
      itemName: request.itemName,
      quantity: donateQty,
      unit: request.unit || "units", // Fallback if unit missing
      status: "Received"
    });

    res.json({
      message: "Item donated successfully and inventory updated",
      remaining: request.remainingQty
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Donate money (mock)
router.post("/donate-money", async (req, res) => {
  const donation = new MoneyDonation({
    donorId: req.body.donorId,
    campId: req.body.campId,
    amount: req.body.amount,
    paymentStatus: "SUCCESS"
  });

  await donation.save();
  res.json({ message: "Money donation successful" });
});

module.exports = router;
