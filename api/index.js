const express = require('express');
const app = express();
const fs = require('fs');
const winston = require('winston');
const { createLogger, format, transports } = require('winston');
const axios = require('axios'); // Import axios
const port = 3000;
const apiKey = 'UnsplashAPIKEY';

// Define log format
const logFormat = format.combine(
    format.timestamp(),
    format.printf(info => `${info.timestamp} ${info.level}: ${info.message}`)
);

// Create a logger with a file transport
const logger = createLogger({
    format: logFormat,
    transports: [
        new transports.Console(), // Log to console
        new transports.File({ filename: 'server.log' }) // Log to a file named server.log
    ]
});


// Middleware function to check the api key
function validateApiKey(req, res, next) {
    const apiKey = req.headers['api-key']; // Get the API key from request headers

    if (!apiKey || apiKey !== 'APIKEYtest') {
        return res.status(401).json({ error: 'Unauthorized: Invalid API key' });
    }
    next(); // If API key is valid, continue to the next middleware/route handler
}

// Middleware function to extract user information
function extractUserInfo(req, res, next) {
    // Extract raw IP address of the request sender (IPv6 representation for IPv4 addresses)
    const rawIp = req.ip;
    
    // Convert IPv6 representation to IPv4 format
    const ip = rawIp.includes('::ffff:') ? rawIp.split('::ffff:')[1] : rawIp;
    
    // Extract user-agent (navigator) information, default to 'Unknown' if not present
    const userAgent = req.get('User-Agent') || 'Unknown';
    
    // Extract operating system information from user-agent (if User-Agent header is present)
    let operatingSystem = 'Unknown';
    const osRegex = /\(([^)]+)\)/;
    const osMatch = userAgent.match(osRegex);
    if (osMatch && osMatch.length > 1) {
        operatingSystem = osMatch[1];
    }    
    // Attach user information to the request object for later use
    req.userInfo = {
        ip: ip,
        userAgent: userAgent,
        operatingSystem: operatingSystem
    };
    const userInfo = req.userInfo;
    logger.info(`Received ${req.method} request for ${req.url}`);
    logger.info(`Ip : ${userInfo.ip} || UserAgent : ${userInfo.userAgent} || OperatingSystem : ${userInfo.operatingSystem}`);
    // Call the next middleware function in the stack
    next();
}


app.use(express.json());
app.use(['/DeleteItem/:id', '/ChangeItem/:id', '/DeleteAll','/AddItem'], validateApiKey);
app.use(extractUserInfo);

// Default GET route to show all the json file
app.get('/items', (req, res) => {
    // Read the existing items from items.json
    fs.readFile('items.json', 'utf8', (readErr, data) => {
        if (readErr) {
            logger.error(readErr);
            return res.status(500).json({ error: 'Internal server error while reading file' });
        }
        try {
            const itemsData = JSON.parse(data); // Parse the JSON data
            res.status(200).json({ items: itemsData.items }); // Send the parsed JSON object
        } catch (parseErr) {
            logger.error(parseErr);
            return res.status(500).json({ error: 'Error parsing JSON data' });
        }
    });
});

