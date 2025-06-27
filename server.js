const express = require('express');
const axios = require('axios');
const path = require('path');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');
const packageJson = require('./package.json');
const validator = require('validator');
const mongoose = require('mongoose');
require('dotenv').config(); // if you're using .env

// --- MongoDB connection ---
mongoose.connect(process.env.MONGODB_URI);

const db = mongoose.connection;
db.on('error', console.error.bind(console, 'MongoDB connection error:'));
db.once('open', () => {
  console.log('Connected to MongoDB');
});

const app = express();
const port = 3000;

const allowedOrigins = ['http://192.168.1.3:3000'];
app.use(cors({ origin: allowedOrigins }));
app.use(helmet());
app.use(express.json());

const VIRUSTOTAL_API_KEY = process.env.VIRUSTOTAL_API_KEY;

// --- Mongoose Schemas ---
const urlHistorySchema = new mongoose.Schema({
  device_id: String,
  scanned_result: String,
  scan_status: String,
  scanned_date: String,
  scanned_time: String,
  deleted: { type: Boolean, default: false }
});
const UrlHistory = mongoose.model('UrlHistory', urlHistorySchema);

const deviceSchema = new mongoose.Schema({
  device_id: { type: String, unique: true },
  user_name: String,
  registered_on: { type: Date, default: Date.now },
  scan_time: String // <-- Added scan_time column here
});
const Device = mongoose.model('Device', deviceSchema);

const userMessageSchema = new mongoose.Schema({
  device_id: String,
  message_date: String,
  message_time: String,
  message: String
});
const UserMessage = mongoose.model('UserMessage', userMessageSchema);

const userRatingSchema = new mongoose.Schema({
  device_id: String,
  rating_date: String,
  rating_time: String,
  rating: String
});
const UserRating = mongoose.model('UserRating', userRatingSchema);

const managePermissionsSchema = new mongoose.Schema({
  device_id: { type: String, unique: true },
  beep_sound_enabled: Number,
  preferred_search_engine: String,
  auto_copy_enabled: Number
});
const ManagePermissions = mongoose.model('ManagePermissions', managePermissionsSchema);

// --- Rate limiter for /check-url ---
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: 'Too many requests, please try again later.'
});
app.use('/check-url', apiLimiter);

// --- Add a scanned result with current scanned_date and scanned_time ---
app.post('/add-url', async (req, res) => {
  const { device_id, url, scan_status } = req.body;

  if (!url || !device_id) {
    return res.status(400).json({ message: 'Device ID and result are required.' });
  }

  const status = scan_status || 'Not Checked';
  const now = new Date();
  const scanned_date = now.toISOString().slice(0, 10);
  const scanned_time = now.toISOString().slice(11, 19);

  try {
    const urlHistory = new UrlHistory({
      device_id,
      scanned_result: url,
      scan_status: status,
      scanned_date,
      scanned_time,
      deleted: false
    });
    const saved = await urlHistory.save();

    // Update scan_time for the device
    await Device.findOneAndUpdate(
      { device_id },
      { scan_time: scanned_time },
      { new: true }
    );

    res.status(201).json({ message: 'Result added with status.', url_id: saved._id });
  } catch (err) {
    console.error('Error inserting result:', err.message);
    res.status(500).json({ message: 'Database error', error: err.message });
  }
});

app.post('/mark-url-visited', async (req, res) => {
  const { url_id } = req.body;

  if (!url_id) {
    return res.status(400).json({ message: 'URL ID is required.' });
  }

  try {
    const result = await UrlHistory.findByIdAndUpdate(url_id, { scan_status: 'Visited' });
    if (!result) {
      return res.status(404).json({ message: 'URL not found.' });
    }
    res.status(200).json({ message: 'URL marked as visited.' });
  } catch (err) {
    console.error('Error updating URL visit status:', err.message);
    res.status(500).json({ message: 'Database update error', error: err.message });
  }
});

