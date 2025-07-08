# uv Best Practices Implementation for py-package-template

This repository demonstrates uv best practices implementation for Python package development.

## Repository Configuration

### pyproject.toml Configuration

Our `pyproject.toml` follows uv best practices:

```toml
[project]
name = "py-package-template"
version = "0.0.1"
description = "Python Package Cookiecutter Code"
readme = "README.md"
authors = [{ name = "Vamsee Achanta", email = "vamsee.achanta@aceengineer.com" }]
license = { file = "LICENSE" }
requires-python = ">=3.8"
dependencies = [
    "pyyaml>=6.0",
    "tomli>=2.0.0; python_version < '3.11'",
]

[project.optional-dependencies]
build = [
    "build>=0.10.0",
    "twine>=4.0.0",
]
dev = [
    "black>=23.0.0",
    "isort>=5.12.0",
    "pytest>=7.0.0",
    "mypy>=1.0.0",
    "pre-commit>=3.0.0",
]
docs = [
    "sphinx>=5.0.0",
    "sphinx-rtd-theme>=1.2.0",
]

[project.scripts]
py-package-template = "py_package_template.__main__:main"

[project.urls]
repository = "https://github.com/vamseeachanta/py-package-template"
documentation = "https://github.com/vamseeachanta/py-package-template/blob/main/README.md"

[build-system]
requires = ["hatchling>=1.13.0"]
build-backend = "hatchling.build"

[tool.uv]
dev-dependencies = [
    "pytest>=7.0.0",
    "black>=23.0.0",
    "isort>=5.12.0",
    "mypy>=1.0.0",
    "pre-commit>=3.0.0",
    "bumpver>=2023.1124",
]

[tool.black]
line-length = 88
target-version = ['py38']

[tool.isort]
profile = "black"
multi_line_output = 3

[tool.mypy]
python_version = "3.8"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true

[tool.bumpver]
current_version = "0.0.1"
version_pattern = "MAJOR.MINOR.PATCH"
commit_message = "bump version {old_version} -> {new_version}"
commit = true
tag = true
push = false

[tool.bumpver.file_patterns]
"pyproject.toml" = [
    'current_version = "{version}"',
    'version = "{version}"',
]
"src/py_package_template/__init__.py" = ["{version}"]
"src/py_package_template/__main__.py" = ["v{version}"]
```

## Development Workflow

### Initial Setup

```bash
# Clone repository
git clone https://github.com/vamseeachanta/py-package-template.git
cd py-package-template

# Install uv if not already installed
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install project in development mode
uv sync --extra dev

# Install pre-commit hooks
uv run pre-commit install
```

### Daily Development Commands

```bash
# Run tests
uv run pytest

# Format code
uv run black .
uv run isort .

# Type checking
uv run mypy src/

# Run the package
uv run python -m py_package_template

# Add new dependency
uv add requests

# Add development dependency
uv add --dev pytest-cov
```

### Version Management

```bash
# Patch version (0.0.1 -> 0.0.2)
uv run bumpver update --patch

# Minor version (0.0.1 -> 0.1.0)
uv run bumpver update --minor

# Major version (0.0.1 -> 1.0.0)
uv run bumpver update --major

# Dry run to see what would change
uv run bumpver update --patch --dry
```

### Building and Publishing

```bash
# Install build dependencies
uv sync --extra build

# Build package
uv run python -m build

# Check package
uv run twine check dist/*

# Upload to PyPI (requires API token)
uv run twine upload dist/*
```

## CI/CD Configuration

### GitHub Actions Workflow

```yaml
# .github/workflows/test.yml
name: Test and Build

on:
  push:
    branches: [ main, develop ]
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
      uses: astral-sh/setup-uv@v1
      with:
        version: "latest"
    
    - name: Set up Python ${{ matrix.python-version }}
      run: uv python install ${{ matrix.python-version }}
    
    - name: Install dependencies
      run: uv sync --extra dev
    
    - name: Run linting
      run: |
        uv run black --check .
        uv run isort --check-only .
        uv run mypy src/
    
    - name: Run tests
      run: uv run pytest --cov=src/ --cov-report=xml
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Install uv
      uses: astral-sh/setup-uv@v1
    
    - name: Set up Python
      run: uv python install
    
    - name: Install build dependencies
      run: uv sync --extra build
    
    - name: Build package
      run: uv run python -m build
    
    - name: Check package
      run: uv run twine check dist/*
```

## Docker Configuration

### Dockerfile

```dockerfile
FROM python:3.11-slim

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV UV_CACHE_DIR=/tmp/uv-cache

# Create app directory
WORKDIR /app

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install dependencies
RUN uv sync --frozen --no-cache --no-dev

# Copy source code
COPY src/ ./src/
COPY README.md LICENSE ./

# Install package
RUN uv pip install --no-deps .

# Create non-root user
RUN useradd --create-home --shell /bin/bash app
USER app

# Run application
CMD ["uv", "run", "python", "-m", "py_package_template"]
```

### Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    volumes:
      - ./data:/app/data
    environment:
      - PYTHONPATH=/app/src
    
  dev:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      - .:/app
      - uv-cache:/tmp/uv-cache
    working_dir: /app
    command: bash

volumes:
  uv-cache:
```

## VS Code Configuration

### .vscode/settings.json

```json
{
    "python.defaultInterpreterPath": ".venv/bin/python",
    "python.terminal.activateEnvironment": true,
    "python.testing.pytestEnabled": true,
    "python.testing.pytestArgs": ["src/", "tests/"],
    "python.linting.enabled": true,
    "python.linting.mypyEnabled": true,
    "python.formatting.provider": "black",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    }
}
```

## Security Best Practices

### Dependency Security

```bash
# Install security audit tool
uv add --dev pip-audit

# Run security audit
uv run pip-audit

# Check for outdated packages
uv tree --outdated
```

### Environment Variables

```bash
# Use .env files for local development
# .env (not committed to git)
UV_PUBLISH_TOKEN=your-pypi-token
DATABASE_URL=sqlite:///local.db

# Load in application
uv add python-dotenv
```

## Performance Optimization

### Cache Configuration

```bash
# Set custom cache directory
export UV_CACHE_DIR="$HOME/.cache/uv"

# Pre-populate cache for faster CI
uv cache prewarm
```

### Parallel Processing

```bash
# Optimize for CI environments
export UV_CONCURRENT_DOWNLOADS=20
export UV_CONCURRENT_INSTALLS=8
```

This configuration demonstrates how to implement uv best practices in a Python package template repository, providing a complete development workflow from setup to deployment.
