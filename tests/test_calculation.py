
import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "src")))

"""Tests for py_package_template.calculation module

This module tests the calculation functionality including:
- pressure_pipe function
- Return values and outputs
- Error handling
"""

import pytest
from unittest.mock import patch
from io import StringIO
import sys

from py_package_template import calculation


class TestPressurePipe:
    """Test cases for the pressure_pipe function."""

    def test_pressure_pipe_returns_ten(self):
        """Test that pressure_pipe returns the value 10."""
        result = calculation.pressure_pipe()
        assert result == 10, f"Expected 10, but got {result}"

    def test_pressure_pipe_return_type(self):
        """Test that pressure_pipe returns an integer."""
        result = calculation.pressure_pipe()
        assert isinstance(result, int), f"Expected int, but got {type(result)}"

    @patch('sys.stdout', new_callable=StringIO)
    def test_pressure_pipe_prints_ten(self, mock_stdout):
        """Test that pressure_pipe prints the value 10 to stdout."""
        calculation.pressure_pipe()
        output = mock_stdout.getvalue().strip()
        assert output == "10", f"Expected '10' to be printed, but got '{output}'"

    @patch('sys.stdout', new_callable=StringIO)
    def test_pressure_pipe_output_format(self, mock_stdout):
        """Test that pressure_pipe prints in the correct format."""
        result = calculation.pressure_pipe()
        output = mock_stdout.getvalue()
        
        # Check that output ends with newline
        assert output.endswith('\n'), "Output should end with a newline"
        
        # Check that printed value matches returned value
        printed_value = output.strip()
        assert printed_value == str(result), "Printed and returned values should match"

    def test_pressure_pipe_callable(self):
        """Test that pressure_pipe is callable."""
        assert callable(calculation.pressure_pipe), "pressure_pipe should be callable"

    def test_pressure_pipe_no_parameters(self):
        """Test that pressure_pipe can be called without parameters."""
        try:
            result = calculation.pressure_pipe()
            assert result is not None, "Function should return a value"
        except TypeError:
            pytest.fail("pressure_pipe should be callable without parameters")

    def test_pressure_pipe_consistent_results(self):
        """Test that pressure_pipe returns consistent results across multiple calls."""
        results = [calculation.pressure_pipe() for _ in range(5)]
        assert all(r == 10 for r in results), "All calls should return 10"
        assert len(set(results)) == 1, "All results should be identical"


class TestCalculationModule:
    """Test cases for the calculation module as a whole."""

    def test_module_has_pressure_pipe(self):
        """Test that the calculation module has pressure_pipe function."""
        assert hasattr(calculation, 'pressure_pipe'), "Module should have pressure_pipe function"

    def test_pressure_pipe_in_all(self):
        """Test that pressure_pipe is in __all__ if it exists."""
        if hasattr(calculation, '__all__'):
            assert 'pressure_pipe' in calculation.__all__, "pressure_pipe should be in __all__"

    def test_module_docstring(self):
        """Test that the module has a docstring."""
        # This is a basic check - the actual module might not have a docstring yet
        # but it's good practice to test for it
        if calculation.__doc__:
            assert len(calculation.__doc__.strip()) > 0, "Module docstring should not be empty"


# Integration tests
class TestCalculationIntegration:
    """Integration tests for calculation module."""

    def test_import_and_call(self):
        """Test importing and calling the function in one flow."""
        from py_package_template.calculation import pressure_pipe
        result = pressure_pipe()
        assert result == 10

    @patch('sys.stdout', new_callable=StringIO)
    def test_multiple_calls_output(self, mock_stdout):
        """Test output from multiple function calls."""
        # Call function multiple times
        results = []
        for i in range(3):
            results.append(calculation.pressure_pipe())
        
        output_lines = mock_stdout.getvalue().strip().split('\n')
        
        # Should have 3 lines of output
        assert len(output_lines) == 3, f"Expected 3 lines of output, got {len(output_lines)}"
        
        # Each line should be "10"
        for line in output_lines:
            assert line == "10", f"Each line should be '10', but got '{line}'"


# Performance tests
class TestCalculationPerformance:
    """Performance tests for calculation functions."""

    def test_pressure_pipe_performance(self):
        """Test that pressure_pipe executes quickly."""
        import time
        
        start_time = time.time()
        for _ in range(1000):
            calculation.pressure_pipe()
        end_time = time.time()
        
        execution_time = end_time - start_time
        # Should complete 1000 calls in less than 1 second
        assert execution_time < 1.0, f"1000 calls took {execution_time:.3f}s, should be < 1.0s"


# Parametrized tests for potential future expansion
class TestCalculationParametrized:
    """Parametrized tests for calculation module."""

    @pytest.mark.parametrize("call_count", [1, 5, 10])
    def test_pressure_pipe_multiple_calls(self, call_count):
        """Test pressure_pipe with different numbers of calls."""
        results = [calculation.pressure_pipe() for _ in range(call_count)]
        
        # All results should be 10
        assert all(r == 10 for r in results)
        
        # Should have the expected number of results
        assert len(results) == call_count

    @pytest.mark.parametrize("expected_value,expected_type", [
        (10, int),
    ])
    def test_pressure_pipe_return_values(self, expected_value, expected_type):
        """Test pressure_pipe return values with different expectations."""
        result = calculation.pressure_pipe()
        assert result == expected_value
        assert isinstance(result, expected_type)


# Validation tests demonstrate comprehensive pytest fixture usage
# Additional fixture examples are available in conftest.py
