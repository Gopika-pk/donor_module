const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  username: String,
  password: String,   // plain for now (hash later)
  role: {
    type: String,
    default: "camp_manager",
  },
  campId: String,
});

module.exports = mongoose.models.User || mongoose.model("User", userSchema);
