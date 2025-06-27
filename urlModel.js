const mongoose = require('mongoose');

// Define the schema (should match server.js and urlController.js)
const urlHistorySchema = new mongoose.Schema({
  device_id: String,
  scanned_result: String,
  scan_status: String,
  scanned_date: String,
  scanned_time: String,
  deleted: { type: Boolean, default: false }
});

const UrlHistory = mongoose.models.UrlHistory || mongoose.model('UrlHistory', urlHistorySchema);

// Save a new URL entry
const saveUrl = async (device_id, scanned_url, scan_status, timestamp, callback) => {
  try {
    const dateObj = timestamp ? new Date(timestamp) : new Date();
    const scanned_date = dateObj.toISOString().slice(0, 10);
    const scanned_time = dateObj.toISOString().slice(11, 19);

    const urlHistory = new UrlHistory({
      device_id,
      scanned_result: scanned_url,
      scan_status,
      scanned_date,
      scanned_time,
      deleted: false
    });

    const result = await urlHistory.save();
    callback(null, result);
  } catch (err) {
    console.error("Error saving URL:", err);
    callback(err);
  }
};

// Get URL history for a device (excluding deleted)
const getUrlHistory = async (device_id, callback) => {
  try {
    const result = await UrlHistory.find({ device_id, deleted: false }).sort({ scanned_date: -1, scanned_time: -1 });
    callback(null, result);
  } catch (err) {
    console.error("Error fetching URL history:", err);
    callback(err);
  }
};

// Soft delete a URL by id
const deleteUrl = async (id, callback) => {
  try {
    const result = await UrlHistory.findByIdAndUpdate(id, { deleted: true });
    callback(null, result);
  } catch (err) {
    console.error("Error deleting URL:", err);
    callback(err);
  }
};

module.exports = {
  saveUrl,
  getUrlHistory,
  deleteUrl
};