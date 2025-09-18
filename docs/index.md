---
layout: home

hero:
  name: "chiptimputation-vcf-liftover"
  text: "VCF Genome Build Liftover Pipeline"
  tagline: "A robust Nextflow pipeline for converting VCF files between genome builds using CrossMap"
  actions:
    - theme: brand
      text: Get Started
      link: /guide/getting-started
    - theme: alt
      text: View on GitHub
      link: https://github.com/AfriGen-D/chiptimputation-vcf-liftover

features:
  - icon: 🔄
    title: Genome Build Conversion
    details: Automatically converts genomic coordinates between reference builds (hg19 to hg38) with high accuracy.
  - icon: 🧬
    title: CrossMap Integration
    details: Uses CrossMap for precise coordinate conversion with comprehensive chain file support.
  - icon: 📊
    title: Multi-File Processing
    details: Process multiple VCF files simultaneously with automatic batch handling and CSV input support.
  - icon: 🧪
    title: Quality Validation
    details: Built-in validation with detailed statistics, success rates, and comprehensive error reporting.
  - icon: ⚡
    title: Fast & Scalable
    details: Parallel processing with Nextflow for efficient analysis of large genomic datasets.
  - icon: 📋
    title: Comprehensive QC
    details: Detailed reports and quality metrics to validate your liftover results.
---

## Quick Start ​

Get started with chiptimputation-vcf-liftover in just a few commands:

```bash
# Clone the repository
git clone https://github.com/AfriGen-D/chiptimputation-vcf-liftover.git
cd chiptimputation-liftover

# Run with your data
nextflow run main.nf \
  --input your_file.vcf.gz \
  --target_fasta /path/to/GRCh38.fa \
  --outdir results \
  -profile singularity
```

## What chiptimputation-vcf-liftover Does ​

This Nextflow pipeline provides:

- **Coordinate Conversion**: Lifts over genomic coordinates from hg19 to hg38 using CrossMap
- **Smart Processing**: Automatically handles VCF sorting, indexing, and chromosome renaming
- **Quality Assessment**: Comprehensive statistics and validation reports
- **Multi-File Support**: Process multiple VCF files simultaneously with CSV batch input

## Documentation ​

- [Tutorials](/tutorials/) - Step-by-step learning exercises
- [Documentation](/docs/) - Comprehensive reference material
- [Reference](/reference/) - Complete parameter and configuration reference
- [Examples](/examples/) - Ready-to-use configurations

## Requirements ​

- Nextflow ≥ 22.10.1
- Docker, Singularity, or Conda
- Target VCF files (bgzipped and indexed)
- Target reference genome FASTA file
- CrossMap chain file (automatically downloaded)

## Support ​

- [GitHub Issues](https://github.com/AfriGen-D/chiptimputation-vcf-liftover/issues)
- [Helpdesk](https://afrigen-d.org)
- [AfriGen-D](https://afrigen-d.org)