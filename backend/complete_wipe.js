// Complete wipe: Remove ALL old data (requests, donations, inventory)
const mongoose = require("mongoose");
require("dotenv").config();

async function completeWipe() {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log("✅ Connected to MongoDB");

        const DonationRecord = require("./models/DonationRecord");
        const Inventory = require("./models/Inventory");
        const CampRequest = require("./models/CampRequest");

        // Delete ALL data for CAMP004
        const donationResult = await DonationRecord.deleteMany({ campId: "CAMP004" });
        console.log(`🗑️  Deleted ${donationResult.deletedCount} donations`);

        const inventoryResult = await Inventory.deleteMany({ campId: "CAMP004" });
        console.log(`🗑️  Deleted ${inventoryResult.deletedCount} inventory items`);

        const requestResult = await CampRequest.deleteMany({ campId: "CAMP004" });
        console.log(`🗑️  Deleted ${requestResult.deletedCount} requests`);

        console.log("\n✅ Complete wipe done!");
        console.log("Database is now completely clean for CAMP004");
        console.log("You can now add fresh requests and donations!");

        await mongoose.disconnect();
    } catch (error) {
        console.error("❌ Error:", error);
    }
}

completeWipe();
