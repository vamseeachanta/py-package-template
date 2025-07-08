"""Pytest configuration and shared fixtures for py-package-template tests

This module provides shared test fixtures, configuration, and utilities
that can be used across all test modules.
"""

import pytest
import sys
from pathlib import Path
from io import StringIO
import tempfile
import os

# Add src directory to path if not already present
ROOT_DIR = Path(__file__).parent.parent
SRC_DIR = ROOT_DIR / "src"
if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))


@pytest.fixture
def capture_stdout():
    """Fixture to capture stdout for testing print statements."""
    original_stdout = sys.stdout
    sys.stdout = captured_output = StringIO()
    yield captured_output
    sys.stdout = original_stdout


@pytest.fixture
def capture_stderr():
    """Fixture to capture stderr for testing error output."""
    original_stderr = sys.stderr
    sys.stderr = captured_output = StringIO()
    yield captured_output
    sys.stderr = original_stderr


@pytest.fixture
def temp_directory():
    """Fixture providing a temporary directory for tests."""
    with tempfile.TemporaryDirectory() as temp_dir:
        yield Path(temp_dir)


@pytest.fixture
def temp_file():
    """Fixture providing a temporary file for tests."""
    with tempfile.NamedTemporaryFile(mode='w+', delete=False) as tmp_file:
        yield Path(tmp_file.name)
    # Clean up
    try:
        os.unlink(tmp_file.name)
    except FileNotFoundError:
        pass


@pytest.fixture
def mock_environment():
    """Fixture providing a clean environment for testing."""
    original_env = os.environ.copy()
    # Clear test-related environment variables
    test_vars = [var for var in os.environ if var.startswith('TEST_')]
    for var in test_vars:
        del os.environ[var]
    
    yield os.environ
    
    # Restore original environment
    os.environ.clear()
    os.environ.update(original_env)


@pytest.fixture
def sample_test_data():
    """Fixture providing sample test data."""
    return {
        'integers': [1, 2, 3, 10, 100],
        'strings': ['hello', 'world', 'test'],
        'floats': [1.0, 2.5, 3.14, 10.0],
        'booleans': [True, False],
        'none_values': [None],
        'mixed': [1, 'hello', 3.14, True, None]
    }


@pytest.fixture
def package_info():
    """Fixture providing package information for tests."""
    return {
        'name': 'py-package-template',
        'version': '0.0.1',
        'python_name': 'py_package_template',
        'author': 'Vamsee Achanta',
        'email': 'vamsee.achanta@aceengineer.com',
        'github_url': 'https://github.com/vamseeachanta/py-package-template',
        'pypi_url': 'https://pypi.org/project/py-package-template/'
    }


# Test markers
def pytest_configure(config):
    """Configure custom pytest markers."""
    config.addinivalue_line(
        "markers", 
        "slow: marks tests as slow (deselect with '-m \"not slow\"')"
    )
    config.addinivalue_line(
        "markers", "integration: marks tests as integration tests"
    )
    config.addinivalue_line(
        "markers", "unit: marks tests as unit tests"
    )
    config.addinivalue_line(
        "markers", "performance: marks tests as performance tests"
    )


# Custom test collection
def pytest_collection_modifyitems(config, items):
    """Modify test collection to add markers automatically."""
    for item in items:
        # Mark slow tests
        if "performance" in item.name.lower() or "slow" in item.name.lower():
            item.add_marker(pytest.mark.slow)
        
        # Mark integration tests
        if "integration" in item.name.lower() or "Integration" in str(item.cls):
            item.add_marker(pytest.mark.integration)
        
        # Mark unit tests (default for most tests)
        if not any(marker.name in ['integration', 'performance'] for marker in item.iter_markers()):
            item.add_marker(pytest.mark.unit)
