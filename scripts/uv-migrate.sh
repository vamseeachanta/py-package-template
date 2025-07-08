#!/bin/bash
# uv Migration and Setup Script
# This script helps migrate from pip-based workflow to uv-based workflow

set -e

echo "🚀 py-package-template uv Migration Script"
echo "=========================================="

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install uv
install_uv() {
    echo "📦 Installing uv..."
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        # Windows
        powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
    else
        # macOS and Linux
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
    echo "✅ uv installed successfully"
}

# Function to setup development environment
setup_dev_environment() {
    echo "🔧 Setting up development environment with uv..."
    
    # Install Python if needed
    echo "🐍 Installing Python 3.11..."
    uv python install 3.11
    
    # Pin Python version for project
    echo "📌 Pinning Python version..."
    uv python pin 3.11
    
    # Sync all dependencies including dev dependencies
    echo "📚 Installing project dependencies..."
    uv sync --extra dev --extra docs --extra build
    
    # Install pre-commit hooks
    echo "🎣 Installing pre-commit hooks..."
    uv run pre-commit install
    
    echo "✅ Development environment setup complete"
}

# Function to run quality checks
run_quality_checks() {
    echo "🔍 Running quality checks..."
    
    # Format code
    echo "🎨 Formatting code with black..."
    uv run black .
    
    # Sort imports
    echo "📋 Sorting imports with isort..."
    uv run isort .
    
    # Type checking
    echo "🔍 Running type checks with mypy..."
    uv run mypy src/ || echo "⚠️  MyPy found issues (this is normal for initial setup)"
    
    # Run tests
    echo "🧪 Running tests..."
    uv run pytest --cov=src/ --cov-report=term-missing
    
    echo "✅ Quality checks complete"
}

# Function to build package
build_package() {
    echo "📦 Building package..."
    uv run python -m build
    uv run twine check dist/*
    echo "✅ Package built successfully"
}

# Function to show helpful commands
show_helpful_commands() {
    echo ""
    echo "🎯 Helpful uv commands for daily development:"
    echo "============================================="
    echo ""
    echo "📚 Dependency Management:"
    echo "  uv add <package>           # Add a dependency"
    echo "  uv add --dev <package>     # Add a dev dependency"
    echo "  uv remove <package>        # Remove a dependency"
    echo "  uv sync                    # Install all dependencies"
    echo "  uv tree                    # Show dependency tree"
    echo ""
    echo "🏃 Running Code:"
    echo "  uv run python script.py    # Run a Python script"
    echo "  uv run pytest             # Run tests"
    echo "  uv run black .            # Format code"
    echo "  uv run mypy src/          # Type checking"
    echo ""
    echo "📦 Package Management:"
    echo "  uv run python -m build    # Build package"
    echo "  uv run bumpver update --patch  # Bump version"
    echo ""
    echo "🔄 Environment Management:"
    echo "  uv python list            # List available Python versions"
    echo "  uv python install 3.12   # Install Python 3.12"
    echo "  uv cache clean            # Clean cache"
    echo ""
}

# Main execution
main() {
    echo "Starting uv migration process..."
    echo ""
    
    # Check if uv is installed
    if ! command_exists uv; then
        echo "❌ uv not found. Installing uv..."
        install_uv
        
        # Reload shell to get uv in PATH
        echo "🔄 Please restart your terminal and run this script again to continue."
        echo "Or run: source ~/.bashrc (Linux/macOS) or restart PowerShell (Windows)"
        exit 0
    else
        echo "✅ uv is already installed"
        uv --version
    fi
    
    echo ""
    
    # Parse command line arguments
    case "${1:-setup}" in
        "setup"|"")
            setup_dev_environment
            ;;
        "check")
            run_quality_checks
            ;;
        "build")
            build_package
            ;;
        "help")
            show_helpful_commands
            ;;
        "all")
            setup_dev_environment
            run_quality_checks
            build_package
            ;;
        *)
            echo "❌ Unknown command: $1"
            echo ""
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  setup  (default) - Set up development environment"
            echo "  check           - Run quality checks (format, lint, test)"
            echo "  build           - Build package"
            echo "  help            - Show helpful uv commands"
            echo "  all             - Run setup, check, and build"
            exit 1
            ;;
    esac
    
    echo ""
    echo "🎉 Migration task completed successfully!"
    
    if [[ "${1:-setup}" == "setup" || "${1:-setup}" == "" ]]; then
        show_helpful_commands
    fi
}

# Run main function with all arguments
main "$@"
