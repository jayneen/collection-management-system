const express = require("express");
const router = express.Router();
const dbConnection = require("../config");


/**
 * @api {get} /games Retrieve all game records
 * @apiName GetAllGames
 * @apiGroup Games
 *
 * @apiSuccess {Object[]} games List of all games.
 * @apiSuccessExample {json} Success-Response:
 *  HTTP/1.1 200 OK
 *  [
 *    {
 *      "UID": 1,
 *      "GameName": "The Legend of Zelda",
 *      "Region": "USA",
 *      ...
 *    }
 *  ]
 */
router.get('/', (request, response) => {
    const sqlQuery = "SELECT * FROM Games;";
    dbConnection.query(sqlQuery, (err, result) => {
        if (err) {
            return response.status(400).json({ Error: "Error in the SQL statement. Please check." });
        }
        response.setHeader('SQLQuery', sqlQuery); // send a custom header attribute
        return response.status(200).json(result);
    });
});

/**
 * @api {get} /games/:uid Retrieve game by UID
 * @apiName GetGameByUID
 * @apiGroup Games
 *
 * @apiParam {Number} uid Game's unique ID.
 *
 * @apiSuccess {Object} game Game data with genre, console, peripheral, and series.
 * @apiSuccessExample {json} Success-Response:
 *  HTTP/1.1 200 OK
 *  [
 *    {
 *      "UID": 1,
 *      "GameName": "Mario Kart 64",
 *      "Genres": "Racing, Sports",
 *      ...
 *    }
 *  ]
 */
router.get('/:uid', (request, response) => {
    const uid = request.params.uid;
    const sqlQuery = `
  SELECT 
    Games.UID,
    Games.GameName, 
    Game_Names.Rating, 
    Games.Region, 
    Game_Has_a_Console.ModelName, 
    Game_Has_a_Series.Series, 
    Game_Has_a_Peripheral.PeripheralName,
    GROUP_CONCAT(TRIM(Game_Has_Genres.Genre), ', ') AS Genres,
    Games.\`Condition\`,
    Games.SealOrCIB,
    Games.Notes
  FROM Games
  LEFT JOIN Game_Names ON Games.GameName = Game_Names.GameName
  LEFT JOIN Game_Has_a_Console ON Games.GameName = Game_Has_a_Console.GameName
  LEFT JOIN Game_Has_a_Series ON Games.GameName = Game_Has_a_Series.GameName
  LEFT JOIN Game_Has_a_Peripheral ON Games.GameName = Game_Has_a_Peripheral.GameName
  LEFT JOIN Game_Has_Genres ON Games.GameName = Game_Has_Genres.GameName
  WHERE Games.UID = ?
  GROUP BY 
    Games.UID,
    Games.GameName, 
    Game_Names.Rating, 
    Games.Region, 
    Game_Has_a_Console.ModelName, 
    Game_Has_a_Series.Series, 
    Game_Has_a_Peripheral.PeripheralName, 
    Games.\`Condition\`, 
    Games.SealOrCIB, 
    Games.Notes;
`;

    dbConnection.query(sqlQuery, [uid], (err, result) => {
        if (err) {
            console.error("Error: " + err);
            return response.status(400).json({ Error: "Error in the SQL statement. Please check." });
        }
        response.setHeader('UID', uid); // send a custom
        return response.status(200).json(result);
    });
});

/**
 * @api {post} /games Add a new game copy
 * @apiName AddGameCopy
 * @apiGroup Games
 *
 * @apiBody {String} gameName Name of the game.
 * @apiBody {String} [notes] Optional notes.
 * @apiBody {String} condition Game condition.
 * @apiBody {String} [sealOrCIB] Optional seal/CIB status.
 * @apiBody {String} region Region of the game.
 *
 * @apiSuccess {String} Success Message.
 */
router.post('/', (req, res) => {
    const { gameName, notes, condition, sealOrCIB, region } = req.body;

    // Build the insert dynamically
    const columns = ['GameName', '\`Condition\`', 'Region'];
    const values = [gameName, condition, region];

    if (notes && notes.trim() !== '') {
        columns.push('Notes');
        values.push(notes.trim());
    }

    if (sealOrCIB && sealOrCIB.trim() !== '') {
        columns.push('SealOrCIB');
        values.push(sealOrCIB.trim());
    }

    const placeholders = columns.map(() => '?').join(', ');
    const sqlQuery = `INSERT INTO Games (${columns.join(', ')}) VALUES (${placeholders});`;

    dbConnection.query(sqlQuery, values, (err, result) => {
        if (err) {
            console.error("Insert error:", err);
            return res.status(400).json({ Error: "Failed to add record." });
        }
        return res.status(200).json({ Success: "Game added successfully!" });
    });
});


/**
 * @api {post} /games/gamenames Add a new game name entry and related metadata
 * @apiName AddGameName
 * @apiGroup Games
 *
 * @apiBody {String} gameName Game name.
 * @apiBody {String} upc UPC code.
 * @apiBody {String} releaseDate Release date.
 * @apiBody {String} rating Game rating.
 * @apiBody {String[]|String} [series] Series name(s).
 * @apiBody {String[]|String} [genre] Genre(s).
 * @apiBody {String[]|String} [consoles] Associated console model name(s).
 *
 * @apiSuccess {String} Success Message.
 */
