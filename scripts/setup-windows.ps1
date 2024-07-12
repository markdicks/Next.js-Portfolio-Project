# PowerShell Script for Setting up Node.js Environment on Windows

# Create a log directory
$logDirectory = Join-Path -Path $PSScriptRoot -ChildPath "setup-log"
$logFile = Join-Path -Path $logDirectory -ChildPath "install_log.txt"
# Attempt to create the directory and handle any errors
try {
    New-Item -ItemType Directory -Force -Path $logDirectory -ErrorAction Stop
} catch {
    Write-Error "Failed to create log directory: $_"
    Exit
}

# Function to write to log
Function Write-Log {
    Param ([string]$message)
    "$message" | Tee-Object -FilePath $logFile -Append
}

# Install fnm using winget
Write-Log "Starting installation of fnm..."
winget install Schniz.fnm | Out-String | Tee-Object -FilePath $logFile

# Install and set Node.js version
Write-Log "Setting up Node.js version 20..."
fnm install 20 | Out-String | Tee-Object -FilePath $logFile
fnm use 20 | Out-String | Tee-Object -FilePath $logFile

# Check Node.js and npm versions
$nodeVersion = node -v
$npmVersion = npm -v
Write-Log "Node.js version: $nodeVersion"
Write-Log "npm version: $npmVersion"

# Install dependencies
Write-Log "Installing project dependencies..."
npm install --save-dev framer-motion three react-intersection-observer @react-three/drei @react-three/fiber | Out-String | Tee-Object -FilePath $logFile

# Verify installation of each package
$dependencies = @("framer-motion", "three", "react-intersection-observer", "@react-three/drei", "@react-three/fiber")
foreach ($dep in $dependencies) {
    if (npm list --depth=0 | Select-String $dep) {
        Write-Log "$dep installation success."
    } else {
        Write-Log "$dep installation failed."
    }
}

Write-Log "Setup complete!"

# Ask to keep the log
$userChoice = Read-Host "Installation complete. Do you want to save the installation log? (y/n)"
if ($userChoice -ne 'y') {
    Remove-Item $logFile
    Remove-Item $logDirectory
    Write-Host "Log discarded."
} else {
    Write-Host "Log saved in $logFile."
}
