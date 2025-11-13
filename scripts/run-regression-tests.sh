#!/bin/bash

# Script to run regression tests
# These tests verify that critical functionality continues to work after code changes

set -e # Exit on any error

echo "=== Running Regression Tests ==="

echo "Creating Python virtual environment..."
python -m venv .venv

echo "Activating virtual environment..."
. .venv/bin/activate # . is a shorthand for 'source'

echo "Installing test dependencies..."
cd app && uv sync --active --all-extras

echo "Running regression tests..."
cd tests && python -m pytest regression.py \
  -v \
  --tb=short \
  --html=../../regression-test-report.html \
  --self-contained-html

echo "Regression tests completed successfully!"
echo "📊 Test report generated: regression-test-report.html"