import os
import sys
from pathlib import Path
sys.path.insert(0, Path(workflow.basedir).parent.parent.as_posix())
from constants.common import *
rule download:
    input:
        download_script = str(BASE_DIR) + "/workflows/scripts/download.sh"
    output:
        data = expand(str(DATA_DIR) + "/{sample}_{ext}.fastq.gz", sample=samples, ext=["R1", "R2"]),
        out_dir = DATA_DIR
    params:
        dump_params = ""
    shell:
        """
        mkdir -p {output.out_dir}
        bash {input.download_script} {params.dump_params}
        """