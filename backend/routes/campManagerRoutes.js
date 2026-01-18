const express = require("express");
const router = express.Router();
const CampRequest = require("../models/CampRequest");

// Create camp request
router.post("/", async (req, res) => {
    const { campId, itemName, requiredQty, unit, category, priority } = req.body;
    try {
        const doc = await CampRequest.create({
            campId,
            itemName,
            requiredQty,
            remainingQty: requiredQty,
            status: "Pending",
            unit,
            category,
            priority,
        });
        res.status(201).json(doc);
    } catch (err) {
        console.error("Create camp request error:", err);
        res.status(500).json({ message: "Failed to create camp request" });
    }
});

// Get donation history for a camp
router.get("/donations/:campId", async (req, res) => {
    try {
        const DonationRecord = require("../models/DonationRecord");
        const history = await DonationRecord.find({ campId: req.params.campId }).sort({ donatedAt: -1 });
        res.json(history);
    } catch (err) {
        console.error("Fetch donations error:", err);
        res.status(500).json({ message: "Failed to fetch donations" });
    }
});

module.exports = router;
