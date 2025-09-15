#!/usr/bin/env nextflow

/*
========================================================================================
    chiptimptation-vcf-liftover
========================================================================================
    Nextflow pipeline for lifting over VCF files between genome builds
    Author: Mamana Mbiyavanga
    Version: 1.0.0
========================================================================================
*/

nextflow.enable.dsl = 2

/*
========================================================================================
    PARAMETER VALIDATION
========================================================================================
*/

def helpMessage() {
    log.info"""
    =========================================
     chiptimptation-vcf-liftover v${workflow.manifest.version}
    =========================================
    
    Usage:
    nextflow run main.nf [options]
    
    Required parameters:
      --input                 Input can be:
                              • Single VCF file: sample.vcf.gz
                              • Multiple VCF files: "*.vcf.gz" or file1.vcf.gz,file2.vcf.gz
                              • CSV file: samples.csv (with sample_id,vcf_path columns)
      --chain_file           Chain file for liftover (e.g., hg19ToHg38.over.chain.gz)
      --target_fasta         Target reference genome FASTA file
    
    Optional parameters:
      --source_build         Source genome build [default: hg19]
      --target_build         Target genome build [default: hg38]
      --chr_mapping          Chromosome mapping file for renaming
      --outdir               Output directory [default: ./results]
      --split_by_chr         Split processing by chromosome [default: false]
      --validate_output      Validate output VCF files [default: true]
    
    Resource parameters:
      --max_memory           Maximum memory [default: 128.GB]
      --max_cpus             Maximum CPUs [default: 16]
      --max_time             Maximum time [default: 240.h]
    
    Container parameters:
      --singularity_cache_dir Singularity cache directory [default: ~/.singularity]
      --scratch_dir          Scratch directory [default: /tmp]
    
    Profiles:
      -profile singularity   Use Singularity containers
      -profile slurm         Use SLURM executor
      -profile test          Use test data
      -profile docker        Use Docker containers
    
    Examples:
      # Single VCF file
      nextflow run main.nf -profile singularity \\
        --input sample.vcf.gz \\
        --chain_file chains/hg19ToHg38.over.chain.gz \\
        --target_fasta hg38.fa

      # Multiple VCF files (wildcard)
      nextflow run main.nf -profile singularity \\
        --input "*.vcf.gz" \\
        --chain_file chains/hg19ToHg38.over.chain.gz \\
        --target_fasta hg38.fa

      # Multiple VCF files (comma-separated)
      nextflow run main.nf -profile singularity \\
        --input "file1.vcf.gz,file2.vcf.gz,file3.vcf.gz" \\
        --chain_file chains/hg19ToHg38.over.chain.gz \\
        --target_fasta hg38.fa

      # CSV file with chromosome renaming
      nextflow run main.nf -profile singularity,slurm \\
        --input samples.csv \\
        --chain_file chains/hg19ToHg38.over.chain.gz \\
        --target_fasta hg38.fa \\
        --chr_mapping chr_mapping.txt

      # Test run
      nextflow run main.nf -profile test,singularity
    """.stripIndent()
}

// Function to check if input is VCF file
def isVcfFile(input) {
    return input.toString().toLowerCase().endsWith('.vcf') ||
           input.toString().toLowerCase().endsWith('.vcf.gz') ||
           input.toString().toLowerCase().endsWith('.bcf')
}

// Function to check if input is CSV file
def isCsvFile(input) {
    return input.toString().toLowerCase().endsWith('.csv')
}

// Function to create channel from input parameter
def createInputChannel(input_param) {
    if (isCsvFile(input_param)) {
        // CSV file input
        return Channel
            .fromPath(input_param, checkIfExists: true)
            .splitCsv(header: true)
            .map { row -> [row.sample_id, file(row.vcf_path)] }
    } else if (input_param.contains(',')) {
        // Comma-separated VCF files
        return Channel
            .fromList(input_param.split(','))
            .map { vcf_path ->
                def vcf_file = file(vcf_path.trim())
                def sample_id = vcf_file.baseName.replaceAll(/\.vcf(\.gz)?$/, '')
                [sample_id, vcf_file]
            }
    } else if (input_param.contains('*') || input_param.contains('?')) {
        // Wildcard pattern
        return Channel
            .fromPath(input_param, checkIfExists: true)
            .map { vcf_file ->
                def sample_id = vcf_file.baseName.replaceAll(/\.vcf(\.gz)?$/, '')
                [sample_id, vcf_file]
            }
    } else {
        // Single VCF file
        def vcf_file = file(input_param)
        def sample_id = vcf_file.baseName.replaceAll(/\.vcf(\.gz)?$/, '')
        return Channel.of([sample_id, vcf_file])
    }
}

/*
========================================================================================
    IMPORT MODULES AND WORKFLOWS
========================================================================================
*/

include { LIFTOVER_WORKFLOW } from './workflows/liftover'

/*
========================================================================================
    MAIN WORKFLOW
========================================================================================
*/

workflow {

    log.info """
    =========================================
     chiptimptation-vcf-liftover v${workflow.manifest.version}
    =========================================
    Input           : ${params.input}
    Chain file      : ${params.chain_file}
    Target FASTA    : ${params.target_fasta}
    Source build    : ${params.source_build}
    Target build    : ${params.target_build}
    Chr mapping     : ${params.chr_mapping ?: 'None'}
    Output dir      : ${params.outdir}
    Split by chr    : ${params.split_by_chr}
    Validate output : ${params.validate_output}
    =========================================
    """.stripIndent()
    
    // Input channels are already created above
    
    // Prepare reference files
    chain_file = file(params.chain_file)
    target_fasta = file(params.target_fasta)
    chr_mapping = params.chr_mapping ? file(params.chr_mapping) : []
    
    // Run main liftover workflow
    LIFTOVER_WORKFLOW(
        params.input,
        chain_file,
        target_fasta,
        chr_mapping
    )
}

/*
========================================================================================
    WORKFLOW COMPLETION
========================================================================================
*/

workflow.onComplete {
    log.info """
    =========================================
     Pipeline completed!
    =========================================
    Completed at : ${workflow.complete}
    Duration     : ${workflow.duration}
    Success      : ${workflow.success}
    Work dir     : ${workflow.workDir}
    Exit status  : ${workflow.exitStatus}
    Error report : ${workflow.errorReport ?: 'None'}
    =========================================
    """.stripIndent()
    
    if (workflow.success) {
        log.info "Pipeline completed successfully!"
        log.info "Results are in: ${params.outdir}"
    } else {
        log.error "Pipeline failed!"
        log.error "Check the error report above for details"
    }
}

workflow.onError {
    log.error "Pipeline failed with error: ${workflow.errorMessage}"
}
