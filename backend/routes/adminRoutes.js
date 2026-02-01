const express = require("express");
const router = express.Router();
const CampManager = require("../models/CampManager");
const { sendCampCredentials } = require("../services/emailService");

// Hardcoded admin credentials (for simplicity)
const ADMIN_USERNAME = "admin";
const ADMIN_PASSWORD = "admin123";

// Admin login
router.post("/login", async (req, res) => {
    try {
        const { username, password } = req.body;

        if (username === ADMIN_USERNAME && password === ADMIN_PASSWORD) {
            res.json({
                message: "Admin login successful",
                role: "admin",
                username: ADMIN_USERNAME,
            });
        } else {
            res.status(401).json({ message: "Invalid admin credentials" });
        }
    } catch (error) {
        console.error("Admin login error:", error);
        res.status(500).json({ message: "Login failed" });
    }
});

// Create new camp (admin only)
router.post("/create-camp", async (req, res) => {
    try {
        const { campName, managerName, email, password, location, contactNumber } = req.body;

        // Check if email already exists
        const existingManager = await CampManager.findOne({ email });
        if (existingManager) {
            return res.status(400).json({ message: "Email already registered" });
        }

        // Generate unique campId by finding the highest existing ID
        const lastCamp = await CampManager.findOne().sort({ campId: -1 }).limit(1);
        let nextId = 1;
        if (lastCamp && lastCamp.campId) {
            // Extract number from CAMP001, CAMP002, etc.
            const lastNumber = parseInt(lastCamp.campId.replace('CAMP', ''));
            nextId = lastNumber + 1;
        }
        const campId = `CAMP${String(nextId).padStart(3, "0")}`;

        // Create new camp manager
        const campManager = await CampManager.create({
            campId,
            campName,
            managerName,
            email,
            password,
            location,
            contactNumber,
        });

        // Send credentials email
        let emailSent = false;
        try {
            console.log(`📧 Attempting to send credentials email to: ${email}`);
            await sendCampCredentials({
                recipientEmail: email,
                campName,
                campId,
                managerName,
                password,
                location: location || "Not specified",
            });
            console.log(`✅ Credentials email sent successfully to ${email}`);
            emailSent = true;
        } catch (emailError) {
            console.error("⚠️ Camp created but email failed:");
            console.error("Error details:", emailError.message);
            console.error("Full error:", emailError);
            emailSent = false;
            // Continue even if email fails - admin can manually share credentials
        }

        res.status(201).json({
            message: emailSent
                ? "Camp created successfully and credentials sent via email"
                : "Camp created successfully but email failed",
            campId: campManager.campId,
            campName: campManager.campName,
            email: campManager.email,
            password: password, // Return password so admin can share if email fails
            emailSent: emailSent,
        });
    } catch (error) {
        console.error("Create camp error:", error);
        res.status(500).json({ message: "Failed to create camp", error: error.message });
    }
});

// Get all camps (admin only)
router.get("/camps", async (req, res) => {
    try {
        const camps = await CampManager.find().sort({ createdAt: -1 });

        const campList = camps.map(camp => ({
            campId: camp.campId,
            campName: camp.campName,
            managerName: camp.managerName,
            email: camp.email,
            location: camp.location,
            contactNumber: camp.contactNumber,
            createdAt: camp.createdAt,
        }));

        res.json(campList);
    } catch (error) {
        console.error("Fetch camps error:", error);
        res.status(500).json({ message: "Failed to fetch camps" });
    }
});

// Delete camp (admin only)
router.delete("/camp/:campId", async (req, res) => {
    try {
        const { campId } = req.params;

        const result = await CampManager.deleteOne({ campId });

        if (result.deletedCount === 0) {
            return res.status(404).json({ message: "Camp not found" });
        }

        res.json({ message: "Camp deleted successfully" });
    } catch (error) {
        console.error("Delete camp error:", error);
        res.status(500).json({ message: "Failed to delete camp" });
    }
});

module.exports = router;
