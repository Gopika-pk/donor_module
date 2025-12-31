const express = require("express");
const CampRequest = require("../models/campRequest");
const MoneyDonation = require("../models/MoneyDonation");
const router = express.Router();

// Donate items
router.post("/donate-item", async (req, res) => {
  try {
    const { requestId, donateQty } = req.body;

    const request = await CampRequest.findById(requestId);
    if (!request || request.remainingQuantity <= 0) {
      return res.status(400).json({ message: "Invalid or fulfilled request" });
    }

    request.remainingQuantity -= donateQty;

    if (request.remainingQuantity <= 0) {
      request.remainingQuantity = 0;
      request.status = "fulfilled";
    }

    await request.save();

    res.json({
      message: "Item donated successfully",
      remaining: request.remainingQuantity
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
