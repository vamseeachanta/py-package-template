# uv Migration and Setup Script for Windows PowerShell
# This script helps migrate from pip-based workflow to uv-based workflow

param(
    [Parameter(Position=0)]
    [ValidateSet("setup", "check", "build", "help", "all")]
    [string]$Command = "setup"
)

Write-Host "🚀 py-package-template uv Migration Script" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Function to check if command exists
function Test-Command {
    param($CommandName)
    $null = Get-Command $CommandName -ErrorAction SilentlyContinue
    return $?
}

# Function to install uv
function Install-Uv {
    Write-Host "📦 Installing uv..." -ForegroundColor Yellow
    try {
        Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression
        Write-Host "✅ uv installed successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to install uv: $_" -ForegroundColor Red
        exit 1
    }
}

# Function to setup development environment
function Setup-DevEnvironment {
    Write-Host "🔧 Setting up development environment with uv..." -ForegroundColor Yellow
    
    try {
        # Install Python if needed
        Write-Host "🐍 Installing Python 3.11..." -ForegroundColor Cyan
        uv python install 3.11
        
        # Pin Python version for project
        Write-Host "📌 Pinning Python version..." -ForegroundColor Cyan
        uv python pin 3.11
        
        # Sync all dependencies including dev dependencies
        Write-Host "📚 Installing project dependencies..." -ForegroundColor Cyan
        uv sync --extra dev --extra docs --extra build
        
        # Install pre-commit hooks
        Write-Host "🎣 Installing pre-commit hooks..." -ForegroundColor Cyan
        uv run pre-commit install
        
        Write-Host "✅ Development environment setup complete" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Setup failed: $_" -ForegroundColor Red
        exit 1
    }
}

# Function to run quality checks
function Invoke-QualityChecks {
    Write-Host "🔍 Running quality checks..." -ForegroundColor Yellow
    
    try {
        # Format code
        Write-Host "🎨 Formatting code with black..." -ForegroundColor Cyan
        uv run black .
        
        # Sort imports
        Write-Host "📋 Sorting imports with isort..." -ForegroundColor Cyan
        uv run isort .
        
        # Type checking
        Write-Host "🔍 Running type checks with mypy..." -ForegroundColor Cyan
        try {
            uv run mypy src/
        }
        catch {
            Write-Host "⚠️  MyPy found issues (this is normal for initial setup)" -ForegroundColor Yellow
        }
        
        # Run tests
        Write-Host "🧪 Running tests..." -ForegroundColor Cyan
        uv run pytest --cov=src/ --cov-report=term-missing
        
        Write-Host "✅ Quality checks complete" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Quality checks failed: $_" -ForegroundColor Red
        exit 1
    }
}

# Function to build package
function Build-Package {
    Write-Host "📦 Building package..." -ForegroundColor Yellow
    
    try {
        uv run python -m build
        uv run twine check dist/*
        Write-Host "✅ Package built successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Build failed: $_" -ForegroundColor Red
        exit 1
    }
}

# Function to show helpful commands
function Show-HelpfulCommands {
    Write-Host ""
    Write-Host "🎯 Helpful uv commands for daily development:" -ForegroundColor Green
    Write-Host "=============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "📚 Dependency Management:" -ForegroundColor Cyan
    Write-Host "  uv add <package>           # Add a dependency"
    Write-Host "  uv add --dev <package>     # Add a dev dependency"
    Write-Host "  uv remove <package>        # Remove a dependency"
    Write-Host "  uv sync                    # Install all dependencies"
    Write-Host "  uv tree                    # Show dependency tree"
    Write-Host ""
    Write-Host "🏃 Running Code:" -ForegroundColor Cyan
    Write-Host "  uv run python script.py    # Run a Python script"
    Write-Host "  uv run pytest             # Run tests"
    Write-Host "  uv run black .            # Format code"
    Write-Host "  uv run mypy src/          # Type checking"
    Write-Host ""
    Write-Host "📦 Package Management:" -ForegroundColor Cyan
    Write-Host "  uv run python -m build    # Build package"
    Write-Host "  uv run bumpver update --patch  # Bump version"
    Write-Host ""
    Write-Host "🔄 Environment Management:" -ForegroundColor Cyan
    Write-Host "  uv python list            # List available Python versions"
    Write-Host "  uv python install 3.12   # Install Python 3.12"
    Write-Host "  uv cache clean            # Clean cache"
    Write-Host ""
}

# Main execution
function Main {
    Write-Host "Starting uv migration process..." -ForegroundColor Cyan
    Write-Host ""
    
    # Check if uv is installed
    if (-not (Test-Command uv)) {
        Write-Host "❌ uv not found. Installing uv..." -ForegroundColor Red
        Install-Uv
        
        # Reload environment
        Write-Host "🔄 Please restart PowerShell and run this script again to continue." -ForegroundColor Yellow
        exit 0
    }
    else {
        Write-Host "✅ uv is already installed" -ForegroundColor Green
        uv --version
    }
    
    Write-Host ""
    
    # Execute based on command
    switch ($Command) {
        "setup" {
            Setup-DevEnvironment
        }
        "check" {
            Invoke-QualityChecks
        }
        "build" {
            Build-Package
        }
        "help" {
            Show-HelpfulCommands
        }
        "all" {
            Setup-DevEnvironment
            Invoke-QualityChecks
            Build-Package
        }
        default {
            Write-Host "❌ Unknown command: $Command" -ForegroundColor Red
            Write-Host ""
            Write-Host "Usage: .\uv-migrate.ps1 [command]"
            Write-Host ""
            Write-Host "Commands:"
            Write-Host "  setup  (default) - Set up development environment"
            Write-Host "  check           - Run quality checks (format, lint, test)"
            Write-Host "  build           - Build package"
            Write-Host "  help            - Show helpful uv commands"
            Write-Host "  all             - Run setup, check, and build"
            exit 1
        }
    }
    
    Write-Host ""
    Write-Host "🎉 Migration task completed successfully!" -ForegroundColor Green
    
    if ($Command -eq "setup") {
        Show-HelpfulCommands
    }
}

# Run main function
Main
