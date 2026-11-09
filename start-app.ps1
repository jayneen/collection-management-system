# Start the Docker containers
Write-Host "Starting database and backend..." -ForegroundColor Cyan

docker compose up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker failed to start." -ForegroundColor Red
    exit 1
}

Write-Host "Starting frontend..." -ForegroundColor Cyan

# Start the frontend and open the entry page
npx --yes live-server ./frontend --port=5500 --open=/viewGames.html
