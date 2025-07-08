# Git Bash Integration with VS Code

This document explains how to use Git Bash with VS Code in the py-package-template project.

## What Was Configured

### 1. Terminal Profiles
VS Code has been configured with multiple terminal profiles:
- **PowerShell** (Windows default)
- **Command Prompt** (Windows legacy)
- **Git Bash** (Unix-like environment on Windows)

### 2. Default Terminal
Git Bash is now set as the default terminal profile for this workspace.

### 3. Environment Variables
Special environment variables have been configured for Git Bash to prevent path conversion issues:
- `MSYS_NO_PATHCONV=1` - Prevents automatic path conversion
- `MSYS2_ARG_CONV_EXCL=*` - Excludes all arguments from conversion

## How to Use Git Bash in VS Code

### Opening a Git Bash Terminal

1. **Automatic (Default)**: Press `Ctrl+`` (backtick) or `Ctrl+Shift+`` to open a new terminal
2. **Manual Selection**: 
   - Press `Ctrl+Shift+P` to open Command Palette
   - Type "Terminal: Select Default Profile"
   - Choose "Git Bash"
   - Open a new terminal with `Ctrl+``

### Using Different Terminal Types

You can switch between terminal types:
1. Click the dropdown arrow next to the `+` in the terminal panel
2. Select from:
   - Git Bash
   - PowerShell
   - Command Prompt

## Running Tests with Git Bash

### Using the Bash Scripts

With Git Bash configured, you can now use the Unix-style test scripts:

```bash
# Basic tests
./scripts/uv-test.sh basic

# Tests with coverage
./scripts/uv-test.sh coverage

# Code quality checks
./scripts/uv-test.sh quality

# Full test suite
./scripts/uv-test.sh full

# Clean test artifacts
./scripts/uv-test.sh clean
```

### Using VS Code Tasks

The following tasks are available in VS Code (accessible via `Ctrl+Shift+P` → "Tasks: Run Task"):

#### PowerShell Tasks (Original)
- `uv: Run Basic Tests`
- `uv: Run Tests with Coverage`
- `uv: Run Code Quality Checks`
- `uv: Run Full Test Suite`

#### Git Bash Tasks (New)
- `uv: Run Basic Tests (Git Bash)`
- `uv: Run Tests with Coverage (Git Bash)`
- `uv: Run Full Test Suite (Git Bash)`

## Advantages of Git Bash

### 1. Cross-Platform Compatibility
- Same commands work on Windows, macOS, and Linux
- Familiar Unix-like environment for developers

### 2. Better Script Support
- Native support for shell scripts (`.sh` files)
- Standard Unix tools available (`grep`, `find`, `sed`, etc.)

### 3. Git Integration
- Enhanced Git command line experience
- Better support for Git hooks and scripts

### 4. Package Management
- Can use Unix-style package managers
- Better compatibility with uv and other tools

## Common Git Bash Commands

### Navigation
```bash
# List files
ls -la

# Change directory
cd src/

# Show current directory
pwd

# Go to project root
cd /k/github/py-package-template
```

### File Operations
```bash
# Create file
touch new_file.py

# Edit file
nano file.py  # or vim file.py

# Make script executable
chmod +x scripts/uv-test.sh

# Copy files
cp source.py destination.py
```

### Testing and Development
```bash
# Install uv (if not installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Run tests
uv run pytest tests/

# Install dependencies
uv sync --dev

# Run specific test file
uv run pytest tests/test_calculation.py -v
```

## Troubleshooting

### Git Bash Not Found
If VS Code can't find Git Bash, ensure Git is installed:
1. Download from [git-scm.com](https://git-scm.com/)
2. Install with default options
3. Restart VS Code

### Path Issues
If you encounter path-related issues:
1. The environment variables are already configured
2. Use forward slashes `/` instead of backslashes `\`
3. For Windows paths, use `/c/Users/` instead of `C:\Users\`

### Script Execution Issues
If scripts don't run:
```bash
# Make script executable
chmod +x scripts/uv-test.sh

# Run with explicit bash
bash scripts/uv-test.sh basic
```

## Configuration Files

The Git Bash integration is configured in:

### `.vscode/settings.json`
```json
{
    "terminal.integrated.profiles.windows": {
        "Git Bash": {
            "path": [
                "${env:ProgramFiles}\\Git\\bin\\bash.exe",
                "${env:ProgramFiles(x86)}\\Git\\bin\\bash.exe",
                "${env:LocalAppData}\\Programs\\Git\\bin\\bash.exe"
            ],
            "args": [],
            "icon": "terminal-bash"
        }
    },
    "terminal.integrated.defaultProfile.windows": "Git Bash"
}
```

### `.vscode/tasks.json`
Contains both PowerShell and Git Bash versions of test tasks.

## Best Practices

1. **Use Git Bash for development**: Better cross-platform compatibility
2. **Use PowerShell for Windows-specific tasks**: When you need Windows-specific functionality
3. **Keep both scripts updated**: Maintain both `.sh` and `.ps1` versions of scripts
4. **Test in both environments**: Ensure compatibility across different shells

## Next Steps

Now that Git Bash is configured:
1. Try running tests with `./scripts/uv-test.sh basic`
2. Explore the Unix-like environment
3. Use Git commands directly in the integrated terminal
4. Consider setting up additional Unix tools if needed
