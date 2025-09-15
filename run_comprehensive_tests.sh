#!/bin/bash

# Comprehensive Test Suite for chiptimptation-vcf-liftover Pipeline
# Tests all generated test datasets with various scenarios

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
PROFILE="test,singularity"
TARGET_FASTA="/cbio/dbs/references/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa"
VALIDATE_OUTPUT="false"
BASE_PATH="/users/mamana/chiptimptation-liftover"

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "INFO")
            echo -e "${BLUE}[INFO]${NC} $message"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[SUCCESS]${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}[WARNING]${NC} $message"
            ;;
    esac
}

# Function to run a single test
run_test() {
    local test_name=$1
    local input_param=$2
    local expected_samples=$3
    local description=$4
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    print_status "INFO" "Running Test $TOTAL_TESTS: $test_name"
    print_status "INFO" "Description: $description"
    print_status "INFO" "Input: $input_param"
    
    # Clean previous results
    rm -rf test_results/ work/ .nextflow*
    
    # Convert relative paths to absolute paths
    if [[ "$input_param" == test_data/* ]]; then
        input_param="$BASE_PATH/$input_param"
    fi

    # Run the pipeline
    if ./nextflow run main.nf \
        -profile $PROFILE \
        --input "$input_param" \
        --target_fasta "$TARGET_FASTA" \
        --validate_output $VALIDATE_OUTPUT \
        > "test_${TOTAL_TESTS}_${test_name}.log" 2>&1; then
        
        # Check if results were generated
        if [ -d "test_results" ] && [ -f "test_results/reports/liftover_statistics.txt" ]; then
            # Extract statistics
            local total_samples=$(grep "Total Samples:" test_results/reports/liftover_statistics.txt | awk '{print $3}')
            local success_rate=$(grep "Average Success Rate:" test_results/reports/liftover_statistics.txt | awk '{print $4}' | sed 's/%//')
            
            print_status "SUCCESS" "Test $TOTAL_TESTS PASSED"
            print_status "INFO" "  - Samples processed: $total_samples"
            print_status "INFO" "  - Success rate: $success_rate%"
            
            # Check if success rate is reasonable (>50%)
            if (( $(echo "$success_rate > 50" | bc -l) )); then
                print_status "SUCCESS" "  - Success rate is acceptable"
            else
                print_status "WARNING" "  - Low success rate: $success_rate%"
            fi
            
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            print_status "ERROR" "Test $TOTAL_TESTS FAILED - No results generated"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        print_status "ERROR" "Test $TOTAL_TESTS FAILED - Pipeline execution failed"
        print_status "INFO" "Check test_${TOTAL_TESTS}_${test_name}.log for details"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    
    echo "----------------------------------------"
}

# Function to verify test data exists
verify_test_data() {
    print_status "INFO" "Verifying test data exists..."
    
    local required_files=(
        "test_data/small_chr22.vcf.gz"
        "test_data/medium_multi_chr.vcf.gz"
        "test_data/large_single_sample.vcf.gz"
        "test_data/population_20samples.vcf.gz"
        "test_data/edge_cases.vcf.gz"
        "test_data/multiallelic.vcf.gz"
        "test_data/single_sample.csv"
        "test_data/multiple_samples.csv"
        "test_data/population_study.csv"
    )
    
    local missing_files=()
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        print_status "ERROR" "Missing test data files:"
        for file in "${missing_files[@]}"; do
            print_status "ERROR" "  - $file"
        done
        print_status "INFO" "Run: python3 bin/generate_test_data.py"
        exit 1
    fi
    
    print_status "SUCCESS" "All test data files found"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "INFO" "Checking prerequisites..."
    
    # Check if nextflow exists
    if [ ! -f "./nextflow" ]; then
        print_status "ERROR" "Nextflow executable not found"
        exit 1
    fi
    
    # Check if target FASTA exists
    if [ ! -f "$TARGET_FASTA" ]; then
        print_status "WARNING" "Target FASTA not found: $TARGET_FASTA"
        print_status "INFO" "Using default small reference"
        TARGET_FASTA="test_data/hg38_chr22.fa"
    fi
    
    # Check if bc is available for calculations
    if ! command -v bc &> /dev/null; then
        print_status "WARNING" "bc calculator not found - some checks will be skipped"
    fi
    
    print_status "SUCCESS" "Prerequisites check completed"
}

# Main test execution
main() {
    echo "========================================"
    echo "chiptimptation-vcf-liftover Test Suite"
    echo "========================================"
    echo "Started: $(date)"
    echo ""
    
    # Check prerequisites
    check_prerequisites
    
    # Verify test data
    verify_test_data
    
    echo ""
    print_status "INFO" "Starting comprehensive test suite..."
    echo ""
    
    # Test 1: Small dataset (quick validation)
    run_test "small_dataset" \
             "test_data/small_chr22.vcf.gz" \
             "1" \
             "Quick validation with 5 variants on chr22"
    
    # Test 2: Medium multi-chromosome dataset
    run_test "medium_multi_chr" \
             "test_data/medium_multi_chr.vcf.gz" \
             "1" \
             "Multi-chromosome processing (chr21-22)"
    
    # Test 3: Large single sample dataset
    run_test "large_single_sample" \
             "test_data/large_single_sample.vcf.gz" \
             "1" \
             "Performance test with 100 variants"
    
    # Test 4: Population dataset
    run_test "population_dataset" \
             "test_data/population_20samples.vcf.gz" \
             "1" \
             "Many samples test (20 samples)"
    
    # Test 5: Edge cases
    run_test "edge_cases" \
             "test_data/edge_cases.vcf.gz" \
             "1" \
             "Complex variants (indels, edge positions)"
    
    # Test 6: Multi-allelic variants
    run_test "multiallelic" \
             "test_data/multiallelic.vcf.gz" \
             "1" \
             "Multi-allelic variant handling"
    
    # Test 7: CSV single sample
    run_test "csv_single_sample" \
             "test_data/single_sample.csv" \
             "1" \
             "CSV input with single sample"
    
    # Test 8: CSV multiple samples
    run_test "csv_multiple_samples" \
             "test_data/multiple_samples.csv" \
             "3" \
             "CSV input with multiple samples"
    
    # Test 9: CSV population study
    run_test "csv_population_study" \
             "test_data/population_study.csv" \
             "3" \
             "CSV input for population study"
    
    # Summary
    echo ""
    echo "========================================"
    echo "TEST SUITE SUMMARY"
    echo "========================================"
    print_status "INFO" "Total tests run: $TOTAL_TESTS"
    print_status "SUCCESS" "Tests passed: $PASSED_TESTS"
    print_status "ERROR" "Tests failed: $FAILED_TESTS"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        print_status "SUCCESS" "🎉 ALL TESTS PASSED!"
        echo ""
        print_status "INFO" "The chiptimptation-vcf-liftover pipeline is working correctly"
        print_status "INFO" "with all test scenarios and input formats."
        exit 0
    else
        print_status "ERROR" "❌ Some tests failed"
        echo ""
        print_status "INFO" "Check individual test logs for details:"
        for i in $(seq 1 $TOTAL_TESTS); do
            if [ -f "test_${i}_*.log" ]; then
                print_status "INFO" "  - test_${i}_*.log"
            fi
        done
        exit 1
    fi
}

# Run main function
main "$@"
