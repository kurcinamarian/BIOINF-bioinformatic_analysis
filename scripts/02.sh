#!/bin/bash
set -e

mkdir -p data/hg38 data/aligned results/2

wget -nc https://hgdownload.gi.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa.gz
gunzip hg38.fa.gz
mv hg38.fa data/hg38/hg38.fa
bwa index data/hg38/hg38.fa

ID=C38BWACXX.C             
SM=Sample_C                               
PL=ILLUMINA                             
LB=C38BWACXX.Sample             
PU=HWI-ST1393:198:C38BWACXX     
CN=FIITSTU                              
DT=2026-01-01T00:00:00          
RG="@RG\tID:$ID\tSM:$SM\tPL:$PL\tLB:$LB\tPU:$PU\tCN:$CN\tDT:$DT"

bwa mem -t 8 -R "$RG" data/hg38/hg38.fa \
    data/paired/P13.C_R1.paired.fastq.gz data/paired/P13.C_R2.paired.fastq.gz | \
    samtools view -hb -o data/aligned/P13_C.bwa.bam
    
samtools sort -o data/aligned/P13_C.bwa.sorted.bam data/aligned/P13_C.bwa.bam
samtools index data/aligned/P13_C.bwa.sorted.bam
rm data/aligned/P13_C.bwa.bam
samtools stats data/aligned/P13_C.bwa.sorted.bam > results/2/P13_C.bwa.stats.txt




ID=C38BWACXX.T             
SM=Sample_T                               
PL=ILLUMINA                             
LB=C38BWACXX.Sample             
PU=HWI-ST1393:198:C38BWACXX     
CN=FIITSTU                              
DT=2026-01-01T00:00:00  
RG="@RG\tID:$ID\tSM:$SM\tPL:$PL\tLB:$LB\tPU:$PU\tCN:$CN\tDT:$DT"

bwa mem -t 8 -R "$RG" data/hg38/hg38.fa \
    data/paired/P13.T_R1.paired.fastq.gz data/paired/P13.T_R2.paired.fastq.gz | \
    samtools view -hb -o data/aligned/P13_T.bwa.bam
    
samtools sort -o data/aligned/P13_T.bwa.sorted.bam data/aligned/P13_T.bwa.bam
samtools index data/aligned/P13_T.bwa.sorted.bam
rm data/aligned/P13_T.bwa.bam
samtools stats data/aligned/P13_T.bwa.sorted.bam > results/2/P13_T.bwa.stats.txt
