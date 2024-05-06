#!/bin/bash

ref_txt="ref.txt"
ref_="results/ref/"
vcf_="results/gatk/"


readarray -t _links < "$ref_txt"

for _link in "${_links[@]}"; do
    base_name=$(basename "$_link")

    if [[ $base_name == *".fna.gz" ]]; then
        out_=$ref_
    elif [[ $base_name == *".vcf" ]]; then
        out_=$vcf_
    fi

    echo wget -P "$out_" "$_link"
done
