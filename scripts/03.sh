#!/bin/bash
set -e
export PATH=$PATH:/home/marian/gatk-4.4.0.0

mkdir -p results/3/T results/3/C data/clean data/dbsnp

samtools sort -n -o data/aligned/P13_T.namesort.bam data/aligned/P13_T.bwa.sorted.bam
samtools fixmate -m data/aligned/P13_T.namesort.bam data/aligned/P13_T.fixmate.bam
rm data/aligned/P13_T.namesort.bam
samtools sort -o data/aligned/P13_T.fixsort.bam data/aligned/P13_T.fixmate.bam
rm data/aligned/P13_T.fixmate.bam
samtools markdup -s data/aligned/P13_T.fixsort.bam data/aligned/P13_T.bwa.dedup.bam 2> results/3/T.dup.txt
rm data/aligned/P13_T.fixsort.bam
samtools index data/aligned/P13_T.bwa.dedup.bam

samtools sort -n -o data/aligned/P13_C.namesort.bam data/aligned/P13_C.bwa.sorted.bam
samtools fixmate -m data/aligned/P13_C.namesort.bam data/aligned/P13_C.fixmate.bam
rm data/aligned/P13_C.namesort.bam
samtools sort -o data/aligned/P13_C.fixsort.bam data/aligned/P13_C.fixmate.bam
rm data/aligned/P13_C.fixmate.bam
samtools markdup -s data/aligned/P13_C.fixsort.bam data/aligned/P13_C.bwa.dedup.bam 2> results/3/C.dup.txt
rm data/aligned/P13_C.fixsort.bam

samtools index data/aligned/P13_C.bwa.dedup.bam

qualimap bamqc -bam data/aligned/P13_T.bwa.dedup.bam -outdir results/3/T --java-mem-size=8G
qualimap bamqc -bam data/aligned/P13_C.bwa.dedup.bam -outdir results/3/C --java-mem-size=8G

samtools stats data/aligned/P13_T.bwa.dedup.bam > results/3/T.stats.txt
samtools stats data/aligned/P13_C.bwa.dedup.bam > results/3/C.stats.txt

wget -nc https://ftp.ncbi.nih.gov/snp/organisms/human_9606/VCF/common_all_20180418.vcf.gz
wget -nc https://ftp.ncbi.nih.gov/snp/organisms/human_9606/VCF/common_all_20180418.vcf.gz.tbi

mv *vcf.gz* data/dbsnp/

cat <<EOF > chr_map.txt
1	chr1
2	chr2
3	chr3
4	chr4
5	chr5
6	chr6
7	chr7
8	chr8
9	chr9
10	chr10
11	chr11
12	chr12
13	chr13
14	chr14
15	chr15
16	chr16
17	chr17
18	chr18
19	chr19
20	chr20
21	chr21
22	chr22
X	chrX
Y	chrY
MT	chrM
EOF

bcftools annotate --rename-chrs chr_map.txt \
    -O z -o data/dbsnp/dbsnp.chr.vcf.gz data/dbsnp/common_all_20180418.vcf.gz

bcftools index -t data/dbsnp/dbsnp.chr.vcf.gz 
rm chr_map.txt

samtools faidx data/hg38/hg38.fa
gatk CreateSequenceDictionary -R data/hg38/hg38.fa

gatk BaseRecalibrator \
-R data/hg38/hg38.fa \
-I data/aligned/P13_T.bwa.dedup.bam \
--known-sites data/dbsnp/dbsnp.chr.vcf.gz \
-O data/aligned/P13_T.recal_data.recalib

gatk ApplyBQSR \
-R data/hg38/hg38.fa \
-I data/aligned/P13_T.bwa.dedup.bam \
--bqsr-recal-file data/aligned/P13_T.recal_data.recalib \
-O data/clean/P13_T.bwa.cleaned.bam

rm data/aligned/P13_T.recal_data.recalib
samtools index data/clean/P13_T.bwa.cleaned.bam

gatk BaseRecalibrator \
-R data/hg38/hg38.fa \
-I data/aligned/P13_C.bwa.dedup.bam \
--known-sites data/dbsnp/dbsnp.chr.vcf.gz \
-O data/aligned/P13_C.recal_data.recalib

gatk ApplyBQSR \
-R data/hg38/hg38.fa \
-I data/aligned/P13_C.bwa.dedup.bam \
--bqsr-recal-file data/aligned/P13_C.recal_data.recalib \
-O data/clean/P13_C.bwa.cleaned.bam

rm data/aligned/P13_C.recal_data.recalib
samtools index data/clean/P13_C.bwa.cleaned.bam

gatk CollectAlignmentSummaryMetrics -R data/hg38/hg38.fa -I data/clean/P13_C.bwa.cleaned.bam -O results/3/P13_C.cleaned.alignment_metrics.txt

gatk CollectAlignmentSummaryMetrics -R data/hg38/hg38.fa -I data/clean/P13_T.bwa.cleaned.bam -O results/3/P13_T.cleaned.alignment_metrics.txt

