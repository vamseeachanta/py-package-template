#!/bin/bash
# PyPI Deployment Script for py-package-template
# This script handles building and publishing the package to PyPI

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TEST_PYPI_URL="https://test.pypi.org/legacy/"
PROD_PYPI_URL="https://upload.pypi.org/legacy/"

echo -e "${BLUE}🚀 PyPI Publishing Script for py-package-template${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -t, --test          Publish to Test PyPI (https://test.pypi.org/)"
    echo "  -p, --prod          Publish to Production PyPI (default)"
    echo "  -c, --check-only    Only build and check package, don't publish"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Environment variables:"
    echo "  PYPI_API_TOKEN      Your PyPI API token (required for production)"
    echo "  TEST_PYPI_API_TOKEN Your Test PyPI API token (required for test)"
    echo ""
    echo "Examples:"
    echo "  $0 --test           # Publish to Test PyPI"
    echo "  $0 --prod           # Publish to Production PyPI"
    echo "  $0 --check-only     # Only build and verify package"
}

# Function to clean previous builds
clean_build() {
    echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
    rm -rf dist/
    rm -rf build/
    rm -rf *.egg-info/
    echo -e "${GREEN}✅ Build artifacts cleaned${NC}"
}

# Function to build package
build_package() {
    echo -e "${YELLOW}📦 Building package...${NC}"
    
    if command_exists uv; then
        echo "Using uv for building..."
        uv sync --extra build
        uv run python -m build
    else
        echo "Using pip for building..."
        # Check if build and twine are available, install only if needed
        python3 -c "import build" 2>/dev/null || python3 -m pip install --user build
        python3 -c "import twine" 2>/dev/null || python3 -m pip install --user twine
        python3 -m build
    fi
    
    echo -e "${GREEN}✅ Package built successfully${NC}"
}

# Function to check package
check_package() {
    echo -e "${YELLOW}🔍 Checking package with twine...${NC}"
    
    if command_exists uv; then
        uv run twine check dist/*
    else
        python3 -m twine check dist/*
    fi
    
    echo -e "${GREEN}✅ Package check passed${NC}"
}

# Function to list package contents
list_package_contents() {
    echo -e "${BLUE}📋 Package contents:${NC}"
    ls -la dist/
    echo ""
}

# Function to publish to PyPI
publish_package() {
    local repository_url=$1
    local token_var=$2
    local repo_name=$3
    
    echo -e "${YELLOW}🚀 Publishing to ${repo_name}...${NC}"
    
    # Check for API token
    if [ -z "${!token_var}" ]; then
        echo -e "${RED}❌ Error: ${token_var} environment variable not set${NC}"
        echo "Please set your API token:"
        echo "export ${token_var}=pypi-..."
        exit 1
    fi
    
    # Publish package
    if command_exists uv; then
        uv run twine upload --repository-url "$repository_url" --username __token__ --password "${!token_var}" dist/*
    else
        python3 -m twine upload --repository-url "$repository_url" --username __token__ --password "${!token_var}" dist/*
    fi
    
    echo -e "${GREEN}✅ Package published successfully to ${repo_name}!${NC}"
}

# Parse command line arguments
PUBLISH_TARGET="prod"
CHECK_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--test)
            PUBLISH_TARGET="test"
            shift
            ;;
        -p|--prod)
            PUBLISH_TARGET="prod"
            shift
            ;;
        -c|--check-only)
            CHECK_ONLY=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    echo -e "${BLUE}Configuration:${NC}"
    echo "  Target: $PUBLISH_TARGET"
    echo "  Check only: $CHECK_ONLY"
    echo ""
    
    # Clean previous builds
    clean_build
    
    # Build package
    build_package
    
    # Check package
    check_package
    
    # List package contents
    list_package_contents
    
    # Exit if check-only mode
    if [ "$CHECK_ONLY" = true ]; then
        echo -e "${GREEN}🎉 Package build and check completed successfully!${NC}"
        echo "Run without --check-only to publish."
        exit 0
    fi
    
    # Publish package
    if [ "$PUBLISH_TARGET" = "test" ]; then
        publish_package "$TEST_PYPI_URL" "TEST_PYPI_API_TOKEN" "Test PyPI"
        echo ""
        echo -e "${GREEN}🎉 Package published to Test PyPI!${NC}"
        echo "View at: https://test.pypi.org/project/py-package-template/"
        echo ""
        echo "To install from Test PyPI:"
        echo "pip install --index-url https://test.pypi.org/simple/ py-package-template"
    else
        # Confirm production publish
        echo -e "${YELLOW}⚠️  You are about to publish to Production PyPI!${NC}"
        echo "This action cannot be undone. Are you sure? (y/N)"
        read -r confirmation
        if [[ ! $confirmation =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}❌ Publication cancelled.${NC}"
            exit 0
        fi
        
        publish_package "$PROD_PYPI_URL" "PYPI_API_TOKEN" "Production PyPI"
        echo ""
        echo -e "${GREEN}🎉 Package published to Production PyPI!${NC}"
        echo "View at: https://pypi.org/project/py-package-template/"
        echo ""
        echo "To install:"
        echo "pip install py-package-template"
    fi
}

# Run main function
main