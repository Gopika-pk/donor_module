// Reset all old "Received" donations back to "Pending"
// So camp managers can properly use the new Received/Not Received buttons

const mongoose = require("mongoose");
require("dotenv").config();

async function resetDonations() {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log("✅ Connected to MongoDB");

        const DonationRecord = require("./models/DonationRecord");

        // Reset all "Received" donations to "Pending"
        const result = await DonationRecord.updateMany(
            { status: "Received" },
            { $set: { status: "Pending", receivedAt: null } }
        );

        console.log(`✅ Reset ${result.modifiedCount} donations to Pending status`);
        console.log("Camp managers can now use Received/Not Received buttons!");

        await mongoose.disconnect();
        console.log("✅ Done!");
    } catch (error) {
        console.error("❌ Error:", error);
    }
}

resetDonations();
