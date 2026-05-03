#!/bin/bash
set -e

mkdir -p results/1/fastqc_reports
mkdir -p data/paired

seqkit stats data/raw/P13.C_R1.fastq.gz
seqkit stats data/raw/P13.C_R2.fastq.gz
seqkit stats data/raw/P13.T_R1.fastq.gz
seqkit stats data/raw/P13.T_R2.fastq.gz

fastqc data/raw/P13.T_R1.fastq.gz data/raw/P13.T_R2.fastq.gz \
       data/raw/P13.C_R1.fastq.gz data/raw/P13.C_R2.fastq.gz \
       -o results/1/fastqc_reports
       
seqkit pair \
-1 data/raw/P13.T_R1.fastq.gz \
-2 data/raw/P13.T_R2.fastq.gz \

mv *.paired.fastq.gz data/paired/

seqkit pair \
-1 data/raw/P13.C_R1.fastq.gz \
-2 data/raw/P13.C_R2.fastq.gz \

mv *.paired.fastq.gz data/paired/
