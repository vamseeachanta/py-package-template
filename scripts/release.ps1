# Automated Release Script for py-package-template (PowerShell)
# This script handles version bumping, git tagging, and publishing to PyPI

param(
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateSet("patch", "minor", "major")]
    [string]$VersionType,
    
    [Parameter()]
    [switch]$Test,
    
    [Parameter()]
    [switch]$Prod,
    
    [Parameter()]
    [switch]$DryRun,
    
    [Parameter()]
    [switch]$NoPublish,
    
    [Parameter()]
    [switch]$Help
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Automated Release Script for py-package-template" -ForegroundColor Blue
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
    Write-Host "Usage: .\release.ps1 [version_type] [options]"
    Write-Host ""
    Write-Host "Version types:"
    Write-Host "  patch    Increment patch version (0.0.1 -> 0.0.2)"
    Write-Host "  minor    Increment minor version (0.0.1 -> 0.1.0)"
    Write-Host "  major    Increment major version (0.0.1 -> 1.0.0)"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Test           Release to Test PyPI only"
    Write-Host "  -Prod           Release to Production PyPI (default)"
    Write-Host "  -DryRun         Show what would be done without making changes"
    Write-Host "  -NoPublish      Only bump version and create tag, don't publish"
    Write-Host "  -Help           Show this help message"
    Write-Host ""
    Write-Host "Environment variables:"
    Write-Host "  `$env:PYPI_API_TOKEN      Your PyPI API token (required for production)"
    Write-Host "  `$env:TEST_PYPI_API_TOKEN Your Test PyPI API token (required for test)"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\release.ps1 patch            # Bump patch version and release to PyPI"
    Write-Host "  .\release.ps1 minor -Test      # Bump minor version and release to Test PyPI"
    Write-Host "  .\release.ps1 major -DryRun    # Show what would be done for major release"
}

# Function to check git status
function Test-GitStatus {
    Write-Host "🔍 Checking git status..." -ForegroundColor Yellow
    
    # Check if we're in a git repository
    try {
        git rev-parse --git-dir | Out-Null
    }
    catch {
        Write-Host "❌ Not in a git repository" -ForegroundColor Red
        exit 1
    }
    
    # Check for uncommitted changes
    $gitStatus = git status --porcelain
    if ($gitStatus) {
        Write-Host "❌ There are uncommitted changes. Please commit or stash them first." -ForegroundColor Red
        exit 1
    }
    
    # Check current branch
    $currentBranch = git branch --show-current
    if ($currentBranch -notin @("main", "master")) {
        Write-Host "⚠️  Warning: You are not on main/master branch (current: $currentBranch)" -ForegroundColor Yellow
        $confirmation = Read-Host "Continue anyway? (y/N)"
        if ($confirmation -notmatch "^[Yy]$") {
            Write-Host "❌ Release cancelled." -ForegroundColor Yellow
            exit 0
        }
    }
    
    Write-Host "✅ Git status check passed" -ForegroundColor Green
}

# Function to get current version
function Get-CurrentVersion {
    try {
        if (Test-Command uv) {
            $output = uv run bumpver show
            $versionLine = $output | Select-String "current_version"
            return ($versionLine -split "=")[1].Trim().Trim('"')
        }
        else {
            $config = Get-Content "pyproject.toml" | ConvertFrom-StringData
            # Simple toml parsing for version
            $content = Get-Content "pyproject.toml" -Raw
            if ($content -match 'current_version\s*=\s*"([^"]+)"') {
                return $matches[1]
            }
        }
    }
    catch {
        Write-Host "❌ Could not determine current version: $_" -ForegroundColor Red
        exit 1
    }
}

# Function to bump version
function Update-Version {
    param(
        [string]$VersionType,
        [bool]$IsDryRun
    )
    
    Write-Host "📈 Bumping $VersionType version..." -ForegroundColor Yellow
    
    if ($IsDryRun) {
        Write-Host "Dry run mode - would execute:"
        if (Test-Command uv) {
            Write-Host "uv run bumpver update --$VersionType --dry"
        }
        else {
            Write-Host "bumpver update --$VersionType --dry"
        }
        return
    }
    
    # Get current version
    $currentVersion = Get-CurrentVersion
    Write-Host "Current version: $currentVersion"
    
    # Bump version
    try {
        if (Test-Command uv) {
            uv run bumpver update --$VersionType
        }
        else {
            bumpver update --$VersionType
        }
        
        # Get new version
        $newVersion = Get-CurrentVersion
        Write-Host "✅ Version bumped from $currentVersion to $newVersion" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Version bump failed: $_" -ForegroundColor Red
        exit 1
    }
}

