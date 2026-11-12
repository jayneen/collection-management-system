// ----------------------------------------------
// retrieve necessary files (express and cors)
const express = require("express")
const cors = require("cors")
const path = require("path");
// retrieve the MySQL DB Configuration Module
const dbConnection = require("./config")
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

// Serve the frontend files
const frontendPath = process.env.FRONTEND_PATH ||
    path.join(__dirname, "../frontend");

app.use(express.static(frontendPath));

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

const server = app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});

// Shut down the backend and its database connection cleanly
let shuttingDown = false;

function shutdown() {
    if (shuttingDown) return;
    shuttingDown = true;

    console.log("Shutting down backend...");

    server.close(() => {
        dbConnection.end((err) => {
            if (err) {
                console.error("Error closing database connection:", err);
                process.exitCode = 1;
            }

            console.log("Backend stopped cleanly.");
        });
    });
}

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);