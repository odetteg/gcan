
import os
import sys
from pathlib import Path
sys.path.insert(0, Path(workflow.basedir))
from constants.common import *
configfile: 'config/config.yaml'
include: "workflows/rules/download.smk"
include: "workflows/rules/map.smk"
include: "workflows/rules/call.smk"


rule all:
    input:
        expand(
            str(BASE_DIR) + "/results/call/gatk/{sample}.vcf.gz",
            sample=samples,
        ),
