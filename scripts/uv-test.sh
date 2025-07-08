#!/usr/bin/env bash
# uv-test.sh - Test runner script using uv for py-package-template
# This script provides various testing options using uv package manager

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}=== py-package-template Test Runner (uv) ===${NC}"
echo "Project root: $PROJECT_ROOT"
echo "Date: $(date)"
echo ""

# Function to print colored output
print_step() {
    echo -e "${BLUE}>>> $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to check if uv is installed
check_uv() {
    if ! command -v uv &> /dev/null; then
        print_error "uv is not installed. Please install it first:"
        echo "  curl -LsSf https://astral.sh/uv/install.sh | sh"
        exit 1
    fi
    print_success "uv is installed: $(uv --version)"
}

# Function to setup test environment
setup_test_env() {
    print_step "Setting up test environment..."
    cd "$PROJECT_ROOT"
    
    # Sync dependencies including dev dependencies
    uv sync --dev
    print_success "Dependencies synchronized"
}

# Function to run basic tests
run_basic_tests() {
    print_step "Running basic test suite..."
    cd "$PROJECT_ROOT"
    
    uv run pytest tests/ -v
    print_success "Basic tests completed"
}

# Function to run tests with coverage
run_tests_with_coverage() {
    print_step "Running tests with coverage..."
    cd "$PROJECT_ROOT"
    
    uv run pytest tests/ --cov=src/py_package_template --cov-report=html --cov-report=term-missing -v
    print_success "Tests with coverage completed"
    
    if [ -d "htmlcov" ]; then
        print_success "Coverage report generated in htmlcov/ directory"
    fi
}

# Function to run specific test categories
run_unit_tests() {
    print_step "Running unit tests only..."
    cd "$PROJECT_ROOT"
    
    uv run pytest tests/ -m "unit" -v
    print_success "Unit tests completed"
}

run_integration_tests() {
    print_step "Running integration tests only..."
    cd "$PROJECT_ROOT"
    
    uv run pytest tests/ -m "integration" -v
    print_success "Integration tests completed"
}

run_performance_tests() {
    print_step "Running performance tests only..."
    cd "$PROJECT_ROOT"
    
    uv run pytest tests/ -m "performance" -v
    print_success "Performance tests completed"
}

# Function to run tests in parallel
run_parallel_tests() {
    print_step "Running tests in parallel..."
    cd "$PROJECT_ROOT"
    
    # Install pytest-xdist if not already installed
    uv add --dev pytest-xdist
    uv run pytest tests/ -n auto -v
    print_success "Parallel tests completed"
}

# Function to run linting and formatting checks
run_quality_checks() {
    print_step "Running code quality checks..."
    cd "$PROJECT_ROOT"
    
    print_step "Running black (code formatting)..."
    uv run black --check src/ tests/
    
    print_step "Running isort (import sorting)..."
    uv run isort --check-only src/ tests/
    
    print_step "Running mypy (type checking)..."
    uv run mypy src/py_package_template/
    
    print_success "Code quality checks completed"
}

# Function to fix code formatting
fix_formatting() {
    print_step "Fixing code formatting..."
    cd "$PROJECT_ROOT"
    
    print_step "Running black (code formatting)..."
    uv run black src/ tests/
    
    print_step "Running isort (import sorting)..."
    uv run isort src/ tests/
    
    print_success "Code formatting fixed"
}

# Function to run all tests and checks
run_full_suite() {
    print_step "Running full test suite..."
    cd "$PROJECT_ROOT"
    
    setup_test_env
    run_quality_checks
    run_tests_with_coverage
    print_success "Full test suite completed"
}

# Function to clean test artifacts
clean_test_artifacts() {
    print_step "Cleaning test artifacts..."
    cd "$PROJECT_ROOT"
    
    # Remove coverage files
    rm -rf htmlcov/
    rm -f .coverage
    
    # Remove pytest cache
    rm -rf .pytest_cache/
    
    # Remove mypy cache
    rm -rf .mypy_cache/
    
    # Remove Python cache
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find . -name "*.pyc" -delete 2>/dev/null || true
    
    print_success "Test artifacts cleaned"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  basic        Run basic test suite (default)"
    echo "  coverage     Run tests with coverage report"
    echo "  unit         Run unit tests only"
    echo "  integration  Run integration tests only"
    echo "  performance  Run performance tests only"
    echo "  parallel     Run tests in parallel"
    echo "  quality      Run code quality checks (black, isort, mypy)"
    echo "  format       Fix code formatting issues"
    echo "  full         Run full test suite (quality + coverage)"
    echo "  clean        Clean test artifacts"
    echo "  help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Run basic tests"
    echo "  $0 coverage          # Run tests with coverage"
    echo "  $0 quality           # Run quality checks"
    echo "  $0 full              # Run everything"
}

# Main script logic
main() {
    check_uv
    
    case "${1:-basic}" in
        "basic")
            setup_test_env
            run_basic_tests
            ;;
        "coverage")
            setup_test_env
            run_tests_with_coverage
            ;;
        "unit")
            setup_test_env
            run_unit_tests
            ;;
        "integration")
            setup_test_env
            run_integration_tests
            ;;
        "performance")
            setup_test_env
            run_performance_tests
            ;;
        "parallel")
            setup_test_env
            run_parallel_tests
            ;;
        "quality")
            setup_test_env
            run_quality_checks
            ;;
        "format")
            setup_test_env
            fix_formatting
            ;;
        "full")
            run_full_suite
            ;;
        "clean")
            clean_test_artifacts
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
