# Development Documentation

This directory contains development-related documentation, test files, and scripts for the chiptimputation-vcf-liftover pipeline.

## Contents

### Documentation
- **PROJECT_SUMMARY.md** - Comprehensive project overview and architecture
- **design.md** - Original design document and technical specifications

### Test Scripts
- **test_pipeline.sh** - Basic pipeline validation script
- **run_comprehensive_tests.sh** - Comprehensive test suite for all scenarios

### Test Data
- **test_data/** - Complete test datasets and scenarios
  - VCF test files for various scenarios
  - Reference genome files for testing
  - CSV batch processing files
  - Test scenarios documentation

## Usage

### Running Tests

```bash
# Basic pipeline validation
./dev_docs/test_pipeline.sh

# Comprehensive test suite
./dev_docs/run_comprehensive_tests.sh

# Generate new test data
python3 bin/generate_test_data.py
```

### Test Data Structure

The test_data directory contains:
- **Small datasets** - For quick validation
- **Multi-chromosome datasets** - For testing chromosome handling
- **Population datasets** - For testing with many samples
- **Edge case datasets** - For testing complex variants
- **CSV batch files** - For testing batch processing

### Development Workflow

1. **Design Changes** - Update design.md with new specifications
2. **Test Development** - Create tests in test_data/ for new features
3. **Validation** - Run test scripts to ensure functionality
4. **Documentation** - Update PROJECT_SUMMARY.md with changes

## File Organization

```
dev_docs/
├── README.md                    # This file
├── PROJECT_SUMMARY.md           # Project overview
├── design.md                    # Technical design
├── test_pipeline.sh             # Basic tests
├── run_comprehensive_tests.sh   # Full test suite
└── test_data/                   # Test datasets
    ├── README.md                # Test data documentation
    ├── TEST_SCENARIOS.md         # Test scenarios guide
    ├── *.vcf.gz                 # Test VCF files
    ├── *.fa                     # Test reference files
    └── *.csv                    # Batch processing files
```

## Notes

- All test data paths have been updated to use `dev_docs/test_data/` prefix
- Test scripts are configured to work with the new directory structure
- Configuration files in `conf/` have been updated to reference the new paths
- This separation keeps development files organized and separate from user documentation
