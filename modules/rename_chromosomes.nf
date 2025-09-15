/*
========================================================================================
    Chromosome Renaming Process
========================================================================================
    Renames chromosomes using bcftools annotate
========================================================================================
*/

process RENAME_CHROMOSOMES {
    tag "${sample_id}"
    label 'vcf_processing'

    input:
    tuple val(sample_id), path(vcf)
    path chr_mapping

    output:
    tuple val(sample_id), path("${sample_id}.renamed.bcf"), emit: vcf

    when:
    chr_mapping

    script:
    """
    echo "Starting chromosome renaming for sample: ${sample_id}"
    echo "Input VCF: ${vcf}"
    echo "Chromosome mapping file: ${chr_mapping}"
    
    # Check if input file exists
    if [ ! -f "${vcf}" ]; then
        echo "ERROR: Input VCF file not found: ${vcf}" >&2
        exit 1
    fi
    
    # Check if chromosome mapping file exists
    if [ ! -f "${chr_mapping}" ]; then
        echo "ERROR: Chromosome mapping file not found: ${chr_mapping}" >&2
        exit 1
    fi
    
    # Validate chromosome mapping file format
    echo "Validating chromosome mapping file..."
    if ! head -5 ${chr_mapping} | grep -E '^[^\\t]+\\t[^\\t]+\$' > /dev/null; then
        echo "WARNING: Chromosome mapping file may not be tab-separated"
        echo "Expected format: old_chr<TAB>new_chr"
        echo "First 5 lines of mapping file:"
        head -5 ${chr_mapping}
    fi
    
    # Rename chromosomes using bcftools
    echo "Renaming chromosomes..."
    bcftools annotate \\
        --rename-chrs ${chr_mapping} \\
        ${vcf} \\
        -Ob \\
        -o ${sample_id}.renamed.bcf
    
    if [ \$? -ne 0 ]; then
        echo "ERROR: Failed to rename chromosomes for sample ${sample_id}" >&2
        exit 1
    fi
    
    # Verify output file was created
    if [ ! -f "${sample_id}.renamed.bcf" ]; then
        echo "ERROR: Renamed BCF file not created for sample ${sample_id}" >&2
        exit 1
    fi
    
    echo "Chromosome renaming completed successfully for sample: ${sample_id}"
    echo "Output BCF: ${sample_id}.renamed.bcf"
    
    # Show chromosome names before and after
    if command -v bcftools &> /dev/null; then
        echo "Chromosomes in output file:"
        bcftools view -h ${sample_id}.renamed.bcf | grep "^##contig" | head -10
        
        variant_count=\$(bcftools view -H ${sample_id}.renamed.bcf | wc -l)
        echo "Variants after renaming: \$variant_count"
    fi
    """
}
