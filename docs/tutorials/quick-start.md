# Quick Start Tutorial (10 minutes) ​

**Objective:** Run your first VCF liftover and understand the basic workflow

**Time:** ~10 minutes  
**Difficulty:** 🟢 Beginner  
**Prerequisites:** Nextflow installed, Docker or Singularity available

## What You'll Learn ​

By the end of this tutorial, you'll be able to:
- Run chiptimptation-vcf-liftover with test data
- Understand basic command structure
- Interpret liftover results
- Identify successful coordinate conversion

## Step 1: Setup ​

### Clone the Repository ​

```bash
# Clone the repository
git clone https://github.com/mamanambiya/chiptimptation-liftover.git
cd chiptimptation-liftover

# Verify you're in the right directory
ls -la
```

**Expected output:** You should see files like `main.nf`, `nextflow.config`, and directories like `modules/`, `test_data/`.

### Verify Prerequisites ​

```bash
# Check Nextflow version
nextflow -version

# Check container engine
singularity --version
# OR
docker --version
```

**Requirements:**
- Nextflow ≥ 22.10.1
- Singularity or Docker available

## Step 2: Generate Test Data ​

```bash
# Generate comprehensive test data
python3 bin/generate_test_data.py

# Generate test reference genome
python3 bin/generate_test_reference.py \
  --regions chr21:1-10000000,chr22:1-20000000 \
  --output test_data/GRCh38_test_regions.fa
```

**What this does:**
- Creates realistic VCF test files with various scenarios
- Generates a small reference genome for fast testing
- Sets up all necessary input files

## Step 3: Run Your First Liftover ​

```bash
# Run the pipeline with test data
nextflow run main.nf -profile test,singularity \
  --input test_data/small_chr22.vcf.gz \
  --target_fasta test_data/GRCh38_test_regions.fa
```

**What happens:**
1. Nextflow downloads required containers
2. Pipeline validates input files
3. CrossMap performs coordinate conversion
4. Output files are sorted and indexed
5. Statistics and reports are generated

**Expected runtime:** 2-5 minutes

## Step 4: Monitor Progress ​

While the pipeline runs, you'll see output like:

```
N E X T F L O W  ~  version 22.10.1
Launching `main.nf` [peaceful_pasteur] - revision: abc123

executor >  local (5)
[12/34abcd] process > CROSSMAP_LIFTOVER (small_chr22) [100%] 1 of 1 ✓
[56/78efgh] process > SORT_VCF (small_chr22)          [100%] 1 of 1 ✓
[90/12ijkl] process > INDEX_VCF (small_chr22)         [100%] 1 of 1 ✓
[34/56mnop] process > RENAME_CHROMOSOMES (small_chr22) [100%] 1 of 1 ✓
[78/90qrst] process > GENERATE_STATS (small_chr22)    [100%] 1 of 1 ✓

Completed at: 2025-01-15T10:30:45.123Z
Duration    : 3m 42s
CPU hours   : 0.2
Succeeded   : 5
```

## Step 5: Examine Results ​

### Check Output Directory ​

```bash
# List output files
ls -la results/

# Check liftover statistics
cat results/reports/liftover_statistics.txt
```

**Expected output structure:**
```
results/
├── vcf/
│   ├── small_chr22_lifted.vcf.gz
│   └── small_chr22_lifted.vcf.gz.tbi
├── reports/
│   ├── liftover_statistics.txt
│   ├── liftover_report.html
│   └── pipeline_info/
└── logs/
```

### Understand the Statistics ​

```bash
# View liftover success metrics
cat results/reports/liftover_statistics.txt
```

**Example output:**
```
=== Liftover Statistics ===
Input variants: 5
Successfully lifted: 4
Failed to lift: 1
Success rate: 80.0%

=== Chromosome Distribution ===
chr22: 5 variants

=== Validation Results ===
Output VCF is valid: ✓
Index created successfully: ✓
```

### Inspect the Lifted VCF ​

```bash
# View first few variants
zcat results/vcf/small_chr22_lifted.vcf.gz | head -20

# Count variants in output
zcat results/vcf/small_chr22_lifted.vcf.gz | grep -v "^#" | wc -l
```

## Step 6: Understand What Happened ​

### Coordinate Conversion ​

The pipeline converted coordinates from hg19 to hg38:

**Before (hg19):**
```
chr22   16050075    .   A   G   .   PASS    .
```

**After (hg38):**
```
chr22   15528088    .   A   G   .   PASS    .
```

### Quality Control ​

The pipeline automatically:
- ✅ Validated input VCF format
- ✅ Performed coordinate liftover
- ✅ Sorted output by genomic position
- ✅ Created index files for fast access
- ✅ Generated comprehensive statistics

## Step 7: View the HTML Report ​

```bash
# Open the interactive report (if you have a browser)
open results/reports/liftover_report.html
# OR copy to your local machine to view
```

The HTML report includes:
- Interactive liftover statistics
- Success rate visualizations
- Quality control metrics
- Detailed process information

## Troubleshooting ​

### Common Issues ​

#### Pipeline Fails to Start ​
```bash
# Check Nextflow installation
nextflow info

# Verify container engine
singularity --version
docker --version
```

#### Container Download Issues ​
```bash
# Pre-pull containers manually
singularity pull docker://quay.io/biocontainers/crossmap:0.6.4--py39h5371cbf_0
```

#### Permission Errors ​
```bash
# Fix permissions on test data
chmod -R 755 test_data/
```

#### Low Success Rate ​
This is normal for test data! Real genomic data typically achieves >95% success rates.

## What You've Accomplished ​

✅ **Successfully ran chiptimptation-vcf-liftover**  
✅ **Converted coordinates from hg19 to hg38**  
✅ **Generated quality control reports**  
✅ **Understood basic pipeline workflow**  
✅ **Interpreted liftover statistics**  

## Next Steps ​

Now that you've completed your first liftover:

1. **Try with your own data:** Replace test data with your VCF files
2. **Learn batch processing:** Try the [Multi-File Tutorial](/tutorials/multi-file-tutorial)
3. **Optimize parameters:** Explore the [Method Selection Tutorial](/tutorials/method-selection)
4. **Understand results:** Read the [Understanding Results](/docs/understanding-results) documentation

## Quick Reference ​

### Basic Command ​
```bash
nextflow run main.nf -profile singularity \
  --input your_file.vcf.gz \
  --target_fasta /path/to/GRCh38.fa
```

### Key Parameters ​
- `--input`: Your VCF file or CSV batch file
- `--target_fasta`: Target reference genome (GRCh38)
- `--outdir`: Output directory (default: `results`)

### Success Indicators ​
- Pipeline completes without errors
- Output VCF file is created and indexed
- Success rate > 80% (varies by data quality)
- HTML report generates successfully

**Congratulations!** You've successfully completed your first VCF liftover. Ready for more advanced tutorials?
