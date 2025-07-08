# PyPI Deployment Demo

This document demonstrates the usage of the new PyPI deployment scripts.

## Demo Script Examples

### 1. Check Package Build (Safe to run anytime)

```bash
# Linux/macOS
./scripts/publish.sh --check-only

# Windows
.\scripts\publish.ps1 -CheckOnly
```

**Expected Output:**
```
🚀 PyPI Publishing Script for py-package-template
================================================

Configuration:
  Target: prod
  Check only: true

🧹 Cleaning previous builds...
✅ Build artifacts cleaned
📦 Building package...
✅ Package built successfully
🔍 Checking package with twine...
✅ Package check passed
📋 Package contents:
[package files listed]

🎉 Package build and check completed successfully!
```

### 2. Dry Run Release (Preview without changes)

```bash
# Linux/macOS
./scripts/release.sh patch --dry-run

# Windows
.\scripts\release.ps1 patch -DryRun
```

**Expected Output:**
```
🚀 Automated Release Script for py-package-template
================================================

Configuration:
  Version type: patch
  Target: prod
  Dry run: true
  No publish: false

📈 Bumping patch version...
Dry run mode - would execute:
bumpver update --patch --dry

🏷️  Creating git tag: v0.0.2
Dry run mode - would execute:
git tag -a v0.0.2 -m "Release version 0.0.2"

📤 Pushing changes to remote...
Dry run mode - would execute:
git push origin main --tags

Dry run mode - would execute:
./scripts/publish.sh --prod

🎉 Dry run completed! No changes were made.
```

### 3. Test PyPI Release (Safe testing)

```bash
# First, set up Test PyPI token
export TEST_PYPI_API_TOKEN="pypi-your-test-token"

# Linux/macOS
./scripts/release.sh patch --test

# Windows
$env:TEST_PYPI_API_TOKEN = "pypi-your-test-token"
.\scripts\release.ps1 patch -Test
```

### 4. Production Release

```bash
# Set up production token
export PYPI_API_TOKEN="pypi-your-production-token"

# Linux/macOS
./scripts/release.sh patch --prod

# Windows
$env:PYPI_API_TOKEN = "pypi-your-production-token"
.\scripts\release.ps1 patch -Prod
```

**Production Release Flow:**
1. ✅ Git status check (ensures clean working directory)
2. ✅ Run tests (if pytest available)
3. ✅ Bump version (patch: 0.0.1 → 0.0.2)
4. ✅ Create git tag (v0.0.2)
5. ✅ Push changes to remote
6. ✅ Build package
7. ✅ Check package with twine
8. ⚠️  Interactive confirmation for production
9. ✅ Upload to PyPI
10. 🎉 Success message with package URL

## Real-World Workflow

### Initial Setup (One-time)
```bash
# 1. Get API tokens from PyPI
# 2. Set environment variables
echo 'export PYPI_API_TOKEN="pypi-..."' >> ~/.bashrc
echo 'export TEST_PYPI_API_TOKEN="pypi-..."' >> ~/.bashrc
source ~/.bashrc

# 3. Validate setup
./scripts/test-deployment.sh
```

### Development Workflow
```bash
# 1. Make changes to code
# 2. Test locally
pytest

# 3. Check package builds
./scripts/publish.sh --check-only

# 4. Preview release
./scripts/release.sh patch --dry-run

# 5. Test on Test PyPI
./scripts/release.sh patch --test

# 6. Verify test installation
pip install --index-url https://test.pypi.org/simple/ py-package-template

# 7. Production release
./scripts/release.sh patch --prod
```

### Version Types
```bash
# Patch release (0.0.1 → 0.0.2) - bug fixes
./scripts/release.sh patch

# Minor release (0.1.0 → 0.2.0) - new features
./scripts/release.sh minor

# Major release (1.0.0 → 2.0.0) - breaking changes
./scripts/release.sh major
```

## Error Scenarios & Handling

### Scenario 1: Missing API Token
```
❌ Error: PYPI_API_TOKEN environment variable not set
Please set your API token:
export PYPI_API_TOKEN=pypi-...
```

### Scenario 2: Uncommitted Changes
```
❌ There are uncommitted changes. Please commit or stash them first.
```

### Scenario 3: Build Failure
```
❌ Build failed: [error details]
```

### Scenario 4: Production Confirmation
```
⚠️  You are about to publish to Production PyPI!
This action cannot be undone. Are you sure? (y/N)
```

## Integration Points

### With GitHub Actions
- Scripts complement the existing CI/CD pipeline
- Manual releases for hotfixes or special releases
- Local testing before pushing tags

### With uv Workflow
- Automatically detects and uses uv when available
- Falls back to pip when uv not present
- Consistent with existing uv migration scripts

### With Existing Tools
- Works with bumpver for version management
- Integrates with twine for PyPI uploads
- Compatible with pytest for testing