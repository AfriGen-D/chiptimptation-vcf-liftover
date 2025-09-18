# Test Data Generation ​

Reference documentation for generating and maintaining test datasets for chiptimputation-vcf-liftover development and testing.

## Overview ​

The chiptimputation-vcf-liftover pipeline includes comprehensive test data for validation, development, and user tutorials. This documentation covers how test data is generated and maintained.

## Pre-Built Test Data ​

The repository includes ready-to-use test data in the `test_data/` directory:

### VCF Test Files ​

| File | Description | Size | Use Case |
|------|-------------|------|----------|
| `small_chr22.vcf.gz` | Small chr22 variants | ~1KB | Quick tutorials |
| `medium_multi_chr.vcf.gz` | Multi-chromosome variants | ~10KB | Standard testing |
| `large_single_sample.vcf.gz` | Large single sample | ~100KB | Performance testing |
| `population_20samples.vcf.gz` | Population study data | ~500KB | Batch processing |
| `edge_cases.vcf.gz` | Edge case variants | ~5KB | Error handling |
| `multiallelic.vcf.gz` | Multiallelic variants | ~3KB | Complex variants |

### Reference Files ​

| File | Description | Size | Coverage |
|------|-------------|------|----------|
| `GRCh38_test_regions.fa` | Test reference regions | 30MB | chr21:1-10M, chr22:1-20M |
| `GRCh38_chr21_chr22.fa` | Full chr21+chr22 | 95MB | Complete chromosomes |
| `hg38_chr22.fa` | Chr22 only | 50MB | Single chromosome |

### CSV Batch Files ​

| File | Description | Samples | Use Case |
|------|-------------|---------|----------|
| `single_sample.csv` | Single sample | 1 | Basic tutorial |
| `samples.csv` | Multiple samples | 3 | Batch processing |
| `multiple_samples.csv` | Extended batch | 5 | Medium batch |
| `population_study.csv` | Population data | 20 | Large-scale analysis |

## Test Data Generation Tools ​

### For Developers and Maintainers ​

The following tools are available for generating and updating test data:

#### Generate VCF Test Data ​

```bash
# Generate all test scenarios
python3 bin/generate_test_data.py --all-scenarios

# Generate specific scenarios
python3 bin/generate_test_data.py --small-test
python3 bin/generate_test_data.py --population-study
python3 bin/generate_test_data.py --edge-cases

# Generate with custom parameters
python3 bin/generate_test_data.py \
    --output-dir custom_test_data \
    --num-variants 1000 \
    --num-samples 10
```

#### Generate Reference Test Data ​

```bash
# Generate test reference regions
python3 bin/generate_test_reference.py \
    --regions chr21:1-10000000,chr22:1-20000000 \
    --output test_data/GRCh38_test_regions.fa

# Generate full chromosomes
python3 bin/generate_test_reference.py \
    --chromosomes chr21,chr22 \
    --output test_data/GRCh38_chr21_chr22.fa

# Generate single chromosome
python3 bin/generate_test_reference.py \
    --chromosomes chr22 \
    --output test_data/GRCh38_chr22.fa
```

### Tool Options ​

#### generate_test_data.py ​

**Basic Options:**
- `--all-scenarios`: Generate all test scenarios
- `--small-test`: Generate minimal test data
- `--population-study`: Generate population-scale data
- `--edge-cases`: Generate edge case variants

**Advanced Options:**
- `--output-dir DIR`: Output directory (default: test_data)
- `--num-variants N`: Number of variants per file
- `--num-samples N`: Number of samples for population data
- `--chromosomes LIST`: Chromosomes to include
- `--build BUILD`: Source genome build (default: hg19)

#### generate_test_reference.py ​

**Region Options:**
- `--regions LIST`: Specific regions (chr:start-end)
- `--chromosomes LIST`: Full chromosomes
- `--size SIZE`: Random regions of specified size

**Source Options:**
- `--source-fasta FILE`: Source reference file
- `--source-url URL`: Download source reference
- `--build BUILD`: Genome build (hg19, hg38, etc.)

**Output Options:**
- `--output FILE`: Output FASTA file
- `--index`: Create index file (.fai)
- `--compress`: Compress output

## Test Scenarios ​

### Scenario Coverage ​

The test data covers various genomic scenarios:

#### Variant Types ​
- **SNPs**: Single nucleotide polymorphisms
- **Indels**: Insertions and deletions
- **Multiallelic**: Multiple alternative alleles
- **Complex**: Structural variants

#### Genomic Regions ​
- **Coding regions**: Exonic variants
- **Non-coding**: Intronic and intergenic
- **Repetitive**: Simple and complex repeats
- **Problematic**: Known difficult regions

#### Data Quality ​
- **High quality**: Clean, well-formatted data
- **Low quality**: Missing data, format issues
- **Edge cases**: Boundary conditions
- **Error conditions**: Invalid formats

### Expected Success Rates ​

| Test File | Expected Success Rate | Notes |
|-----------|----------------------|-------|
| `small_chr22.vcf.gz` | >95% | High-quality variants |
| `medium_multi_chr.vcf.gz` | >90% | Mixed quality |
| `edge_cases.vcf.gz` | 70-85% | Challenging variants |
| `population_20samples.vcf.gz` | >92% | Population data |

## Maintenance ​

### Updating Test Data ​

When updating test data:

1. **Regenerate with new tools**:
   ```bash
   python3 bin/generate_test_data.py --all-scenarios
   ```

2. **Validate new data**:
   ```bash
   nextflow run main.nf -profile test,singularity
   ```

3. **Update documentation**:
   - Update file sizes in this document
   - Update expected success rates
   - Update test scenarios

4. **Commit changes**:
   ```bash
   git add test_data/
   git commit -m "Update test data"
   ```

### Quality Assurance ​

Before committing new test data:

- **Validate VCF format**: `bcftools view -h file.vcf.gz`
- **Check file sizes**: Ensure reasonable sizes for tutorials
- **Test pipeline**: Run full test suite
- **Document changes**: Update README and documentation

### File Size Guidelines ​

| Category | Target Size | Maximum Size |
|----------|-------------|--------------|
| Tutorial files | <10KB | 50KB |
| Standard test | <100KB | 500KB |
| Performance test | <1MB | 5MB |
| Reference regions | <50MB | 100MB |

## Integration with CI/CD ​

### Automated Testing ​

Test data is used in continuous integration:

```yaml
# .github/workflows/test.yml
- name: Test with small dataset
  run: nextflow run main.nf -profile test,docker

- name: Test with medium dataset  
  run: |
    nextflow run main.nf \
      --input test_data/medium_multi_chr.vcf.gz \
      --target_fasta test_data/GRCh38_test_regions.fa \
      -profile docker
```

### Performance Benchmarks ​

Test data enables performance monitoring:

- **Runtime benchmarks**: Track execution time
- **Memory usage**: Monitor resource consumption
- **Success rates**: Track liftover accuracy
- **File sizes**: Monitor output sizes

## Related Documentation ​

- [Parameters Reference](/reference/parameters) - Pipeline parameters
- [Profiles Reference](/reference/profiles) - Execution profiles  
- [Quick Start Tutorial](/tutorials/quick-start) - Using test data
- [Understanding Results](/docs/understanding-results) - Interpreting test results
