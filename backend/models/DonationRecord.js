const mongoose = require("mongoose");

const donationRecordSchema = new mongoose.Schema({
    campId: String,
    donorName: { type: String, default: "Anonymous Donor" },
    itemName: String,
    quantity: Number,
    unit: String, // e.g., kg, liters
    status: { type: String, default: "Received" },
    donatedAt: { type: Date, default: Date.now },
});

module.exports = mongoose.models.DonationRecord || mongoose.model("DonationRecord", donationRecordSchema);
