const express = require('express');
const axios = require('axios');

const app = express();
const port = 3000;

const MAGIC_CODE_URL = 'https://magic-server-802314573716.europe-north1.run.app/magic-code';
const FINAL_ANSWER_URL = 'https://final-answer-802314573716.europe-north1.run.app/final-answer';

// Endpoint to fetch the magic header
app.get('/magic-header', async (req, res) => {
    try {
        // Call the external API to get the magic code
        const response = await axios.get(MAGIC_CODE_URL);
        const data = response.data;

        // Extract the required field
        const headerValue = data.useThisHeaderToAuthenticateTowardsTheFinalEndpoint;
        if (!headerValue) {
            return res.status(400).json({ error: "Required field not found in response" });
        }

        res.json({ useThisHeaderToAuthenticateTowardsTheFinalEndpoint: headerValue });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Endpoint to fetch the final answer
app.get('/final-answer', async (req, res) => {
    try {
        // First, fetch the magic header value from the `/magic-code` API
        const magicResponse = await axios.get(MAGIC_CODE_URL);
        const magicData = magicResponse.data;
        const token = magicData.useThisHeaderToAuthenticateTowardsTheFinalEndpoint;

        if (!token) {
            return res.status(400).json({ error: "Authentication token not found" });
        }

        // Call the `/final-answer` API with the token in the Authorization header
        const finalResponse = await axios.get(FINAL_ANSWER_URL, {
            headers: {
                Authorization: `Bearer ${token}`,
            },
        });

        const finalData = finalResponse.data;

        // Extract the final answer
        const finalAnswer = finalData.finalAnswer;
        if (!finalAnswer) {
            return res.status(400).json({ error: "Final answer not found in response" });
        }

        res.json({ finalAnswer });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Start the server
app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});