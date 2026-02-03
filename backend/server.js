const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
require("dotenv").config();

const app = express();
app.use(cors());
app.use(express.json());

// MongoDB connection
const MONGO_URI = process.env.MONGO_URI || "mongodb://127.0.0.1:27017/sahaya";

mongoose.connect(MONGO_URI)
  .then(() => console.log("MongoDB connected"))
  .catch(err => console.log(err));

// Routes
app.use("/api/camp", require("./routes/campRoutes")); // Existing donor camp routes
app.use("/api/donor", require("./routes/donorRoutes"));
app.use("/api/dashboard", require("./routes/dashboardRoutes"));

// Camp Manager Routes
app.use("/api/camp-manager", require("./routes/campManagerAuthRoutes"));
app.use("/inventory", require("./routes/inventoryRoutes"));
app.use("/camp-request", require("./routes/campManagerRoutes"));
app.use("/inmates", require("./routes/inmateRoutes"));

// Admin Routes
app.use("/api/admin", require("./routes/adminRoutes"));

const PORT = 5000;
const HOST = '0.0.0.0'; // Listen on all network interfaces
app.listen(PORT, HOST, () => {
  console.log(`Backend running on http://${HOST}:${PORT}`);
  console.log(`Access from network devices using your local IP`);
});
