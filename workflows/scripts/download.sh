#!/bin/bash
set -x
list_of_accessions="can.txt"

accessions_array=()
out_dir="results/data/"
while IFS= read -r acc_no || [[ -n "$acc_no" ]]; do
accessions_array+=("$acc_no")
done < "$list_of_accessions"

for acc_no in "${accessions_array[@]}"; do
fastq-dump --split-files --gzip "$acc_no" -O "$out_dir"
done

for fq in "$out_dir"*.fastq.gz; do
if [[ "$fq" == "*_1.fastq.gz" && "$fq" != "*_R1.fastq.gz" ]]; then
renamed_r1="${fq/_1.fastq.gz/_R1.fastq.gz}"
mv "$fq" "$renamed_r1"
elif [[ "$fq" == "*_2.fastq.gz" && "$fq" != "*_R2.fastq.gz" ]]; then
renamed_r2="${fq/_2.fastq.gz/_R2.fastq.gz}"
mv "$fq" "$renamed_r2"
fi
done