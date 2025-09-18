# VCF Liftover Pipeline Documentation

## Overview

A comprehensive Nextflow pipeline for lifting over VCF files between genome builds using Docker containers with Singularity. This pipeline is designed to be modular, scalable, and production-ready for high-throughput genomics workflows.

## Table of Contents

1. [Pipeline Structure](#pipeline-structure)
2. [Key Components](#key-components)
3. [Container Strategy](#container-strategy)
4. [Configuration Files](#configuration-files)
5. [Modular Processes](#modular-processes)
6. [Workflow Logic](#workflow-logic)
7. [Input Format](#input-format)
8. [Usage Examples](#usage-examples)
9. [Key Improvements](#key-improvements)
10. [Container Requirements](#container-requirements)
11. [Installation and Setup](#installation-and-setup)
12. [Troubleshooting](#troubleshooting)

## Pipeline Structure

```
chiptimputation-liftover/
├── main.nf                    # Main workflow entry point
├── nextflow.config           # Main configuration file
├── conf/                     # Environment-specific configurations
│   ├── base.config          # Base resource requirements
│   ├── singularity.config   # Singularity-specific settings
│   ├── slurm.config         # SLURM cluster configuration
│   └── test.config          # Test data configuration
├── modules/                  # Modular process definitions
│   ├── input_check.nf       # Input validation
│   ├── crossmap.nf          # CrossMap liftover process
│   ├── sort_vcf.nf          # VCF sorting with bcftools
│   ├── rename_chromosomes.nf # Chromosome renaming
│   ├── fix_contig.nf        # Fix contig headers
│   ├── index_vcf.nf         # VCF indexing with tabix
│   ├── validate_vcf.nf      # Output validation
│   └── liftover_stats.nf    # Generate statistics
├── workflows/               # Sub-workflows
│   └── liftover.nf          # Main liftover workflow
├── bin/                     # Helper scripts
│   ├── check_vcf.py         # VCF validation script
│   └── generate_stats.py    # Statistics generation
├── docs/                    # Documentation
│   ├── README.md            # Main documentation
│   ├── usage.md             # Usage examples
│   └── parameters.md        # Parameter descriptions
├── test_data/               # Sample test data
│   ├── sample.vcf.gz        # Test VCF file
│   ├── hg19ToHg38.chain.gz  # Test chain file
│   └── samples.csv          # Test input CSV
└── assets/                  # Static assets
    ├── chr_mapping.txt      # Chromosome mapping files
    └── multiqc_config.yaml  # MultiQC configuration
```

## Key Components

### 1. Main Workflow (`main.nf`)

**Features:**
- DSL2 syntax with modern Nextflow features
- Parameter validation with helpful error messages
- Help documentation built into the script
- Workflow completion reporting with execution statistics
- Modular imports from modules and workflows directories

**Key Parameters:**
- `--input`: CSV file with sample_id,vcf_path columns
- `--chain_file`: Chain file for liftover (e.g., hg19ToHg38.over.chain.gz)
- `--target_fasta`: Target reference genome FASTA file
- `--source_build`: Source genome build [default: hg19]
- `--target_build`: Target genome build [default: hg38]
- `--chr_mapping`: Chromosome mapping file for renaming
- `--outdir`: Output directory [default: ./results]
- `--split_by_chr`: Split processing by chromosome [default: false]
- `--validate_output`: Validate output VCF files [default: true]

### 2. Workflow Steps

1. **Input Validation**: Check file existence and format
2. **CrossMap Liftover**: Convert coordinates between genome builds
3. **VCF Sorting**: Sort VCF files using bcftools
4. **Chromosome Renaming**: Optional chromosome name standardization
5. **Contig Header Fixing**: Update VCF headers with target reference
6. **VCF Indexing**: Create tabix indices for final files
7. **Validation**: Verify output file integrity
8. **Statistics Generation**: Create liftover summary reports

## Container Strategy

The pipeline uses Docker containers through Singularity for reproducibility and portability.

### Primary Containers (mamana namespace)
```groovy
process {
    withLabel: 'crossmap' {
        container = 'mamana/crossmap:latest'
        memory = { 8.GB * task.attempt }
        cpus = 2
        time = { 4.h * task.attempt }
    }
    
    withLabel: 'vcf_processing' {
        container = 'mamana/vcf-processing:latest'
        memory = { 16.GB * task.attempt }
        cpus = 4
        time = { 2.h * task.attempt }
    }
    
    withLabel: 'imputation' {
        container = 'mamana/imputation:latest'
        memory = { 12.GB * task.attempt }
        cpus = 2
        time = { 3.h * task.attempt }
    }
}
```

### Fallback Containers (biocontainers)
```groovy
// If mamana containers are unavailable
withLabel: 'crossmap' {
    container = 'quay.io/biocontainers/crossmap:0.6.4--pyhdfd78af_0'
}

withLabel: 'bcftools' {
    container = 'quay.io/biocontainers/bcftools:1.17--haef29d1_0'
}
```

## Configuration Files

### Main Configuration (`nextflow.config`)

```groovy
params {
    // Required parameters
    input = null
    chain_file = null
    target_fasta = null
    
    // Optional parameters
    source_build = 'hg19'
    target_build = 'hg38'
    chr_mapping = null
    outdir = './results'
    split_by_chr = false
    validate_output = true
    
    // Resource limits
    max_memory = '128.GB'
    max_cpus = 16
    max_time = '240.h'
    
    // Container settings
    singularity_cache_dir = "${HOME}/.singularity"
    scratch_dir = '/tmp'
}

profiles {
    singularity {
        singularity.enabled = true
        singularity.autoMounts = true
        singularity.cacheDir = "${params.singularity_cache_dir}"
        docker.enabled = false
        includeConfig 'conf/singularity.config'
    }
    
    slurm {
        process.executor = 'slurm'
        process.queue = 'main'
        includeConfig 'conf/slurm.config'
    }
    
    test {
        includeConfig 'conf/test.config'
    }
    
    docker {
        docker.enabled = true
        singularity.enabled = false
        includeConfig 'conf/docker.config'
    }
}

manifest {
    name = 'VCF-Liftover-Pipeline'
    author = 'Mamana Mbiyavanga'
    description = 'Nextflow pipeline for VCF liftover between genome builds'
    version = '1.0.0'
    nextflowVersion = '>=22.04.0'
    homePage = 'https://github.com/username/vcf-liftover-pipeline'
}
```

### Singularity Configuration (`conf/singularity.config`)

```groovy
singularity {
    enabled = true
    autoMounts = true
    cacheDir = "${params.singularity_cache_dir}"
    runOptions = "--bind ${params.scratch_dir}"
}

process {
    withLabel: 'crossmap' {
        container = 'docker://mamana/crossmap:latest'
        memory = { 8.GB * task.attempt }
        cpus = 2
        time = { 4.h * task.attempt }
        errorStrategy = { task.exitStatus in [143,137,104,134,139] ? 'retry' : 'finish' }
        maxRetries = 3
    }
    
    withLabel: 'bcftools' {
        container = 'docker://mamana/vcf-processing:latest'
        memory = { 16.GB * task.attempt }
        cpus = 4
        time = { 2.h * task.attempt }
        errorStrategy = { task.exitStatus in [143,137,104,134,139] ? 'retry' : 'finish' }
        maxRetries = 3
    }
    
    withLabel: 'general' {
        container = 'docker://mamana/imputation:latest'
        memory = { 4.GB * task.attempt }
        cpus = 1
        time = { 1.h * task.attempt }
        errorStrategy = { task.exitStatus in [143,137,104,134,139] ? 'retry' : 'finish' }
        maxRetries = 2
    }
}
```

### SLURM Configuration (`conf/slurm.config`)

```groovy
process {
    executor = 'slurm'
    queue = 'main'
    clusterOptions = '--mail-user=your.email@domain.com --mail-type=END,FAIL'
    
    withLabel: 'crossmap' {
        queue = 'main'
        cpus = 2
        memory = '8 GB'
        time = '4h'
    }
    
    withLabel: 'bcftools' {
        queue = 'main'
        cpus = 4
        memory = '16 GB'
        time = '2h'
    }
    
    withLabel: 'large_mem' {
        queue = 'highmem'
        cpus = 8
        memory = '64 GB'
        time = '8h'
    }
}

executor {
    queueSize = 50
    submitRateLimit = '10 sec'
}
```

## Modular Processes

### CrossMap Process (`modules/crossmap.nf`)

```groovy
process CROSSMAP_VCF {
    tag "${sample_id}"
    label 'crossmap'

    publishDir "${params.outdir}/crossmap", mode: 'copy'

    input:
    tuple val(sample_id), path(vcf), path(chain_file), path(target_fasta)

    output:
    tuple val(sample_id), path("${sample_id}.crossmap.vcf"), emit: vcf
    path("${sample_id}.crossmap.log"), emit: log
    path("${sample_id}.crossmap.unmap"), emit: unmap, optional: true

    script:
    """
    CrossMap.py vcf \\
        ${chain_file} \\
        ${vcf} \\
        ${target_fasta} \\
        ${sample_id}.crossmap.vcf \\
        2> ${sample_id}.crossmap.log

    # Check if unmapped file was created
    if [ -f "${sample_id}.crossmap.vcf.unmap" ]; then
        mv "${sample_id}.crossmap.vcf.unmap" "${sample_id}.crossmap.unmap"
    fi
    """
}
```

### VCF Sorting Process (`modules/sort_vcf.nf`)

```groovy
process SORT_VCF {
    tag "${sample_id}"
    label 'bcftools'

    input:
    tuple val(sample_id), path(vcf)

    output:
    tuple val(sample_id), path("${sample_id}.sorted.bcf"), emit: vcf

    script:
    """
    # Convert to BCF and sort
    bcftools view ${vcf} -Ob -o temp.bcf
    bcftools sort temp.bcf -T . -Ob -o ${sample_id}.sorted.bcf

    # Clean up temporary file
    rm temp.bcf
    """
}
```

### Chromosome Renaming Process (`modules/rename_chromosomes.nf`)

```groovy
process RENAME_CHROMOSOMES {
    tag "${sample_id}"
    label 'bcftools'

    input:
    tuple val(sample_id), path(vcf)
    path chr_mapping

    output:
    tuple val(sample_id), path("${sample_id}.renamed.bcf"), emit: vcf

    when:
    chr_mapping

    script:
    """
    bcftools annotate \\
        --rename-chrs ${chr_mapping} \\
        ${vcf} \\
        -Ob \\
        -o ${sample_id}.renamed.bcf
    """
}
```

### Contig Header Fix Process (`modules/fix_contig.nf`)

```groovy
process FIX_CONTIG_HEADER {
    tag "${sample_id}"
    label 'bcftools'

    publishDir "${params.outdir}/final", mode: 'copy'

    input:
    tuple val(sample_id), path(vcf)
    path target_fasta

    output:
    tuple val(sample_id), path("${sample_id}.${params.target_build}.vcf.gz"), emit: vcf

    script:
    """
    # Index reference if not already indexed
    if [ ! -f "${target_fasta}.fai" ]; then
        samtools faidx ${target_fasta}
    fi

    # Convert to VCF, reheader, and compress
    bcftools view ${vcf} -o temp.vcf
    bcftools reheader -f ${target_fasta}.fai temp.vcf -o reheadered.vcf
    bcftools view reheadered.vcf -Oz -o ${sample_id}.${params.target_build}.vcf.gz

    # Clean up
    rm temp.vcf reheadered.vcf
    """
}
```

### VCF Indexing Process (`modules/index_vcf.nf`)

```groovy
process INDEX_VCF {
    tag "${sample_id}"
    label 'bcftools'

    publishDir "${params.outdir}/final", mode: 'copy'

    input:
    tuple val(sample_id), path(vcf)

    output:
    tuple val(sample_id), path(vcf), path("${vcf}.tbi"), emit: vcf_with_index
    path("${vcf}.tbi"), emit: index

    script:
    """
    tabix -f ${vcf}
    """
}
```

### Input Validation Process (`modules/input_check.nf`)

```groovy
process INPUT_CHECK {
    tag "input_validation"
    label 'general'

    input:
    path input_csv

    output:
    path "validated_samples.csv", emit: csv

    script:
    """
    #!/usr/bin/env python3

    import csv
    import sys
    import os

    def validate_input(input_file):
        validated_samples = []

        with open(input_file, 'r') as f:
            reader = csv.DictReader(f)

            # Check required columns
            required_cols = ['sample_id', 'vcf_path']
            if not all(col in reader.fieldnames for col in required_cols):
                sys.exit(f"ERROR: Input CSV must contain columns: {required_cols}")

            for row in reader:
                sample_id = row['sample_id']
                vcf_path = row['vcf_path']

                # Check if VCF file exists
                if not os.path.exists(vcf_path):
                    sys.exit(f"ERROR: VCF file not found: {vcf_path}")

                # Check file extension
                if not vcf_path.endswith(('.vcf', '.vcf.gz', '.bcf')):
                    sys.exit(f"ERROR: Invalid VCF file format: {vcf_path}")

                validated_samples.append({'sample_id': sample_id, 'vcf_path': vcf_path})

        # Write validated samples
        with open('validated_samples.csv', 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=['sample_id', 'vcf_path'])
            writer.writeheader()
            writer.writerows(validated_samples)

        print(f"Validated {len(validated_samples)} samples")

    if __name__ == "__main__":
        validate_input("${input_csv}")
    """
}
```

## Workflow Logic

### Main Liftover Workflow (`workflows/liftover.nf`)

```groovy
include { CROSSMAP_VCF } from '../modules/crossmap'
include { SORT_VCF } from '../modules/sort_vcf'
include { RENAME_CHROMOSOMES } from '../modules/rename_chromosomes'
include { FIX_CONTIG_HEADER } from '../modules/fix_contig'
include { INDEX_VCF } from '../modules/index_vcf'
include { VALIDATE_VCF } from '../modules/validate_vcf'
include { LIFTOVER_STATS } from '../modules/liftover_stats'

workflow LIFTOVER_WORKFLOW {
    take:
    vcf_files     // Channel: [sample_id, vcf_path]
    chain_file    // Path: chain file
    target_fasta  // Path: target reference
    chr_mapping   // Path: chromosome mapping (optional)

    main:
    // Combine inputs for CrossMap
    crossmap_input = vcf_files.map { sample_id, vcf ->
        [sample_id, vcf, chain_file, target_fasta]
    }

    // Run liftover
    CROSSMAP_VCF(crossmap_input)

    // Sort VCF files
    SORT_VCF(CROSSMAP_VCF.out.vcf)

    // Rename chromosomes if mapping provided
    if (chr_mapping && !chr_mapping.isEmpty()) {
        RENAME_CHROMOSOMES(SORT_VCF.out.vcf, chr_mapping)
        sorted_vcf = RENAME_CHROMOSOMES.out.vcf
    } else {
        sorted_vcf = SORT_VCF.out.vcf
    }

    // Fix contig headers
    FIX_CONTIG_HEADER(sorted_vcf, target_fasta)

    // Index final VCF files
    INDEX_VCF(FIX_CONTIG_HEADER.out.vcf)

    // Validate output if requested
    if (params.validate_output) {
        VALIDATE_VCF(INDEX_VCF.out.vcf_with_index)
    }

    // Generate statistics
    LIFTOVER_STATS(
        CROSSMAP_VCF.out.log.collect(),
        INDEX_VCF.out.vcf_with_index.collect()
    )

    emit:
    vcf = INDEX_VCF.out.vcf_with_index
    stats = LIFTOVER_STATS.out.report
    logs = CROSSMAP_VCF.out.log
}
```

## Input Format

### Sample Input CSV (`samples.csv`)

```csv
sample_id,vcf_path
sample1,/path/to/sample1.vcf.gz
sample2,/path/to/sample2.vcf.gz
sample3,/path/to/sample3.bcf
```

**Requirements:**
- CSV file with header row
- `sample_id`: Unique identifier for each sample
- `vcf_path`: Full path to VCF/BCF file
- Files can be compressed (.gz) or uncompressed
- Supported formats: .vcf, .vcf.gz, .bcf

### Chromosome Mapping File (`chr_mapping.txt`)

```
1	chr1
2	chr2
3	chr3
...
X	chrX
Y	chrY
MT	chrM
```

**Format:**
- Tab-separated file
- First column: source chromosome name
- Second column: target chromosome name
- Used for standardizing chromosome naming conventions

## Usage Examples

### Basic Usage

```bash
# Simple liftover from hg19 to hg38
nextflow run main.nf \
    -profile singularity \
    --input samples.csv \
    --chain_file hg19ToHg38.over.chain.gz \
    --target_fasta hg38.fa \
    --outdir results/
```

### Advanced Usage with SLURM

```bash
# Run on SLURM cluster with chromosome renaming
nextflow run main.nf \
    -profile singularity,slurm \
    --input samples.csv \
    --chain_file hg19ToHg38.over.chain.gz \
    --target_fasta hg38.fa \
    --chr_mapping chr_mapping.txt \
    --source_build hg19 \
    --target_build hg38 \
    --outdir results/ \
    --validate_output true
```

### Test Run

```bash
# Run with test data
nextflow run main.nf \
    -profile test,singularity \
    --outdir test_results/
```

### Resume Failed Run

```bash
# Resume from last checkpoint
nextflow run main.nf \
    -profile singularity \
    --input samples.csv \
    --chain_file hg19ToHg38.over.chain.gz \
    --target_fasta hg38.fa \
    --outdir results/ \
    -resume
```

### Custom Resource Allocation

```bash
# Override default resource limits
nextflow run main.nf \
    -profile singularity \
    --input samples.csv \
    --chain_file hg19ToHg38.over.chain.gz \
    --target_fasta hg38.fa \
    --max_memory 256.GB \
    --max_cpus 32 \
    --max_time 480.h \
    --outdir results/
```

## Key Improvements

### Over Existing Pipeline

1. **Modularity**: Separate process files for better maintainability and reusability
2. **Error Handling**: Comprehensive error messages, validation, and retry strategies
3. **Flexibility**: Support for optional chromosome renaming and validation steps
4. **Documentation**: Built-in help system and comprehensive parameter descriptions
5. **Testing**: Integrated test profile with sample data for validation
6. **Reporting**: Automated statistics generation and liftover summary reports
7. **Container Management**: Proper Singularity configuration with fallback options
8. **Resource Management**: Dynamic resource allocation with automatic retry on failure
9. **Input Validation**: Robust checking of input files and parameters
10. **Output Organization**: Structured output directories with clear naming conventions

### Technical Enhancements

- **DSL2 Syntax**: Modern Nextflow features for better workflow composition
- **Channel Operations**: Efficient data flow and parallel processing
- **Process Labels**: Consistent resource allocation and container management
- **Conditional Logic**: Smart workflow branching based on parameters
- **Error Recovery**: Automatic retry mechanisms for transient failures
- **Logging**: Comprehensive logging and execution tracking

## Container Requirements

### Primary Tools Required

1. **CrossMap**: Coordinate liftover between genome builds
   - Python-based tool for genomic coordinate conversion
   - Requires chain files for build-to-build mapping
   - Handles VCF, BED, and other genomic formats

2. **bcftools/samtools**: VCF manipulation and processing
   - VCF/BCF format conversion and manipulation
   - Sorting, indexing, and header modification
   - Reference genome indexing

3. **tabix**: VCF file indexing
   - Creates .tbi index files for compressed VCF files
   - Enables rapid random access to genomic regions

4. **Python**: Validation and statistics scripts
   - Input validation and error checking
   - Statistics generation and reporting
   - Custom processing scripts

### Container Specifications

#### mamana/crossmap:latest
```dockerfile
# Expected contents:
- CrossMap (latest version)
- Python 3.x
- Required Python libraries (pysam, etc.)
- Basic Unix utilities
```

#### mamana/vcf-processing:latest
```dockerfile
# Expected contents:
- bcftools (v1.15+)
- samtools (v1.15+)
- tabix/htslib
- Basic Unix utilities
```

#### mamana/imputation:latest
```dockerfile
# Expected contents:
- Python 3.x with scientific libraries
- Basic bioinformatics tools
- Text processing utilities
```

## Installation and Setup

### Prerequisites

1. **Nextflow**: Version 22.04.0 or later
2. **Singularity**: Version 3.5.0 or later (for container execution)
3. **Java**: Version 11 or later (for Nextflow)

### Installation Steps

```bash
# 1. Install Nextflow
curl -s https://get.nextflow.io | bash
sudo mv nextflow /usr/local/bin/

# 2. Install Singularity (Ubuntu/Debian)
sudo apt update
sudo apt install -y singularity-container

# 3. Clone the pipeline
git clone https://github.com/username/vcf-liftover-pipeline.git
cd vcf-liftover-pipeline

# 4. Test installation
nextflow run main.nf --help
```

### Configuration Setup

```bash
# 1. Create Singularity cache directory
mkdir -p ~/.singularity

# 2. Set environment variables (optional)
export NXF_SINGULARITY_CACHEDIR="$HOME/.singularity"
export NXF_TEMP="/tmp"

# 3. Configure cluster settings (if using SLURM)
cp conf/slurm.config.template conf/slurm.config
# Edit conf/slurm.config with your cluster settings
```

### Required Reference Files

1. **Chain Files**: Download from UCSC Genome Browser
   ```bash
   # Example: hg19 to hg38 liftover
   wget http://hgdownload.cse.ucsc.edu/goldenpath/hg19/liftOver/hg19ToHg38.over.chain.gz
   ```

2. **Reference Genomes**: Target build FASTA files
   ```bash
   # Example: hg38 reference
   wget http://hgdownload.cse.ucsc.edu/goldenpath/hg38/bigZips/hg38.fa.gz
   gunzip hg38.fa.gz
   ```

3. **Chromosome Mapping**: Create if needed for naming standardization

## Troubleshooting

### Common Issues and Solutions

#### 1. Container Pull Failures

**Problem**: Singularity cannot pull Docker containers
```
ERROR: Failed to pull container: mamana/crossmap:latest
```

**Solutions**:
```bash
# Check Singularity installation
singularity --version

# Manually pull container
singularity pull docker://mamana/crossmap:latest

# Use fallback containers
# Edit nextflow.config to use biocontainers
container = 'quay.io/biocontainers/crossmap:0.6.4--pyhdfd78af_0'
```

#### 2. Memory Issues

**Problem**: Process killed due to memory limits
```
ERROR: Process exceeded memory limit
```

**Solutions**:
```bash
# Increase memory limits in config
--max_memory 256.GB

# Use memory-efficient profile
-profile slurm,large_mem

# Process smaller batches
--split_by_chr true
```

#### 3. Chain File Issues

**Problem**: CrossMap fails with chain file errors
```
ERROR: Invalid chain file format
```

**Solutions**:
```bash
# Verify chain file format
file hg19ToHg38.over.chain.gz

# Re-download chain file
wget http://hgdownload.cse.ucsc.edu/goldenpath/hg19/liftOver/hg19ToHg38.over.chain.gz

# Check file integrity
gunzip -t hg19ToHg38.over.chain.gz
```

#### 4. VCF Format Issues

**Problem**: Input VCF files are malformed
```
ERROR: Invalid VCF format
```

**Solutions**:
```bash
# Validate VCF files
bcftools view -h input.vcf.gz

# Fix VCF format issues
bcftools norm -f reference.fa input.vcf.gz -o fixed.vcf.gz

# Check for required fields
bcftools query -l input.vcf.gz
```

#### 5. Permission Issues

**Problem**: Cannot write to output directory
```
ERROR: Permission denied
```

**Solutions**:
```bash
# Check directory permissions
ls -la /path/to/outdir

# Create output directory with proper permissions
mkdir -p results && chmod 755 results

# Use different output location
--outdir $HOME/vcf_liftover_results
```

#### 6. SLURM Job Failures

**Problem**: Jobs fail on SLURM cluster
```
ERROR: Job submission failed
```

**Solutions**:
```bash
# Check SLURM configuration
sinfo
squeue -u $USER

# Verify queue names in config
# Edit conf/slurm.config
queue = 'your_queue_name'

# Test with smaller resources
cpus = 1
memory = '4 GB'
time = '1h'
```

### Performance Optimization

#### 1. Parallel Processing

```bash
# Enable chromosome-based splitting
--split_by_chr true

# Increase parallel job limit
executor.queueSize = 100
```

#### 2. Resource Tuning

```bash
# Optimize for your cluster
process {
    withLabel: 'crossmap' {
        cpus = 4
        memory = '16 GB'
        time = '6h'
    }
}
```

#### 3. Storage Optimization

```bash
# Use fast local storage for work directory
export NXF_WORK="/fast/local/storage"

# Clean up work directory after successful completion
nextflow run main.nf ... && rm -rf work/
```

### Debugging Tips

#### 1. Enable Debug Mode

```bash
# Run with debug output
nextflow run main.nf -profile singularity --input samples.csv ... -with-trace -with-report -with-timeline
```

#### 2. Check Process Logs

```bash
# Find failed process logs
find work/ -name ".command.log" -exec grep -l "ERROR" {} \;

# View specific process output
cat work/xx/xxxxxx/.command.out
cat work/xx/xxxxxx/.command.err
```

#### 3. Test Individual Processes

```bash
# Test CrossMap manually
singularity exec docker://mamana/crossmap:latest \
    CrossMap.py vcf chain.gz input.vcf ref.fa output.vcf
```

### Getting Help

1. **Check Documentation**: Review parameter descriptions and examples
2. **Nextflow Community**: https://nextflow.slack.com
3. **GitHub Issues**: Report bugs and feature requests
4. **CrossMap Documentation**: https://crossmap.readthedocs.io/

### Version Compatibility

| Component | Minimum Version | Recommended |
|-----------|----------------|-------------|
| Nextflow | 22.04.0 | 23.04.0+ |
| Singularity | 3.5.0 | 3.8.0+ |
| CrossMap | 0.6.0 | 0.6.4+ |
| bcftools | 1.15 | 1.17+ |
| samtools | 1.15 | 1.17+ |

---

## Summary

This VCF Liftover Pipeline provides a robust, scalable solution for converting genomic coordinates between different genome builds. The modular design, comprehensive error handling, and flexible configuration options make it suitable for both small-scale research projects and large-scale production environments.

Key benefits:
- **Reproducible**: Containerized execution ensures consistent results
- **Scalable**: Supports parallel processing and cluster execution
- **Flexible**: Configurable for different genome builds and naming conventions
- **Robust**: Comprehensive error handling and validation
- **Well-documented**: Extensive documentation and examples

For questions or contributions, please refer to the project repository and documentation.
```
```