app.post('/check-url', async (req, res) => {
  const { url_id, url } = req.body;

  if (!url_id || !url) {
    return res.status(400).json({ message: 'URL ID and URL are required.' });
  }

  if (!validator.isURL(url)) {
    return res.status(400).json({ message: 'Invalid URL format.' });
  }

  try {
    const scanResponse = await axios.post(
      'https://www.virustotal.com/api/v3/urls',
      new URLSearchParams({ url }),
      {
        headers: {
          'x-apikey': VIRUSTOTAL_API_KEY,
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      }
    );

    const scanId = scanResponse.data.data.id;
    const maxRetries = 20;
    const retryDelayMs = 15000;

    let analysisStatus = '';
    let reportResponse;

    for (let attempt = 0; attempt < maxRetries; attempt++) {
      reportResponse = await axios.get(
        `https://www.virustotal.com/api/v3/analyses/${scanId}`,
        {
          headers: { 'x-apikey': VIRUSTOTAL_API_KEY }
        }
      );

      analysisStatus = reportResponse.data.data.attributes.status;

      if (analysisStatus === 'completed') {
        break;
      }

      await new Promise(resolve => setTimeout(resolve, retryDelayMs));
    }

    if (analysisStatus !== 'completed') {
      return res.status(202).json({ status: 'loading', message: 'Scan is still in progress. Please try again shortly.' });
    }

    const maliciousCount = reportResponse.data.data.attributes.stats.malicious;
    const status = maliciousCount > 0 ? 'Insecure' : 'Secure';

    await UrlHistory.findByIdAndUpdate(url_id, { scan_status: status });

    res.status(200).json({ status, data: reportResponse.data });
  } catch (error) {
    console.error('Error checking URL with VirusTotal:', error.message);
    res.status(500).json({ message: 'Error checking URL security', error: error.message });
  }
});

app.get('/get-history/:device_id', async (req, res) => {
  const { device_id } = req.params;

  try {
    const results = await UrlHistory.find({ device_id, deleted: false }).sort({ scanned_date: -1, scanned_time: -1 });
    res.status(200).json({ history: results });
  } catch (err) {
    console.error('Error fetching history:', err.message);
    res.status(500).json({ message: 'Database error', error: err.message });
  }
});

// Soft delete a URL
app.post('/delete-url', async (req, res) => {
  const { url_id } = req.body;

  if (!url_id) {
    return res.status(400).json({ message: 'A valid URL ID is required.' });
  }

  try {
    const result = await UrlHistory.findByIdAndUpdate(url_id, { deleted: true });
    if (!result) {
      return res.status(404).json({ message: 'URL not found.' });
    }
    res.status(200).json({ message: 'URL marked as deleted.' });
  } catch (err) {
    console.error('Error deleting URL:', err.message);
    res.status(500).json({ message: 'Database update error', error: err.message });
  }
});

// Redirect to an educational page
app.get('/education-page', (req, res) => {
  res.redirect('https://krebsonsecurity.com/');
});

// Get the latest version status
app.get('/version-status', (req, res) => {
  res.json({ latest_version: packageJson.version });
});

// Submit user feedback
app.post('/api/user_feedback', async (req, res) => {
  const { device_id, message, rating, user_name } = req.body;

  if (!device_id) {
    return res.status(400).json({ message: 'Device ID is required.' });
  }

  const validRatings = ['1 Star', '2 Stars', '3 Stars', '4 Stars', '5 Stars', 'No rating provided'];
  if (rating && !validRatings.includes(rating)) {
    return res.status(400).json({ message: 'Invalid rating value.' });
  }

  const currentDate = new Date().toISOString().slice(0, 10);
  const currentTime = new Date().toISOString().slice(11, 19);

  try {
    let device = await Device.findOne({ device_id });
    if (!device) {
      device = new Device({
        device_id,
        user_name: user_name || 'Anonymous',
        registered_on: new Date()
      });
      await device.save();
    }

    const queries = [];

    if (message && message.trim() !== '') {
      const userMsg = new UserMessage({
        device_id,
        message_date: currentDate,
        message_time: currentTime,
        message: message.trim()
      });
      queries.push(userMsg.save());
    }

    if (rating && rating.trim() !== '') {
      const userRate = new UserRating({
        device_id,
        rating_date: currentDate,
        rating_time: currentTime,
        rating: rating.trim()
      });
      queries.push(userRate.save());
    }

    if (queries.length === 0) {
      return res.status(400).json({ message: 'At least one of message or rating must be provided.' });
    }

    await Promise.all(queries);
    res.status(200).json({ message: 'User feedback submitted successfully.' });

  } catch (error) {
    console.error('Error submitting user feedback:', error.message);
    res.status(500).json({ message: 'Database error while submitting feedback.', error: error.message });
  }
});

app.post('/api/manage_permissions/update', async (req, res) => {
  const { device_id, beep_enabled, preferred_search_engine, auto_copy_to_clipboard } = req.body;

  if (!device_id) {
    return res.status(400).json({ message: 'Device ID is required.' });
  }

  const beepSound = beep_enabled ? 1 : 0;
  const autoCopy = auto_copy_to_clipboard ? 1 : 0;
  const searchEngine = preferred_search_engine || null;

  try {
    await ManagePermissions.findOneAndUpdate(
      { device_id },
      {
        beep_sound_enabled: beepSound,
        preferred_search_engine: searchEngine,
        auto_copy_enabled: autoCopy
      },
      { upsert: true, new: true }
    );
    res.status(200).json({ message: 'Permissions updated successfully.' });
  } catch (err) {
    console.error('Error updating manage_permissions:', err.message);
    res.status(500).json({ message: 'Database error', error: err.message });
  }
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});