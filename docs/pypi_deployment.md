# PyPI Deployment Guide

This document outlines the best practices and procedures for deploying the py-package-template to PyPI.

## Overview

The repository includes several deployment options:

1. **Manual deployment** using the `publish.sh`/`publish.ps1` scripts
2. **Automated release** using the `release.sh`/`release.ps1` scripts
3. **GitHub Actions CI/CD** for automated deployment on git tags

## Prerequisites

### API Tokens

You need API tokens for PyPI deployment:

1. **Production PyPI Token**:
   - Visit [https://pypi.org/manage/account/token/](https://pypi.org/manage/account/token/)
   - Create a new token with scope limited to this project
   - Set environment variable: `export PYPI_API_TOKEN="pypi-..."`

2. **Test PyPI Token** (optional, for testing):
   - Visit [https://test.pypi.org/manage/account/token/](https://test.pypi.org/manage/account/token/)
   - Create a new token
   - Set environment variable: `export TEST_PYPI_API_TOKEN="pypi-..."`

### Dependencies

The deployment scripts support both `uv` and traditional `pip` workflows:

- **With uv**: `uv sync --extra build`
- **With pip**: `pip install build twine bumpver`

## Deployment Methods

### 1. Manual Deployment

Use the `publish.sh` (Linux/macOS) or `publish.ps1` (Windows) scripts for manual deployment:

```bash
# Build and check package only
./scripts/publish.sh --check-only

# Publish to Test PyPI
./scripts/publish.sh --test

# Publish to Production PyPI (with confirmation prompt)
./scripts/publish.sh --prod
```

**Windows PowerShell:**
```powershell
# Build and check package only
.\scripts\publish.ps1 -CheckOnly

# Publish to Test PyPI
.\scripts\publish.ps1 -Test

# Publish to Production PyPI
.\scripts\publish.ps1 -Prod
```

### 2. Automated Release

Use the `release.sh` (Linux/macOS) or `release.ps1` (Windows) scripts for complete release automation:

```bash
# Patch release (0.0.1 -> 0.0.2)
./scripts/release.sh patch

# Minor release (0.1.0 -> 0.2.0)
./scripts/release.sh minor --test

# Major release (1.0.0 -> 2.0.0) - dry run first
./scripts/release.sh major --dry-run
./scripts/release.sh major

# Version bump only (no publishing)
./scripts/release.sh patch --no-publish
```

**Windows PowerShell:**
```powershell
# Patch release
.\scripts\release.ps1 patch

# Minor release to Test PyPI
.\scripts\release.ps1 minor -Test

# Major release - dry run first
.\scripts\release.ps1 major -DryRun
.\scripts\release.ps1 major

# Version bump only
.\scripts\release.ps1 patch -NoPublish
```

### 3. GitHub Actions (Automatic)

The repository includes a GitHub Actions workflow that automatically publishes to PyPI when you push a git tag:

1. **Set up secrets** in your GitHub repository:
   - `PYPI_API_TOKEN`: Your PyPI API token

2. **Create and push a tag**:
   ```bash
   git tag v0.1.0
   git push origin v0.1.0
   ```

3. **Monitor the workflow** in the Actions tab of your GitHub repository.

## Best Practices

### Version Management

- Use semantic versioning (MAJOR.MINOR.PATCH)
- Always test on Test PyPI before production release
- Use dry-run mode to preview changes
- Keep a clean git history

### Security

- **Never commit API tokens** to the repository
- Use environment variables for sensitive data
- Limit API token scope to specific projects
- Regularly rotate API tokens

### Testing

- Run all tests before releasing: `pytest`
- Verify package builds cleanly: `python -m build`
- Check package with twine: `twine check dist/*`
- Test installation from Test PyPI before production

### Release Process

1. **Pre-release checks**:
   ```bash
   # Run tests
   pytest
   
   # Check current version
   bumpver show
   
   # Dry run release
   ./scripts/release.sh patch --dry-run
   ```

2. **Test release**:
   ```bash
   # Release to Test PyPI
   ./scripts/release.sh patch --test
   
   # Verify installation
   pip install --index-url https://test.pypi.org/simple/ py-package-template
   ```

3. **Production release**:
   ```bash
   # Release to Production PyPI
   ./scripts/release.sh patch --prod
   ```

## Troubleshooting

### Common Issues

1. **Authentication errors**:
   - Verify API token is set correctly
   - Check token has correct permissions
   - Ensure token hasn't expired

2. **Build failures**:
   - Check `pyproject.toml` syntax
   - Verify all dependencies are available
   - Clean build artifacts: `rm -rf dist/ build/`

3. **Upload errors**:
   - Version already exists on PyPI
   - Package name conflicts
   - File size limits exceeded

### Debug Commands

```bash
# Check package metadata
python -m twine check dist/*

# Verbose upload (for debugging)
python -m twine upload --verbose dist/*

# Check installed package
python -c "import py_package_template; print(py_package_template.__version__)"
```

## Package Information

- **Package name**: `py-package-template`
- **PyPI URL**: https://pypi.org/project/py-package-template/
- **Test PyPI URL**: https://test.pypi.org/project/py-package-template/
- **Source**: https://github.com/vamseeachanta/py-package-template

## Useful Links

- [PyPI Help](https://pypi.org/help/)
- [Python Packaging User Guide](https://packaging.python.org/)
- [Twine Documentation](https://twine.readthedocs.io/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)