#!/bin/bash

seqkit stats data/raw/P13.C_R1.fastq.gz
seqkit stats data/raw/P13.C_R2.fastq.gz
seqkit stats data/raw/P13.T_R1.fastq.gz
seqkit stats data/raw/P13.T_R2.fastq.gz
mkdir -p results/1/fastqc_reports
fastqc data/raw/P13.T_R1.fastq.gz data/raw/P13.T_R2.fastq.gz \
       data/raw/P13.C_R1.fastq.gz data/raw/P13.C_R2.fastq.gz \
       -o results/1/fastqc_reports
seqkit pair -1 data/raw/P13.T_R1.fastq.gz -2 data/raw/P13.T_R2.fastq.gz -o data/paired