router.post('/gamenames', (req, res) => {
    const { gameName, upc, releaseDate, rating, series, genre, consoles } = req.body;

    const columns = ['GameName', 'UPC', 'ReleaseDate', 'Rating'];
    const values = [gameName, upc, releaseDate, rating];
    const placeholders = columns.map(() => '?').join(', ');

    const query = (sql, params) => new Promise((resolve, reject) => {
        dbConnection.query(sql, params, (err, result) => err ? reject(err) : resolve(result));
    });

    (async () => {
        const conn = dbConnection;

        // Start a manual transaction
        conn.beginTransaction(async (err) => {
            if (err) {
                console.error("Transaction start error:", err);
                return res.status(500).json({ Error: "Failed to start transaction." });
            }
            try {
                // Insert into Game_Names
                await query(`INSERT INTO Game_Names (${columns.join(', ')}) VALUES (${placeholders})`, values);
                // Handle series array
                if (Array.isArray(series)) {
                    for (const s of series) {
                        await query('INSERT IGNORE INTO Series (Series) VALUES (?)', [s]);
                        await query('INSERT INTO Game_Has_a_Series (GameName, Series) VALUES (?, ?)', [gameName, s]);
                    }
                } else if (series) {
                    await query('INSERT IGNORE INTO Series (Series) VALUES (?)', [series]);
                    await query('INSERT INTO Game_Has_a_Series (GameName, Series) VALUES (?, ?)', [gameName, series]);
                }
                // Handle genre array
                if (Array.isArray(genre)) {
                    for (const g of genre) {
                        await query('INSERT IGNORE INTO Genres (Genre) VALUES (?)', [g]);
                        await query('INSERT INTO Game_Has_Genres (GameName, Genre) VALUES (?, ?)', [gameName, g]);
                    }
                } else if (genre) {
                    await query('INSERT IGNORE INTO Genres (Genre) VALUES (?)', [genre]);
                    await query('INSERT INTO Game_Has_Genres (GameName, Genre) VALUES (?, ?)', [gameName, genre]);
                }
                // Handle consoles array
                if (Array.isArray(consoles)) {
                    for (const c of consoles) {
                        await query('INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES (?, ?)', [gameName, c]);
                    }
                } else if (consoles) {
                    console.log("in consoles");
                    await query('INSERT INTO Game_Has_a_Console (GameName, ModelName) VALUES (?, ?)', [gameName, consoles]);
                }
                // If everything succeeded, commit
                conn.commit((err) => {
                    if (err) {
                        conn.rollback(() => {
                            console.error("Commit failed, rolled back:", err);
                            return res.status(500).json({ Error: "Failed to commit transaction." });
                        });
                    } else {
                        res.status(200).json({ Success: "Game added successfully!" });
                    }
                });
            } catch (err) {
                // On any error, rollback everything
                conn.rollback(() => {
                    console.error("Transaction rolled back due to error:", err);
                    res.status(400).json({ Error: "Failed to add record. Transaction cancelled." });
                });
            }
        });
    })();
});

/**
 * @api {put} /games Update a game record by UID
 * @apiName UpdateGame
 * @apiGroup Games
 *
 * @apiBody {Number} uid Game UID.
 * @apiBody {String} condition Updated condition.
 * @apiBody {String} sealOrCIB Updated seal/CIB status.
 * @apiBody {String} notes Updated notes.
 *
 * @apiSuccess {String} Success Message.
 * @apiError {String} Error Message.
 */
router.put('/', (request, response) => {
    const { uid, condition, sealOrCIB, notes } = request.body;
    if (!uid) {
        return response.status(400).json({ Error: "UID is required for update." });
    }
    const sqlQuery = `
        UPDATE Games 
        SET \`Condition\` = ?, SealOrCIB = ?, Notes = ?
        WHERE UID = ?;
    `;
    const values = [condition, sealOrCIB, notes, uid];
    dbConnection.query(sqlQuery, values, (err, result) => {
        if (err) {
            console.error("SQL Error:", err);
            return response.status(400).json({ Error: "Failed to update record." });
        }
        if (result.affectedRows === 0) {
            return response.status(404).json({ Error: "No record found with that UID." });
        }
        return response.status(200).json({ Success: "Record successfully updated." });
    });
});

/**
 * @api {delete} /games/:uid Delete a game by UID
 * @apiName DeleteGame
 * @apiGroup Games
 *
 * @apiParam {Number} uid Game UID.
 *
 * @apiSuccess {String} Success Message.
 * @apiError {String} Error Message.
 */
router.delete('/:uid', (request, response) => {
    const uid = request.params.uid;
    const sqlQuery = "DELETE FROM Games WHERE UID = ? ; ";
    dbConnection.query(sqlQuery, uid, (err, result) => {
        if (err) {
            return response.status(400).json({ Error: "Failed: Record was not deleted" });
        }
        return response.status(200).json({ Success: "Succcessful: Record was deleted!" });
    });
});



module.exports = router;
