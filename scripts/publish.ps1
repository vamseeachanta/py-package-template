# PyPI Deployment Script for py-package-template (PowerShell)
# This script handles building and publishing the package to PyPI

param(
    [Parameter()]
    [switch]$Test,
    
    [Parameter()]
    [switch]$Prod,
    
    [Parameter()]
    [switch]$CheckOnly,
    
    [Parameter()]
    [switch]$Help
)

$ErrorActionPreference = "Stop"

# Configuration
$TEST_PYPI_URL = "https://test.pypi.org/legacy/"
$PROD_PYPI_URL = "https://upload.pypi.org/legacy/"

Write-Host "🚀 PyPI Publishing Script for py-package-template" -ForegroundColor Blue
Write-Host "================================================" -ForegroundColor Blue
Write-Host ""

# Function to check if command exists
function Test-Command {
    param($CommandName)
    $null = Get-Command $CommandName -ErrorAction SilentlyContinue
    return $?
}

# Function to show usage
function Show-Usage {
    Write-Host "Usage: .\publish.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Test           Publish to Test PyPI (https://test.pypi.org/)"
    Write-Host "  -Prod           Publish to Production PyPI (default)"
    Write-Host "  -CheckOnly      Only build and check package, don't publish"
    Write-Host "  -Help           Show this help message"
    Write-Host ""
    Write-Host "Environment variables:"
    Write-Host "  `$env:PYPI_API_TOKEN      Your PyPI API token (required for production)"
    Write-Host "  `$env:TEST_PYPI_API_TOKEN Your Test PyPI API token (required for test)"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\publish.ps1 -Test        # Publish to Test PyPI"
    Write-Host "  .\publish.ps1 -Prod        # Publish to Production PyPI"
    Write-Host "  .\publish.ps1 -CheckOnly   # Only build and verify package"
}

# Function to clean previous builds
function Clean-Build {
    Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
    
    if (Test-Path "dist") { Remove-Item "dist" -Recurse -Force }
    if (Test-Path "build") { Remove-Item "build" -Recurse -Force }
    Get-ChildItem -Name "*.egg-info" | ForEach-Object { Remove-Item $_ -Recurse -Force }
    
    Write-Host "✅ Build artifacts cleaned" -ForegroundColor Green
}

# Function to build package
function Build-Package {
    Write-Host "📦 Building package..." -ForegroundColor Yellow
    
    try {
        if (Test-Command uv) {
            Write-Host "Using uv for building..."
            uv sync --extra build
            uv run python -m build
        }
        else {
            Write-Host "Using pip for building..."
            python -m pip install --upgrade build twine
            python -m build
        }
        
        Write-Host "✅ Package built successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Build failed: $_" -ForegroundColor Red
        exit 1
    }
}

# Function to check package
function Test-Package {
    Write-Host "🔍 Checking package with twine..." -ForegroundColor Yellow
    
    try {
        if (Test-Command uv) {
            uv run twine check dist/*
        }
        else {
            python -m twine check dist/*
        }
        
        Write-Host "✅ Package check passed" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Package check failed: $_" -ForegroundColor Red
        exit 1
    }
}

# Function to list package contents
function Show-PackageContents {
    Write-Host "📋 Package contents:" -ForegroundColor Blue
    Get-ChildItem -Path "dist" | Format-Table -AutoSize
    Write-Host ""
}

# Function to publish to PyPI
function Publish-Package {
    param(
        [string]$RepositoryUrl,
        [string]$TokenVarName,
        [string]$RepoName
    )
    
    Write-Host "🚀 Publishing to $RepoName..." -ForegroundColor Yellow
    
    # Get token from environment variable
    $token = [Environment]::GetEnvironmentVariable($TokenVarName)
    
    # Check for API token
    if ([string]::IsNullOrEmpty($token)) {
        Write-Host "❌ Error: $TokenVarName environment variable not set" -ForegroundColor Red
        Write-Host "Please set your API token:"
        Write-Host "`$env:$TokenVarName = 'pypi-...'"
        exit 1
    }
    
    # Publish package
    try {
        if (Test-Command uv) {
            uv run twine upload --repository-url $RepositoryUrl --username __token__ --password $token dist/*
        }
        else {
            python -m twine upload --repository-url $RepositoryUrl --username __token__ --password $token dist/*
        }
        
        Write-Host "✅ Package published successfully to $RepoName!" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Publication failed: $_" -ForegroundColor Red
        exit 1
    }
}

# Show help if requested
if ($Help) {
    Show-Usage
    exit 0
}

# Determine publish target
$PublishTarget = "prod"
if ($Test) {
    $PublishTarget = "test"
}
elseif ($Prod) {
    $PublishTarget = "prod"
}

# Main execution
function Main {
    Write-Host "Configuration:" -ForegroundColor Blue
    Write-Host "  Target: $PublishTarget"
    Write-Host "  Check only: $CheckOnly"
    Write-Host ""
    
    # Clean previous builds
    Clean-Build
    
    # Build package
    Build-Package
    
    # Check package
    Test-Package
    
    # List package contents
    Show-PackageContents
    
    # Exit if check-only mode
    if ($CheckOnly) {
        Write-Host "🎉 Package build and check completed successfully!" -ForegroundColor Green
        Write-Host "Run without -CheckOnly to publish."
        exit 0
    }
    
    # Publish package
    if ($PublishTarget -eq "test") {
        Publish-Package -RepositoryUrl $TEST_PYPI_URL -TokenVarName "TEST_PYPI_API_TOKEN" -RepoName "Test PyPI"
        Write-Host ""
        Write-Host "🎉 Package published to Test PyPI!" -ForegroundColor Green
        Write-Host "View at: https://test.pypi.org/project/py-package-template/"
        Write-Host ""
        Write-Host "To install from Test PyPI:"
        Write-Host "pip install --index-url https://test.pypi.org/simple/ py-package-template"
    }
    else {
        # Confirm production publish
        Write-Host "⚠️  You are about to publish to Production PyPI!" -ForegroundColor Yellow
        Write-Host "This action cannot be undone. Are you sure? (y/N)"
        $confirmation = Read-Host
        if ($confirmation -notmatch "^[Yy]$") {
            Write-Host "❌ Publication cancelled." -ForegroundColor Yellow
            exit 0
        }
        
        Publish-Package -RepositoryUrl $PROD_PYPI_URL -TokenVarName "PYPI_API_TOKEN" -RepoName "Production PyPI"
        Write-Host ""
        Write-Host "🎉 Package published to Production PyPI!" -ForegroundColor Green
        Write-Host "View at: https://pypi.org/project/py-package-template/"
        Write-Host ""
        Write-Host "To install:"
        Write-Host "pip install py-package-template"
    }
}

# Run main function
Main