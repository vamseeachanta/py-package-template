#!/bin/bash
# Automated Release Script for py-package-template
# This script handles version bumping, git tagging, and publishing to PyPI

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Automated Release Script for py-package-template${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [version_type] [options]"
    echo ""
    echo "Version types:"
    echo "  patch    Increment patch version (0.0.1 -> 0.0.2)"
    echo "  minor    Increment minor version (0.0.1 -> 0.1.0)"
    echo "  major    Increment major version (0.0.1 -> 1.0.0)"
    echo ""
    echo "Options:"
    echo "  -t, --test          Release to Test PyPI only"
    echo "  -p, --prod          Release to Production PyPI (default)"
    echo "  -d, --dry-run       Show what would be done without making changes"
    echo "  -n, --no-publish    Only bump version and create tag, don't publish"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Environment variables:"
    echo "  PYPI_API_TOKEN      Your PyPI API token (required for production)"
    echo "  TEST_PYPI_API_TOKEN Your Test PyPI API token (required for test)"
    echo ""
    echo "Examples:"
    echo "  $0 patch            # Bump patch version and release to PyPI"
    echo "  $0 minor --test     # Bump minor version and release to Test PyPI"
    echo "  $0 major --dry-run  # Show what would be done for major release"
}

# Function to check git status
check_git_status() {
    echo -e "${YELLOW}🔍 Checking git status...${NC}"
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}❌ Not in a git repository${NC}"
        exit 1
    fi
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        echo -e "${RED}❌ There are uncommitted changes. Please commit or stash them first.${NC}"
        exit 1
    fi
    
    # Check current branch
    current_branch=$(git branch --show-current)
    if [ "$current_branch" != "main" ] && [ "$current_branch" != "master" ]; then
        echo -e "${YELLOW}⚠️  Warning: You are not on main/master branch (current: $current_branch)${NC}"
        echo "Continue anyway? (y/N)"
        read -r confirmation
        if [[ ! $confirmation =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}❌ Release cancelled.${NC}"
            exit 0
        fi
    fi
    
    echo -e "${GREEN}✅ Git status check passed${NC}"
}

# Function to get current version
get_current_version() {
    if command_exists uv; then
        uv run bumpver show | grep "current_version" | cut -d'=' -f2 | tr -d ' "'
    else
        python3 -c "import toml; print(toml.load('pyproject.toml')['tool']['bumpver']['current_version'])"
    fi
}

# Function to bump version
bump_version() {
    local version_type=$1
    local dry_run=$2
    
    echo -e "${YELLOW}📈 Bumping $version_type version...${NC}"
    
    if [ "$dry_run" = true ]; then
        echo "Dry run mode - would execute:"
        if command_exists uv; then
            echo "uv run bumpver update --$version_type --dry"
        else
            echo "bumpver update --$version_type --dry"
        fi
        return
    fi
    
    # Get current version
    current_version=$(get_current_version)
    echo "Current version: $current_version"
    
    # Bump version
    if command_exists uv; then
        uv run bumpver update --$version_type
    else
        bumpver update --$version_type
    fi
    
    # Get new version
    new_version=$(get_current_version)
    echo -e "${GREEN}✅ Version bumped from $current_version to $new_version${NC}"
}

# Function to run tests
run_tests() {
    echo -e "${YELLOW}🧪 Running tests...${NC}"
    
    if command_exists uv; then
        if uv run pytest --version > /dev/null 2>&1; then
            uv run pytest
        else
            echo "No pytest found, skipping tests"
        fi
    else
        if command_exists pytest; then
            pytest
        else
            echo "No pytest found, skipping tests"
        fi
    fi
    
    echo -e "${GREEN}✅ Tests passed${NC}"
}

# Function to create git tag
create_git_tag() {
    local dry_run=$1
    local version=$(get_current_version)
    local tag_name="v$version"
    
    echo -e "${YELLOW}🏷️  Creating git tag: $tag_name${NC}"
    
    if [ "$dry_run" = true ]; then
        echo "Dry run mode - would execute:"
        echo "git tag -a $tag_name -m \"Release version $version\""
        return
    fi
    
    git tag -a "$tag_name" -m "Release version $version"
    echo -e "${GREEN}✅ Git tag created: $tag_name${NC}"
}

# Function to push changes
push_changes() {
    local dry_run=$1
    
    echo -e "${YELLOW}📤 Pushing changes to remote...${NC}"
    
    if [ "$dry_run" = true ]; then
        echo "Dry run mode - would execute:"
        echo "git push origin main --tags"
        return
    fi
    
    current_branch=$(git branch --show-current)
    git push origin "$current_branch" --tags
    echo -e "${GREEN}✅ Changes pushed to remote${NC}"
}

# Function to publish package
publish_package() {
    local target=$1
    local dry_run=$2
    
    if [ "$dry_run" = true ]; then
        echo "Dry run mode - would execute:"
        echo "./scripts/publish.sh --$target"
        return
    fi
    
    # Use the publish script
    ./scripts/publish.sh --$target
}

# Parse command line arguments
VERSION_TYPE=""
PUBLISH_TARGET="prod"
DRY_RUN=false
NO_PUBLISH=false

# First argument is version type
if [ $# -ge 1 ] && [[ "$1" =~ ^(patch|minor|major)$ ]]; then
    VERSION_TYPE=$1
    shift
fi

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
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -n|--no-publish)
            NO_PUBLISH=true
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

# Check if version type is provided
if [ -z "$VERSION_TYPE" ]; then
    echo -e "${RED}❌ Version type is required${NC}"
    show_usage
    exit 1
fi

# Main execution
main() {
    echo -e "${BLUE}Configuration:${NC}"
    echo "  Version type: $VERSION_TYPE"
    echo "  Target: $PUBLISH_TARGET"
    echo "  Dry run: $DRY_RUN"
    echo "  No publish: $NO_PUBLISH"
    echo ""
    
    # Check git status
    if [ "$DRY_RUN" = false ]; then
        check_git_status
    fi
    
    # Run tests first
    if [ "$DRY_RUN" = false ]; then
        run_tests
    fi
    
    # Bump version
    bump_version "$VERSION_TYPE" "$DRY_RUN"
    
    # Create git tag
    create_git_tag "$DRY_RUN"
    
    # Push changes
    push_changes "$DRY_RUN"
    
    # Publish package (unless no-publish flag is set)
    if [ "$NO_PUBLISH" = false ]; then
        echo ""
        publish_package "$PUBLISH_TARGET" "$DRY_RUN"
    fi
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${BLUE}🎉 Dry run completed! No changes were made.${NC}"
    else
        new_version=$(get_current_version)
        echo ""
        echo -e "${GREEN}🎉 Release completed successfully!${NC}"
        echo "Version: $new_version"
        if [ "$NO_PUBLISH" = false ]; then
            if [ "$PUBLISH_TARGET" = "test" ]; then
                echo "Published to: Test PyPI"
                echo "View at: https://test.pypi.org/project/py-package-template/"
            else
                echo "Published to: Production PyPI"
                echo "View at: https://pypi.org/project/py-package-template/"
            fi
        fi
    fi
}

# Run main function
main