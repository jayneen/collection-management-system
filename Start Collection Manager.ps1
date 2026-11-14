
$ErrorActionPreference = "Stop"

# Locate application folders
$AppRoot = $PSScriptRoot
$MySQL = Join-Path $AppRoot "runtime\mysql"
$Application = Join-Path $AppRoot "application"
$Backend = Join-Path $Application "backend"
$Frontend = Join-Path $Application "frontend"

# Build MySQL paths relative to the USB drive
$MySQLData = Join-Path $AppRoot "data\mysql"
$MySQLConfig = Join-Path $MySQL "my.ini"
$FirstLaunch = -not (Test-Path $MySQLData)

# Generate MySQL configuration using the current drive location
@"
[mysqld]
basedir=$($MySQL.Replace('\', '/'))
datadir=$($MySQLData.Replace('\', '/'))
log-error=$($MySQLData.Replace('\', '/'))/mysql-error.log
port=3307
bind-address=127.0.0.1
mysqlx=0
"@ | Set-Content -Path $MySQLConfig -Encoding ASCII

# Database settings
$env:DB_HOST = "127.0.0.1"
$env:DB_PORT = "3307"
$env:DB_USERNAME = "root"
$env:DB_NAME = "game_collection"
$env:FRONTEND_PATH = $Frontend

$MySQLProcess = $null
$BackendProcess = $null

try {
    Write-Host "Starting Collection Manager..."

    $PasswordFile = Join-Path $AppRoot "database-password.txt"

    if (-not (Test-Path $PasswordFile)) {
        Write-Host "Generating database password..."

        $GeneratedPassword = [guid]::NewGuid().ToString("N")

        Set-Content -Path $PasswordFile `
            -Value $GeneratedPassword `
            -NoNewline
    }

    $env:DB_PASSWORD = (Get-Content $PasswordFile -Raw).Trim()


    # Initialize MySQL the first time the application runs
    if ($FirstLaunch) {
        Write-Host "First launch detected. Initializing the database..."

        New-Item -ItemType Directory -Force `
            -Path (Split-Path $MySQLData) | Out-Null

        & (Join-Path $MySQL "bin\mysqld.exe") `
            --defaults-file="$MySQLConfig" `
            --initialize-insecure `
            --console

        if ($LASTEXITCODE -ne 0) {
            throw "MySQL database initialization failed."
        }

        Write-Host "MySQL database initialized."
    }


    # Start MySQL in the background
    $MySQLProcess = Start-Process `
        -FilePath (Join-Path $MySQL "bin\mysqld.exe") `
        -ArgumentList "--defaults-file=`"$MySQL\my.ini`"" `
        -WorkingDirectory $MySQL `
        -WindowStyle Hidden `
        -PassThru

    # Wait for MySQL to accept connections
    $Ready = $false

    for ($i = 0; $i -lt 30; $i++) {
        $Client = [System.Net.Sockets.TcpClient]::new()

        try {
            $Client.Connect("127.0.0.1", 3307)
            $Ready = $true
            break
        }
        catch {
            Start-Sleep -Seconds 1
        }
        finally {
            $Client.Dispose()
        }

        $MySQLProcess.Refresh()
        if ($MySQLProcess.HasExited) {
            throw "MySQL stopped unexpectedly. Check its error log."
        }
    }

    if (-not $Ready) {
        throw "MySQL did not become ready within 30 seconds."
    }

    Write-Host "MySQL is ready."

    # Initial MySQL root password setup and database creation
    if ($FirstLaunch) {
        Write-Host "Setting up the database password..."

        & (Join-Path $MySQL "bin\mysql.exe") `
            -h 127.0.0.1 `
            -P 3307 `
            -u root `
            --execute="ALTER USER 'root'@'localhost' IDENTIFIED BY '$env:DB_PASSWORD';"

        if ($LASTEXITCODE -ne 0) {
            throw "Could not configure the MySQL root password."
        }

        Write-Host "Database password configured."


        # Create the application database
        Write-Host "Creating the game_collection database..."

        & (Join-Path $MySQL "bin\mysql.exe") `
            -h 127.0.0.1 `
            -P 3307 `
            -u root `
            "-p$env:DB_PASSWORD" `
            --execute="CREATE DATABASE game_collection;"

        if ($LASTEXITCODE -ne 0) {
            throw "Could not create the application database."
        }

        # Import the application tables and data
        $SQLFile = Join-Path $AppRoot "database\game_collection.sql"

        if (-not (Test-Path $SQLFile)) {
            throw "Database setup file not found: $SQLFile"
        }

        Write-Host "Importing application data..."

        Get-Content -Path $SQLFile -Raw |
            & (Join-Path $MySQL "bin\mysql.exe") `
                -h 127.0.0.1 `
                -P 3307 `
                -u root `
                "-p$env:DB_PASSWORD" `
                game_collection

        if ($LASTEXITCODE -ne 0) {
            throw "Database import failed."
        }

        Write-Host "Database setup completed."
    }

    # Use the Node.js version bundled with the application
    $Node = Join-Path $AppRoot "runtime\node\node.exe"

    if (-not (Test-Path $Node)) {
        throw "Bundled Node.js runtime was not found: $Node"
    }

    $BackendProcess = Start-Process `
        -FilePath $Node `
        -ArgumentList "index.js" `
        -WorkingDirectory $Backend `
        -PassThru `
        -NoNewWindow

    # Open the application in the default browser
    Start-Sleep -Seconds 2
    Start-Process "http://localhost:2000/viewGames.html"

    Write-Host ""
    Write-Host "Collection Manager is running."
    Write-Host "Open http://localhost:2000/viewGames.html"
    Write-Host "Press Ctrl+C here to stop."
    Write-Host ""

    # Wait while backend is running
    while (-not $BackendProcess.HasExited) {
        Start-Sleep -Milliseconds 500
        $BackendProcess.Refresh()
    }

    if ($BackendProcess.ExitCode -ne 0) {
        Write-Warning "The backend exited with an error."
    }
}
finally {
    Write-Host ""
    Write-Host "Stopping Collection Manager..."

    # Stop backend first
    if ($BackendProcess -and -not $BackendProcess.HasExited) {
        Stop-Process -Id $BackendProcess.Id -Force -ErrorAction SilentlyContinue
        $BackendProcess.WaitForExit()
    }

    # Shut down MySQL cleanly
    if ($MySQLProcess -and -not $MySQLProcess.HasExited) {
        Write-Host "Shutting down database..."

        & (Join-Path $MySQL "bin\mysqladmin.exe") `
            -h 127.0.0.1 `
            -P 3307 `
            -u root `
            "-p$env:DB_PASSWORD" `
            shutdown

        if ($LASTEXITCODE -ne 0) {
            Write-Warning "MySQL did not confirm shutdown. Check its error log."
        }
    }

    Remove-Item Env:DB_PASSWORD -ErrorAction SilentlyContinue

    Write-Host "Collection Manager stopped."
}
