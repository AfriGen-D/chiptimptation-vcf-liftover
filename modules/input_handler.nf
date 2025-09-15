/*
========================================================================================
    Input Handler Process
========================================================================================
    Handles multiple input types: single VCF, multiple VCFs, or CSV file
    Uses external Python script for processing
========================================================================================
*/

process INPUT_HANDLER {
    tag "input_processing"
    label 'python'

    input:
    val input_param
    path script_file

    output:
    path "processed_samples.csv", emit: csv

    script:
    """
    python3 ${script_file} "${input_param}" -o processed_samples.csv
    """
}
