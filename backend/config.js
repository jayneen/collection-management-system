// ----------------------------------------------
// TCSS 460: Summer 2025
// MySQL Coonfiguration: Backend
// ----------------------------------------------
// Code is based on the 
// Node.js for MySQL Library:
// https://github.com/mysqljs/mysql
// ----------------------------------------------

// ----------------------------------------------
// (A) Import the MySQL module or library
// ----------------------------------------------
const mysql = require("mysql2");

// ----------------------------------------------
// (B) Configure the connection options for MySQL
//     The database name is: 'washingtondb'
//     This is the database that we have created 
//     in Part I.B using phpMyAdmin via XAMPP. 
// ----------------------------------------------
// ###### username and password must match ######
// ----------------------------------------------
// Ensure username and password match thoe ones
// identified using phpMyAdmin when creating 
// the testuser account. We are using  default 
// tport hat is created by XAMPP for MySQL: 3306.
// ----------------------------------------------
const mysqlConfig = {
    host: process.env.DB_HOST || "localhost",
    port: process.env.DB_PORT || 3306,
    user: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: "game_collection",
    debug: false // Connection debugging mode is ON
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
