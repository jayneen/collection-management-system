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

function startServer(port = process.env.PORT || 2000) {
    return new Promise((resolve) => {
        const server = app.listen(port, "127.0.0.1", () => resolve(server));
    });
}

// runs automatically when all windows are closed
function stopServer(server) {
    return new Promise((resolve) => {
        console.log("Shutting down...");
        server.closeAllConnections?.();
        server.close(() => {
            console.log("HTTP server closed.");
            dbConnection.end((err) => {
                if (err) console.error("Error closing database:", err);
                else console.log("Database closed.");
                resolve();
            });
        });
    });
}

module.exports = { startServer, stopServer };

// Still works as `node index.js` for debugging
if (require.main === module) {
    startServer().then(() => console.log("Server is running"));
}