const mysql = require("mysql2");

const mysqlConfig = {
    host: process.env.DB_HOST || "127.0.0.1",
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USERNAME || "root",
    password: process.env.DB_PASSWORD || "",
    database: process.env.DB_NAME || "game_collection",
    debug: false
};
// ----------------------------------------------
// (C) Establishing connection using the options
//     defined in mySQLConfig (without a query)
// ----------------------------------------------
const dbConnection = mysql.createConnection(mysqlConfig);
dbConnection.connect(function (err) {
    // unsucessful: handle any errors that might occur during connection
    if (err) {
        console.error('Opps. There was an error connecting to the database: ', err.stack);
        return;
    }
    // successful: output on the screen a message that connection was successful
    console.log('Backend is now connected to: ' + dbConnection.config.database + '.');
});

// ----------------------------------------------
// (D) This module exports dbConnection to be 
//     used other files (e..g, index.js)
// ----------------------------------------------
module.exports = dbConnection;
