# uv-test.ps1 - Test runner script using uv for py-package-template
# This script provides various testing options using uv package manager

param(
    [Parameter(Position=0)]
    [string]$Command = "basic"
)

# Colors for PowerShell output
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Blue"
    Cyan = "Cyan"
}

# Get script and project directories
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

Write-Host "=== py-package-template Test Runner (uv) ===" -ForegroundColor $Colors.Blue
Write-Host "Project root: $ProjectRoot"
Write-Host "Date: $(Get-Date)"
Write-Host ""

# Helper functions for colored output
function Write-Step {
    param([string]$Message)
    Write-Host ">>> $Message" -ForegroundColor $Colors.Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor $Colors.Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor $Colors.Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor $Colors.Red
}

# Function to check if uv is installed
function Test-UvInstalled {
    try {
        $uvVersion = uv --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "uv is installed: $uvVersion"
            return $true
        }
    }
    catch {
        # uv command not found
    }
    
    Write-Error "uv is not installed. Please install it first:"
    Write-Host "  PowerShell: powershell -c `"irm https://astral.sh/uv/install.ps1 | iex`""
    Write-Host "  Scoop: scoop install uv"
    exit 1
}

# Function to setup test environment
function Initialize-TestEnvironment {
    Write-Step "Setting up test environment..."
    Set-Location $ProjectRoot
    
    # Sync dependencies including dev dependencies
    uv sync --dev
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to sync dependencies"
        exit 1
    }
    Write-Success "Dependencies synchronized"
}

# Function to run basic tests
function Invoke-BasicTests {
    Write-Step "Running basic test suite..."
    Set-Location $ProjectRoot
    
    uv run pytest tests/ -v
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Basic tests failed"
        exit 1
    }
    Write-Success "Basic tests completed"
}

# Function to run tests with coverage
function Invoke-TestsWithCoverage {
    Write-Step "Running tests with coverage..."
    Set-Location $ProjectRoot
    
    uv run pytest tests/ --cov=src/py_package_template --cov-report=html --cov-report=term-missing -v
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Tests with coverage failed"
        exit 1
    }
    Write-Success "Tests with coverage completed"
    
    if (Test-Path "htmlcov") {
        Write-Success "Coverage report generated in htmlcov/ directory"
    }
}

# Function to run specific test categories
function Invoke-UnitTests {
    Write-Step "Running unit tests only..."
    Set-Location $ProjectRoot
    
    uv run pytest tests/ -m "unit" -v
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Unit tests failed"
        exit 1
    }
    Write-Success "Unit tests completed"
}

function Invoke-IntegrationTests {
    Write-Step "Running integration tests only..."
    Set-Location $ProjectRoot
    
    uv run pytest tests/ -m "integration" -v
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Integration tests failed"
        exit 1
    }
    Write-Success "Integration tests completed"
}

function Invoke-PerformanceTests {
    Write-Step "Running performance tests only..."
    Set-Location $ProjectRoot
    
    uv run pytest tests/ -m "performance" -v
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Performance tests failed"
        exit 1
    }
    Write-Success "Performance tests completed"
}

# Function to run tests in parallel
function Invoke-ParallelTests {
    Write-Step "Running tests in parallel..."
    Set-Location $ProjectRoot
    
    # Install pytest-xdist if not already installed
    uv add --dev pytest-xdist
    uv run pytest tests/ -n auto -v
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Parallel tests failed"
        exit 1
    }
    Write-Success "Parallel tests completed"
}

# Function to run linting and formatting checks
function Invoke-QualityChecks {
    Write-Step "Running code quality checks..."
    Set-Location $ProjectRoot
    
    Write-Step "Running black (code formatting)..."
    uv run black --check src/ tests/
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Black formatting check failed"
        exit 1
    }
    
    Write-Step "Running isort (import sorting)..."
    uv run isort --check-only src/ tests/
    if ($LASTEXITCODE -ne 0) {
        Write-Error "isort check failed"
        exit 1
    }
    
    Write-Step "Running mypy (type checking)..."
    uv run mypy src/py_package_template/
    if ($LASTEXITCODE -ne 0) {
        Write-Error "mypy check failed"
        exit 1
    }
    
    Write-Success "Code quality checks completed"
}

