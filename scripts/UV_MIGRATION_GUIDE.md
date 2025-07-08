# uv Migration Quick Reference Guide

## 🚀 Quick Start

### 1. Install uv
```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows PowerShell
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### 2. Run Migration Script
```bash
# Linux/macOS
./scripts/uv-migrate.sh

# Windows
.\scripts\uv-migrate.ps1
```

## 📋 Command Migration Cheat Sheet

| Old pip/pip-tools Command | New uv Command | Description |
|---------------------------|----------------|-------------|
| `pip install package` | `uv add package` | Add dependency |
| `pip install -e .` | `uv sync` | Install project in dev mode |
| `pip install -r requirements.txt` | `uv sync` | Install from lock file |
| `pip install --dev package` | `uv add --dev package` | Add dev dependency |
| `pip uninstall package` | `uv remove package` | Remove dependency |
| `pip list` | `uv tree` | Show installed packages |
| `pip freeze` | `uv export` | Export dependencies |
| `python script.py` | `uv run python script.py` | Run Python script |
| `pytest` | `uv run pytest` | Run tests |
| `python -m build` | `uv run python -m build` | Build package |

## 🔄 Daily Development Workflow

### Setting Up New Development Environment
```bash
# 1. Clone repository
git clone <repo-url>
cd py-package-template

# 2. Install uv (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# 3. Setup development environment
uv sync --extra dev

# 4. Install pre-commit hooks
uv run pre-commit install
```

### Development Tasks
```bash
# Add new dependency
uv add requests

# Add development dependency
uv add --dev pytest-mock

# Run tests
uv run pytest

# Format code
uv run black .
uv run isort .

# Type checking
uv run mypy src/

# Run all quality checks
uv run pre-commit run --all-files
```

### Version Management
```bash
# Patch version (0.1.0 -> 0.1.1)
uv run bumpver update --patch

# Minor version (0.1.0 -> 0.2.0)
uv run bumpver update --minor

# Major version (0.1.0 -> 1.0.0)
uv run bumpver update --major
```

### Building and Publishing
```bash
# Build package
uv run python -m build

# Check package
uv run twine check dist/*

# Publish to PyPI (requires token)
uv run twine upload dist/*
```

## 🔧 Environment Management

### Python Version Management
```bash
# List available Python versions
uv python list

# Install specific Python version
uv python install 3.11

# Pin Python version for project
uv python pin 3.11

# Show current Python version
uv run python --version
```

### Cache Management
```bash
# Show cache directory
uv cache dir

# Clean cache
uv cache clean

# Show cache size
uv cache size
```

## 🐛 Troubleshooting

### Common Issues and Solutions

#### Issue: "uv: command not found"
**Solution:** Restart terminal or run:
```bash
# Linux/macOS
source ~/.bashrc

# Windows
# Restart PowerShell
```

#### Issue: Python version conflicts
**Solution:** Pin specific Python version:
```bash
uv python pin 3.11
uv sync
```

#### Issue: Dependency conflicts
**Solution:** Check dependency tree and update:
```bash
uv tree
uv lock --upgrade
```

#### Issue: Cache corruption
**Solution:** Clean and rebuild cache:
```bash
uv cache clean
uv sync
```

### Performance Optimization

#### Speed up CI/CD
```bash
# Use cache in CI
export UV_CACHE_DIR="/tmp/uv-cache"

# Increase concurrent downloads
export UV_CONCURRENT_DOWNLOADS=20
```

#### Optimize local development
```bash
# Pre-warm cache
uv cache prewarm

# Use frozen installs
uv sync --frozen
```

## 📊 Performance Comparison

| Task | pip | uv | Improvement |
|------|-----|----| ------------|
| Install numpy | ~15s | ~2s | 7.5x faster |
| Install Django | ~30s | ~3s | 10x faster |
| Fresh environment setup | ~2min | ~10s | 12x faster |
| Dependency resolution | ~45s | ~3s | 15x faster |

## 🔗 Additional Resources

- [uv GitHub Repository](https://github.com/astral-sh/uv)
- [Official Documentation](https://docs.astral.sh/uv/)
- [Migration Guides](https://docs.astral.sh/uv/guides/)
- [GitHub Actions Integration](https://docs.astral.sh/uv/guides/integration/github/)

## 🆘 Getting Help

1. **Check uv documentation**: `uv --help`
2. **View command help**: `uv add --help`
3. **Check project status**: `uv check`
4. **Show dependency tree**: `uv tree`
5. **Open GitHub issue**: [py-package-template issues](https://github.com/vamseeachanta/py-package-template/issues)
