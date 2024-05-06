rule gatk_preprocessing:
    input:
        bam_output=expand(
            str(BASE_DIR) + "/results/aligned/{sample}.bam", sample=samples
        ),
        ref = os.path.join(BASE_DIR, 'results','ref', config["ref"]),
        known_sites = os.path.join(BASE_DIR, 'results', 'gatk', config['known_sites']),
    output:
        sorted_bam_out_=expand(
            str(BASE_DIR) + "/results/aligned/{sample}.gatk_sorted.bam",
            sample=samples,
        ),
        duplicates_=expand(
            str(BASE_DIR) + "/results/aligned/{sample}.dedupped.bam",
            sample=samples,
        ),
        recal_tables=expand(
            str(BASE_DIR) + "/results/aligned/{sample}.recall_data.table",
            sample=samples,
        ),
        recal_bams=expand(
            str(BASE_DIR) + "/results/aligned/{sample}.recal.bam",
            sample=samples,
        ),
    shell:
        """
        for bam_ in {input.bam_output}; do
        sorted_out="${{bam_%bam}}.gatk_sorted.bam"
        gatk SortSam -I $bam_ -O $sorted_out --CREATE_INDEX True
        done

        for bam_out in {output.sorted_bam_out_}; do
        duplicate_="${{bam_out%.sorted.bam}}.dedupped.bam"
        gatk MarkDuplicates -I $bam_out -O $duplicate_
        done

        for dupped in {output.duplicates_}; do
        out_table="${{dupped%.dedupped.bam}}.recall_data.table"
        gatk BaseRecalibrator -R {input.ref} -I $dupped --known-sites {input.known_sites} -O $out_table
        done

        for dupped in {output.duplicates_}; do
        out_table= ${{dupped%.dedupped.bam}}.recall_data.table
        racal_out="${{dupped%.dedupped.bam}}.recal.ba"
        gatk ApplyBQSR -R {input.ref} -I $dupped --bqsr-recal-file $out_table -O racal_out
        done
        
        """
rule gatk_call:
    input:
        ref = os.path.join(BASE_DIR, 'results','ref', config["ref"]),
        sorted_bam_out_=expand(
            str(BASE_DIR) + "/results/aligned/{sample}.gatk_sorted.bam",
            sample=samples,
        ),
        duplicates_=expand(
            str(BASE_DIR) + "/results/aligned/{sample}.dedupped.bam",
            sample=samples,
        ),
        recal_tables=expand(
            str(BASE_DIR) + "/results/aligned/{sample}.recall_data.table",
            sample=samples,
        ),
        recal_bams=expand(
            str(BASE_DIR) + "/results/aligned/{sample}.recal.bam",
            sample=samples,
        ),
    output:
        vcfs_=expand(
            str(BASE_DIR) + "/results/call/gatk/{sample}.vcf.gz",
            sample=samples,
        ),
    shell:
        """
        for bam_ in {input.recal_bams}; do
        vc_ = "${{bam_in%.recal.bam}}.vcf.gz"
        vc_out="results/call/gatk/$(basename $vc_)"
        gatk HaplotypeCaller -R {input.ref} -I $bam_in -O $vc_out -ERC GVCF
        done
        """
# rule filtering:
#     input:
#     output:
#     shell:
#     """
#     """
# rule annotation:
#     input:
#     output:
#     shell:
#     """
#     """
