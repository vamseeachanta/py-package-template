# UV Quick Start Guide

This guide gets you started with UV in under 5 minutes.

## 1. Install UV

### Option A: Using pip (Recommended for CI/CD)
```bash
pip install uv
```

### Option B: Using the installer script (Linux/macOS)
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Option C: Using pipx
```bash
pipx install uv
```

Verify installation:
```bash
uv --version
```

## 2. Initialize Your Project

### For a new library project:
```bash
uv init --lib my-package
cd my-package
```

### For an existing project:
```bash
cd your-existing-project
uv sync  # Creates virtual environment and installs dependencies
```

## 3. Essential Commands

### Dependency Management
```bash
# Add a dependency
uv add requests

# Add a development dependency  
uv add --dev pytest

# Install all dependencies
uv sync

# Install with dev dependencies
uv sync --extra dev
```

### Running Code
```bash
# Run Python scripts (no need to activate venv)
uv run python your_script.py

# Run tests
uv run pytest

# Run your package
uv run python -m your_package
```

### Building & Publishing
```bash
# Build wheels and source distribution
uv build

# Publish to PyPI
uv publish
```

## 4. Project Structure

UV creates a standard Python project structure:

```
my-package/
├── .python-version    # Python version pinning
├── pyproject.toml     # Project configuration
├── uv.lock           # Dependency lockfile (commit this!)
├── README.md
├── src/
│   └── my_package/
│       ├── __init__.py
│       └── main.py
└── tests/
    └── test_main.py
```

## 5. Key Files Explained

### `.python-version`
Pins the Python version for your project:
```
3.11
```

### `uv.lock`
Dependency lockfile ensuring reproducible installations. **Always commit this file!**

### `pyproject.toml`
Your project configuration. UV works with standard Python packaging:
```toml
[project]
name = "my-package"
version = "0.1.0"
dependencies = ["requests>=2.25.0"]

[project.optional-dependencies]
dev = ["pytest>=6.0", "black>=22.0"]
```

## 6. Common Workflows

### Adding a new feature
```bash
# Add any needed dependencies
uv add beautiful-soup4

# Make your changes
# ...

# Run tests
uv run pytest

# Build to verify everything works
uv build
```

### Setting up a new developer
```bash
git clone your-repo
cd your-repo
uv sync  # Everything is ready!
```

### Updating dependencies
```bash
# Update all dependencies
uv sync --upgrade

# Update specific package
uv sync --upgrade-package requests
```

## 7. Migration from Other Tools

### From pip + requirements.txt
1. Create `pyproject.toml` with your dependencies
2. Run `uv sync` to create lockfile
3. Replace `pip install -r requirements.txt` with `uv sync`

### From Poetry
1. Your `pyproject.toml` is mostly compatible
2. Run `uv sync` to create UV lockfile  
3. Replace `poetry run` with `uv run`

### From Pipenv
1. Convert `Pipfile` dependencies to `pyproject.toml`
2. Run `uv sync`
3. Replace `pipenv run` with `uv run`

## 8. CI/CD Integration

### GitHub Actions
```yaml
- name: Install uv
  uses: astral-sh/setup-uv@v3

- name: Install dependencies
  run: uv sync --extra dev

- name: Run tests
  run: uv run pytest

- name: Build package
  run: uv build
```

## 9. Performance Benefits

UV is significantly faster than traditional tools:

- **Virtual environment creation**: 10x faster
- **Dependency resolution**: 10-100x faster  
- **Package installation**: 10-25x faster
- **Overall workflow**: 5-10x faster

## 10. Getting Help

```bash
# General help
uv --help

# Help for specific commands
uv add --help
uv build --help

# Check what UV would do without doing it
uv sync --dry-run
```

## Next Steps

- Read the full [UV Best Practices Guide](uv_best_practices.md)
- See the [workflow comparison](uv_workflow_comparison.md) with traditional tools
- Check out the [example GitHub Actions workflow](../.github/workflows/test_uv.yml)

**Welcome to the future of Python packaging! 🚀**