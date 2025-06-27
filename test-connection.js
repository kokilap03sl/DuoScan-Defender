const mongoose = require('mongoose');
require('dotenv').config();

mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  tls: true,
}).then(() => {
  console.log('Connected to MongoDB!');
  process.exit(0);
}).catch(err => {
  console.error('Connection error:', err);
  process.exit(1);
});
