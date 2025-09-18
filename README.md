# chiptimputation-vcf-liftover

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A522.04.0-23aa62.svg)](https://www.nextflow.io/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed.svg?labelColor=000000)](https://www.docker.com/)
[![Documentation](https://img.shields.io/badge/docs-GitHub%20Pages-blue)](https://afrigen-d.github.io/chiptimputation-vcf-liftover)

A Nextflow pipeline for lifting over VCF files between genome builds using CrossMap.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/AfriGen-D/chiptimputation-vcf-liftover.git
cd chiptimputation-vcf-liftover

# Run with test data
nextflow run main.nf -profile test,singularity

# Run with your data
nextflow run main.nf \
    --input your_file.vcf.gz \
    --target_fasta /path/to/GRCh38.fa \
    -profile singularity
```

## Documentation

📖 **Complete documentation is available at: [https://afrigen-d.github.io/chiptimputation-vcf-liftover](https://afrigen-d.github.io/chiptimputation-vcf-liftover)**

The documentation includes:

- **[Quick Start Tutorial](https://afrigen-d.github.io/chiptimputation-vcf-liftover/tutorials/quick-start)** - Get started in 10 minutes
- **[Complete Reference](https://afrigen-d.github.io/chiptimputation-vcf-liftover/reference/)** - All parameters and options
- **[Step-by-Step Tutorials](https://afrigen-d.github.io/chiptimputation-vcf-liftover/tutorials/)** - Learn with guided examples
- **[Understanding Results](https://afrigen-d.github.io/chiptimputation-vcf-liftover/docs/understanding-results)** - Interpret your output

## Requirements

- **Nextflow** ≥ 22.10.1
- **Singularity** or **Docker**
- **Target reference genome** (e.g., GRCh38)

## Support

- **📚 Documentation**: [https://afrigen-d.github.io/chiptimputation-vcf-liftover](https://afrigen-d.github.io/chiptimputation-vcf-liftover)
- **🐛 Issues**: [GitHub Issues](https://github.com/AfriGen-D/chiptimputation-vcf-liftover/issues)
- **✉️ Contact**: [mamana.mbiyavanga@uct.ac.za](mailto:mamana.mbiyavanga@uct.ac.za)

## License

MIT License - see [LICENSE](LICENSE) file for details.
