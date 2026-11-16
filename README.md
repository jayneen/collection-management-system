# collection-management-system
This is a fullstack portable application for game collection management. It is designed to help keep track of a video game memorabilia collection and all adjacent items. While current iteration provides features like searching, editing, adding, and deleting records of physical copies of video games and consoles, the underlying database offers a wider range of relations that will be implemented in future versions.

### Running the Application
To start the application download the zip from the latest release, extract the files, and run the .bat script. This repository packages the required MySQL and Node.js runtimes making the application fully self-contained and requiring no additional set up.

### Architecture
- **Frontend:** HTML, CSS, Bootstrap, JavaScript, and jQuery provide the user interface and handle client-side interactions.
- **Backend:** Node.js and Express provide the web server and REST API endpoints for managing collection data.
- **Database:** MySQL stores the collection data, with relationships, constraints, and triggers maintaining data integrity.
- **API Communication:** AJAX requests allow the frontend to communicate asynchronously with the backend.
- **Containerization:** Docker Compose provides a consistent development environment for the backend and MySQL database.
- **Deployment:** The application is packaged as a portable Windows application, bundling its own Node.js and MySQL runtimes so it can run without requiring these dependencies to be installed on the target computer.

## Development

### Prerequisites
The following software is required to develop and run the application locally:
- Node.js – Version 24.x (includes npm).
- MySQL Server – Version 8.4.x.
- Docker Compose - Version 2.x.

### Environment Variables
Create a `.env` file based on `.env.example`.

| Variable | Description |
|---|---|
| `DB-USERNAME` | Database account username |
| `DB-PASSWORD` | Password associated with the database account |
| `DB-ROOT-PASSWORD` | Root account password |

### Installation
Clone and set up the repository:
```bash
git clone https://github.com/jayneen/collection-management-system.git
cd repo
npm install
```
Configure the database connection using the project's environment variables and run the starting script:
```bash
./start-app.ps1
```

## Known Limitations
The current version does not support live updates, in-application shut down, and full database modification, which will be implemented in future releases.

## Credits
### Developers
- Zane Swaims
- Evgeniia Nemynova

### Libraries and Frameworks
- [Node.js](https://nodejs.org/) — JavaScript runtime for the backend.
- [Express](https://expressjs.com/) — Web framework for handling API routes and serving the frontend.
- [MySQL](https://www.mysql.com/) — Relational database for storing collection data.
- [MySQL2](https://github.com/sidorares/node-mysql2) — MySQL client for Node.js.
- [jQuery](https://jquery.com/) — DOM manipulation, event handling, and AJAX requests.
- [Bootstrap](https://getbootstrap.com/) — Responsive UI components and styling.
- [Bootswatch](https://bootswatch.com/) — Bootstrap themes and visual styling.
- [Nodemon](https://nodemon.io/) — Automatically restarts the backend during development.
- [Docker](https://www.docker.com/) — Containerization for the development environment.
