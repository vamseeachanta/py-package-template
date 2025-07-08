# UV Best Practices for Python Package Development

## Introduction

UV is an extremely fast Python package and project manager, written in Rust by Astral (creators of Ruff). It aims to replace the entire Python packaging toolchain with a single, fast tool that handles dependency management, virtual environments, package building, and publishing.

## Key Benefits of UV

### Performance
- **10-100x faster** than pip for most operations
- **Parallel downloads** and installations
- **Smart caching** that works across projects
- **Minimal overhead** for virtual environment creation

### Developer Experience
- **Single tool** replaces pip, pip-tools, pipenv, poetry, virtualenv, and more
- **Lockfile support** for reproducible builds
- **Project templates** and scaffolding
- **Built-in Python version management**
- **Direct integration** with pyproject.toml

### Reliability
- **Dependency resolution** is faster and more reliable
- **Cross-platform support** with consistent behavior
- **Offline mode** support
- **Comprehensive error messages**

## Installation

### Installing UV

```bash
# Method 1: Using pip (recommended for CI/CD)
pip install uv

# Method 2: Using the installer script (Linux/macOS)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Method 3: Using pipx
pipx install uv

# Method 4: Using conda/mamba
conda install -c conda-forge uv
```

### Verify Installation

```bash
uv --version
```

## Project Initialization

### New Project from Scratch

```bash
# Create a new library project
uv init --lib my-package
cd my-package

# Create a new application project
uv init --app my-app
cd my-app

# Create with specific build backend
uv init --lib --build-backend setuptools my-package
```

### Converting Existing Project

For existing projects with `pyproject.toml`:

```bash
# In your project directory
uv sync  # Creates virtual environment and installs dependencies
```

## Project Structure Best Practices

### Recommended Structure

```
my-package/
├── .python-version          # Python version pinning
├── pyproject.toml           # Project configuration
├── uv.lock                  # Dependency lockfile
├── README.md
├── LICENSE
├── src/
│   └── my_package/
│       ├── __init__.py
│       ├── __main__.py
│       └── core.py
├── tests/
│   ├── __init__.py
│   └── test_core.py
└── docs/
    └── README.md
```

### Important Files

- **`.python-version`**: Pins Python version for the project
- **`uv.lock`**: Lockfile ensuring reproducible installations
- **`pyproject.toml`**: Project configuration with UV optimizations

## Pyproject.toml Configuration

### UV-Optimized Configuration

```toml
[build-system]
requires = ["setuptools>=61.0.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "my-package"
version = "0.1.0"
description = "A sample Python package"
readme = "README.md"
license = "MIT"
authors = [
    { name = "Your Name", email = "your.email@example.com" }
]
classifiers = [
    "Development Status :: 4 - Beta",
    "Intended Audience :: Developers",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.8",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]
keywords = ["example", "package"]
dependencies = [
    "requests>=2.25.0",
    "click>=8.0.0",
]
requires-python = ">=3.8"

[project.optional-dependencies]
dev = [
    "pytest>=6.0",
    "pytest-cov>=2.0",
    "black>=22.0",
    "isort>=5.0",
    "mypy>=0.900",
    "ruff>=0.1.0",
]
docs = [
    "sphinx>=4.0",
    "sphinx-rtd-theme>=1.0",
]
build = [
    "build>=0.7.0",
    "twine>=4.0.0",
]

[project.scripts]
my-package = "my_package.__main__:main"

[project.urls]
Homepage = "https://github.com/username/my-package"
Documentation = "https://my-package.readthedocs.io"
Repository = "https://github.com/username/my-package"
"Bug Tracker" = "https://github.com/username/my-package/issues"

# UV-specific configurations
[tool.uv]
dev-dependencies = [
    "pytest>=6.0",
    "pytest-cov>=2.0",
    "black>=22.0",
    "isort>=5.0",
    "mypy>=0.900",
    "ruff>=0.1.0",
]

# Optional: Specify package sources
[[tool.uv.sources]]
# Example for using a development version
my-dependency = { git = "https://github.com/user/my-dependency" }

[tool.black]
line-length = 88
target-version = ["py38"]

[tool.isort]
profile = "black"
multi_line_output = 3

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_functions = ["test_*"]
addopts = "-v --tb=short"

[tool.coverage.run]
source = ["src"]
omit = ["tests/*"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "raise AssertionError",
    "raise NotImplementedError",
]

[tool.mypy]
python_version = "3.8"
strict = true
warn_return_any = true
warn_unused_configs = true
```

## Development Workflow

### Environment Management

```bash
# Create and sync virtual environment
uv sync

# Sync with dev dependencies
uv sync --extra dev

# Sync with specific extras
uv sync --extra dev --extra docs

# Activate the virtual environment (optional, uv run handles this)
source .venv/bin/activate  # Linux/macOS
# .venv\Scripts\activate   # Windows
```

### Dependency Management

```bash
# Add a new dependency
uv add requests

# Add a development dependency
uv add --dev pytest

# Add with version constraints
uv add "numpy>=1.20,<2.0"

# Add from git
uv add git+https://github.com/user/repo.git

# Remove a dependency
uv remove requests

# Update dependencies
uv sync --upgrade

# Update specific package
uv sync --upgrade-package requests
```

### Running Commands

```bash
# Run Python scripts
uv run python src/my_package/__main__.py

# Run tests
uv run pytest

# Run with specific extra dependencies
uv run --extra dev pytest

# Run tools
uv run black src/
uv run isort src/
uv run mypy src/

# Run your package as a module
uv run python -m my_package
```

### Building and Publishing

