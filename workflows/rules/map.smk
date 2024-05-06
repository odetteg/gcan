import os
import sys
from pathlib import Path
sys.path.insert(0, Path(workflow.basedir).parent.parent.as_posix())
from constants.common import *
configfile: "config/config.yaml"

rule get_ref_and_known_sites:
    input:
        ref_script = os.path.join(BASE_DIR, 'workflows/scripts/get_ref_and_vcf.sh')
    output:
        ref= os.path.join(BASE_DIR, 'results', 'ref', config["ref"]),
        vcf_known= os.path.join(BASE_DIR, 'results', 'gatk', config["known_sites"])
    shell:
        """
        {input.ref_script}
        """
rule get_bwa_cmds:
    input:
        ref= os.path.join(BASE_DIR, 'results', 'ref', config["ref"])
    output:
        bwa_cmds = temp(os.path.join(BASE_DIR, 'temp', 'map_cmds.txt'))
    params:
        ref= os.path.join(BASE_DIR, 'results', 'ref', config["ref"])
    threads: 8
    run:
        map_cmds(ref=params.ref, t=threads)

rule index_ref:
    input:
        ref = os.path.join(BASE_DIR, 'results','ref', config["ref"])
    output:
        expand(
            REF_DIR + "/{ref}.fasta.{ext}",
            ref=ref_name,
            ext=["amb", "ann", "bwt", "pac", "sa"],
        ),
    shell:
        "bwa index {input}"


rule bwa_map:
    input:
        bwa_cmds = os.path.join(BASE_DIR, 'temp', 'map_cmds.txt'),
        ref = os.path.join(BASE_DIR, 'results','ref', config["ref"]),
        indices=expand(
            REF_DIR + "/{ref}.fasta.{ext}",
            ref=ref_name,
            ext=["amb", "ann", "bwt", "pac", "sa"],
        ),
        data = expand(str(DATA_DIR) + "/{sample}_{ext}.fastq.gz", sample=samples, ext=["R1", "R2"]),
    output:
        sam_file=expand(
            str(BASE_DIR) + "/results/aligned/{sample}.sam", sample=samples
        ),
        bam_output=expand(
            str(BASE_DIR) + "/results/aligned/{sample}.bam", sample=samples
        ),
        sorted_bam_out_=expand(
            str(BASE_DIR) + "/results/aligned/{sample}.bwa_sorted.bam",
            sample=samples,
        ),
        bai=expand(
            str(BASE_DIR) + "/results/aligned/{sample}.bwa_sorted.bam.bai",
            sample=samples,
        ),
    params:
        extra_args = config['params']['bwa']["extra_args"]
    log:
        "logs/bwa_map.log"
    shell:
        """
        while read -r cmd;do
        $cmd {params.extra_args} &>> {log}
        done < {input.bwa_cmds}
        for sam_ in {output.sam_file}; do
        bam_="${{sam_%.sam}}.bam"
        samtools view -Sb $sam_ -o $bam_
        done
        for bam_ in {output.bam_output}; do
        bam_out="${{bam_%.bam}}_bwa_sorted.bam"
        samtools sort $bam_ -o $bam_out && samtools index $bam_out
        done
        """
