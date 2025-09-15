/*
========================================================================================
    Liftover Statistics Process
========================================================================================
    Generates comprehensive statistics and reports for the liftover process
========================================================================================
*/

process LIFTOVER_STATS {
    tag "liftover_statistics"
    label 'python'

    publishDir "${params.outdir}/reports", mode: 'copy'

    input:
    path crossmap_logs
    path final_vcfs

    output:
    path "liftover_summary_report.html", emit: report
    path "liftover_statistics.txt", emit: stats
    path "sample_summary.csv", emit: csv

    script:
    """
    #!/usr/bin/env python3
    
    import os
    import re
    import csv
    import json
    import subprocess
    from datetime import datetime
    from pathlib import Path
    
    def parse_crossmap_log(log_file):
        \"\"\"Parse CrossMap log file for statistics\"\"\"
        stats = {
            'sample_id': '',
            'input_variants': 0,
            'output_variants': 0,
            'unmapped_variants': 0,
            'success_rate': 0.0,
            'errors': []
        }
        
        try:
            with open(log_file, 'r') as f:
                content = f.read()
                
            # Extract sample ID from filename
            stats['sample_id'] = Path(log_file).stem.replace('.crossmap', '')
            
            # Look for variant counts in log
            input_match = re.search(r'Total entries:\\s*(\\d+)', content)
            if input_match:
                stats['input_variants'] = int(input_match.group(1))

            # Look for failed liftover count (CrossMap format: "Failed to map: 47")
            failed_match = re.search(r'Failed to map:\\s*(\\d+)', content)
            if failed_match:
                stats['unmapped_variants'] = int(failed_match.group(1))

            # Calculate successful liftover count
            if stats['input_variants'] > 0 and stats['unmapped_variants'] >= 0:
                stats['output_variants'] = stats['input_variants'] - stats['unmapped_variants']

            # Calculate success rate
            if stats['input_variants'] > 0:
                stats['success_rate'] = (stats['output_variants'] / stats['input_variants']) * 100
            
            # Look for errors
            error_patterns = [
                r'ERROR:.*',
                r'WARNING:.*',
                r'Failed.*'
            ]
            
            for pattern in error_patterns:
                errors = re.findall(pattern, content, re.IGNORECASE)
                stats['errors'].extend(errors)
                
        except Exception as e:
            stats['errors'].append(f"Error parsing log file: {e}")
            
        return stats
    
    def count_vcf_variants(vcf_file):
        \"\"\"Count variants in VCF file using bcftools\"\"\"
        try:
            cmd = f"bcftools view -H {vcf_file} | wc -l"
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            if result.returncode == 0:
                return int(result.stdout.strip())
        except:
            pass
        return 0
    
    def get_file_size(file_path):
        \"\"\"Get file size in MB\"\"\"
        try:
            size_bytes = os.path.getsize(file_path)
            return round(size_bytes / (1024 * 1024), 2)
        except:
            return 0
    
    def generate_html_report(all_stats, summary_stats):
        \"\"\"Generate HTML report\"\"\"
        
        html_template = '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>chiptimptation-vcf-liftover Summary Report</title>
        <style>
            body {{ font-family: Arial, sans-serif; margin: 40px; }}
            .header {{ background-color: #f0f0f0; padding: 20px; border-radius: 5px; }}
            .summary {{ background-color: #e8f4fd; padding: 15px; margin: 20px 0; border-radius: 5px; }}
            .stats-table {{ border-collapse: collapse; width: 100%; margin: 20px 0; }}
            .stats-table th, .stats-table td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
            .stats-table th {{ background-color: #f2f2f2; }}
            .success {{ color: green; font-weight: bold; }}
            .warning {{ color: orange; font-weight: bold; }}
            .error {{ color: red; font-weight: bold; }}
            .metric {{ display: inline-block; margin: 10px 20px; }}
            .metric-value {{ font-size: 24px; font-weight: bold; color: #2c3e50; }}
            .metric-label {{ font-size: 14px; color: #7f8c8d; }}
        </style>
    </head>
    <body>
        <div class="header">
            <h1>chiptimptation-vcf-liftover Summary Report</h1>
            <p><strong>Generated:</strong> {timestamp}</p>
            <p><strong>Source Build:</strong> {source_build}</p>
            <p><strong>Target Build:</strong> {target_build}</p>
        </div>
        
        <div class="summary">
            <h2>Overall Summary</h2>
            <div class="metric">
                <div class="metric-value">{total_samples}</div>
                <div class="metric-label">Total Samples</div>
            </div>
            <div class="metric">
                <div class="metric-value">{total_input_variants:,}</div>
                <div class="metric-label">Input Variants</div>
            </div>
            <div class="metric">
                <div class="metric-value">{total_output_variants:,}</div>
                <div class="metric-label">Output Variants</div>
            </div>
            <div class="metric">
                <div class="metric-value">{avg_success_rate:.1f}%</div>
                <div class="metric-label">Average Success Rate</div>
            </div>
        </div>
        
        <h2>Sample Details</h2>
        <table class="stats-table">
            <thead>
                <tr>
                    <th>Sample ID</th>
                    <th>Input Variants</th>
                    <th>Output Variants</th>
                    <th>Unmapped</th>
                    <th>Success Rate</th>
                    <th>File Size (MB)</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                {sample_rows}
            </tbody>
        </table>
        
        <h2>Pipeline Parameters</h2>
        <table class="stats-table">
            <tr><td><strong>Source Build</strong></td><td>{source_build}</td></tr>
            <tr><td><strong>Target Build</strong></td><td>{target_build}</td></tr>
            <tr><td><strong>Chain File</strong></td><td>{chain_file}</td></tr>
            <tr><td><strong>Target FASTA</strong></td><td>{target_fasta}</td></tr>
            <tr><td><strong>Chromosome Mapping</strong></td><td>{chr_mapping}</td></tr>
            <tr><td><strong>Output Directory</strong></td><td>{outdir}</td></tr>
        </table>
        
    </body>
    </html>
        '''
        
        # Generate sample rows
        sample_rows = ""
        for stats in all_stats:
            status_class = "success" if stats['success_rate'] > 90 else "warning" if stats['success_rate'] > 70 else "error"
            status_text = "Good" if stats['success_rate'] > 90 else "Warning" if stats['success_rate'] > 70 else "Poor"
            
            sample_rows += f'''
                <tr>
                    <td>{stats['sample_id']}</td>
                    <td>{stats['input_variants']:,}</td>
                    <td>{stats['output_variants']:,}</td>
                    <td>{stats['unmapped_variants']:,}</td>
                    <td class="{status_class}">{stats['success_rate']:.1f}%</td>
                    <td>{stats.get('file_size_mb', 'N/A')}</td>
                    <td class="{status_class}">{status_text}</td>
                </tr>
            '''
        
        # Fill template
        html_content = html_template.format(
            timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            source_build="${params.source_build}",
            target_build="${params.target_build}",
            total_samples=summary_stats['total_samples'],
            total_input_variants=summary_stats['total_input_variants'],
            total_output_variants=summary_stats['total_output_variants'],
            avg_success_rate=summary_stats['avg_success_rate'],
            sample_rows=sample_rows,
            chain_file="${params.chain_file}",
            target_fasta="${params.target_fasta}",
            chr_mapping="${params.chr_mapping}" if "${params.chr_mapping}" else "None",
            outdir="${params.outdir}"
        )
        
        with open('liftover_summary_report.html', 'w') as f:
            f.write(html_content)
    
    # Main processing
    print("Generating liftover statistics...")
    
    # Parse all CrossMap logs
    all_stats = []
    log_files = [f for f in os.listdir('.') if f.endswith('.crossmap.log')]
    
    for log_file in log_files:
        print(f"Processing log file: {log_file}")
        stats = parse_crossmap_log(log_file)
        
        # Try to get final VCF file size
        sample_id = stats['sample_id']
        vcf_pattern = f"{sample_id}.${params.target_build}.vcf.gz"
        vcf_files = [f for f in os.listdir('.') if f == vcf_pattern]
        
        if vcf_files:
            vcf_file = vcf_files[0]
            stats['file_size_mb'] = get_file_size(vcf_file)
            # Double-check variant count from final VCF
            final_count = count_vcf_variants(vcf_file)
            if final_count > 0:
                stats['output_variants'] = final_count
                if stats['input_variants'] > 0:
                    stats['success_rate'] = (stats['output_variants'] / stats['input_variants']) * 100
        
        all_stats.append(stats)
    
    # Calculate summary statistics
    summary_stats = {
        'total_samples': len(all_stats),
        'total_input_variants': sum(s['input_variants'] for s in all_stats),
        'total_output_variants': sum(s['output_variants'] for s in all_stats),
        'total_unmapped_variants': sum(s['unmapped_variants'] for s in all_stats),
        'avg_success_rate': sum(s['success_rate'] for s in all_stats) / len(all_stats) if all_stats else 0
    }
    
    # Generate reports
    generate_html_report(all_stats, summary_stats)
    
    # Generate text statistics
    with open('liftover_statistics.txt', 'w') as f:
        f.write("chiptimptation-vcf-liftover Statistics\\n")
        f.write("=" * 50 + "\\n")
        f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\\n")
        f.write(f"Source Build: ${params.source_build}\\n")
        f.write(f"Target Build: ${params.target_build}\\n\\n")
        
        f.write("Summary Statistics:\\n")
        f.write(f"  Total Samples: {summary_stats['total_samples']}\\n")
        f.write(f"  Total Input Variants: {summary_stats['total_input_variants']:,}\\n")
        f.write(f"  Total Output Variants: {summary_stats['total_output_variants']:,}\\n")
        f.write(f"  Total Unmapped Variants: {summary_stats['total_unmapped_variants']:,}\\n")
        f.write(f"  Average Success Rate: {summary_stats['avg_success_rate']:.2f}%\\n\\n")
        
        f.write("Per-Sample Statistics:\\n")
        for stats in all_stats:
            f.write(f"  {stats['sample_id']}:\\n")
            f.write(f"    Input Variants: {stats['input_variants']:,}\\n")
            f.write(f"    Output Variants: {stats['output_variants']:,}\\n")
            f.write(f"    Success Rate: {stats['success_rate']:.2f}%\\n")
            if stats['errors']:
                f.write(f"    Errors: {len(stats['errors'])}\\n")
            f.write("\\n")
    
    # Generate CSV summary
    with open('sample_summary.csv', 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['sample_id', 'input_variants', 'output_variants', 'unmapped_variants', 
                        'success_rate', 'file_size_mb', 'errors'])
        
        for stats in all_stats:
            writer.writerow([
                stats['sample_id'],
                stats['input_variants'],
                stats['output_variants'],
                stats['unmapped_variants'],
                f"{stats['success_rate']:.2f}",
                stats.get('file_size_mb', ''),
                len(stats['errors'])
            ])
    
    print(f"Statistics generated for {len(all_stats)} samples")
    print(f"Overall success rate: {summary_stats['avg_success_rate']:.2f}%")
    """
}