// POST route to update items.json with new items
app.post('/AddItem', async (req, res) => {
    const newItem = {
        id: '',
        name: req.body.name,
        quantity: req.body.quantity,
        imageUrl: '', // Initialize imageUrl as an empty array
    };

    try {
        // Make a request to Unsplash API based on the 'name' parameter
        const response = await axios.get(`https://api.unsplash.com/search/photos`, {
            headers: {
                Authorization: `Client-ID ${apiKey}`,
            },
            params: {
                query: newItem.name, // Use newItem.name as the query
                per_page: 1, // Limit the number of results to 1
            },
        });

        const imageUrls = response.data.results.map((result) => result.urls.regular);
        newItem.imageUrl = imageUrls; // Assign the imageUrls to newItem.imageUrl

        // Read the existing items from items.json
        fs.readFile('items.json', 'utf8', (readErr, data) => {
            if (readErr) {
                logger.error(readErr);
                return res.status(500).json({ error: 'Internal server error while reading file' });
            }

            let itemsData = JSON.parse(data);
            newItem.id = itemsData.items.length + 1, // Generate a unique ID for the new item
                // Add the new item to the items array
                itemsData.items.push(newItem);

            // Write the updated data back to items.json
            fs.writeFile('items.json', JSON.stringify(itemsData, null, 2), (writeErr) => {
                if (writeErr) {
                    logger.error(writeErr);
                    return res.status(500).json({ error: 'Internal server error while writing file' });
                }

                res.status(200).json({ message: 'Item added successfully' });
            });
        });
    } catch (error) {
        logger.error(error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// DELETE route to delete a specific item by ID
app.delete('/DeleteItem/:id', (req, res) => {
    // Read the existing items from items.json
    fs.readFile('items.json', 'utf8', (readErr, data) => {
        if (readErr) {
            logger.error(readErr);
            return res.status(500).json({ error: 'Internal server error while reading file' });
        }
        let itemsData = JSON.parse(data);

        const itemId = parseInt(req.params.id, 10); // Convert the ID parameter to an integer

        // Find the index of the item with the specified ID
        const itemIndex = itemsData.items.findIndex((item) => item.id === itemId);

        if (itemIndex === -1) {
            return res.status(404).json({ error: 'Item not found' });
        }

        // Remove the item from the array
        itemsData.items.splice(itemIndex, 1);

        // Write the updated data back to items.json
        fs.writeFile('items.json', JSON.stringify(itemsData, null, 2), (writeErr) => {
            if (writeErr) {
                logger.error(writeErr);
                return res.status(500).json({ error: 'Internal server error while writing file' });
            }

            res.status(200).json({ message: 'Item deleted successfully' });
        });
    });
});

// DELETE route to delete a specific item by ID
app.delete('/DeleteAll', (req, res) => {
    // Read the existing items from items.json
    fs.readFile('items.json', 'utf8', (readErr, data) => {
        if (readErr) {
            logger.error(readErr);
            return res.status(500).json({ error: 'Internal server error while reading file' });
        }
        let itemsData = JSON.parse(data);
        const Reset = {
            "items": []
          }; 
        // Write the updated data back to items.json
        fs.writeFile('items.json', JSON.stringify(Reset, null, 2), (writeErr) => {
            if (writeErr) {
                logger.error(writeErr);
                return res.status(500).json({ error: 'Internal server error while writing file' });
            }

            res.status(200).json({ message: 'Item deleted successfully' });
        });
    });
});

// PUT  route to change/edit a specific item by ID + name or quantity parameters
app.put('/ChangeItem/:id', async (req, res) => {
    try {
        // Read the existing items from items.json
        const data = await fs.promises.readFile('items.json', 'utf8');
        let itemsData = JSON.parse(data);

        const itemId = parseInt(req.params.id, 10); // Convert the ID parameter to an integer

        // Find the index of the item with the specified ID
        const itemIndex = itemsData.items.findIndex((item) => item.id === itemId);

        if (itemIndex === -1) {
            return res.status(404).json({ error: 'Item not found' });
        }

        // Change the item properties if provided in the query parameters
        if (req.query.name) {
            itemsData.items[itemIndex].name = req.query.name;
            // Make a request to Unsplash API based on the 'name' parameter
            const response = await axios.get(`https://api.unsplash.com/search/photos`, {
                headers: {
                    Authorization: `Client-ID ${apiKey}`,
                },
                params: {
                    query: req.query.name,
                    per_page: 1,
                },
            });

            const imageUrls = response.data.results.map((result) => result.urls.regular);
            itemsData.items[itemIndex].imageUrl = imageUrls;
        }

        if (req.query.quantity) {
            itemsData.items[itemIndex].quantity = parseInt(req.query.quantity, 10);
        }

        if (!req.query.quantity && !req.query.name) {
            return res.status(404).json({ error: 'Please specify a name or a quantity to change and the changed value' });
        }

        // Write the updated data back to items.json
        await fs.promises.writeFile('items.json', JSON.stringify(itemsData, null, 2));
        res.status(200).json({ message: 'Item changed successfully' });
    } catch (error) {
        logger.error(error);
        res.status(500).json({ error: 'Internal server error' });
    }
});


// Start the API server
app.listen(port, () => {
    logger.info(`Server is listening on port ${port}`);
});
