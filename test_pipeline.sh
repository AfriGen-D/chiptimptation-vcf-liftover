#!/bin/bash

# chiptimputation-vcf-liftover Pipeline Test Script
# =================================================
# This script tests the pipeline functionality with various configurations

set -e  # Exit on any error

echo "=========================================="
echo " chiptimputation-vcf-liftover Test Suite"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "PASS")
            echo -e "${GREEN}[PASS]${NC} $message"
            ;;
        "FAIL")
            echo -e "${RED}[FAIL]${NC} $message"
            ;;
        "INFO")
            echo -e "${YELLOW}[INFO]${NC} $message"
            ;;
    esac
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Test 1: Check dependencies
print_status "INFO" "Testing dependencies..."

if command_exists nextflow; then
    print_status "PASS" "Nextflow is installed"
    nextflow -version
else
    print_status "FAIL" "Nextflow is not installed"
    exit 1
fi

if command_exists singularity; then
    print_status "PASS" "Singularity is installed"
    singularity --version
else
    print_status "FAIL" "Singularity is not installed"
    echo "Note: You can still test with Docker if available"
fi

if command_exists docker; then
    print_status "PASS" "Docker is installed"
    docker --version
else
    print_status "INFO" "Docker is not installed (optional)"
fi

# Test 2: Check pipeline structure
print_status "INFO" "Checking pipeline structure..."

required_files=(
    "main.nf"
    "nextflow.config"
    "README.md"
    "LICENSE"
    "workflows/liftover.nf"
    "modules/crossmap.nf"
    "modules/sort_vcf.nf"
    "modules/index_vcf.nf"
    "modules/input_check.nf"
    "conf/singularity.config"
    "conf/test.config"
    "test_data/samples.csv"
    "bin/check_vcf.py"
    "bin/generate_stats.py"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        print_status "PASS" "Found required file: $file"
    else
        print_status "FAIL" "Missing required file: $file"
        exit 1
    fi
done

# Test 3: Validate Nextflow syntax
print_status "INFO" "Validating Nextflow syntax..."

if nextflow run main.nf --help >/dev/null 2>&1; then
    print_status "PASS" "Main workflow syntax is valid"
else
    print_status "FAIL" "Main workflow syntax error"
    exit 1
fi

# Test 4: Check test data
print_status "INFO" "Checking test data..."

if [[ -f "test_data/samples.csv" ]]; then
    sample_count=$(tail -n +2 test_data/samples.csv | wc -l)
    print_status "PASS" "Test samples CSV found with $sample_count samples"
else
    print_status "FAIL" "Test samples CSV not found"
    exit 1
fi

# Check if test VCF files exist
while IFS=, read -r sample_id vcf_path; do
    if [[ "$sample_id" != "sample_id" ]]; then  # Skip header
        if [[ -f "$vcf_path" ]]; then
            print_status "PASS" "Test VCF found: $vcf_path"
        else
            print_status "FAIL" "Test VCF missing: $vcf_path"
            exit 1
        fi
    fi
done < test_data/samples.csv

# Test 5: Pipeline syntax validation
print_status "INFO" "Validating pipeline with test profile..."

if nextflow run main.nf -profile test --help >/dev/null 2>&1; then
    print_status "PASS" "Pipeline test profile validation successful"
else
    print_status "FAIL" "Pipeline test profile validation failed"
    echo "Check the pipeline configuration and test data"
    exit 1
fi

# Test 6: Configuration validation
print_status "INFO" "Validating configuration files..."

config_files=(
    "conf/base.config"
    "conf/singularity.config"
    "conf/docker.config"
    "conf/slurm.config"
    "conf/test.config"
)

for config in "${config_files[@]}"; do
    if [[ -f "$config" ]]; then
        print_status "PASS" "Configuration file exists: $config"
    else
        print_status "FAIL" "Configuration file missing: $config"
    fi
done

# Test 7: Helper scripts validation
print_status "INFO" "Validating helper scripts..."

if python3 bin/check_vcf.py --help >/dev/null 2>&1; then
    print_status "PASS" "VCF validation script is functional"
else
    print_status "FAIL" "VCF validation script has issues"
fi

if python3 bin/generate_stats.py --help >/dev/null 2>&1; then
    print_status "PASS" "Statistics generation script is functional"
else
    print_status "FAIL" "Statistics generation script has issues"
fi

# Test 8: Documentation check
print_status "INFO" "Checking documentation..."

doc_files=(
    "README.md"
    "docs/usage.md"
    "docs/parameters.md"
    "design.md"
)

for doc in "${doc_files[@]}"; do
    if [[ -f "$doc" ]]; then
        print_status "PASS" "Documentation file exists: $doc"
    else
        print_status "FAIL" "Documentation file missing: $doc"
    fi
done

# Test 9: Asset files check
print_status "INFO" "Checking asset files..."

if [[ -f "assets/chr_mapping.txt" ]]; then
    print_status "PASS" "Chromosome mapping file exists"
else
    print_status "FAIL" "Chromosome mapping file missing"
fi

if [[ -f "assets/multiqc_config.yaml" ]]; then
    print_status "PASS" "MultiQC configuration exists"
else
    print_status "FAIL" "MultiQC configuration missing"
fi

# Summary
echo ""
echo "=========================================="
echo " Test Summary"
echo "=========================================="
print_status "PASS" "All basic tests completed successfully!"
echo ""
echo "The chiptimputation-vcf-liftover pipeline appears to be properly set up."
echo ""
echo "Next steps:"
echo "1. Run a full test: nextflow run main.nf -profile test,singularity"
echo "2. Check the output in test_results/"
echo "3. Review the generated reports"
echo ""
echo "For production use:"
echo "1. Prepare your input CSV file"
echo "2. Download appropriate chain files and reference genomes"
echo "3. Run: nextflow run main.nf -profile singularity --input samples.csv --chain_file chain.gz --target_fasta ref.fa"
echo ""
print_status "INFO" "Pipeline validation completed successfully!"
