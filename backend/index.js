// ----------------------------------------------
// TCSS 460: Summer 2025
// Backend REST Service Module
// ----------------------------------------------
// Express is a Node.js web application framework
// that provides a wide range of APIs and methods
// Express API Reference:
// https://expressjs.com/en/resources/middleware/cors.html

// ----------------------------------------------
// retrieve necessary files (express and cors)
const express = require("express")
const cors = require("cors")
// retrieve the MySQL DB Configuration Module
// const dbConnection = require("./config")
// use this library for parsing HTTP body requests
// var bodyParser = require('body-parser');

// routes
const gamesRoutes = require("./routes/games");
const consolesRoutes = require("./routes/consoles");
const optionsRoutes = require("./routes/options");

// ----------------------------------------------
// (A)  Create an express application instance
//      and parses incoming requests with JSON
//      payloads
// ----------------------------------------------
var app = express();
app.use(express.json());

// ----------------------------------------------
// (B)  Use the epxress cors middleware
//      Cross-origin resource sharing (CORS)
//      is a technique that restricts specified
//      resources within web page to be accessed
//      from other domains on which the origin
//      resource was initiated the HTTP request
//      Also use the bodyParser to parse in 
//      format the body of HTTP Requests
// ----------------------------------------------
app.use(cors());
// app.use(bodyParser.json());

// register routes
app.use("/games", gamesRoutes);
app.use("/consoles", consolesRoutes);
app.use("/options", optionsRoutes);



const PORT = process.env.PORT || 2000;
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
