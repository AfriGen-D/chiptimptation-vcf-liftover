/*
========================================================================================
    Main Liftover Workflow
========================================================================================
    Orchestrates the complete VCF liftover process
========================================================================================
*/

// Import all required modules
include { INPUT_HANDLER } from '../modules/input_handler'
include { INPUT_CHECK } from '../modules/input_check'
include { CROSSMAP_VCF } from '../modules/crossmap'
include { SORT_VCF } from '../modules/sort_vcf'
include { RENAME_CHROMOSOMES } from '../modules/rename_chromosomes'
include { FIX_CONTIG_HEADER } from '../modules/fix_contig'
include { INDEX_VCF } from '../modules/index_vcf'
include { VALIDATE_VCF } from '../modules/validate_vcf'
include { LIFTOVER_STATS } from '../modules/liftover_stats'

workflow LIFTOVER_WORKFLOW {
    take:
    input_param   // String: input parameter (VCF file(s) or CSV)
    chain_file    // Path: chain file
    target_fasta  // Path: target reference
    chr_mapping   // Path: chromosome mapping (optional)

    main:
    // Process input to get standardized CSV
    script_file = file("${projectDir}/bin/process_input.py")
    INPUT_HANDLER(input_param, script_file)

    // Parse CSV to get VCF files
    validated_csv = INPUT_CHECK(INPUT_HANDLER.out.csv)

    log.info """
    ========================================
     Starting Liftover Workflow
    ========================================
    Chain file: ${chain_file}
    Target FASTA: ${target_fasta}
    Chr mapping: ${chr_mapping ?: 'None'}
    ========================================
    """.stripIndent()

    // Convert CSV to channel of tuples
    vcf_files = validated_csv
        .splitCsv(header: true)
        .map { row -> [row.sample_id, file(row.vcf_path)] }

    // Combine inputs for CrossMap
    crossmap_input = vcf_files.map { sample_id, vcf ->
        [sample_id, vcf, chain_file, target_fasta]
    }

    // Step 1: Run CrossMap liftover
    log.info "Step 1: Running CrossMap liftover..."
    CROSSMAP_VCF(crossmap_input)

    // Step 2: Sort VCF files
    log.info "Step 2: Sorting VCF files..."
    SORT_VCF(CROSSMAP_VCF.out.vcf)

    // Step 3: Rename chromosomes if mapping provided
    if (chr_mapping && !chr_mapping.isEmpty()) {
        log.info "Step 3: Renaming chromosomes..."
        RENAME_CHROMOSOMES(SORT_VCF.out.vcf, chr_mapping)
        sorted_vcf = RENAME_CHROMOSOMES.out.vcf
    } else {
        log.info "Step 3: Skipping chromosome renaming (no mapping file provided)"
        sorted_vcf = SORT_VCF.out.vcf
    }

    // Step 4: Fix contig headers
    log.info "Step 4: Fixing contig headers..."
    FIX_CONTIG_HEADER(sorted_vcf, target_fasta)

    // Step 5: Index final VCF files
    log.info "Step 5: Indexing VCF files..."
    INDEX_VCF(FIX_CONTIG_HEADER.out.vcf)

    // Step 6: Validate output if requested
    if (params.validate_output) {
        log.info "Step 6: Validating output VCF files..."
        VALIDATE_VCF(INDEX_VCF.out.vcf_with_index)
        validation_reports = VALIDATE_VCF.out.report
    } else {
        log.info "Step 6: Skipping validation (validate_output = false)"
        validation_reports = Channel.empty()
    }

    // Step 7: Generate comprehensive statistics
    log.info "Step 7: Generating liftover statistics..."
    LIFTOVER_STATS(
        CROSSMAP_VCF.out.log.collect(),
        INDEX_VCF.out.vcf_with_index.map { _sample_id, vcf, _index -> vcf }.collect()
    )

    emit:
    // Final outputs
    vcf = INDEX_VCF.out.vcf_with_index
    stats = LIFTOVER_STATS.out.report
    logs = CROSSMAP_VCF.out.log
    unmap = CROSSMAP_VCF.out.unmap
    validation = validation_reports
    summary_csv = LIFTOVER_STATS.out.csv
    summary_stats = LIFTOVER_STATS.out.stats
}
