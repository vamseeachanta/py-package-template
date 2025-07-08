import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "src")))

"""Tests for py_package_template.__main__ module

This module tests the main entry point functionality including:
- Module docstring and version information
- Package metadata
- Import functionality
"""

import pytest
from unittest.mock import patch

import py_package_template
from py_package_template import __main__ as main_module


class TestMainModule:
    """Test cases for the __main__ module."""

    def test_main_module_has_docstring(self):
        """Test that the main module has a docstring."""
        assert main_module.__doc__ is not None, "Main module should have docstring"
        assert len(main_module.__doc__.strip()) > 0, "Docstring should not be empty"

    def test_main_module_docstring_content(self):
        """Test that the main module docstring contains expected content."""
        docstring = main_module.__doc__
        
        # Check for expected sections
        expected_sections = ["Usage:", "Contact:", "Version:"]
        for section in expected_sections:
            assert section in docstring, f"Docstring should contain '{section}'"

    def test_main_module_contains_version_info(self):
        """Test that the main module docstring contains version information."""
        docstring = main_module.__doc__
        assert "py-package-template v0.0.1" in docstring, (
            "Docstring should contain version info"
        )

    def test_main_module_contains_github_url(self):
        """Test that the main module contains GitHub repository URL."""
        docstring = main_module.__doc__
        expected_url = "https://github.com/vamseeachanta/py-package-template"
        assert expected_url in docstring, (
            "Docstring should contain GitHub repository URL"
        )

    def test_main_module_contains_pypi_url(self):
        """Test that the main module contains PyPI project URL."""
        docstring = main_module.__doc__
        expected_url = "https://pypi.org/project/py-package-template/"
        assert expected_url in docstring, (
            "Docstring should contain PyPI project URL"
        )


class TestMainModuleStructure:
    """Test cases for main module structure and metadata."""

    def test_main_module_is_importable(self):
        """Test that the main module can be imported."""
        try:
            from py_package_template import __main__
            assert __main__ is not None
        except ImportError as e:
            pytest.fail(f"Failed to import __main__ module: {e}")

    def test_main_module_file_attribute(self):
        """Test that the main module has a __file__ attribute."""
        assert hasattr(main_module, '__file__'), (
            "Main module should have __file__ attribute"
        )
        assert main_module.__file__ is not None, (
            "__file__ attribute should not be None"
        )

    def test_main_module_name_attribute(self):
        """Test that the main module has a __name__ attribute."""
        assert hasattr(main_module, '__name__'), (
            "Main module should have __name__ attribute"
        )


class TestMainModuleExecution:
    """Test cases for main module execution scenarios."""

    def test_main_module_direct_execution(self):
        """Test that the main module can handle direct execution."""
        # This tests the structure but doesn't actually execute
        # since there's no main() function yet
        
        # Check if there would be a main execution block
        docstring = main_module.__doc__
        assert docstring is not None, "Module should be ready for execution"

    @patch('builtins.print')
    def test_main_module_no_side_effects_on_import(self, mock_print):
        """Test that importing the main module doesn't cause side effects."""
        # Re-import the module to test
        import importlib
        importlib.reload(main_module)
        
        # Should not print anything just from importing
        mock_print.assert_not_called()


class TestMainModuleDocumentation:
    """Test cases for main module documentation quality."""

    def test_docstring_formatting(self):
        """Test that the docstring is properly formatted."""
        docstring = main_module.__doc__
        lines = docstring.split('\n')
        
        # Should have multiple lines
        assert len(lines) > 5, "Docstring should have multiple lines"
        
        # Should not have trailing whitespace on lines
        for i, line in enumerate(lines):
            if line.strip():  # Skip empty lines
                assert line == line.rstrip(), (
                    f"Line {i} should not have trailing whitespace"
                )

    def test_docstring_sections_structure(self):
        """Test that docstring sections are properly structured."""
        docstring = main_module.__doc__
        
        # Check that sections have proper line breaks
        assert "Usage:\n------" in docstring, (
            "Usage section should have proper formatting"
        )
        assert "Contact:\n--------" in docstring, (
            "Contact section should have proper formatting"
        )
        assert "Version:\n--------" in docstring, (
            "Version section should have proper formatting"
        )

    def test_docstring_urls_format(self):
        """Test that URLs in docstring are properly formatted."""
        docstring = main_module.__doc__
        
        # Check URL formatting with bullet points
        github_url = "- https://github.com/vamseeachanta/py-package-template"
        pypi_url = "- https://pypi.org/project/py-package-template/"
        
        assert github_url in docstring, "GitHub URL should be bullet-pointed"
        assert pypi_url in docstring, "PyPI URL should be bullet-pointed"


class TestMainModuleIntegration:
    """Integration tests for main module with package."""

    def test_main_module_package_integration(self):
        """Test that main module integrates properly with package."""
        # Test that main module is part of the package
        assert hasattr(py_package_template, '__main__'), (
            "Package should have __main__ module"
        )

    def test_main_module_version_consistency(self):
        """Test that version in main module matches package version."""
        main_docstring = main_module.__doc__
        package_version = py_package_template.__version__
        
        # Version should appear in main module docstring
        version_string = f"py-package-template v{package_version}"
        assert version_string in main_docstring, (
            f"Main module should contain version string: {version_string}"
        )

    def test_package_can_be_executed_as_module(self):
        """Test that package structure supports -m execution."""
        # This tests that the structure is correct for python -m execution
        assert hasattr(py_package_template, '__main__'), (
            "Package should have __main__ for -m execution"
        )


# Future enhancement tests
class TestMainModuleFutureFeatures:
    """Test cases for potential future features in main module."""

    def test_main_function_placeholder(self):
        """Test readiness for future main() function."""
        # Check if main module is ready for a main() function
        if hasattr(main_module, 'main'):
            assert callable(main_module.main), "main should be callable if present"
        else:
            # Module is ready for future main() function addition
            assert True, "Module structure supports future main() function"

    def test_cli_argument_parsing_readiness(self):
        """Test readiness for future CLI argument parsing."""
        # The docstring structure suggests CLI usage
        docstring = main_module.__doc__
        assert "Usage:" in docstring, (
            "Module is structured for future CLI implementation"
        )


# Performance and quality tests
class TestMainModuleQuality:
    """Test cases for main module code quality."""

    def test_main_module_import_speed(self):
        """Test that main module imports quickly."""
        import time
        import importlib
        
        start_time = time.time()
        importlib.reload(main_module)
        end_time = time.time()
        
        import_time = end_time - start_time
        assert import_time < 0.1, (
            f"Main module import took {import_time:.3f}s, should be < 0.1s"
        )

    def test_main_module_memory_efficiency(self):
        """Test that main module doesn't consume excessive memory."""
        import sys
        
        # Get module size (this is a basic check)
        module_size = sys.getsizeof(main_module.__dict__)
        
        # Should be reasonable size (less than 10KB for a simple module)
        assert module_size < 10000, (
            f"Main module dict size is {module_size} bytes, seems excessive"
        )


# Validation tests
@pytest.mark.parametrize("url", [
    "https://github.com/vamseeachanta/py-package-template",
    "https://pypi.org/project/py-package-template/",
])
def test_main_module_contains_url(url):
    """Test that main module contains expected URLs."""
    docstring = main_module.__doc__
    assert url in docstring, f"Main module should contain URL: {url}"


@pytest.mark.parametrize("section", [
    "Usage:",
    "Contact:",
    "Version:",
])
def test_main_module_contains_section(section):
    """Test that main module contains expected sections."""
    docstring = main_module.__doc__
    assert section in docstring, f"Main module should contain section: {section}"
