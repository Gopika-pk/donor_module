// Script to sync old donations with inventory
// This will process all "Received" donations and add them to inventory

const mongoose = require("mongoose");
require("dotenv").config();

async function syncOldDonations() {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log("✅ Connected to MongoDB");

        const DonationRecord = require("./models/DonationRecord");
        const Inventory = require("./models/Inventory");
        const CampRequest = require("./models/CampRequest");

        // Find all "Received" donations
        const receivedDonations = await DonationRecord.find({ status: "Received" });
        console.log(`Found ${receivedDonations.length} received donations to process`);

        let updated = 0;

        for (const donation of receivedDonations) {
            // Add to inventory
            let inventory = await Inventory.findOne({
                campId: donation.campId,
                itemName: donation.itemName
            });

            if (inventory) {
                inventory.quantity += donation.quantity;
                inventory.lastUpdated = new Date();
                await inventory.save();
            } else {
                inventory = await Inventory.create({
                    campId: donation.campId,
                    itemName: donation.itemName,
                    quantity: donation.quantity
                });
            }

            // Update CampRequest
            const request = await CampRequest.findOne({
                campId: donation.campId,
                itemName: donation.itemName,
                status: { $in: ["Pending", "open", "Open"] }
            });

            if (request) {
                request.remainingQty = Math.max(0, request.remainingQty - donation.quantity);
                if (request.remainingQty === 0) {
                    request.status = "Fulfilled";
                }
                await request.save();
            }

            updated++;
            console.log(`✅ Synced: ${donation.itemName} - ${donation.quantity}${donation.unit} for ${donation.campId}`);
        }

        console.log(`\n✅ Successfully synced ${updated} donations to inventory`);

        await mongoose.disconnect();
        console.log("✅ Done!");
    } catch (error) {
        console.error("❌ Error:", error);
    }
}

syncOldDonations();
