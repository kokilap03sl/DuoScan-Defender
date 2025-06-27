const express = require('express'); 
const router = express.Router();
const urlController = require('./urlController'); 


router.post('/url-history', urlController.saveUrl); 


router.put('/url-history/:id/delete', urlController.deleteUrl); 


router.delete('/url-history/:id', urlController.deleteUrl); 

module.exports = router;