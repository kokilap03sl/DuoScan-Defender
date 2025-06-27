const urlModel = require('./urlModel');
const axios = require('axios');
const mongoose = require('mongoose');

// --- Mongoose Schema (should match server.js) ---
const urlHistorySchema = new mongoose.Schema({
  device_id: String,
  scanned_result: String,
  scan_status: String,
  scanned_date: String,
  scanned_time: String,
  deleted: { type: Boolean, default: false }
});
const UrlHistory = mongoose.models.UrlHistory || mongoose.model('UrlHistory', urlHistorySchema);

const saveUrl = async (req, res) => {
  const { device_id, scanned_url, scan_status } = req.body;

  if (!device_id || !scanned_url || !scan_status) {
    return res.status(400).json({ message: "Missing required fields: device_id, scanned_url, scan_status" });
  }

  const now = new Date();
  const scanned_date = now.toISOString().slice(0, 10);
  const scanned_time = now.toISOString().slice(11, 19);

  try {
    const urlHistory = new UrlHistory({
      device_id,
      scanned_result: scanned_url,
      scan_status,
      scanned_date,
      scanned_time,
      deleted: false
    });
    await urlHistory.save();
    res.status(200).json({ message: "Data saved successfully" });
  } catch (err) {
    return res.status(500).json({ message: "Error saving data" });
  }
};

const checkUrl = async (req, res) => {
  const { device_id, url } = req.body;

  if (!device_id || !url) {
    return res.status(400).json({ error: "Missing required fields: device_id, url" });
  }

  try {
    // Step 1: Submit URL for analysis
    const scanResponse = await axios.post(
      'https://www.virustotal.com/api/v3/urls',
      new URLSearchParams({ url: url }),
      {
        headers: {
          'x-apikey': process.env.VIRUSTOTAL_API_KEY,
          'Content-Type': 'application/x-www-form-urlencoded',
        }
      }
    );

    const scanId = scanResponse.data.data.id;

    // Step 2: Poll for analysis report using scan ID
    const reportResponse = await axios.get(
      `https://www.virustotal.com/api/v3/analyses/${scanId}`,
      {
        headers: {
          'x-apikey': process.env.VIRUSTOTAL_API_KEY
        }
      }
    );

    const maliciousCount = reportResponse.data.data.attributes.stats.malicious;

    // Determine scan status based on malicious count
    const status = maliciousCount > 0 ? 'Insecure' : 'Secure';

    // Find the most recent matching entry
    const urlDoc = await UrlHistory.findOne({
      device_id,
      scanned_result: url,
      deleted: false
    }).sort({ scanned_date: -1, scanned_time: -1 });

    if (!urlDoc) {
      return res.status(404).json({ error: "No matching URL record found to update." });
    }

    // Update the scan_status
    urlDoc.scan_status = status;
    await urlDoc.save();

    return res.status(200).json({ status });

  } catch (error) {
    console.error("Error checking URL via VirusTotal:", error?.response?.data || error.message);
    return res.status(500).json({ error: "Failed to check URL via VirusTotal" });
  }
};

// Controller function to soft delete a URL
const deleteUrl = async (req, res) => {
  const { id } = req.body;

  if (!id) {
    return res.status(400).json({ error: "Missing required field: id" });
  }

  try {
    const result = await UrlHistory.findByIdAndUpdate(id, { deleted: true });
    if (!result) {
      return res.status(404).json({ error: "URL not found or already deleted." });
    }
    return res.status(200).json({ message: "URL marked as deleted." });
  } catch (err) {
    return res.status(500).json({ error: "Error deleting URL" });
  }
};

// Controller function to get URL history, excluding deleted URLs
const getUrlHistory = async (req, res) => {
  const { device_id } = req.params;

  try {
    const rows = await UrlHistory.find({ device_id, deleted: false }).sort({ scanned_date: -1, scanned_time: -1 });

    if (!rows || rows.length === 0) {
      return res.status(404).json({ message: "No history found for this device." });
    }

    return res.status(200).json({ history: rows });
  } catch (error) {
    console.error("Error fetching URL history:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
};

module.exports = {
  saveUrl,
  checkUrl,
  deleteUrl,
  getUrlHistory
};