```bash
# Build source distribution and wheel
uv build

# Build only wheel
uv build --wheel

# Build only source distribution
uv build --sdist

# Publish to PyPI
uv publish

# Publish to test PyPI
uv publish --index-url https://test.pypi.org/legacy/

# Publish with credentials
uv publish --username __token__ --password your-token
```

## Version Management

### Using UV with Version Bumping

```bash
# Install bumpver for version management
uv add --dev bumpver

# Bump version
uv run bumpver update --patch
uv run bumpver update --minor
uv run bumpver update --major

# Custom version
uv run bumpver update --set-version 1.2.3
```

### Alternative: Built-in Version Management

```bash
# UV has built-in version management
uv version patch
uv version minor
uv version major

# Set specific version
uv version 1.2.3
```

## Testing

### Test Setup

```bash
# Install test dependencies
uv sync --extra dev

# Run tests
uv run pytest

# Run with coverage
uv run pytest --cov=src --cov-report=html

# Run specific test file
uv run pytest tests/test_core.py

# Run with specific markers
uv run pytest -m "not slow"
```

### Test Configuration

Add to `pyproject.toml`:

```toml
[tool.pytest.ini_options]
minversion = "6.0"
addopts = "-ra -q --strict-markers --strict-config"
testpaths = ["tests"]
markers = [
    "slow: marks tests as slow",
    "integration: marks tests as integration tests",
]
```

## Python Version Management

### Managing Python Versions

```bash
# List available Python versions
uv python list

# Install a specific Python version
uv python install 3.11

# Use specific Python version for project
uv python pin 3.11

# Show current Python version
uv python find
```

### .python-version File

Create `.python-version` file:

```
3.11
```

This ensures consistent Python version across environments.

## CI/CD Integration

### GitHub Actions Workflow

Create `.github/workflows/test.yml`:

```yaml
name: Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.8", "3.9", "3.10", "3.11", "3.12"]

    steps:
    - uses: actions/checkout@v4
    
    - name: Install uv
      uses: astral-sh/setup-uv@v3
      with:
        enable-cache: true
        cache-dependency-glob: "uv.lock"
    
    - name: Set up Python ${{ matrix.python-version }}
      run: uv python install ${{ matrix.python-version }}
    
    - name: Install dependencies
      run: uv sync --extra dev
    
    - name: Run tests
      run: uv run pytest --cov=src --cov-report=xml
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
```

### Build and Publish Workflow

Create `.github/workflows/publish.yml`:

```yaml
name: Publish to PyPI

on:
  release:
    types: [published]

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Install uv
      uses: astral-sh/setup-uv@v3
    
    - name: Build package
      run: uv build
    
    - name: Publish to PyPI
      run: uv publish
      env:
        UV_PUBLISH_TOKEN: ${{ secrets.PYPI_API_TOKEN }}
```

## Migration Guide

### From pip + requirements.txt

1. **Create pyproject.toml** with dependencies from requirements.txt
2. **Run `uv sync`** to create lockfile and virtual environment
3. **Update CI/CD** to use UV commands
4. **Remove** requirements.txt files

### From Poetry

1. **Convert pyproject.toml** (most sections are compatible)
2. **Run `uv sync`** to create UV lockfile
3. **Update scripts** to use `uv run` instead of `poetry run`
4. **Remove poetry.lock**

### From Pipenv

1. **Extract dependencies** from Pipfile to pyproject.toml
2. **Run `uv sync`** to create lockfile
3. **Update workflows** to use UV
4. **Remove Pipfile and Pipfile.lock**

## Performance Optimizations

### Caching

UV automatically caches downloads and built wheels:

```bash
# Check cache size
uv cache info

# Clean cache
uv cache clean

# Clear specific package from cache
uv cache clean requests
```

### Parallel Operations

UV automatically parallelizes operations. For CI/CD:

```bash
# Use maximum parallelism
UV_CONCURRENT_DOWNLOADS=10 uv sync
```

### Offline Mode

```bash
# Work offline (use only cache)
uv sync --offline

# Check what would be downloaded
uv sync --dry-run
```

## Troubleshooting

### Common Issues

1. **Package conflicts**: UV provides clear error messages
2. **Build failures**: Use `uv build --verbose` for detailed output
3. **Cache issues**: Clear cache with `uv cache clean`

### Debug Mode

```bash
# Verbose output
uv sync --verbose

# Very verbose output
uv sync -vv

# Show resolution information
uv sync --resolution=lowest
```

## Best Practices Summary

1. **Always commit `uv.lock`** to version control
2. **Use `.python-version`** for Python version pinning
3. **Organize dependencies** into optional extras
4. **Use `uv run`** instead of activating virtual environments
5. **Leverage UV's caching** for faster builds
6. **Pin dependency versions** in production
7. **Use `uv sync --frozen`** in CI/CD for reproducible builds
8. **Regular updates** with `uv sync --upgrade`
9. **Test with multiple Python versions** using UV's Python management
10. **Use UV's built-in tools** instead of external alternatives where possible

## Comparison: UV vs Traditional Tools

| Task | Traditional | UV | Benefits |
|------|-------------|-----|-----------|
| Virtual env | `python -m venv .venv` | `uv sync` | Automatic creation + dependency install |
| Install deps | `pip install -r requirements.txt` | `uv sync` | Faster, with lockfile |
| Add dependency | Edit requirements.txt + `pip install` | `uv add package` | Automatic pyproject.toml update |
| Build package | `python -m build` | `uv build` | Integrated workflow |
| Publish | `twine upload dist/*` | `uv publish` | Single command |
| Run scripts | `source .venv/bin/activate && python script.py` | `uv run python script.py` | No activation needed |

UV provides a **modern, fast, and unified** approach to Python package development that significantly improves developer productivity while maintaining compatibility with existing Python packaging standards.