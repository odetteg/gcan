import os
import sys
from pathlib import Path
import yaml
BASE_DIR=Path(__file__).resolve().parent.parent
DATA_DIR= os.path.join(BASE_DIR, 'results', 'data')
REF_DIR= os.path.join(BASE_DIR, 'results','ref')

with open('config/config.yaml', 'r') as yamlfile:
    config = yaml.safe_load(yamlfile)
ref = config.get('ref')
ref_name = ref.split('.')[0]
accessions_txt = "can.txt"

samples=[]

try:
    with open(accessions_txt, 'r') as can:
        for acc_no in can:
            samples.append(acc_no.strip())
except FileNotFoundError:
    print("File not found")
    
def map_cmds(ref, t, samples=samples):
    map_cmds = os.path.join(BASE_DIR, 'temp','map_cmds.txt')
    with open(map_cmds, 'w') as f:
        for sample in samples:
            r1 = os.path.join(DATA_DIR, f'{sample}_R1.fastq.gz')
            r2 = r1.replace('_R1.fastq.gz', '_R2.fastq.gz')
            out_= os.path.join(DATA_DIR, 'aligned', f'{sample}.sam')
            rg=f"RG@\\tID:{sample}\\tSM:{sample}"
            cmd_ = f"bwa mem -t {t} -R \"{rg}\" {ref} {r1} {r2} -o {out_}\n"
            f.write(cmd_)
