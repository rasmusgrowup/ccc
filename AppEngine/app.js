// Import the required modules
const express = require('express');
const path = require('path');

// Create an Express application
const app = express();
const PORT = process.env.PORT || 8080;

// Define a route to display the message
app.get('/', (req, res) => {
    res.send('Hello Cloud');
});

// Start the server and listen on the specified port
app.listen(PORT, () => {
    console.log("Server is running on http://localhost:" + `${PORT}`);
});