# Function to fix code formatting
function Repair-CodeFormatting {
    Write-Step "Fixing code formatting..."
    Set-Location $ProjectRoot
    
    Write-Step "Running black (code formatting)..."
    uv run black src/ tests/
    
    Write-Step "Running isort (import sorting)..."
    uv run isort src/ tests/
    
    Write-Success "Code formatting fixed"
}

# Function to run all tests and checks
function Invoke-FullTestSuite {
    Write-Step "Running full test suite..."
    Set-Location $ProjectRoot
    
    Initialize-TestEnvironment
    Invoke-QualityChecks
    Invoke-TestsWithCoverage
    Write-Success "Full test suite completed"
}

# Function to clean test artifacts
function Clear-TestArtifacts {
    Write-Step "Cleaning test artifacts..."
    Set-Location $ProjectRoot
    
    # Remove coverage files
    if (Test-Path "htmlcov") { Remove-Item -Recurse -Force "htmlcov" }
    if (Test-Path ".coverage") { Remove-Item -Force ".coverage" }
    
    # Remove pytest cache
    if (Test-Path ".pytest_cache") { Remove-Item -Recurse -Force ".pytest_cache" }
    
    # Remove mypy cache
    if (Test-Path ".mypy_cache") { Remove-Item -Recurse -Force ".mypy_cache" }
    
    # Remove Python cache
    Get-ChildItem -Recurse -Directory -Name "__pycache__" | ForEach-Object {
        Remove-Item -Recurse -Force $_
    }
    Get-ChildItem -Recurse -Filter "*.pyc" | Remove-Item -Force
    
    Write-Success "Test artifacts cleaned"
}

# Function to show usage
function Show-Usage {
    Write-Host "Usage: .\uv-test.ps1 [COMMAND]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  basic        Run basic test suite (default)"
    Write-Host "  coverage     Run tests with coverage report"
    Write-Host "  unit         Run unit tests only"
    Write-Host "  integration  Run integration tests only"
    Write-Host "  performance  Run performance tests only"
    Write-Host "  parallel     Run tests in parallel"
    Write-Host "  quality      Run code quality checks (black, isort, mypy)"
    Write-Host "  format       Fix code formatting issues"
    Write-Host "  full         Run full test suite (quality + coverage)"
    Write-Host "  clean        Clean test artifacts"
    Write-Host "  help         Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\uv-test.ps1                    # Run basic tests"
    Write-Host "  .\uv-test.ps1 coverage          # Run tests with coverage"
    Write-Host "  .\uv-test.ps1 quality           # Run quality checks"
    Write-Host "  .\uv-test.ps1 full              # Run everything"
}

# Main script logic
function Main {
    # Check if uv is installed
    Test-UvInstalled
    
    switch ($Command.ToLower()) {
        "basic" {
            Initialize-TestEnvironment
            Invoke-BasicTests
        }
        "coverage" {
            Initialize-TestEnvironment
            Invoke-TestsWithCoverage
        }
        "unit" {
            Initialize-TestEnvironment
            Invoke-UnitTests
        }
        "integration" {
            Initialize-TestEnvironment
            Invoke-IntegrationTests
        }
        "performance" {
            Initialize-TestEnvironment
            Invoke-PerformanceTests
        }
        "parallel" {
            Initialize-TestEnvironment
            Invoke-ParallelTests
        }
        "quality" {
            Initialize-TestEnvironment
            Invoke-QualityChecks
        }
        "format" {
            Initialize-TestEnvironment
            Repair-CodeFormatting
        }
        "full" {
            Invoke-FullTestSuite
        }
        "clean" {
            Clear-TestArtifacts
        }
        { $_ -in @("help", "-h", "--help") } {
            Show-Usage
        }
        default {
            Write-Error "Unknown command: $Command"
            Write-Host ""
            Show-Usage
            exit 1
        }
    }
}

# Run main function
Main
