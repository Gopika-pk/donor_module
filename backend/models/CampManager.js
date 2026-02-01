const mongoose = require("mongoose");

const campManagerSchema = new mongoose.Schema(
    {
        campId: {
            type: String,
            required: true,
            unique: true,
        },
        campName: {
            type: String,
            required: true,
        },
        managerName: {
            type: String,
            required: true,
        },
        email: {
            type: String,
            required: true,
            unique: true,
        },
        password: {
            type: String,
            required: true,
        },
        location: String,
        contactNumber: String,
    },
    { timestamps: true }
);

module.exports = mongoose.models.CampManager || mongoose.model("CampManager", campManagerSchema);
