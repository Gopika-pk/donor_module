const mongoose = require("mongoose");

const MoneyDonationSchema = new mongoose.Schema({
  donorId: String,
  campId: String,
  amount: Number,
  paymentStatus: String,
  donatedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.models.MoneyDonation || mongoose.model("MoneyDonation", MoneyDonationSchema);
