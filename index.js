const express = require('express');
const cors = require('cors');
const axios = require('axios');
const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

const VIRUSTOTAL_API_KEY = '8a019c4ae3dea51f03e8ab463dbbb6ebf67e3fd1615974ac8d676018014f22fa';

app.get('/', (req, res) => {
  res.send('Hello from Node.js backend!');
});

// New API route to check URL safety using VirusTotal
app.post('/check-url', async (req, res) => {
  const { url } = req.body;

  if (!url) {
    return res.status(400).json({ message: 'URL is required.' });
  }

  try {
    const submitResponse = await axios.post(
      'https://www.virustotal.com/api/v3/urls',
      new URLSearchParams({ url: url }),
      {
        headers: {
          'x-apikey': VIRUSTOTAL_API_KEY,
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      }
    );

    const scanId = submitResponse.data.data.id;

    const analysisResponse = await axios.get(
      `https://www.virustotal.com/api/v3/analyses/${scanId}`,
      {
        headers: {
          'x-apikey': VIRUSTOTAL_API_KEY
        }
      }
    );

    const analysisData = analysisResponse.data.data.attributes;

    const maliciousCount = analysisData.stats.malicious;

    if (maliciousCount > 0) {
      res.json({
        safe: false,
        message: 'URL is insecure',
        maliciousEngines: maliciousCount,
        analysisUrl: `https://www.virustotal.com/gui/url/${scanId}`
      });
    } else {
      res.json({
        safe: true,
        message: 'URL is secure',
        maliciousEngines: 0,
        analysisUrl: `https://www.virustotal.com/gui/url/${scanId}`
      });
    }

  } catch (error) {
    console.error('Error checking URL via VirusTotal:', error?.response?.data || error.message);
    res.status(500).json({ message: 'Error checking URL via VirusTotal', error: error.message });
  }
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
