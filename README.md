# Grocery List Application 

Grocery List App is a simple mobile application built with Flutter. It allows users to manage their grocery shopping list by adding, editing, and deleting items.
It is a connected grecory shopping list so multiple users can work on the same one. 

## Main table of contents

- [Server-Side API Documentation](#server-side-api-documentation)
- [Application-Side Documentation](#application-side-documentation)
- [Contributing](#contributing)
- [License](#License)

## Server-Side API Documentation

This is the documentation for the server-side API. This API is built with Node.js using Express.js and provides endpoints to manage the grocery list items in a JSON file. It includes features for adding, updating, deleting items, and retrieving the list of items.

### Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Dependencies](#dependencies)
- [Usage](#usage)
- [Endpoints](#endpoints)
- [Error Handling](#error-handling)
- [Logging](#logging)

### Prerequisites

- Node.js installed on your machine
- An API key for authentication (required for certain endpoints)

### Installation

1. **Clone the repository:**

   ```bash
   git clone <repository-url>

2. **Install dependencies:**
    cd <project-folder>
    npm install

### Dependencies

- Express : Used to create the web server, handle HTTP requests, routes, and middleware.
- fs : Used for reading and writing files, such as reading the JSON data from a file or saving log files.
- winston : Used for logging various information and errors in a structured format, aiding in debugging and understanding the server's behavior.
- axios : Used for making HTTP requests to external APIs, in this case, interacting with the [Unsplash API](https://unsplash.com/documentation) to fetch images based on search queries.

### Usage

1. **Start the server:**
    node index.js

The server will be running at http://localhost:3000.

2. **Make API requests to the specified endpoints (see [Endpoints](#endpoints)).**

### Endpoints


- GET /items: Get the list of items.
- POST /AddItem: Add a new item. Requires name and quantity parameters in the request body.
- DELETE /DeleteItem/:id: Delete an item by ID.
- DELETE /DeleteAll: Delete all items.
- PUT /ChangeItem/:id: Update an item by ID. Requires either name or quantity parameters in the query.

Note: POST,DELETE and PUT endpoints require an API key for authentication.

### Error Handling

The API provides detailed error messages in case of invalid requests or server errors. Error responses include a error field with a descriptive message.

### Logging

The API logs information, errors, and requests to both the console and a log file (server.log) for monitoring and debugging purposes.


## Application-Side Documentation

### Table of Contents
- [Prerequisites](#prerequisites-1)
- [Getting Started](#getting-started)
- [Features](#features)
- [Screenshots](#screenshots)
- [Dependencies](#dependencies-1)
- [Usage](#usage-1)
- [Server-Side API Integration](#server-side-api-integration)

### Prerequisites

- Flutter installed on your machine
- A running instance of the server-side API (refer to the [Server-Side API Documentation](#server-side-api-documentation))

### Getting Started

1. **Clone the repository:**

   ```bash
   git clone <repository-url>

2. **Install dependencies:**
    cd <project-folder>
    flutter pub get

3. **Run the application:**
    flutter run

The app will be launched on your connected device or emulator.

### Features

- Add items to the grocery list with a name and quantity. The Image will be automatically generated.
- Edit existing items to update their names and quantities. The Image will be automatically modified.
- Delete items from the list individually or delete all items at once.
- View the list of grocery items, including their names, quantities, and images (if available).

### Screenshots

![Application screenshot](https://i.ibb.co/Y2nRRbJ/Capture-d-cran-2023-10-15-230631.png)

![Application screenshot edit item](https://i.ibb.co/Xy3Qn37/image-2023-10-15-230936505.png)

### Dependencies

- http: For making HTTP requests to interact with the server-side API.
- flutter/material.dart: Material Design widgets for building the user interface.

### Usage

The Flutter app interacts with the server-side API to perform CRUD operations on the grocery items. Make sure the API server is running and accessible from the app.

### Server-Side API Integration

Ensure that the API endpoint URLs in the Flutter app match the routes and IP address of your running server-side API.
Ensure that the right API key is put in. By default, the key is "APIKEYtest".

```js
const String apiKey = 'APIKEYtest';
final String apiBaseUrl = 'http://<your-api-ip>:<your-api-port>'; // Replace with your API IP address and the port, by default the port is 3000

// Example API endpoints
addItemEndpoint = '$apiBaseUrl/AddItem';
deleteItemEndpoint = '$apiBaseUrl/DeleteItem';
editItemEndpoint = '$apiBaseUrl/ChangeItem';
deleteAllItemsEndpoint = '$apiBaseUrl/DeleteAll';
getItemsEndpoint = '$apiBaseUrl/items';

```

## Contributing
Contributions are welcome! Feel free to open issues or submit pull requests.

## License
This project is licensed under the [MIT License](https://opensource.org/license/mit/). 
**Do not use this application or any part of my code for commercial purpose.**