# Function to run tests
function Invoke-Tests {
    Write-Host "🧪 Running tests..." -ForegroundColor Yellow
    
    try {
        if (Test-Command uv) {
            try {
                uv run pytest --version | Out-Null
                uv run pytest
            }
            catch {
                Write-Host "No pytest found, skipping tests"
            }
        }
        else {
            if (Test-Command pytest) {
                pytest
            }
            else {
                Write-Host "No pytest found, skipping tests"
            }
        }
        
        Write-Host "✅ Tests passed" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Tests failed: $_" -ForegroundColor Red
        exit 1
    }
}

# Function to create git tag
function New-GitTag {
    param([bool]$IsDryRun)
    
    $version = Get-CurrentVersion
    $tagName = "v$version"
    
    Write-Host "🏷️  Creating git tag: $tagName" -ForegroundColor Yellow
    
    if ($IsDryRun) {
        Write-Host "Dry run mode - would execute:"
        Write-Host "git tag -a $tagName -m `"Release version $version`""
        return
    }
    
    try {
        git tag -a $tagName -m "Release version $version"
        Write-Host "✅ Git tag created: $tagName" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Git tag creation failed: $_" -ForegroundColor Red
        exit 1
    }
}

# Function to push changes
function Push-Changes {
    param([bool]$IsDryRun)
    
    Write-Host "📤 Pushing changes to remote..." -ForegroundColor Yellow
    
    if ($IsDryRun) {
        Write-Host "Dry run mode - would execute:"
        Write-Host "git push origin main --tags"
        return
    }
    
    try {
        $currentBranch = git branch --show-current
        git push origin $currentBranch --tags
        Write-Host "✅ Changes pushed to remote" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Push failed: $_" -ForegroundColor Red
        exit 1
    }
}

# Function to publish package
function Publish-Package {
    param(
        [string]$Target,
        [bool]$IsDryRun
    )
    
    if ($IsDryRun) {
        Write-Host "Dry run mode - would execute:"
        Write-Host ".\scripts\publish.ps1 -$Target"
        return
    }
    
    # Use the publish script
    try {
        if ($Target -eq "test") {
            & ".\scripts\publish.ps1" -Test
        }
        else {
            & ".\scripts\publish.ps1" -Prod
        }
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
    Write-Host "  Version type: $VersionType"
    Write-Host "  Target: $PublishTarget"
    Write-Host "  Dry run: $DryRun"
    Write-Host "  No publish: $NoPublish"
    Write-Host ""
    
    # Check git status
    if (-not $DryRun) {
        Test-GitStatus
    }
    
    # Run tests first
    if (-not $DryRun) {
        Invoke-Tests
    }
    
    # Bump version
    Update-Version -VersionType $VersionType -IsDryRun $DryRun
    
    # Create git tag
    New-GitTag -IsDryRun $DryRun
    
    # Push changes
    Push-Changes -IsDryRun $DryRun
    
    # Publish package (unless no-publish flag is set)
    if (-not $NoPublish) {
        Write-Host ""
        Publish-Package -Target $PublishTarget -IsDryRun $DryRun
    }
    
    if ($DryRun) {
        Write-Host "🎉 Dry run completed! No changes were made." -ForegroundColor Blue
    }
    else {
        $newVersion = Get-CurrentVersion
        Write-Host ""
        Write-Host "🎉 Release completed successfully!" -ForegroundColor Green
        Write-Host "Version: $newVersion"
        if (-not $NoPublish) {
            if ($PublishTarget -eq "test") {
                Write-Host "Published to: Test PyPI"
                Write-Host "View at: https://test.pypi.org/project/py-package-template/"
            }
            else {
                Write-Host "Published to: Production PyPI"
                Write-Host "View at: https://pypi.org/project/py-package-template/"
            }
        }
    }
}

# Run main function
Main