#!/usr/bin/env pwsh
# PowerShell Make Simulator
# For executing Makefile commands on Windows

param(
    [string]$Target = "help"
)

# Get Makefile path in current directory
$MakefilePath = Join-Path $PWD "Makefile"

if (-not (Test-Path $MakefilePath)) {
    Write-Error "Makefile not found in current directory: $PWD"
    exit 1
}

# Parse and execute target
switch ($Target) {
    "help" {
        Write-Host "Vue + Go/Gin + Rust Demo Project"
        Write-Host ""
        Write-Host "Available commands:"
        Write-Host "  install    - Install all dependencies"
        Write-Host "  build      - Build all projects"
        Write-Host "  run        - Run backend service"
        Write-Host "  dev        - Development mode"
        Write-Host "  test       - Run tests"
        Write-Host "  clean      - Clean build files"
    }
    "install" {
        Write-Host "Installing dependencies..."
        Set-Location "frontend"
        npm install
        Set-Location ".."
        Set-Location "backend"
        go mod tidy
        Set-Location ".."
        Set-Location "tools"
        cargo build
        Set-Location ".."
    }
    "build" {
        Write-Host "Building all projects..."
        # Frontend
        Write-Host "Building Vue frontend..."
        Set-Location "frontend"
        npm run build
        Set-Location ".."
        # Backend
        Write-Host "Building Go backend..."
        Set-Location "backend"
        go build -o bin/server .
        Set-Location ".."
        # Tools
        Write-Host "Building Rust tools..."
        Set-Location "tools"
        cargo build --release
        Set-Location ".."
    }
    "run" {
        Set-Location "backend"
        go run .
        Set-Location ".."
    }
    "dev" {
        Write-Host "Starting development servers..."
        Write-Host "Frontend: http://localhost:5173"
        Write-Host "Backend: http://localhost:8080"
        
        # Start frontend dev server (background)
        Start-Process -FilePath "powershell" -ArgumentList "-Command", "cd frontend; npm run dev" -WindowStyle Hidden
        
        # Start backend server
        Set-Location "backend"
        go run .
        Set-Location ".."
    }
    "test" {
        Set-Location "backend"
        go test ./...
        Set-Location ".."
        Set-Location "tools"
        cargo test
        Set-Location ".."
    }
    "clean" {
        Write-Host "Cleaning build files..."
        if (Test-Path "frontend/dist") { Remove-Item -Recurse -Force "frontend/dist" }
        if (Test-Path "backend/bin") { Remove-Item -Recurse -Force "backend/bin" }
        if (Test-Path "tools/target") { Remove-Item -Recurse -Force "tools/target" }
    }
    default {
        Write-Error "Unknown target: $Target"
        Write-Host "Use './make.ps1 help' to see available commands"
        exit 1
    }
}