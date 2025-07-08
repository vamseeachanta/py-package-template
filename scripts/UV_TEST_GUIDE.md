# UV Test Scripts Quick Reference

This document provides a quick reference for using the uv test scripts in the py-package-template repository.

## Files

- `scripts/uv-test.sh` - Bash script for Unix/Linux/macOS
- `scripts/uv-test.ps1` - PowerShell script for Windows

## Prerequisites

1. **Install uv**: 
   - **Unix/Linux/macOS**: `curl -LsSf https://astral.sh/uv/install.sh | sh`
   - **Windows**: `powershell -c "irm https://astral.sh/uv/install.ps1 | iex"`
   - **Scoop**: `scoop install uv`

2. **Make scripts executable** (Unix/Linux/macOS):
   ```bash
   chmod +x scripts/uv-test.sh
   ```

## Usage

### Basic Commands

| Command | Description |
|---------|-------------|
| `basic` (default) | Run basic test suite |
| `coverage` | Run tests with coverage report |
| `unit` | Run unit tests only |
| `integration` | Run integration tests only |
| `performance` | Run performance tests only |
| `parallel` | Run tests in parallel |
| `quality` | Run code quality checks (black, isort, mypy) |
| `format` | Fix code formatting issues |
| `full` | Run full test suite (quality + coverage) |
| `clean` | Clean test artifacts |
| `help` | Show help message |

### Examples

#### Unix/Linux/macOS (Bash)
```bash
# Run basic tests
./scripts/uv-test.sh

# Run tests with coverage
./scripts/uv-test.sh coverage

# Run code quality checks
./scripts/uv-test.sh quality

# Fix formatting issues
./scripts/uv-test.sh format

# Run full suite
./scripts/uv-test.sh full

# Clean test artifacts
./scripts/uv-test.sh clean
```

#### Windows (PowerShell)
```powershell
# Run basic tests
.\scripts\uv-test.ps1

# Run tests with coverage
.\scripts\uv-test.ps1 coverage

# Run code quality checks
.\scripts\uv-test.ps1 quality

# Fix formatting issues
.\scripts\uv-test.ps1 format

# Run full suite
.\scripts\uv-test.ps1 full

# Clean test artifacts
.\scripts\uv-test.ps1 clean
```

## Test Categories

The scripts support different test categories using pytest markers:

- **Unit tests**: `@pytest.mark.unit` - Fast, isolated tests
- **Integration tests**: `@pytest.mark.integration` - Tests that verify component interaction
- **Performance tests**: `@pytest.mark.performance` - Tests that measure performance
- **Slow tests**: `@pytest.mark.slow` - Tests that take longer to run

## Script Features

### Environment Setup
- Automatically checks for uv installation
- Syncs dependencies including dev dependencies
- Sets up proper Python path for testing

### Test Execution
- Runs tests with verbose output
- Supports parallel testing with pytest-xdist
- Provides coverage reports in multiple formats (HTML, XML, terminal)

### Code Quality
- **Black**: Code formatting
- **isort**: Import sorting
- **mypy**: Type checking

### Artifacts Management
- Cleans pytest cache, coverage files, and Python cache
- Generates HTML coverage reports in `htmlcov/` directory
- Creates XML coverage reports for CI/CD integration

## Configuration

Test configuration is managed in `pyproject.toml`:

```toml
[tool.pytest.ini_options]
minversion = "7.0"
addopts = [
    "--strict-markers",
    "--strict-config", 
    "--verbose",
    "--tb=short",
    "--cov-report=term-missing",
    "--cov-report=html:htmlcov",
    "--cov-report=xml",
]
testpaths = ["tests"]
markers = [
    "slow: marks tests as slow",
    "integration: marks tests as integration tests",
    "unit: marks tests as unit tests",
    "performance: marks tests as performance tests",
]
```

## Coverage Reports

Coverage reports are generated in multiple formats:

1. **Terminal**: Shows missing lines in terminal output
2. **HTML**: Interactive report in `htmlcov/` directory
3. **XML**: Machine-readable format in `coverage.xml`

## CI/CD Integration

The scripts are designed to work well with GitHub Actions and other CI/CD systems:

```yaml
- name: Run tests
  run: |
    ./scripts/uv-test.sh full
```

## Troubleshooting

### Common Issues

1. **uv not found**: Install uv using the installation commands above
2. **Permission denied** (Unix/Linux/macOS): Make script executable with `chmod +x`
3. **PowerShell execution policy**: Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

### Performance Tips

1. Use `parallel` command for faster test execution
2. Run `unit` tests first during development
3. Use `quality` command before committing code
4. Run `full` suite before pushing to main branch

## Development Workflow

Recommended workflow for development:

1. **During development**: `./scripts/uv-test.sh unit`
2. **Before committing**: `./scripts/uv-test.sh quality`
3. **Before pushing**: `./scripts/uv-test.sh full`
4. **Clean up**: `./scripts/uv-test.sh clean`

## Integration with IDEs

The scripts work well with VS Code and other IDEs:

1. **VS Code**: Add tasks to `.vscode/tasks.json`
2. **PyCharm**: Configure as external tools
3. **Terminal**: Run directly from integrated terminal

## Additional Resources

- [uv documentation](https://docs.astral.sh/uv/)
- [pytest documentation](https://docs.pytest.org/)
- [pytest-cov documentation](https://pytest-cov.readthedocs.io/)
- [Project repository](https://github.com/vamseeachanta/py-package-template)
