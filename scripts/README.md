# PyPI Deployment Scripts - Quick Reference

This directory contains scripts for deploying the py-package-template to PyPI.

## Available Scripts

### 📦 Publishing Scripts

| Script | Platform | Purpose |
|--------|----------|---------|
| `publish.sh` | Linux/macOS | Build and publish package to PyPI |
| `publish.ps1` | Windows | Build and publish package to PyPI |

**Usage Examples:**
```bash
# Linux/macOS
./scripts/publish.sh --help
./scripts/publish.sh --check-only    # Build and verify only
./scripts/publish.sh --test          # Publish to Test PyPI
./scripts/publish.sh --prod          # Publish to Production PyPI

# Windows PowerShell
.\scripts\publish.ps1 -Help
.\scripts\publish.ps1 -CheckOnly     # Build and verify only
.\scripts\publish.ps1 -Test          # Publish to Test PyPI
.\scripts\publish.ps1 -Prod          # Publish to Production PyPI
```

### 🚀 Release Scripts

| Script | Platform | Purpose |
|--------|----------|---------|
| `release.sh` | Linux/macOS | Complete release workflow with version bumping |
| `release.ps1` | Windows | Complete release workflow with version bumping |

**Usage Examples:**
```bash
# Linux/macOS
./scripts/release.sh --help
./scripts/release.sh patch --dry-run    # Preview patch release
./scripts/release.sh minor --test       # Minor release to Test PyPI
./scripts/release.sh major --prod       # Major release to Production PyPI

# Windows PowerShell
.\scripts\release.ps1 -Help
.\scripts\release.ps1 patch -DryRun     # Preview patch release
.\scripts\release.ps1 minor -Test       # Minor release to Test PyPI
.\scripts\release.ps1 major -Prod       # Major release to Production PyPI
```

## Prerequisites

### API Tokens (Required for Publishing)

Set environment variables with your PyPI API tokens:

```bash
# Production PyPI (required for --prod releases)
export PYPI_API_TOKEN="pypi-..."

# Test PyPI (required for --test releases)
export TEST_PYPI_API_TOKEN="pypi-..."
```

**Windows PowerShell:**
```powershell
$env:PYPI_API_TOKEN = "pypi-..."
$env:TEST_PYPI_API_TOKEN = "pypi-..."
```

### Dependencies

The scripts work with both `uv` and traditional `pip` workflows:

- **With uv**: `uv sync --extra build`
- **With pip**: Dependencies installed automatically as needed

## Quick Start

1. **First-time setup:**
   ```bash
   # Get API tokens from PyPI
   # Set environment variables
   export PYPI_API_TOKEN="your-token-here"
   ```

2. **Test your package build:**
   ```bash
   ./scripts/publish.sh --check-only
   ```

3. **Test deployment:**
   ```bash
   ./scripts/release.sh patch --test
   ```

4. **Production release:**
   ```bash
   ./scripts/release.sh patch --prod
   ```

## Integration with GitHub Actions

The repository also includes automated PyPI publishing via GitHub Actions:

1. Set `PYPI_API_TOKEN` secret in your GitHub repository
2. Create and push a git tag: `git tag v1.0.0 && git push origin v1.0.0`
3. GitHub Actions will automatically build and publish to PyPI

## Documentation

For detailed information, see:
- [`docs/pypi_deployment.md`](../docs/pypi_deployment.md) - Complete deployment guide
- [`docs/uv_best_practices_implementation.md`](../docs/uv_best_practices_implementation.md) - uv workflow guide

## Script Features

✅ **Cross-platform support** (Linux, macOS, Windows)  
✅ **Dual workflow support** (uv and pip)  
✅ **Test PyPI and Production PyPI** deployment  
✅ **Dry-run mode** for safe testing  
✅ **Automatic version bumping** with semantic versioning  
✅ **Git integration** with automatic tagging  
✅ **Interactive confirmations** for production releases  
✅ **Comprehensive error handling** and colored output  
✅ **Security best practices** for API token management