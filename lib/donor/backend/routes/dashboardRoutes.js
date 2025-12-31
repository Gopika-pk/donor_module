const express = require("express");
const CampRequest = require("../models/campRequest");
const MoneyDonation = require("../models/MoneyDonation");
const router = express.Router();

router.get("/summary", async (req, res) => {
  const totalRequests = await CampRequest.countDocuments();
  const fulfilled = await CampRequest.countDocuments({ status: "fulfilled" });
  const pending = await CampRequest.countDocuments({ status: "open" });

  const money = await MoneyDonation.aggregate([
    { $group: { _id: null, total: { $sum: "$amount" } } }
  ]);

  res.json({
    inventory: {
      totalRequests,
      fulfilled,
      pending
    },
    totalMoneyDonated: money[0]?.total || 0
  });
});

module.exports = router;
