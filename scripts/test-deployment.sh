#!/bin/bash
# Validation script to test PyPI deployment scripts

set -e

echo "🧪 Testing PyPI Deployment Scripts"
echo "=================================="
echo ""

# Test syntax of bash scripts
echo "📋 Testing bash script syntax..."
for script in scripts/*.sh; do
    if [ -f "$script" ]; then
        echo -n "  Testing $script... "
        if bash -n "$script"; then
            echo "✅"
        else
            echo "❌ Syntax error"
            exit 1
        fi
    fi
done

# Test PowerShell scripts if pwsh is available
if command -v pwsh >/dev/null 2>&1; then
    echo ""
    echo "📋 Testing PowerShell script syntax..."
    for script in scripts/*.ps1; do
        if [ -f "$script" ]; then
            echo -n "  Testing $script... "
            # Test syntax by using Get-Help which parses but doesn't execute
            if pwsh -Command "Get-Help '$script' -ErrorAction SilentlyContinue" >/dev/null 2>&1; then
                echo "✅"
            else
                echo "❌ Syntax error"
                exit 1
            fi
        fi
    done
else
    echo ""
    echo "⚠️  PowerShell not available, skipping .ps1 syntax tests"
fi

# Test help messages
echo ""
echo "📋 Testing help messages..."
echo -n "  publish.sh --help... "
if ./scripts/publish.sh --help >/dev/null 2>&1; then
    echo "✅"
else
    echo "❌"
    exit 1
fi

echo -n "  release.sh --help... "
if ./scripts/release.sh --help >/dev/null 2>&1; then
    echo "✅"
else
    echo "❌"
    exit 1
fi

# Test dry-run functionality (should not require network)
echo ""
echo "📋 Testing dry-run functionality..."
echo -n "  release.sh patch --dry-run... "
if ./scripts/release.sh patch --dry-run >/dev/null 2>&1; then
    echo "✅"
else
    echo "❌"
    exit 1
fi

echo ""
echo "🎉 All tests passed! PyPI deployment scripts are ready to use."
echo ""
echo "Next steps:"
echo "1. Set up API tokens: export PYPI_API_TOKEN='your-token'"
echo "2. Test package build: ./scripts/publish.sh --check-only"
echo "3. Make a test release: ./scripts/release.sh patch --test"
echo ""
echo "For detailed usage, see: docs/pypi_deployment.md"