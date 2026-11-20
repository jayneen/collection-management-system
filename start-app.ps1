Write-Host "Starting database and backend..." -ForegroundColor Cyan

docker compose up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker failed to start." -ForegroundColor Red
    exit 1
}

# Wait until the backend answers (up to ~30 seconds)
$url = "http://127.0.0.1:2000/menu.html"
$ready = $false
for ($i = 0; $i -lt 30; $i++) {
    try {
        Invoke-WebRequest $url -UseBasicParsing -TimeoutSec 2 | Out-Null
        $ready = $true
        break
    } catch {
        Start-Sleep -Seconds 1
    }
}

if (-not $ready) {
    Write-Host "Backend did not respond in time. Check: docker compose logs backend" -ForegroundColor Red
    exit 1
}

Write-Host "Opening app..." -ForegroundColor Cyan
$profileDir = Join-Path $env:TEMP "collection-app-profile"
$browser = Start-Process "msedge" `
    -ArgumentList "--app=$url", "--user-data-dir=`"$profileDir`"", "--no-first-run" `
    -PassThru

Write-Host "Application is running. Use Quit in the app (or press Ctrl+C here) to stop." -ForegroundColor Green

try {
    while ($true) {
        if ($browser.HasExited) { break }   # window was closed

        $running = docker inspect -f "{{.State.Running}}" collection-backend 2>$null
        if ($running -ne "true") { break }  # Quit button was used

        Start-Sleep -Milliseconds 500
    }
}
finally {
    if ($browser -and -not $browser.HasExited) {
        taskkill /PID $browser.Id /T /F | Out-Null
    }

    Write-Host "Stopping application..." -ForegroundColor Cyan
    docker compose stop | Out-Null     # stops backend and db

    Write-Host ""
    Write-Host "Application closed." -ForegroundColor Cyan
}