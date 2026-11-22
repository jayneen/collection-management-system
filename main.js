const { app, BrowserWindow } = require("electron");
const path = require("path");

// config.js opens the database when it's first required, so this has to come first
process.env.DB_PATH ??= path.join(app.getPath("userData"), "game_collection.db");

const { startServer, stopServer } = require("./backend/index");

let server;
let quitting = false;

async function createWindow() {
    console.log("Starting server...");
    server = await startServer(0);              // 0 = pick any free port
    const port = server.address().port;

    const win = new BrowserWindow({ width: 1200, height: 800 });
    win.webContents.once("did-finish-load", () => {
        console.log(`App is running on http://127.0.0.1:${port}`);
    });
    win.loadURL(`http://127.0.0.1:${port}/menu.html`);

    // development live updates
    if (!app.isPackaged) {
        const fs = require("fs");
        const path = require("path");
        let timer;
        fs.watch(path.join(__dirname, "frontend"), { recursive: true }, () => {
            clearTimeout(timer);                                  // editors fire several events per save
            timer = setTimeout(() => win.webContents.reloadIgnoringCache(), 100);
        });
    }
}

app.whenReady().then(createWindow);

app.on("window-all-closed", () => app.quit());

app.on("before-quit", async (event) => {
    if (quitting) return;
    event.preventDefault();
    quitting = true;
    if (server) await stopServer(server);
    console.log("Shutdown complete.");
    app.quit();
});