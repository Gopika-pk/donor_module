// Complete reset: Clear inventory and reset all donations to Pending
const mongoose = require("mongoose");
require("dotenv").config();

async function completeReset() {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log("✅ Connected to MongoDB");

        const DonationRecord = require("./models/DonationRecord");
        const Inventory = require("./models/Inventory");
        const CampRequest = require("./models/CampRequest");

        // 1. Clear all inventory for CAMP004
        const inventoryResult = await Inventory.deleteMany({ campId: "CAMP004" });
        console.log(`🗑️  Cleared ${inventoryResult.deletedCount} inventory items`);

        // 2. Reset all donations to Pending
        const donationResult = await DonationRecord.updateMany(
            { campId: "CAMP004" },
            { $set: { status: "Pending", receivedAt: null } }
        );
        console.log(`🔄 Reset ${donationResult.modifiedCount} donations to Pending`);

        // 3. Reset all requests to original amounts
        const requests = await CampRequest.find({ campId: "CAMP004" });
        for (const request of requests) {
            request.remainingQty = request.requiredQty;
            request.status = "Pending";
            await request.save();
        }
        console.log(`🔄 Reset ${requests.length} requests`);

        console.log("\n✅ Complete reset done!");
        console.log("Now you can test the full donation flow:");
        console.log("1. All donations are Pending");
        console.log("2. Inventory is empty");
        console.log("3. Click Received → Adds to inventory");
        console.log("4. Click Not Received → Doesn't add to inventory");

        await mongoose.disconnect();
    } catch (error) {
        console.error("❌ Error:", error);
    }
}

completeReset();
