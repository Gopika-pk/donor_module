const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

// MongoDB connection
mongoose.connect("mongodb://127.0.0.1:27017/sahaya")
  .then(() => console.log("MongoDB connected"))
  .catch(err => console.log(err));

// Routes
app.use("/api/camp", require("./routes/campRoutes"));
app.use("/api/donor", require("./routes/donorRoutes"));
app.use("/api/dashboard", require("./routes/dashboardRoutes"));

app.listen(5000, () => {
  console.log("Backend running on port 5000");
});
