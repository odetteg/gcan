import os
import sys
from pathlib import Path
BASE_DIR=Path(__file__).resolve().parent.parent
DATA_DIR= os.path.join(BASE_DIR, 'results', 'data')
accessions_txt = "can.txt"

samples=[]

try:
    with open(accessions_txt, 'r') as can:
        for acc_no in can:
            samples.append(acc_no.strip())
except FileNotFoundError:
    print("File not found")