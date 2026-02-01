// Run this script to update existing donations from "Received" to "Pending"
// This allows you to test the "Mark Received" button

const mongoose = require("mongoose");
require("dotenv").config();

async function updateDonations() {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log("✅ Connected to MongoDB");

        const DonationRecord = require("./models/DonationRecord");

        const result = await DonationRecord.updateMany(
            { status: "Received" },
            { $set: { status: "Pending", receivedAt: null } }
        );

        console.log(`✅ Updated ${result.modifiedCount} donations to Pending status`);

        await mongoose.disconnect();
        console.log("✅ Done!");
    } catch (error) {
        console.error("❌ Error:", error);
    }
}

updateDonations();
